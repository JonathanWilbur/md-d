# Readme

* Author: [Jonathan M. Wilbur](https://jonathan.wilbur.space) <[jonathan@wilbur.space](mailto:jonathan@wilbur.space)>
* Copyright Year: 2018
* License: [MIT License](https://mit-license.org/)
* Version: [0.1.0](https://semver.org/)

Readme is a command line tool for reading GitHub-flavored Markdown, which is
intended to be a replacement for `man` pages. The author's aspiration is to
replace `man` pages with equivalent markdown pages.

## Command-Line Tool

The command line tool is `view-markdown`. You must supply the file to read
as the first argument like so:

```bash
view-markdown ./test/data/good/example.md
```

## Building and Installing

There are four scripts in `build/scripts` that help you build this library,
in addition to building using `dub`. If you are using Windows, you can build
by running `.\build\scripts\build.ps1` from PowerShell, or `.\build\scripts\build.bat`
from the traditional `cmd` shell. If you are on any POSIX-compliant(-ish)
operating system, such as Linux or Mac OS X, you may build this library using
`./build/scripts/build.sh` or `make -f ./build/scripts/posix.make`. The output
library will be in `./build/libraries`. The command-line tools will be in
`./build/executables`.

For more information on building and installing, see `documentation/install.md`.

## See Also

* [Mastering Markdown](https://guides.github.com/features/mastering-markdown/)
* [Wikipedia Page for Markdown](https://en.wikipedia.org/wiki/Markdown)
* [Wikipedia Page for Man Pages](https://en.wikipedia.org/wiki/Man_page)

## Contact Me

If you would like to suggest fixes or improvements on this library, please just
[leave an issue on this GitHub page](https://github.com/JonathanWilbur/asn1-d/issues). If you would like to contact me for other reasons,
please email me at [jonathan@wilbur.space](mailto:jonathan@wilbur.space)
([My GPG Key](https://jonathan.wilbur.space/downloads/jonathan@wilbur.space.gpg.pub))
([My TLS Certificate](https://jonathan.wilbur.space/downloads/jonathan@wilbur.space.chain.pem)). :boar: