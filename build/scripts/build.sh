#!/bin/sh
#
# NOTE:
# This script assumes that your terminal supports ANSI Escape Codes and colors.
# It should not fail if your terminal does not support it--the output will just
# look a bit garbled.
#
GREEN='\033[32m'
RED='\033[31m'
NOCOLOR='\033[0m'
TIMESTAMP=$(date '+%Y-%m-%d@%H:%M:%S')
VERSION="0.1.0"

if [ "$(uname)" == "Darwin" ]; then
	ECHOFLAGS=""
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	ECHOFLAGS="-e"
fi

# Unfortunately, because this is running in a shell script, brace expansion
# might not work, so I can't create all the necessary directories "the cool
# way." See this StackOverflow question that addresses my problem:
# https://stackoverflow.com/questions/40164660/bash-brace-expansion-not-working-on-dockerfile-run-command
mkdir -p ./documentation
mkdir -p ./documentation/html
mkdir -p ./documentation/links
mkdir -p ./build
mkdir -p ./build/assemblies
mkdir -p ./build/executables
mkdir -p ./build/interfaces
mkdir -p ./build/libraries
mkdir -p ./build/logs
mkdir -p ./build/maps
mkdir -p ./build/objects
mkdir -p ./build/scripts

echo $ECHOFLAGS "Building the Markdown Library (static)... \c"
if dmd \
 ./source/macros.ddoc \
 ./source/md/*.d \
 ./source/md/flavors/*.d \
 ./source/md/terminals/*.d \
 -Dd./documentation/html \
 -Hd./build/interfaces \
 -op \
 -of./build/libraries/md-${VERSION}.a \
 -Xf./documentation/md-${VERSION}.json \
 -lib \
 -inline \
 -release \
 -O \
 -map \
 -v >> ./build/logs/${TIMESTAMP}.log 2>&1; then
    echo $ECHOFLAGS "${GREEN}Done.${NOCOLOR}"
else
    echo $ECHOFLAGS "${RED}Failed. See ./build/logs.${NOCOLOR}"
fi

echo $ECHOFLAGS "Building the Markdown Library (shared / dynamic)... \c"
if dmd \
 ./source/md/*.d \
 ./source/md/flavors/*.d \
 ./source/md/terminals/*.d \
 -of./build/libraries/md-${VERSION}.so \
 -shared \
 -fPIC \
 -inline \
 -release \
 -O \
 -v >> ./build/logs/${TIMESTAMP}.log 2>&1; then
    echo $ECHOFLAGS "${GREEN}Done.${NOCOLOR}"
else
    echo $ECHOFLAGS "${RED}Failed. See ./build/logs.${NOCOLOR}"
fi

# NOTE:
# Supplying the -lphobos2 flag to the linker is a hard-coded feature of the DMD
# compiler. It is not specified in any configuration file.
# To compile other libraries in addition to Phobos, you must send both the -L
# and -l flags to the linker, indicating what folder to search, and what file
# to use, respectively.

echo $ECHOFLAGS "Building the Markdown Command-Line Tool, view-markdown... \c"
if dmd \
    -I./build/interfaces/source \
    -L./build/libraries/md-${VERSION}.a \
    ./source/tools/view_readme.d \
    -od./build/objects \
    -of./build/executables/view-markdown \
    -inline \
    -release \
    -O \
    -v >> ./build/logs/${TIMESTAMP}.log 2>&1; then
    echo $ECHOFLAGS "${GREEN}Done.${NOCOLOR}"
 chmod +x ./build/executables/view-markdown
else
    echo $ECHOFLAGS "${RED}Failed. See ./build/logs.${NOCOLOR}"
fi

mv *.lst ./build/logs 2>/dev/null
mv *.map ./build/maps 2>/dev/null