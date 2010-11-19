#!/usr/bin/env python
#-*- coding:utf-8 -*-

# ebs -- Evidence Based Scheduling

import random, sys,os

import time

import gobject
import gtk

import matplotlib
matplotlib.use('GTKAgg')
from matplotlib import pyplot, cm, colors
from pylab import get_current_fig_manager as get_current_fig_manager

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

	probe = lambda self: round( sum([ i*random.sample(self.E,1)[0] for i in self.P ]) , 2 )
	probes = lambda self,n: [ self.probe() for i in range(n) ]

class PlotEBS(object):
	def __init__ (self,mc):
		self.count = 50
		self.mc = mc
		self.u = mc.u
		self.H = mc.probes(1000)

		self.figure = pyplot.figure()
		self.ax = self.figure.add_subplot(111)

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
			if event.key=='q':
				if self.pause:
					self.pause = False
					gobject.idle_add(update)
				else:
					self.pause = True
			if event.key=='escape': gtk.main_quit()

		self.pause = False
		self.figure.canvas.mpl_connect('key_press_event', key_press)

		gobject.idle_add(update)
		pyplot.show()

	def histogram(self):
		self.H += self.mc.probes(1000)
		self.ax.set_title('Histogram of Evidence Based Scheduling [ %s ]'%str(len(self.H)))
		self.ax.set_xlabel('Time (h)')
		self.ax.set_ylabel('Probability (%)')
		self.ax.set_ylim(0,110)

		#@TODO nie mogę ustawić skali osi Y
		# a, b = 2, 9 # integral area
		# ax.set_xticks((a,b))
		# ax.set_xticklabels(('a','b'))

		self.ax.grid(True)
		#@TODO label na średniej się nie pojawia
		self.ax.axvline(self.u, color='#90EE90', linestyle='dashed', label=" simple estimation ", lw=2)


		n, bins, patches = self.ax.hist(self.H, bins=self.count , edgecolor='white', alpha=0.75)
		nmax=n.max() # najwyższy słupek

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
	#~ mc = MonteCarlo('/home/lucas/p.dat','/home/lucas/n.dat')
	PlotEBS(mc)
