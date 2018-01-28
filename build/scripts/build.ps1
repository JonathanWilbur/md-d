mkdir .\documentation 2>&1 | Out-Null
mkdir .\documentation\html 2>&1 | Out-Null
mkdir .\documentation\links 2>&1 | Out-Null
mkdir .\build 2>&1 | Out-Null
mkdir .\build\assemblies 2>&1 | Out-Null
mkdir .\build\executables 2>&1 | Out-Null
mkdir .\build\interfaces 2>&1 | Out-Null
mkdir .\build\libraries 2>&1 | Out-Null
mkdir .\build\logs 2>&1 | Out-Null
mkdir .\build\maps 2>&1 | Out-Null
mkdir .\build\objects 2>&1 | Out-Null
mkdir .\build\scripts 2>&1 | Out-Null

$version = "0.1.0"

Write-Host "Building the Markdown Library (static)... " -NoNewLine
dmd `
 .\source\macros.ddoc `
 .\source\md\interfaces.d `
 .\source\md\terminals\ansi.d `
 .\source\md\flavors\common.d `
 .\source\md\flavors\github.d `
 .\source\md\flavors\stackoverflow.d `
 -Dd".\\documentation\\html\\" `
 -Hd".\\build\\interfaces" `
 -op `
 -of".\\build\\libraries\\md-$version.a" `
 -Xf".\\documentation\\md-$version.json" `
 -lib `
 -O `
 -release `
 -d
Write-Host "Done." -ForegroundColor Green

Write-Host "Building the Markdown Library (shared / dynamic)... " -NoNewLine
dmd `
 .\source\md\interfaces.d `
 .\source\md\terminals\ansi.d `
 .\source\md\flavors\common.d `
 .\source\md\flavors\github.d `
 .\source\md\flavors\stackoverflow.d `
 -of".\\build\\libraries\\md-$version.dll" `
 -lib `
 -shared `
 -O `
 -inline `
 -release `
 -d
Write-Host "Done." -ForegroundColor Green

Write-Host "Building the Markdown Command-Line Tool, view-markdown... " -NoNewLine
dmd `
 -I".\\build\\interfaces\\source" `
 .\source\tools\view_markdown.d `
 -L+".\\build\\libraries\\md-$version.a" `
 -od".\\build\\objects" `
 -of".\\build\\executables\\view-markdown" `
 -O `
 -release `
 -inline `
 -d
Write-Host "Done." -ForegroundColor Green