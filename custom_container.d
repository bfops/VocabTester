module custom_container;

//Return a copy of [array] with an un-stabley deleted [index] element.
T[] deleteArrayIndex(T)(in T[] array, ulong index)
{
    assert(index < array.length);

    auto ret = array[0 .. $ - 1].dup;
    ret[index] = array[$ - 1];

    return ret;
}
