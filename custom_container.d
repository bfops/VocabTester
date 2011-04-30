module custom_container;

//Return a copy of [array] with an un-stabley deleted [index] element.
//Swaps the element to be deleted with the last element, then reduces the length by 1.
T[] deleteArrayIndex(T)(in T[] array, ulong index)
{
    assert(index < array.length);

    if(array.length == 1)
        return [];

    auto ret = array[0 .. $ - 1].dup;

    //If we're removing anything but the last element.
    if(index < ret.length)
        ret[index] = array[$ - 1];

    return ret;
}
