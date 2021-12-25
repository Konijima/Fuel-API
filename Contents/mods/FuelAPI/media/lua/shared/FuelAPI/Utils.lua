local function SplitString(str, delimiter)
    local result = {};
    for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local Utils = {};

function Utils.IsCustom(item)
    return item:getTags():contains("CustomFuelContainer");
end

---@param item InventoryItem
function Utils.PredicateNotEmpty(item)
    return Utils.IsCustom(item) and instanceof(item, "DrainableComboItem") and item:getUsedDelta() > 0;
end

---@param item InventoryItem
function Utils.PredicateNotEmptyWithBase(item)
    return Utils.PredicateNotEmpty(item) or (item:getFullType() == "Base.PetrolCan" and item:getUsedDelta() > 0);
end

---@param item InventoryItem
function Utils.PredicateNotFull(item)
    return Utils.IsCustom(item) and instanceof(item, "DrainableComboItem") and item:getUsedDelta() < 1;
end

---@param item InventoryItem
function Utils.PredicateNotFullWithBase(item)
    return Utils.PredicateNotFull(item) or item:getFullType() == "Base.PetrolCan" and item:getUsedDelta() < 1;
end

---@param item InventoryItem
function Utils.PredicateEmpty(item)
    return Utils.IsCustom(item) and not instanceof(item, "DrainableComboItem");
end

---@param item InventoryItem
function Utils.PredicateEmptyWithBase(item)
    return Utils.PredicateEmpty(item) or item:getFullType() == "Base.EmptyPetrolCan";
end

---@param item DrainableComboItem
function Utils.GetProperLitres(item)
    local customCapacity = 1 / item:getUseDelta();
    local diff = customCapacity / (1 / 0.125);
    return Vehicles.JerryCanLitres * diff;
end

---@param item InventoryItem
function Utils.GetEmptyItemFromTag(item)
    local tags = item:getTags();
    for i=0, tags:size()-1 do
        local tag = tags:get(i);
        local splitted = SplitString(tag, "_");
        if splitted and #splitted == 3 and splitted[1] == "Empty" then
            return splitted[2] .. "." .. splitted[3];
        end;
    end
end

---@param item InventoryItem
function Utils.GetPetrolItemFromTag(item)
    local tags = item:getTags();
    for i=0, tags:size()-1 do
        local tag = tags:get(i);
        local splitted = SplitString(tag, "_");
        if splitted and #splitted == 3 and splitted[1] == "Petrol" then
            return splitted[2] .. "." .. splitted[3];
        end;
    end
end

return Utils;
