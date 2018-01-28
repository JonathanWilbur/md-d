import md.flavors.github;
import std.file : readText, exists, isFile, FileException;
import std.stdio : writeln;
import std.utf : UTFException;

int main (string[] args)
{
    if (args.length != 2)
    {
        writeln("You must specify a markdown file to parse.");
        return 1;
    }

    if (!exists(args[1]))
    {
        writeln("No such file.");
        return 1;
    }

    if (!isFile(args[1]))
    {
        writeln("The specified object is not a file.");
        return 1;
    }

    string readme;
    try
    {
        readme = readText(args[1]);
    }
    catch (FileException fe)
    {
        writeln("File cannot be opened or read. Markdown processing aborted.");
    }
    catch (UTFException utfe)
    {
        writeln("UTF decoding error while trying to open file. Markdown processing aborted.");
    }

    version (Windows)
    {
        import core.sys.windows.windows;
        SetConsoleMode(GetStdHandle(cast(short) -11), 0x0007);
    }

    writeln(GitHubMarkdownParser.toANSITerminalOutput(readme));
    return 0;
}