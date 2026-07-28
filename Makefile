
.PHONY: help all clean pkg webpages check-depends check-metadata check-quality list

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36mmake %-17s\033[0m #%s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

all: pkg webpages ## Build all

clean: ## Clean package and public folder
	@rm -rf public *.deb

pkg: $(SOFT) Makefile make-package-debian ## Build Debian package
	@./make-package-debian

webpages: pkg ## Build public webpages for GitLab CI pages
	./make-webpages

check-depends: ## Check binaries dependencies
	@./check-depends

check-metadata: ## Check metadata in packaging definition
	@./check-metadata

check-quality: ## Shellcheck packaging script code
	@shellcheck -e SC2034,SC2317,SC1091,SC1090 oberapk
	@file * | grep 'script.*executable' | cut -f 1 -d ':' | xargs -r shellcheck -e SC2317,SC2034,SC1090,SC1091,SC2001,SC2126
	@(cd pakaj.d; shellcheck -e SC2012,SC2164,SC2166,SC2001 *.sh)
	@(cd annex.d; shellcheck *.sh)

list: ## List packaging for README
	@./list-pakaj
