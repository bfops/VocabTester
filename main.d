import std.stdio, std.file, std.stream;
import vocab_tester;

void main(string[] args)
{
    if(args.length <= 1)
    {
        writeln("No input file given. Quitting.");
        return;
    }

    auto filename = args[1];

    if(!exists(filename))
    {
        writeln("Input file doesn't exist. Quitting.");
        return;
    }

    vocabTest(parseDictionary(new BufferedFile(filename)));
}
