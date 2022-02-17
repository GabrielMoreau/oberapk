SHELL:=/bin/bash

SOFT:=oberapk
VERSION:=$(shell grep '^VERSION=' $(SOFT) | cut -f 2 -d "'")
PATCH:=$(shell grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d '=')


.PHONY: all help pkg version pages clean check list
.ONESHELL:

all: $(SOFT).1.gz $(SOFT).html

clean:
	@rm -rf public $(SOFT).1.gz $(SOFT).html pod2htmd.tmp

%.1.gz: $(SOFT) Makefile
	@pod2man $(SOFT) | gzip > $@

%.html: $(SOFT) Makefile
	@pod2html --css podstyle.css --index --header $(SOFT) > $@

pkg: all Makefile make-package-debian oberapk
	@./make-package-debian

pages: pkg Makefile
	@mkdir -p public/download
	@cp -p *.html       public/
	@cp -p podstyle.css public/
	@cp -p LICENSE.md  public/
	@echo -n "$(VERSION)-$(PATCH)" > public/version.txt
	@cp -p --no-clobber $(SOFT)_*_all.deb  public/download/
	@(cd public; ln -sf $(SOFT).html index.html)
	@cd public/download
	@echo '<html><body><h1>Oberapk Debian Package (Latest version: $(VERSION)-$(PATCH))</h1><ul>' > index.html
	@(while read file; do printf '<li><a href="%s">%s</a> (%s)</li>\n' $$file $$file $$(stat -c %y $$file | cut -f 1 -d ' '); done < <(ls -1t *.deb) >> index.html)
	@echo '</ul></body></html>' >> index.html

help:
	@echo "Possibles targets:"
	@echo " * all     : make manual"
	@echo " * pkg     : build Debian package"
	@echo " * pages   : build pages for GitLab-CI"
	@echo " * clean   : clean build files"
	@echo " * check   : check binaries dependencies"
	@echo " * list    : list packaging for README"

check:
	@./check-depends

list:
	@./list-pakaj
