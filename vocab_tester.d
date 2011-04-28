import std.stream, std.string, std.stdio, std.random, std.algorithm;

private
{
    struct DictionaryEntry
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

auto rand()
{
    return MinstdRand(unpredictableSeed).front;
}

void vocabTest(Dictionary dictionary)
{
    if(dictionary.length == 0)
        return;

    const index = rand() % dictionary.length;

    auto entry = dictionary[index];
    auto question = entry.term;
    auto answer = entry.definition;
    // 50% chance of asking the definition instead of the question.
    if(rand() % 2 == 1)
        swap(question, answer);

    writeln(question);
    readln();
    writeln(answer);
    writeln();

    vocabTest(dictionary[0..index] ~ dictionary[index + 1..$]);
}
