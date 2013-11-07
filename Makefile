# Latex Makefile

# pseudo targets
# .SILENT:
.SUFFIXES:
.SUFFIXES: .pdf .tex .ps .aux .eps .pstex_t .bib .bbl .png .pnm .jpg \
	.dia .ps.gz .fig .tpt .pov .ini .gnuplot .svg .iso .cc .o \
	.data .erb .ini .txt .rb .dot

HORNETSEYE = $(HOME)/test/hornetseye
ARTICLES = $(HOME)/Documents/work/nano/articles
#applications
LIBTOOL = libtool
CXX = g++
GIT = git
BZIP2 = bzip2
GUNZIP = gunzip
PDFLATEX = pdflatex
PSSELECT = psselect
PDFFONTS = pdffonts
PSLATEX = pslatex
THUMBPDF = thumbpdf
BIBTEX = bibtex
DVIPS = dvips
CONVERT = convert
MENCODER = mencoder
PNM2PS = pnmtops
DIA = dia
PS2EPS = ps2epsi
EPS2PDF = epstopdf
GZIP = gzip
FIG2DEV = fig2dev
POVRAY = povray
PS2PDF = ps2pdf
GNUPLOT = gnuplot
PDFTK = pdftk
INKSCAPE = inkscape
LN_S = ln -s
RUBY = ruby
DOT = dot

default: pdf

help:
	echo 'make pdf' creates colour electronic version 'elcvia11.pdf'
#	echo 'make foils' creates colour electronic foils 'foils.pdf'

pdf: joser13.pdf

# foils: foils.pdf

joser13.pdf: joser13.tex joser13.aux joser13.bbl joser13.tpt \
	IEEEtran.bst joser13.cls IEEEabrv.bib \
	triangle.pdf amavasai.jpg chliveros.jpg wedekind.jpg \
	types.pdf image.pdf
	$(PDFLATEX) -shell-escape $<
	$(THUMBPDF) --modes=pdftex $@
	$(PDFFONTS) $@
	ls -la $@
	echo
	( sleep 1 && touch joser13.aux && touch joser13.tpt ) &

# elcvia11.128.pdf: elcvia11.pdf
# 	$(PDFTK) $< output $@ encrypt_128bit compress owner_pw lockHornMath34 allow AllFeatures

joser13.bbl: joser13.bib joser13.aux noPercent.awk
	$(BIBTEX) joser13
	./noPercent.awk $@ > joser13.tmp
	mv joser13.tmp $@

dist:
	$(GIT) archive --format=tar --prefix=joser13/ HEAD | $(BZIP2) > joser13.tar.bz2

clean:
	rm -Rf *.pdf *.eps *.pstex_t *.ps *.ps.gz *.bbl *.log *.aux *.tmp \
	*.tpt *.blg *.out *~ .*~ .xvpics *.fig.bak *.o .libs *.brf

# Emergency-rule for skipping creation of thumbnails
%.tpt:
	echo Thumbnail-file $@ required! Rerun make after this build!

# Emergency-rule for enabling creation of bibliography
%.aux:
	echo '\\citation{undefined}' > $@
	echo '\\bibstyle{IEEEtran}' >> $@
	echo '\\bibdata{IEEEabrv,joser13}' >> $@

.png.pnm:
	$(CONVERT) $< -colorspace gray $@

.pnm.ps:
	$(PNM2PS) -noturn $< > $@

.ps.eps:
	$(PS2EPS) $< $@

.eps.pdf:
	$(EPS2PDF) $< -o $@

%.ps.gz: %.ps
	$(GZIP) -c $< > $@

.gnuplot.pdf:
	$(GNUPLOT) $<
	$(PS2PDF) $(basename $@).ps $@
#	$(GNUPLOT) $<
#	$(PS2EPS) $(basename $@).ps $(basename $@).eps
#	$(EPS2PDF) $(basename $@).eps $@

.fig.pstex_t:
	$(FIG2DEV) -L pstex_t $< > $@

.fig.eps:
	$(FIG2DEV) -L pstex $< $@

.dot.png:
	$(DOT) -T png -o $@ $<

.dot.pdf:
	$(DOT) -T pdf -o $@ $<

# Do not create pdf directly!
# Set all text-flags in xfig to special! Use pstex_t!
# Call "pdftools <file>" to see wether all fonts are included (embedded).
# Do not follow Selvan's rule "always create PDF's directly"
# .fig.pdf:
# 	$(FIG2DEV) -L pdf $< $@

.png.jpg:
	$(CONVERT) $< -quality 90 $@

.svg.pdf:
	$(INKSCAPE) $< -A $@

%-70.jpg: %.png
	$(CONVERT) $< -quality 70 $@

%-60.jpg: %.png
	$(CONVERT) $< -quality 60 $@

%-50.jpg: %.png
	$(CONVERT) $< -quality 50 $@

%-40.jpg: %.png
	$(CONVERT) $< -quality 40 $@

# .ps.pdf:
# 	$(PS2PDF) $< $@

DEPS_MAGIC := $(shell mkdir .deps > /dev/null 2>&1 || :)

tensor: tensor.o
	$(CXX) -o $@ tensor.o

.cc.o:
	$(CXX) -Wp,-MD,.deps/$(*F).pp -c $< -o $@ -O6 -DNDEBUG -I$(MIMAS)/include
	@-cp .deps/$(*F).pp .deps/$(*F).P; \
	tr ' ' '\012' < .deps/$(*F).pp \
	  | sed -e 's/^\\$$//' -e '/^$$/ d' -e '/:$$/ d' -e 's/$$/ :/' \
	    >> .deps/$(*F).P; \
	rm .deps/$(*F).pp

-include $(wildcard .deps/*.P) :-)
