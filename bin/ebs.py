#!/usr/bin/env python
#-*- coding:utf-8 -*-

# ebs -- Evidence Based Scheduling
# ver. 2010.11.20-17:24
# autor: http://jedral.one.pl/2010/11/na-80-w-piatek.html

# http://matplotlib.sourceforge.net/users/navigation_toolbar.html

import random, sys,os
import gobject, gtk

import matplotlib
matplotlib.use('GTKAgg')
from matplotlib import use, pyplot, cm, colors
from pylab import get_current_fig_manager

class Cli(object):
	def __init__ (self):
		self.basename = sys.argv[0].split('/')[-1]
		if len(sys.argv) != 3:
			self.usage(1)
		else:
			self.project = sys.argv[1]
			self.estimator = sys.argv[2]

		if os.path.isfile(self.project) and os.path.isfile(self.estimator):
			pass
		else:
			sys.stderr.write('This script nead "project.dat" & "estimator.dat" files to work\n')
			self.usage(1)

	def usage(self,status=None):
		print ' -- Evidence Based Scheduling -- '
		print 'Usage:'
		print '\t', self.basename, ' project.dat estimator.dat'
		sys.exit(status)

class MonteCarlo(object):
	u = int # średnia bez Monte Carlo

	def __init__ (self,project,estimator):

		with open(project,'r') as file:
			self.P = [ float(line.split('#')[0]) for line in file ]

		with open(estimator,'r') as file:
			E = [ line.split('#')[0] for line in file ]
			self.E = [ float(h.split('/')[0]) / float(h.split('/')[1]) for h in E ]

		self.u = sum(self.P)*(sum(self.E)*1.0)/len(self.E)

	probe = lambda self: round( sum([ i*random.choice(self.E) for i in self.P ]) , 2 )
	probes = lambda self,n: [ self.probe() for i in range(n) ]

class PlotEBS(object):
	def __init__ (self,mc):
		self.count = 50
		self.scale = 3
		self.mc = mc
		self.u = mc.u
		self.H = []
		self.pause = False
		self.help = 1
		self.arrow = True
		self.usage=['h - show/hide help',
					'a - narrow bars',
					'z - extend bars',
					'x - narrow x ticks',
					'c - extend x ticks',
					'e - show arrow',
					'q - pause',
					'esc - exit']

		self.figure = pyplot.figure()
		self.ax = self.figure.add_subplot(111) # (211)

		self.histogram()
		self.manager = get_current_fig_manager()

		def update(*args):
			self.ax.clear()
			self.histogram()
			self.manager.canvas.draw()
			if self.pause:
				return False
			return True

		def key_press(event):
			print 'press', event.key
			if event.key=='a': self.count /=0.9
			if event.key=='z': self.count /=1.1
			if event.key=='c': self.scale +=1
			if event.key=='x' and self.scale !=1: self.scale -=1
			if event.key=='e': self.arrow = not self.arrow
			if event.key=='h':
				if self.help == 2:
						self.help = 0
				else:
					self.help += 1
			if event.key=='q':
				if self.pause:
					self.pause = False
					gobject.idle_add(update)
				else:
					self.pause = True
			if event.key=='escape': gtk.main_quit()

		self.figure.canvas.mpl_connect('key_press_event', key_press)

		gobject.idle_add(update)
		pyplot.show()

	def histogram(self):
		self.ax.set_title('Histogram of Evidence Based Scheduling [ %d ]' % len(self.H))
		self.ax.set_xlabel('Time (h)',fontstyle='italic')
		self.ax.set_ylabel('Probability (%)',fontstyle='italic')
		self.ax.set_ylim(0,110)
		self.ax.grid(True)

		self.ax.axvline(self.u, color='#90EE90', linestyle='dashed', lw=2)

		self.H += self.mc.probes(1000)
		n, bins, patches = self.ax.hist(self.H, bins=self.count , edgecolor='white', alpha=0.75)
		nmax=n.max() # najwyższy słupek

		# zmienna skala osi Y
		self.ax.set_xticks([ round(i,2) for i in bins[::self.scale] ])
		# self.ax.set_xticklabels(('a','b')) # tak można dodać label zamiast wartości
		self.figure.autofmt_xdate() # pochyłe literki

		# strzałka
		if self.arrow:
			pyplot.annotate('simple estimation', xy=(self.u, 90), xytext=(min(bins), 100),
				arrowprops=dict(facecolor='blue', shrink=0.005))

		if self.help == 1 :
			pyplot.annotate('help (h)',
				xy=(max(bins), 90),
				xytext=((self.u+max(bins))/2, 90),
				ha='left')
		elif self.help == 2 :
			pyplot.annotate('\n'.join(self.usage),
				xy=(max(bins), 90),
				xytext=((self.u+max(bins))/2, 60),
				ha='left')

		# normalizacja
		for p in patches:
			p.set_height((p.get_height() * 100.0 ) / nmax )

		# tęcza
		fracs = n.astype(float)/nmax
		norm = colors.normalize(fracs.min(), fracs.max())

		for f, p in zip(fracs, patches):
			color = cm.jet(norm(f))
			p.set_facecolor(color)

if __name__ == '__main__':
	cli = Cli()
	mc = MonteCarlo(cli.project,cli.estimator)
	PlotEBS(mc)
