.PHONY: FORCE_MAKE

all: cv-mikheyev.pdf

#pdf:   clean $(PDFS)
#html:  clean $(HTML)

validate_yaml:
	@python -c 'import yaml,sys;yaml.safe_load(sys.stdin)' < curriculum_vitae.yaml

%.pdf: %.tex FORCE_MAKE
	latexmk -lualatex -dvi-  $*

yaml-cv.md: curriculum_vitae.yaml
# Pandoc can't actually read YAML, just YAML blocks in
# Markdown. So I give it a document that's just a YAML block,
# while still editing a straight YAML file which has a bunch of advantages.
	cat $< > $@

%.tex: template-%.tex yaml-cv.md
# Pandoc does the initial compilation to tex; we then latex handle the
# actual bibliography and pdf creation.
	pandoc --template=$< -t latex yaml-cv.md > $@
# Citekeys get screwed up by pandoc which escapes the underscores.
# Years should have en-dashes, which damned if I'm going to do it
# on my own.
	perl -pi -e 'if ($$_=~/cite\{/) {s/\\_/_/g}; s/(\d{4})-(\.|[Pp]resent|\d{4})/$$1--$$2/g' $@;

%-scholar.tex: FORCE_MAKE
	Rscript scholar.R > $@

%.md: template-%.md yaml-cv.md mikheyev.bib
# for some reason pandoc inserts ::: into the references and I manually remove them
	sed 's/-[0-9][0-9]-[0-9][0-9]//g;s/\\\\emph{\([^}]*\)}/_\1_/g;' yaml-cv.md | pandoc --template=$< -t markdown | pandoc --filter pandoc-citeproc --bibliography=mikheyev.bib  -t markdown | grep -v  '^:::'  > $@

%.html: %.md
	pandoc -f markdown -t html $< > $@

clean:
	rm -f *.aux *.bcf *.log *.out *.run.xml *.pdf *.bbl *.blg *yaml-cv.md
