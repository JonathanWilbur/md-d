#!/usr/bin/make
#
# Run this from the root directory like so:
# make -f ./build/scripts/posix.make
# sudo make -f ./build/scripts/posix.make install
#
vpath %.o ./build/objects
vpath %.di ./build/interfaces
vpath %.d ./source/md
vpath %.d ./source/md/flavors
vpath %.d ./source/md/terminals
vpath %.html ./documentation/html
vpath %.a ./build/libraries
vpath %.so ./build/libraries
vpath % ./build/executables

version = 0.1.0

flavors = \
	common \
	github \
	stackoverflow

terminals = \
	ansi

modules = \
	interfaces \
	$(flavors) \
	$(terminals)

sources = $(addsuffix .d,$(modules))
interfaces = $(addsuffix .di,$(modules))
objects = $(addsuffix .o,$(modules))
htmldocs = $(addsuffix .html,$(modules))
encoders = $(addprefix encode-,$(codecs))
decoders = $(addprefix decode-,$(codecs))

.SILENT : all libs tools md-$(version).a md-$(version).so $(encoders) $(decoders) install purge
all : libs tools
libs : md-$(version).a md-$(version).so
tools : view-markdown

uname := $(shell uname)
ifeq ($(uname), Linux)
	echoflags = "-e"
endif
ifeq ($(uname), Darwin)
	echoflags = ""
endif

# You will most likely need to run this will root privileges
install : all
	cp ./build/libraries/md-$(version).so /usr/local/lib
	-rm -f /usr/local/lib/md.so
	ln -s /usr/local/lib/md-$(version).so /usr/local/lib/md.so
	cp ./build/executables/view-markdown /usr/local/bin
	-cp ./documentation/man/1/view-markdown /usr/local/share/man/1
	-cp ./documentation/man/1/view-markdown /usr/local/share/man/man1
	mkdir -p /usr/local/share/md/{html,md,json}
	cp -r ./documentation/html/* /usr/local/share/md/html
	cp -r ./documentation/*.md /usr/local/share/md/md
	cp -r ./documentation/md-$(version).json /usr/local/share/asn1/json/md-$(version).json
	cp ./documentation/mit.license /usr/local/share/md
	cp ./documentation/credits.csv /usr/local/share/md
	cp ./documentation/releases.csv /usr/local/share/md

purge :
	-rm -f /usr/local/lib/md.so
	-rm -f /usr/local/lib/md-$(version).so
	-rm -f /usr/local/bin/view-markdown
	-rm -rf /usr/local/share/md
	-rm -f /usr/local/share/man/man1/view-markdown.1
	-rm -f /usr/local/share/man/1/view-markdown.1

md-$(version).a : $(sources)
	echo $(echoflags) "Building the Markdown Library (static)... \c"
	dmd \
	./source/macros.ddoc \
	./source/md/*.d \
	./source/md/flavors/*.d \
	./source/md/terminals/*.d \
	-Dd./documentation/html \
	-Hd./build/interfaces \
	-op \
	-of./build/libraries/md-$(version).a \
	-Xf./documentation/md-$(version).json \
	-lib \
	-inline \
	-release \
	-O \
	-map \
	-d
	echo $(echoflags) "\033[32mDone.\033[0m"

md-$(version).so : $(sources)
	echo $(echoflags) "Building the Markdown Library (shared / dynamic)... \c"
	dmd \
	./source/md/*.d \
	./source/md/flavors/*.d \
	./source/md/terminals/*.d \
	-Dd./documentation/html \
	-Hd./build/interfaces \
	-op \
	-of./build/libraries/md-$(version).so \
	-lib \
	-inline \
	-release \
	-O \
	-map \
	-d
	echo $(echoflags) "\033[32mDone.\033[0m"

./build/executables/view-markdown : ./source/tools/view-readme.d md-$(version).a
	echo $(echoflags) "Building the Markdown Command-Line Tool, view-markdown... \c"
	dmd \
	-I./build/interfaces/source \
	-L./build/libraries/md-$(version).a \
	./source/tools/view_markdown.d \
	-od./build/objects \
	-of./build/executables/view-markdown \
	-inline \
	-release \
	-O \
	-d
	chmod +x ./build/executables/view-markdown
	echo $(echoflags) "\033[32mDone.\033[0m"

# How Phobos compiles only the JSON file:
# JSON = phobos.json
# json : $(JSON)
# $(JSON) : $(ALL_D_FILES)
# $(DMD) $(DFLAGS) -o- -Xf$@ $^