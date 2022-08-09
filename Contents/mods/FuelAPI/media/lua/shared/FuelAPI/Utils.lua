local Utils = {};

function Utils.predicateEmptyPetrol(item)
    return item:hasTag("EmptyPetrol") or item:getType() == "EmptyPetrolCan"
end

function Utils.predicatePetrol(item)
    return item:hasTag("Petrol") or item:getType() == "PetrolCan"
end

function Utils.predicatePetrolFull(item)
    return Utils.predicatePetrol(item) and item:getUsedDelta() >= 1;
end

function Utils.predicatePetrolNotFull(item)
    return Utils.predicatePetrol(item) and item:getUsedDelta() < 1;
end

function Utils.predicateEmptyPetrolOrNotFull(item)
    return Utils.predicateEmptyPetrol(item) or Utils.predicatePetrolNotFull(item);
end

return Utils;
