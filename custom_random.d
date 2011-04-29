module custom_random;

public import std.random;

auto rand()
{
    return MinstdRand(unpredictableSeed).front;
}
