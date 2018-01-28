@echo off
mkdir .\documentation > nul 2>&1
mkdir .\documentation\html > nul 2>&1
mkdir .\documentation\links > nul 2>&1
mkdir .\build > nul 2>&1
mkdir .\build\assemblies > nul 2>&1
mkdir .\build\executables > nul 2>&1
mkdir .\build\interfaces > nul 2>&1
mkdir .\build\libraries > nul 2>&1
mkdir .\build\logs > nul 2>&1
mkdir .\build\maps > nul 2>&1
mkdir .\build\objects > nul 2>&1
mkdir .\build\scripts > nul 2>&1

set version="0.1.0"

echo|set /p="Building the Markdown Library (static)... "
dmd ^
 .\source\macros.ddoc ^
 .\source\md\interfaces.d ^
 .\source\md\terminals\ansi.d ^
 .\source\md\flavors\common.d ^
 .\source\md\flavors\github.d ^
 .\source\md\flavors\stackoverflow.d ^
 -Dd.\documentation\html\ ^
 -Hd.\build\interfaces ^
 -op ^
 -of.\build\libraries\md-%version%.a ^
 -Xf.\documentation\md-%version%.json ^
 -lib ^
 -O ^
 -release ^
 -d
echo Done.

echo|set /p="Building the Markdown Library (shared / dynamic)... "
dmd ^
 .\source\md\interfaces.d ^
 .\source\md\terminals\ansi.d ^
 .\source\md\flavors\common.d ^
 .\source\md\flavors\github.d ^
 .\source\md\flavors\stackoverflow.d ^
 -of.\build\libraries\md-%version%.dll ^
 -lib ^
 -shared ^
 -O ^
 -inline ^
 -release ^
 -d
echo Done.

echo|set /p="Building the Markdown Command-Line Tool, view-markdown... "
dmd ^
 -I".\\build\\interfaces\\source" ^
 .\source\tools\view_markdown.d ^
 -L+".\\build\\libraries\\md-%version%.a" ^
 -od".\\build\\objects" ^
 -of".\\build\\executables\\view-markdown" ^
 -O ^
 -release ^
 -inline ^
 -d
echo Done.