## A Makefile for the presentations

OPTIONS = --slide-level 2 --mathjax --no-highlight --variable revealjs-url=/data/git/reveal.js 
STYLE = revealjs

SRC_PRES = $(wildcard *.Rpres)
TEX_PRES = $(wildcard *.Rnw)

MD_PRES = $(patsubst %.Rpres, %.md, $(SRC_PRES))
HTML_PRES = $(patsubst %.md, %.html, $(MD_PRES))
PDF_PRES = $(patsubst %.Rnw, %.pdf, $(TEX_PRES))

all: $(HTML_PRES) $(MD_PRES) $(PDF_PRES)
mds: $(MD_PRES)
html: $(HTML_PRES)
pdf: $(PDF_PRES)

%.html: %.md
	pandoc -sSt $(STYLE) $< -o $@ $(OPTIONS)

%.md: %.Rpres
	Rscript \
	-e "library(knitr)" \
	-e "knitr::knit('$<','$@')"

%.pdf: %.tex
	pdflatex $<
	pdflatex $<

%.tex: %.Rnw
	Rscript \
	-e "library(knitr)" \
	-e "knitr::knit('$<','$@')"

clean_html:
	rm -f *.html *.md 

clean_tex:
	rm -fv *.aux *.log *.toc *.blg *.bbl *.synctex.gz
	rm -fv *.out *.bcf *blx.bib *.run.xml
	rm -fv *.fdb_latexmk *.fls
	rm -fv *.vrb *.snm *.nav
