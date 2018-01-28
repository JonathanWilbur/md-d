module md.flavors.github;
import md.interfaces;
import md.terminals.ansi;
import std.array : replace, split;
import std.ascii : isAlpha, isAlphaNum, isDigit, isWhite;
import std.conv : to;
import std.stdio : writeln;
import std.string : indexOf;

///
public
class GitHubMarkdownParser : MarkdownParser, ANSITerminalPrintable
{
    ///
    public static
    T toANSITerminalOutput(T)(in T markdown)
    if (isSomeString!T)
    {
        /*
            The prepended '\n' is intended to make the parsing done later on
            easier, because all lines can be guaranteed to start with a
            newline. (Otherwise, the first line does not.)
        */
        T[] stripes = ('\n' ~ markdown.replace("\r", "")).split("\n```");
        
        T output;
        for (size_t i = 0u; i < stripes.length; i++)
        {
            if (i % 2u)
            {
                size_t j = 0u;
                while (j++ < stripes[i].length) if (stripes[i][j] == '\n') break;
                output ~= (ANSITerminal.escapes.faint ~ stripes[i][j .. $] ~ ANSITerminal.escapes.reset ~ '\n');
            }
            else
            {
                output ~= GitHubMarkdownParser.convertNonCodeBlockMarkdownToANSITerminalOutput(stripes[i]);
            }
        }

        return output;
    }

