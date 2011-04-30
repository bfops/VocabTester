module vocab_tester;

import std.stream, std.string, std.stdio, std.algorithm;
import custom_container, custom_random;

private
{
    struct DictionaryEntry
    {
        //Under what section this entry is, in the dictionary.
        string category;
        string term1;
        string term2;
    }

    alias DictionaryEntry[] Dictionary;

    immutable string seperator = " | ";

    //Undefined behaviour for invalid lines.
    private DictionaryEntry parseLine(const string line, const string category)
    {
        assert(isValidLine(line));

        const seperatorIndex = indexOf(line, seperator);
        assert(seperatorIndex != -1);

        DictionaryEntry ret = { category, line[0..seperatorIndex], line[seperatorIndex + seperator.length..$] };
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

Dictionary parseDictionary(InputStream input)
{
    Dictionary dictionary;
    string category = "";

    foreach(char[] line; input)
    {
        const string strLine = line.idup;
        if(strLine.length > 2 && strLine[0..2] == "--")
            category = strLine[2..$];
        else if(isValidLine(strLine))
            dictionary ~= parseLine(category, strLine);
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

    write(qAndA.category);
    write(": ");
    writeln(qAndA.term1);
    readln();
    writeln(qAndA.term2);
    writeln();

    vocabTest(deleteArrayIndex(dictionary, index));
}
