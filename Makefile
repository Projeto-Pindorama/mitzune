VER := $(shell date +%Y%m%d)
DIST = dist
DISTDIRS = .local/bin .local/lib .config mitzune
DISTBALL = mitzune.$(VER).NOARCH.Linux.tar.xz
all: makedist $(DISTBALL)

makedist: $(DISTDIRS)
	cp mitzune.sh $(DIST)/.local/bin/mitzune
	cp lib/errhand.shi lib/posix-alt.shi $(DIST)/.local/lib
	cp mitzrc $(DIST)/.config/mitzrc
	cp prefixes $(DIST)/mitzune/prefixes

$(DISTDIRS):
	@mkdir -p $(DIST)/$@

$(DISTBALL): makedist
	@cd $(DIST) && tar -cvf - $(DISTDIRS) | xz -4e > $@

clean:
	rm -fr $(DIST) $(DISTBALL)
