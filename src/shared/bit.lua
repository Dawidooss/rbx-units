local bit = {}

function bit:FromBits(bitArray)
    local result = 0

    for i = 1, #bitArray do
        result = result + bitArray[i] * 2^(#bitArray - i)
    end

    return result
end

function bit:ToBits(number, bits)
    local bin = {}
    bits = bits - 1
    while bits >= 0 do --As bit32.extract(1, 0) will return number 1 and bit32.extract(1, 1) will return number 0
                   --I do this in reverse order because binary should like that
        table.insert(bin, bit32.extract(number, bits))
        bits = bits - 1
    end
    return bin
end

return bit