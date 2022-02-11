SHELL:=/bin/bash

SOFT:=oberapk
VERSION:=$(shell grep '^VERSION=' $(SOFT) | cut -f 2 -d "'")


.PHONY: all help pkg version pages

all:
	#pod2man $(SOFT) | gzip > $(SOFT).1.gz
	#pod2html --css podstyle.css --index --header $(SOFT) > $(SOFT).html

pkg:
	./make-package-debian
	
version:
	@echo -n $(VERSION)

pages: pkg
	mkdir -p public/download
	#cp -p *.html       public/
	#cp -p podstyle.css public/
	cp -p LICENSE.md  public/
	make version > public/version.txt
	cp -p --no-clobber $(SOFT)_*_all.deb  public/download/
	#cd public; ln -sf $(SOFT).html index.html
	echo '<html><body><h1>Oberapk Debian Package</h1><ul>' > public/download/index.html
	(cd public/download; while read file; do printf '<li><a href="%s">%s</a> (%s)</li>\n' $$file $$file $$(stat -c %y $$file | cut -f 1 -d ' '); done < <(ls -1t *.deb) >> index.html)
	echo '</ul></body></html>' >> public/download/index.html

help:
	@echo "Possibles targets:"
	@echo " * all     : make manual"
	@echo " * pkg     : build Debian package"
	@echo " * pages   : build pages for GitLab-CI"
