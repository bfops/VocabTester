import std.stream, std.string, std.random;

private
{
    static struct DictionaryEntry
    {
        string term;
        string definition;
    }

    //TODO: Pick a more efficient data structure.
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
}

void vocabTest(BufferedStream input)
{
    auto dictionary = parseDictionary(input);
    auto rand = MinstdRand(unpredictableSeed);

    while(dictionary.length > 0)
    {
        const index = rand.front % dictionary.length;
        rand.popFront();

        auto entry = dictionary[index];

    }
}
