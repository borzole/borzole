#!/usr/bin/env python
# coding=utf-8

"""    pwn2dict 2.1 - converts PWN dictionaries to StarDict and tabfile formats
	http://my.opera.com/mziab/blog/2010/02/11/pwn2dict-2-0
    Copyright (C) 2008-2010  Michał "mziab" Ziąbkowski

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>."""

from __future__ import unicode_literals

import sys
import zlib
import codecs
import struct
import re
import os

from optparse import OptionParser
from contextlib import nested

try:
	import psyco
	psyco.full()
except ImportError:
	pass

def cmp_to_key(mycmp):
	class K(object):
		def __init__(self, obj, *args):
			self.obj = obj
		def __lt__(self, other):
			return mycmp(self.obj, other.obj) < 0
		def __gt__(self, other):
			return mycmp(self.obj, other.obj) > 0
		def __eq__(self, other):
			return mycmp(self.obj, other.obj) == 0
		def __le__(self, other):
			return mycmp(self.obj, other.obj) <= 0
		def __ge__(self, other):
			return mycmp(self.obj, other.obj) >= 0
		def __ne__(self, other):
			return mycmp(self.obj, other.obj) != 0
	return K

# attempts to emulate the sort routine from stardict
def stardict_strcmp(x, y):
	pos = 0
	string_x = x[0]
	string_y = y[0]
	while (pos < len(string_x) and pos < len(string_y)):
		c1 = ord(string_x[pos].lower())
		c2 = ord(string_y[pos].lower())

		if c1 != c2:
			return c1-c2

		pos += 1

	if pos < len(string_x):
		c1 = ord(string_x[pos])
	else:
		c1 = 0

	if pos < len(string_y):
		c2 = ord(string_y[pos])
	else:
		c2 = 0

	# special case: identical word, differing only in case
	# StarDict wants the ones with capital letters first
	if c1-c2 == 0:
		return ord(string_x[0])-ord(string_y[0])

	return c1-c2


