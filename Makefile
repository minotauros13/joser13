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
ZIP = zip

TAG = wedekind_20131110
FIGURES = $(TAG)_f01.pdf $(TAG)_f02.pdf $(TAG)_f03.pdf \
	$(TAG)_f04.jpg $(TAG)_f05.jpg $(TAG)_f06.jpg

default: pdf
	
pdf: $(TAG).pdf

zip: $(TAG).zip

$(TAG).zip: $(TAG).tex $(TAG).pdf $(TAG).bib $(FIGURES)
	$(ZIP) -9 $@ $(TAG).tex $(TAG).pdf $(TAG).bib $(FIGURES)

$(TAG).pdf: $(TAG).tex $(TAG).aux $(TAG).bbl $(TAG).tpt \
	IEEEtran.bst joser1.cls IEEEabrv.bib $(FIGURES)
	$(PDFLATEX) -shell-escape $<
	$(THUMBPDF) --modes=pdftex $@
	$(PDFFONTS) $@
	ls -la $@
	echo
	( sleep 1 && touch $(TAG).aux && touch $(TAG).tpt ) &

$(TAG).bbl: $(TAG).bib $(TAG).aux
	$(BIBTEX) $(TAG)

# $(TAG).bbl: $(TAG).bib $(TAG).aux noPercent.awk
# 	$(BIBTEX) $(TAG)
# 	./noPercent.awk $@ > $(TAG).tmp
# 	mv $(TAG).tmp $@

dist:
	$(GIT) archive --format=tar --prefix=$(TAG)/ HEAD | $(BZIP2) > $(TAG).tar.bz2

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
	echo '\\bibdata{IEEEabrv,$(TAG)}' >> $@

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
