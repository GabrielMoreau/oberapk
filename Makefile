SHELL:=/bin/bash

SOFT:=oberapk
VERSION:=$(shell grep '^VERSION=' $(SOFT) | cut -f 2 -d "'")
PATCH:=$(shell grep '^PKG_VERSION=' make-package-debian | cut -f 2 -d '=')


.PHONY: all help man pkg version pages clean check-depends check-metadata check-quality list
.ONESHELL:

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all: man pkg ## Build manual and Debian package

clean: ## Clean build files
	@rm -rf public $(SOFT).1.gz $(SOFT).html pod2htmd.tmp

%.1.gz: $(SOFT).pod Makefile
	@pod2man $< | gzip > $@

%.html: $(SOFT).pod Makefile podstyle.css
	@pod2html --css podstyle.css --index --header $< > $@

man: $(SOFT).1.gz $(SOFT).html # Build manual

pkg: $(SOFT) Makefile make-package-debian ## Build Debian package
	@./make-package-debian

pages: pkg $(SOFT).html Makefile ## Build pages for GitLab-CI
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

check-depends: ## Check binaries dependencies
	@./check-depends

check-metadata: ## Check metadata in packaging definition
	@./check-metadata

check-quality: ## Shellcheck packaging script code
	@shellcheck -e SC2034,SC2317,SC1091,SC1090 oberapk 
	@(cd pakaj.d; shellcheck -e SC2012,SC2164,SC2166,SC2001 *.sh)

list: ## List packaging for README
	@./list-pakaj
