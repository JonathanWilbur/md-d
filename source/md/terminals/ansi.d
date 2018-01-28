/**
    A class representing an ANSI Terminal, which includes the ANSI control characters.

    Windows cmd.exe does not support:
    $(UL
        $(LI strikethrough)
        $(LI bold)
        $(LI italic)
    )
*/
module md.terminals.ansi;

///
public alias ANSITerminal = AmericanNationalStandardsInstituteTerminal;
///
public
class AmericanNationalStandardsInstituteTerminal
{
    public static
    enum escapes : string
    {
        reset = "\x1B[0m",
        bold = "\x1B[1m",
        faint = "\x1B[90m",
        italic = "\x1B[3m",
        underline = "\x1B[4m",
        negative = "\x1B[7m",
        strikethrough = "\x1B[9m",
        normal = "\x1B[22m",
        blackText = "\x1B[30m",
        redText = "\x1B[91m",
        greenText = "\x1B[32m",
        yellowText = "\x1B[33m",
        blueText = "\x1B[34m",
        magentaText = "\x1B[35m",
        cyanText = "\x1B[36m",
        whiteText = "\x1B[97m",
        blackBackground = "\x1B[40m",
        redBackground = "\x1B[41m",
        greenBackground = "\x1B[42m",
        yellowBackground = "\x1B[43m",
        blueBackground = "\x1B[44m",
        magentaBackground = "\x1B[45m",
        cyanBackground = "\x1B[46m",
        whiteBackground = "\x1B[107m"
    }
}