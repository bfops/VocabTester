module vocab_tester;

import std.stream, std.string, std.stdio, std.algorithm;
import custom_container, custom_random;

private
{
    struct DictionaryEntry
    {
        string term1;
        string term2;
    }

    //Tells what [term1] represents, and what [term2] represents.
    alias DictionaryEntry Legend;
    alias DictionaryEntry[] Dictionary;

    immutable seperator = " | ";

    //Undefined behaviour for invalid lines.
    private DictionaryEntry parseLine(string line)
    {
        assert(isValidLine(line));

        const seperatorIndex = indexOf(line, seperator);
        assert(seperatorIndex != -1);

        DictionaryEntry ret = { line[0..seperatorIndex], line[seperatorIndex + seperator.length..$] };
        return ret;
    }

    //Returns true iff [line] defines a valid dictionary entry.
    bool isValidLine(string line)
    {
        return indexOf(line, seperator) != -1;
    }

    DictionaryEntry getQAndA(in DictionaryEntry entry)
    {
        if(rand() % 2 == 0)
            return entry;

        return DictionaryEntry(entry.term2, entry.term1);
    }
}

Dictionary parseDictionary(BufferedStream input)
{
    Dictionary dictionary;

    foreach(char[] line; input)
    {
        const string strLine = line.idup;
        if(isValidLine(strLine))
            dictionary ~= parseLine(strLine);
    }

    return dictionary;
}

void vocabTest(Dictionary dictionary)
{
    if(dictionary.length == 0)
        return;

    const index = rand() % dictionary.length;

    const entry = dictionary[index];
    const qAndA = getQAndA(entry);

    writeln(qAndA.term1);
    readln();
    writeln(qAndA.term2);
    writeln();

    vocabTest(deleteArrayIndex(dictionary, index));
}