class PwnDict:
	# color table
	__colors = ["#736324", "#0000E0", "#E00000"]

	# defines what gets changed to what
	__replacements = [("&amp;", "&"),
			("&rsquo;", "'"),
			("&agrave;", "\u00E0"),
			("&ccedil;", "\u00E7"),
			("&egrave;", "\u00E8"),
			("&eacute;", "\u00E9"),
			("&ecirc;", "\u00EA"),
			("&reg;", "\u00AE"),
			("<IMG SRC=\"ipa503.JPG\">", "\u02D0"),
			("&IPA502;", "\u02CC"),
			("&inodot;", "\u026A"),
			("<IMG SRC=\"schwa.JPG\">", "\u0259"),
			("<IMG SRC=\"ipa306.JPG\">", "\u0254"),
			("<IMG SRC=\"ipa313.JPG\">", "\u0252"),
			("<IMG SRC=\"IPAa313.JPG\">", "\u0252"),
			("<IMG SRC=\"ipa314.JPG\">", "\u028C"),
			("<IMG SRC=\"ipa321.JPG\">", "\u028A"),
			("<IMG SRC=\"ipa305.JPG\">", "\u0251"),
			("<IMG SRC=\"ipa326.JPG\">", "\u025C"),
			("<IMG SRC=\"ipa182.JPG\">", "\u0255"),
			("&#952;", "\u03B8"),
			("&##952;", "\u03B8"),
			("&##8747;", "\u0283"),
			("<SUB><IMG SRC=\"ipa135.JPG\"></SUB>", "\u0292"),
			("&eng;", "\u014B"),
			("&##39;", "'"),
			("<SUB><IMG SRC=\"rzym1.jpg\"></SUB>", "I"),
			("<SUB><IMG SRC=\"rzym2.jpg\"></SUB>", "II"),
			("<SUB><IMG SRC=\"rzym3.jpg\"></SUB>", "III"),
			("<SUB><IMG SRC=\"rzym4.jpg\"></SUB>", "IV"),
			("<SUB><IMG SRC=\"rzym5.jpg\"></SUB>", "V"),
			("<SUB><IMG SRC=\"rzym6.jpg\"></SUB>", "VI"),
			("<SUB><IMG SRC=\"rzym7.jpg\"></SUB>", "VII"),
			("<SUB><IMG SRC=\"rzym8.jpg\"></SUB>", "VIII"),
			("&square;", "\u2026"),
			("&quotlw;", "\""),
			("&quotup;", "\""),
			("<IMG SRC=\"idioms.JPG\">", "IDIOMS:"),
			("&squareb;", "\u2022"),
			("&hfpause;", "-"),
			("&tilde;", "~"),
			("&aelig;", "\u00E6"),
			("&rarr;", "\u2192"),
			("&theta;", "\u03B8"),
			("&pause;", "\u2014"),
			("&lsquo;", "\u2018"),
			("&eth;", "\u00F0"),
			("&para;", "\u00B6"),
			("&deg;", "\u00B0"),
			("&iuml;", "\u00EF"),
			("&ouml;", "\u00F6"),
			("&ocirc;", "\u00F4"),
			("&acirc;", "\u00E2"),
			("&epsilon;", "\u03B5"),
			("&icirc;", "\u00EE"),
			("&uuml;", "\u00FC"),
			("&##163;", "\u00A3"),
			("&dots;", "\u2026"),
			("&rArr;", "\u2192"),
			("&IPA118;", "\u0272"),
			("&##949;", "\u03B5"),
			("<IMG SRC=\"ipa183.JPG\">", "\u0291"),
			("&IPA413;", "\u031F"),
			("&IPA424;", "\u0303"),
			("&IPA505;", "\u0306"),
			# added for PWN 2006/2007
			("&IPA135;", "\u0292"),
			("&IPA305;", "\u0251"),
			("&IPA306;", "\u0254"),
			("&IPA313;", "\u0252"),
			("&IPAa313;", "\u0252"),
			("&IPA314;", "\u028C"),
			("&IPA321;", "\u028A"),
			("&IPA326;", "\u025C"),
			("&IPA503;", "\u02D0"),
			("&IPA146;", "h"),
			("&IPA170;", "w"),
			("&IPA128;", "f"),
			("&IPA325;", "\u00E6"),
			("&IPA301;", "i"),
			("&IPA155;", "l"),
			("&IPA319;", "\u026A"),
			("&IPA114;", "m"),
			("&IPA134;", "\u0283"),
			("&IPA103;", "t"),
			("&IPA140;", "x"),
			("&IPA119;", "\u014B"),
			("&IPA131;", "\u00F0"),
			("&IPA130;", "\u03B8"),
			("&schwa.x;", "\u0259"),
			("&apos;", "'"),
			("&pound;", "\u00A3"),
			("&epsi;", "\u03B5"),
			("&ldquor;", "\u201C"),
			("&rdquo;", "\u201D"),
			("&mdash;", "\u2014"),
			("&marker;", "\u2022"),
			("<SUB><IMG SRC=\"rzym9.jpg\"></SUB>", "IX"),
			("<SUB><IMG SRC=\"rzym10.jpg\"></SUB>", "X"),
			("<SUB><IMG SRC=\"rzym11.jpg\"></SUB>", "XI"),
			("<SUB><IMG SRC=\"rzym12.jpg\"></SUB>", "XII"),
			("<SUB><IMG SRC=\"rzym13.jpg\"></SUB>", "XIII"),
			("<SUB><IMG SRC=\"rzym14.jpg\"></SUB>", "XIV"),
			("<SUB><IMG SRC=\"rzym15.jpg\"></SUB>", "XV"),
			("&IPA101;", "p"),
			("&IPA102;", "b"),
			("&IPA104;", "d"),
			("&IPA109;", "k"),
			("&IPA110;", "g"),
			("&IPA116;", "n"),
			("&IPA122;", "r"),
			("&IPA129;", "v"),
			("&IPA132;", "s"),
			("&IPA133;", "z"),
			("&IPA153;", "j"),
			("&IPA182;", "\u0255"),
			("&IPA183;", "\u0291"),
			("&IPA302;", "e"),
			("&IPA304;", "a"),
			("&IPA307;", "o"),
			("&IPA308;", "u"),
			("&IPA309;", "y"),
			("&IPA322;", "\u0259"),
			("&IPA426;", "\u02E1"),
			("&IPA491;", "\u01EB"),
			("&IPA501;", "\u02C8"),
			("&ldquo;", "\u201C"),
			("&ndash;", "\u2013"),
			("&hellip;", "\u2026"),
			("&asymp;", "\u2248"),
			("&aacute;", "\u00E1"),
			("&comma;", ","),
			("&squ;", "\u2022"),
			("&ncaron;", "\u0148"),
			("&arabicrsquo.x;", "'"),
			("&atildedotbl.x;", "\u00E3"),
			# Added for PWN Oxford 2005
			("<LITERA SRC=\"ipa135.JPG\">", "\u0292"),
			("<LITERA SRC=\"ipa305.JPG\">", "\u0251"),
			("<LITERA SRC=\"ipa306.JPG\">", "\u0254"),
			("<LITERA SRC=\"ipa313.JPG\">", "\u0252"),
			("<LITERA SRC=\"ipa314.JPG\">", "\u028C"),
			("<LITERA SRC=\"ipa321.JPG\">", "\u028A"),
			("<LITERA SRC=\"ipa326.JPG\">", "\u025C"),
			("<LITERA SRC=\"ipa503.JPG\">", "\u02D0"),
			("<LITERA SRC=\"schwa.JPG\">", "\u0259"),
			("<LITERA SRC=\"ipa182.JPG\">", "\u0255"),
			("<LITERA SRC=\"ipa183.JPG\">", "\u0291"),
			("&Eacute;", "\u00E9"),
			("&auml;", "\u00E4"),
			("&rdquor;", "\u201D"),
			("&verbar;", "|"),
			("&IPA405;", "\u0324"),
			("&idot;", "\u0130"),
			("&equals;", "="),
			("&vprime;", "'"),
			("&lsqb;", "\u005B"),
			("&rsqb;", "\u005D"),
			# added for PWN Russian
			("&Acy;", "\u0410"),
			("&acy;", "\u0430"),
			("&Bcy;", "\u0411"),
			("&bcy;", "\u0431"),
			("&CHcy;", "\u0427"),
			("&chcy;", "\u0447"),
			("&Dcy;", "\u0414"),
			("&dcy;", "\u0434"),
			("&Ecy;", "\u042d"),
			("&ecy;", "\u044d"),
			("&Fcy;", "\u0424"),
			("&fcy;", "\u0444"),
			("&Gcy;", "\u0413"),
			("&gcy;", "\u0433"),
			("&HARDcy;", "\u042A"),
			("&hardcy;", "\u044A"),
			("&Icy;", "\u0418"),
			("&icy;", "\u0438"),
			("&IEcy;", "\u0415"),
			("&iecy;", "\u0435"),
			("&IOcy;", "\u0401"),
			("&iocy;", "\u0451"),
			("&Jcy;", "\u0419"),
			("&jcy;", "\u0439"),
			("&Kcy;", "\u041a"),
			("&kcy;", "\u043a"),
			("&KHcy;", "\u0425"),
			("&khcy;", "\u0445"),
			("&Lcy;", "\u041b"),
			("&lcy;", "\u043b"),
			("&Mcy;", "\u041c"),
			("&mcy;", "\u043c"),
			("&Ncy;", "\u041d"),
			("&ncy;", "\u043d"),
			("&numero;", "\u2116"),
			("&Ocy;", "\u041e"),
			("&ocy;", "\u043e"),
			("&Pcy;", "\u041f"),
			("&pcy;", "\u043f"),
			("&Rcy;", "\u0420"),
			("&rcy;", "\u0440"),
			("&Scy;", "\u0421"),
			("&scy;", "\u0441"),
			("&SHCHcy;", "\u0429"),
			("&shchcy;", "\u0449"),
			("&SHcy;", "\u0428"),
			("&shcy;", "\u0448"),
			("&SOFTcy;", "\u042C"),
			("&softcy;", "\u044C"),
			("&Tcy;", "\u0422"),
			("&tcy;", "\u0442"),
			("&TScy;", "\u0426"),
			("&tscy;", "\u0446"),
			("&Ucy;", "\u0423"),
			("&ucy;", "\u0443"),
			("&Vcy;", "\u0412"),
			("&vcy;", "\u0432"),
			("&YAcy;", "\u042f"),
			("&yacy;", "\u044f"),
			("&Ycy;", "\u042b"),
			("&ycy;", "\u044b"),
			("&YUcy;", "\u042e"),
			("&yucy;", "\u044e"),
			("&Zcy;", "\u0417"),
			("&zcy;", "\u0437"),
			("&ZHcy;", "\u0416"),
			("&zhcy;", "\u0436"),
			("&Delta;", "\u0394"),
			("&xutri;", "\u25B3"),
			("&diam;", "\u22C4"),
			("&Aacute;", "\u00C1"),
			("&Aring;", "\u00C5"),
			("&Ccaron;", "\u010C"),
			("&yacute;", "\u00FD"),
			("&rcaron;", "\u0159"),
			("&Icirc;", "\u00CE"),
			("&Omacr;", "\u014C"),
			("&Ouml;", "\u00D6"),
			("&Rcaron;", "\u0158"),
			("&ccaron;", "\u010D"),
			("&Scaron;", "\u0160"),
			("&scaron;", "\u0161"),
			("&Zcaron;", "\u017D"),
			("&zcaron;", "\u017E"),
			("&uacute;", "\u00FA"),
			("&oslash;", "\u00F8"),
			("&abreve;", "\u0103"),
			("&laquo;", "\u00AB"),
			("&raquo;", "\u00BB"),
			("&umacr;", "\u016B"),
			("&tcedil;", "\u0162"),
			("&iacute;", "\u00ED"),
			("&ecaron;", "\u011B"),
			("&euml;", "\u00EB"),
			("&ntilde;", "\u00F1"),
			("&scedil;", "\u015F"),
			("&omacr;", "\u014D"),
			("&igrave;", "\u00EC"),
			("&#337;", "\u0150"),
			("&amacr;", "\u0101"),
			("&ograve;", "\u00F2"),
			("&atilde;", "\u00E3"),
			("&uring;", "\u016F"),
			("&#8470;", "\u2116"),
			("&ucirc;", "\u00FB"),
			("&aring;", "\u00E5"),
			("&Ccedil;", "\u00C7"),
			("&amp;lt;", "\u2039"),
			("&amp;gt;", "\u203A"),
			("&amp;amp;", "&"),
			("&lt;", "\u2039"),
			("&diams;", "\u2666"),
			("&nbsp;", "\u00A0"),
			("&lstrok;", "\u0142"),
			("&eogon;", "\u0119"),
			("&nacute;", "\u0144"),
			("&sacute;", "\u015B"),
			("&cacute;", "\u0107"),
			("&oacute;", "\u00F3"),
			("&aogon;", "\u0105"),
			("&zdot;", "\u017C"),
			("&Sacute;", "\u015A"),
			("&Zdot;", "\u017B"),
			# added for SWO and SF
			("&dash;", "\u2010"),
			("<IMG SRC=\"ksiazecz.bmp\">", ""),
			("&zeta;", "\u03B6"),
			("&xi;", "\u03BE"),
			("&utilde;", "\u0169"),
			("&upsi;", "\u03C5"),
			("&Upsi;", "\u03D2"),
			("&Zeta;", "\u0396"),
			("&permil;", "\u2030"),
			("&mu;", "\u03BC"),
			("&Lambda;", "\u039B"),
			("&rho;", "\u03C1"),
			("&sigma;", "\u03C3"),
			("&Phi;", "\u03A6"),
			("&gamma;", "\u03B3"),
			("&beta;", "\u03B2"),
			("&Uuml;", "\u00DC"),
			("&kappa;", "\u03BA"),
			("&percnt;", "%"),
			("&phiv;", "\u03C6"),
			("&pi;", "\u03C0"),
			("&psi;", "\u03C8"),
			("&Pi;", "\u03A0"),
			("&Psi;", "\u03A8"),
			("&Tau;", "\u03A4"),
			("&Theta;", "\u0398"),
			("&tau;", "\u03C4"),
			("&sect;", "\u00A7"),
			("&star;", "\u2606"),
			("&Sigma;", "\u03A3"),
			("&gt;", "\u203A"),
			("&omacrac.x;", "\u1E53"),
			("&#8219;", "\u201B"),
			("&emacr;", "\u0113"),
			("&emacrac.x;", "\u1E17"),
			("&bullb;", "\u2022"),
			("&wcirc;", "\u0175"),
			("&mdot.x;", "\u1E41"),
			("&imacr;", "\u012B"),
			("&gmacr.x;", "\u1E21"),
			("&tdotbl.x;", "\u1E6D"),
			("&alpha;", "\u03B1"),
			("&gcaron.x;", "\u01E7"),
			("&hdotbl.x;", "\u1E25"),
			("&wdot;", "\u1E87"),
			("&lsquor;", "\u201A"),
			("&cdot;", "\u010B"),
			("&Omega;", "\u03A9"),
			("&bdot;", "\u1E03"),
			("&sdotbl.x;", "\u1E63"),
			("&Beta;", "\u0392"),
			("&ndotbl.x;", "\u1E47"),
			("&acaron.x;", "\u01CE"),
			("&ndot.x;", "\u1E45"),
			("&kdot;", "\uE568"),
			("&chi;", "\u03C7"),
			("&delta;", "\u03B4"),
			("&#62;", ">"),
			("&amacrac.x;", "\uE40A"),
			("&Auml;", "\u00C4"),
			("&Emacr;", "\u0112"),
			("&eta;", "\u03B7"),
			("&Hdotbl.x;", "\u1E24"),
			("&Gamma;", "\u0393"),
			("&rringbl.x;", "\uE6A3"),
			("&etilde.x;", "\u1EBD"),
			("&Imacr;", "\u012A"),
			("&ddotbl.x;", "\u1E0D"),
			("&iota;", "\u03B9"),
			("&ucaron.x;", "\u01D4"),
			("&rdotbl.x;", "\u1E5B"),
			("&Xi;", "\u039E"),
			("&lambda;", "\u03BB"),
			("&nu;", "\u03BD"),
			("&omega;", "\u03C9"),
			("&gdot;", "\u0121"),
			("&ugrave;", "\u00F9"),
			("&itilde;", "\u0129"),
			("&iumlacute;", "\u1E2F"),
			("&imacrtilde;", "\u012B"),
			("&eibrevebl;", "\u1EB5"),
			("&hmacrbl.x;", "\u1E96"),
			("&nmacr.x;", "\u0304"),
			("&tmacrbl.x;", "\u1E6F"),
			("&dmacrbl.x;", "\u1E0F"),
			("&umacrtilde;", "\u0169"),
			("&Hmacrbl.x;", "Kh"),
			("&zdotbl.x;", "\u1E93"),
			("&edot;", "\u0117"),
			("&dolnagw;", "\u2606"),
			# needs to be done here
			("&ap;~", "\u2248"),
			("&ap;", "\u2248")
			]

	# converts and cleans up definitions/words
	def __format(self, temp):
		# convert symbols to unicode
		for i in self.__replacements:
			temp = temp.replace(i[0], i[1])

		# some clean-up
		temp = re.sub("^<BIG>.*?</BIG> ?", "", temp)			# remove entry name, we already have it
		temp = re.sub("<ICON.*?>", "", temp)
		temp = re.sub("<P> ?</P>", "", temp) 				# remove redundant <P>s
		temp = temp.replace("<P>", "<br><br>") 				# change <P>s to linebreaks
		temp = temp.replace("</P><B>", "<br><br><B>") 			# add linebreak before some bold words
		temp = temp.replace("</P>", "")
		temp = temp.replace("<HANGINGPAR>", "")
		temp = re.sub("<TEXTSECTION.*?>", "", temp)
		temp = re.sub("</?PL>", "", temp)
		temp = re.sub("</?GB>", "", temp)
		temp = re.sub("<SUP>(.*?)</SUP>", " \\1", temp)
		temp = re.sub("<HMS NR=\"(.*?)\">", " \\1", temp)
		# added for PWN 2006/2007
		temp = re.sub("</?STEM>", "", temp)
		temp = re.sub("</?PH>", "", temp)
		# added for PWN Russian
		temp = re.sub("</?RU>", "", temp)
		temp = re.sub("<IGNORE>.*?</IGNORE>", "", temp)
		temp = re.sub("<IGNORE>.*", "", temp)				# leftovers in rus-pol

		# fix Polish-English ugliness
		temp = temp.replace("\n", "<br>")
		temp = re.sub("</?A.*?>", "", temp)
		temp = re.sub("^<br><br> ?", "", temp)

		# add some color, if requested
		if self.__use_colors:
			temp = re.sub("<I>( [^<]*)</I>",
					"<I><font color=\"" + self.__colors[0] + "\">\\1</font></I>", temp)
			temp = re.sub("<I>([^<\[]*)</I>",
					"<I><font color=\"" + self.__colors[1] + "\">\\1</font></I>", temp)
			temp = re.sub("([^(])<SMALL>([^<]*)</SMALL>",
					"\\1<font color=\"" + self.__colors[2] + "\">\\2</font>", temp)

		# remove leading and trailing whitespace
		temp = temp.strip()

		return temp

	def write_stardict(self, fname):
		path, book_name = os.path.split(fname)
		book_name = os.path.splitext(book_name)[0]
		book_name = os.path.join(path, book_name)

		with nested(codecs.open(fname, "w", "UTF-8"),
				open(book_name + ".idx", "wb"),
				open(book_name + ".ifo", "wb")) as (dictionary, idx, ifo):

			for word, addr in self.words:
				definition = self.read_definition(addr)

				if definition == "":
					continue

				offset = dictionary.tell()
				size = len(definition.encode("UTF-8"))

				# write definition to .dict
				dictionary.write(definition)

				# write null-terminated word, offset and size to .idx
				idx.write(word.encode("UTF-8") + b"\x00")
				idx.write(struct.pack(b">2I", offset, size))

			# write .ifo
			header = "StarDict's dict ifo file\n"
			header += "version=3.0.0\n"
			header += "idxoffsetbits=32\n"
			header += "wordcount=%d\n" % len(self.words)
			header += "idxfilesize=%d\n" % idx.tell()
			header += "bookname=%s\n" % book_name
			header += "sametypesequence=h\n"
			ifo.write(header.encode("UTF-8"))

	def write_tabfile(self, fname):
		with codecs.open(fname, "w", "UTF-8") as tab:
			for word, addr in self.words:
				tmp = self.read_definition(addr)

				if tmp != "":
					tab.write("%s\t%s\n" % (word, tmp))

	def read_definition(self, addr):
		# read definition
		self.__dict.seek(addr)
		word_buffer = self.__dict.read(30000)
		temp = ""

		# workaround for Python 2.6/3.x interop
		if type(word_buffer) == type(str()):
			first_byte = ord(word_buffer[0])
		else:
			first_byte = word_buffer[0]

		if first_byte < 20:
			# take pointer and decompress
			temp = zlib.decompress(word_buffer[first_byte + 1:])
		else:
			# copy up to next null char
			pos = word_buffer.index(b"\x00")
			temp = word_buffer[:pos]

		cur = temp.decode(self.__encoding)
		return self.__format(cur)

	def __init__(self, dict_name, use_colors=False):
		self.__dict = open(dict_name, "rb")
		self.__use_colors = use_colors

		# temporary variables
		wordcount = 0
		index_base = 0
		words_base = 0
		header_offset = 2

		# check header
		header = struct.unpack(b"<I", self.__dict.read(4))[0]

		# seek and read data
		if header == 0x81125747:
			print("Detected Oxford PWN 2004 format...")
			self.__encoding = "cp1250"

			# checking for alternative 2005 format
			if struct.unpack(b"<I", self.__dict.read(4))[0] == 2:
				header_offset = 5

			self.__dict.seek(0x18)
			wordcount, index_base, words_base = struct.unpack(b"<3I", self.__dict.read(12))
		elif header == 0x81135747:
			print("Detected PWN 2005 format...")
			self.__encoding = "iso-8859-2"
			self.__dict.seek(0x18)
			wordcount, index_base, words_base = struct.unpack(b"<3I", self.__dict.read(12))
		elif header == 0x81145747:
			print("Detected Oxford PWN 2006/2007 format...")
			self.__encoding = "iso-8859-2"
			self.__dict.seek(0x68)
			wordcount, index_base, _, words_base = struct.unpack(b"<4I", self.__dict.read(16))
		else:
			raise ValueError("Incorrect file header")

		offsets = []
		self.words = []

		# read alphabetical index
		print("Reading alphabetical index...")

		self.__dict.seek(index_base)
		for i in range(wordcount):
			addr = struct.unpack(b"<I", self.__dict.read(4))[0] & 0x07ffffff
			offsets += [addr]

		# read index table
		print("Reading words...")

		for i in range(wordcount):
			word_start = words_base + offsets[i]
			self.__dict.seek(word_start)
			word_buffer = self.__dict.read(300)

			# workaround for Python 2.6/3.x interop
			if type(word_buffer) == type(str()):
				entry_type = ord(word_buffer[2 + 1])
			else:
				entry_type = word_buffer[2 + 1]

			# 0x49, 0x38, 0x76 = information entries
			if entry_type not in [0x49, 0x38, 0x76]:
				word_buffer = word_buffer[2 + 4 + 6:]
				length = word_buffer.index(b"\x00")
				word = word_buffer[:length]

				word = word.decode(self.__encoding)

				# formatting is very costly, so bail out if it's not needed
				if re.search("[<&;]", word):
					word = self.__format(word)

				word = word.replace("|", "") 		# make Polish->English words nicer to look at
				word = re.sub(" \d+$", "" , word) 	# remove word-final numbers

				self.words += [(word, length + header_offset + word_start + 2 + 4 + 6)]

		# sort words, since stardict requires it
		self.words.sort(key=cmp_to_key(stardict_strcmp))

if __name__ == "__main__":
	# parse options
	usage = "usage: %prog [options] pwn_file.win [stardict_file.dict]"
	parser = OptionParser(usage=usage)
	parser.add_option("-t", "--tabfile", action="store_true", dest="tabfile",
			help="convert to tabfile format instead")
	parser.add_option("-c", "--colors", action="store_true", dest="colors",
			help="add some colors for readability (experimental)")
	options, args = parser.parse_args()

	# set up variables for formats
	if options.tabfile:
		mode = "tabfile"
		ext = ".tab"
	else:
		mode = "stardict"
		ext = ".dict"

	# make output filename if not specified
	if len(args) == 2:
		dest_name = args[1]
	elif len(args) == 1:
		base_name = os.path.splitext(args[0])[0]
		dest_name = base_name + ext
	else:
		parser.print_help()
		sys.exit(1)

	src_dict = PwnDict(args[0], use_colors=options.colors)

	# convert and write data
	print("Writing converted data...")

	if mode == "stardict":
		src_dict.write_stardict(dest_name)
	elif mode == "tabfile":
		src_dict.write_tabfile(dest_name)