    private static
    T convertNonCodeBlockMarkdownToANSITerminalOutput(T)(in T markdown)
    {
        T ret;
        for (size_t i = 1u; i < markdown.length; i++)
        {
            if (markdown[i] == '\\' && i+1 < markdown.length)
            {
                ret ~= markdown[++i];
                continue;
            }

            // For formatting characters that must appear at the start of a line
            if (markdown[i-1] == '\n')
            {
                ret ~= ANSITerminal.escapes.reset;
                if (markdown[i] == '\n')
                {
                    ret ~= markdown[i];
                    GitHubMarkdownParser.orderedListNumbers = [];
                    continue;
                }

                // Section Header
                if (markdown[i] == '#')
                {
                    i++;
                    GitHubMarkdownParser.headerLevel = 1u;
                    while (i < markdown.length && markdown[i++] == '#')
                    {
                        /* NOTE:
                            Yes, headerLevel absolutely can overflow, but
                            it is not used for range indexing, so if some
                            dumbass wants to create a markdown file with 256
                            leading octothorpes before a section header only for
                            it to appear as an <h1> upon rendering, be my guest.
                        */
                        GitHubMarkdownParser.headerLevel++;
                    }

                    ret ~= (
                        ANSITerminal.escapes.whiteBackground ~ " " ~ 
                        ANSITerminal.escapes.reset ~ 
                        ANSITerminal.escapes.underline
                    );

                    while (i < markdown.length && markdown[i] == ' ') i++;
                    while (i < markdown.length && markdown[i] != '\n') ret ~= markdown[i++];
                    ret ~= '\n';
                    continue;
                }

                // Blockquote
                if (markdown[i] == '>')
                {
                    i++;
                    ret ~= ANSITerminal.escapes.faint;
                    while (i < markdown.length && markdown[i] == ' ') i++;
                    while (i < markdown.length && markdown[i] != '\n') ret ~= markdown[i++];
                    ret ~= '\n';
                    continue;
                }

                // Unordered List
                if (markdown[i] == '*' || markdown[i] == '-')
                {
                    ret ~= ANSITerminal.escapes.reset;
                    ret ~= markdown[i];
                    continue;
                }
                if (markdown[i] == ' ' || markdown[i] == '\t')
                {
                    size_t j = i;
                    while (j < markdown.length && (markdown[j] == ' ' || markdown[j] == '\t'))
                        if (markdown[j++] == '\n') break;
                    if (markdown[j] == '*' || markdown[j] == '-')
                    {
                        ret ~= ANSITerminal.escapes.reset;
                        ret ~= markdown[i];
                        continue;
                    }
                }
            }

            if (markdown[i] == '`' && markdown[i-1] != '\\')
            {
                i++;
                ret ~= (ANSITerminal.escapes.reset ~ ANSITerminal.escapes.faint);
                while
                (
                    i < markdown.length && 
                    (
                        markdown[i] != '`' || 
                        (
                            markdown[i] == '`' && 
                            markdown[i-1] == '\\'
                        )
                    )
                )
                    ret ~= markdown[i++];
                i++;
                ret ~= ANSITerminal.escapes.reset;
                // TODO: Re-apply styles
            }

            // Ordered List
            if
            (
                markdown[i].isDigit &&
                markdown.startsLineWithOnlyWhiteSpaceUntil(i)
            )
            {
                ptrdiff_t nextPeriod = markdown.indexOf(".", i);
                if (nextPeriod != -1)
                {
                    bool allDigitsUntilPeriod = true;
                    for (ptrdiff_t x = i; x < nextPeriod; x++)
                    {
                        if (!markdown[x].isDigit)
                        {
                            allDigitsUntilPeriod = false;
                            break;
                        }
                    }

                    if (allDigitsUntilPeriod) // Then it's an ordered list!
                    {
                        ret ~= ANSITerminal.escapes.reset;

                        // REVIEW: How will this deal with odd number of spaces?
                        int indentation = leadingSpaces(markdown, i) / 2;
                        // if (orderedListNumbers.length < indentation+1)
                        orderedListNumbers.length = indentation+1;
                        GitHubMarkdownParser.orderedListNumbers[indentation]++;
                        i = (cast(int) nextPeriod + 1);
                        while (i+1 < markdown.length && (markdown[i] == ' ' || markdown[i] == '\t')) i++;
                        ret ~= (to!string(GitHubMarkdownParser.orderedListNumbers[indentation]) ~ ".\t");
                    }
                }
            }

            if (markdown[i] == '_' && (i+1 < markdown.length))
            {
                // Bold
                if (markdown[++i] == '_')
                {
                    i++;
                    ret ~= ANSITerminal.escapes.reset;
                    ret ~= ANSITerminal.escapes.redText;
                    while (i < markdown.length-1 && !(markdown[i] == '_' && markdown[i+1] == '_')) ret ~= markdown[i++];
                    i++;
                }
                else // Italic
                {
                    ret ~= ANSITerminal.escapes.reset;
                    ret ~= ANSITerminal.escapes.yellowText;
                    while (i < markdown.length && !(markdown[i] == '_')) ret ~= markdown[i++];
                }
                ret ~= ANSITerminal.escapes.reset;
                continue;
            }

            if (markdown[i] == '*' && (i+1 < markdown.length))
            {
                ret ~= ANSITerminal.escapes.reset;
                // Bold
                if (markdown[++i] == '*')
                {
                    i++;
                    ret ~= ANSITerminal.escapes.redText;
                    while (i < markdown.length-1 && !(markdown[i] == '*' && markdown[i+1] == '*')) ret ~= markdown[i++];
                    i++;
                }
                else // Italic
                {
                    ret ~= ANSITerminal.escapes.yellowText;
                    while (i < markdown.length && !(markdown[i] == '*')) ret ~= markdown[i++];
                }
                ret ~= ANSITerminal.escapes.reset;
                continue;
            }

            if (i < markdown.length-2 && markdown[i] == '~' && markdown[i+1] == '~')
            {
                i += 2u;
                ret ~= (ANSITerminal.escapes.reset ~ ANSITerminal.escapes.faint ~ '-');
                while (i < markdown.length-1 && !(markdown[i] == '~' && markdown[i+1] == '~'))
                    ret ~= (markdown[i++] ~ "-");
                i += 2u;
                ret ~= ANSITerminal.escapes.reset;
            }

            /* NOTE:
                A closing parenthesis could appear in a valid URI. This code
                just assumes the URI is terminated with the first parenthesis
                encountered. It also assumes that there is an opening square
                bracket earlier.
            */
            if (i < markdown.length-5 && markdown[i] == ']' && markdown[i+1] == '(')
            {
                ret ~= "](";
                i += 2u;
                ret ~= (ANSITerminal.escapes.reset ~ ANSITerminal.escapes.blueText ~ ANSITerminal.escapes.underline);
                while (i < markdown.length && markdown[i] != ')') ret ~= markdown[i++];
                ret ~= ANSITerminal.escapes.reset;
            }

            // Mentions
            if (i < markdown.length-2 && markdown[i] == '@' && markdown[i-1].isWhite)
            {
                ret ~= (ANSITerminal.escapes.reset ~ ANSITerminal.escapes.cyanText ~ markdown[i++]);
                while 
                (
                    i < markdown.length &&
                    (
                        markdown[i].isAlphaNum ||
                        markdown[i] == '_'
                    )
                )
                    ret ~= markdown[i++];
                ret ~= ANSITerminal.escapes.reset;
            }

            // Hashtags
            if (i < markdown.length-2 && markdown[i] == '#' && markdown[i-1].isWhite && markdown[i+1].isAlpha)
            {
                ret ~= (ANSITerminal.escapes.reset ~ ANSITerminal.escapes.greenText ~ markdown[i++]);
                while 
                (
                    i < markdown.length &&
                    (
                        markdown[i].isAlphaNum ||
                        markdown[i] == '_'
                    )
                )
                    ret ~= markdown[i++];
                ret ~= ANSITerminal.escapes.reset;
            }

            ret ~= markdown[i];
        }

        while (ret.indexOf("\n\n\n") != -1) ret = ret.replace("\n\n\n", "\n\n");
        version(emojis)
        {
            // TODO: Put more emojis here.
            ret = ret.replace(":smile:", "\u263A");
        }

        return ret;
    }
}

private
bool startsLineWithOnlyWhiteSpaceUntil(in string s, int x)
{
    if (s[x-1] == '\n') return true;
    while (x-1 > 0 && (s[x-1] == ' ' || s[x-1] == '\t')) x--;
    return (s[x-1] == '\n');
}

private
int leadingSpaces(in string s, int x)
{
    int spacesCounted = 0;
    while (x-1 > 0 && (s[x-1] == ' ' || s[x-1] == '\t'))
    {
        x--;
        spacesCounted++;
    }
    return spacesCounted;
}