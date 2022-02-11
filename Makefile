SHELL:=/bin/bash

DESTDIR=

BINDIR=/usr/sbin
MANDIR=/usr/share/man/man1
SHAREDIR=/usr/share/oberapk
LIBDIR=/usr/lib/oberapk
CRONDIR=/etc/cron.d
ETCDIR=/etc/oberapk
COMPDIR=/etc/bash_completion.d

.PHONY: all help pkg pages

all:
	#pod2man oberapk | gzip > oberapk.1.gz
	#pod2html --css podstyle.css --index --header oberapk > oberapk.html

pkg:
	./make-package-debian

pages: pkg
	mkdir -p public/download
	#cp -p *.html       public/
	#cp -p podstyle.css public/
	cp -p LICENSE.md  public/
	cp -p --no-clobber oberapk_*_all.deb  public/download/
	#cd public; ln -sf oberapk.html index.html
	echo '<html><body><h1>Klask Debian Package</h1><ul>' > public/download/index.html
	(cd public/download; while read file; do printf '<li><a href="%s">%s</a> (%s)</li>\n' $$file $$file $$(stat -c %y $$file | cut -f 1 -d ' '); done < <(ls -1t *.deb) >> index.html)
	echo '</ul></body></html>' >> public/download/index.html

help:
	@echo "Possibles targets:"
	@echo " * all     : make manual"
	@echo " * pkg     : build Debian package"
	@echo " * pages   : build pages for GitLab-CI"
