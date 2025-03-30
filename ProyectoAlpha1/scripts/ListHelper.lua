function listHasValue(list, value)

    for _, item in ipairs(list) do
        if (item == value) then return true end
    end

    return false
end

function listIsEmpty(list)
    for _, item in ipairs(list) do
        return false
    end
    return true
end