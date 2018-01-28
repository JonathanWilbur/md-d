module md.interfaces;
public import std.traits : isSomeString;

// TODO: Scrub control characters
// TODO: http://spec.commonmark.org/0.28/

// REVIEW: Is this ever used?
///
public
enum ParsingState
{
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    link,
    blockquote,
    italic1, // * *
    italic2, // _ _
    bold1, // ** **
    bold2, // __ __
    strikethrough,
    orderedList,
    unorderedList,
    taskList,
    inlineCode,
    codeBlock,
    emoji,
    username,
    tableHeader,
    tableRow,
    image
}

///
public abstract
class MarkdownParser
{
    immutable size_t maximumMarkdownSizeInBytes = 500000u;
    protected static size_t[] orderedListNumbers;
    protected static ubyte headerLevel = 0u;
    private ParsingState[] stateStack;
    // private Style[] queuedStyles;

    // ///
    // public static string convertToANSITerminalOutput(T)(T markdown)
    // if (isSomeString!T);
}

///
public alias ANSITerminalPrintable = AmericanNationalStandardsInstituteTerminalPrintable;
///
public
interface AmericanNationalStandardsInstituteTerminalPrintable
{
    ///
    public alias toANSITerminalOutput = toAmericanNationalStandardsInstituteTerminalOutput;
    ///
    public static
    string toAmericanNationalStandardsInstituteTerminalOutput(T)(T markdown)
    if (isSomeString!T);
}

///
public alias HTMLable = HyperTextMarkupLanguageable;
///
public
interface HyperTextMarkupLanguageable
{
    ///
    public alias toHTML = toHyperTextMarkupLanguage;
    ///
    public static
    string toHyperTextMarkupLanguage(T)(T markdown)
    if (isSomeString!T);
}