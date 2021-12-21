local function SplitString(str, delimiter)
    local result = {};
    for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local Utils = {};

---@param item InventoryItem
function Utils.PredicateNotEmpty(item)
    return item:getTags():contains("CustomFuelContainer") and instanceof(item, "DrainableComboItem") and item:getUsedDelta() > 0;
end

---@param item InventoryItem
function Utils.PredicateNotFull(item)
    return item:getTags():contains("CustomFuelContainer") and instanceof(item, "DrainableComboItem") and item:getUsedDelta() < 1;
end

---@param item InventoryItem
function Utils.PredicateEmpty(item)
    return item:getTags():contains("CustomFuelContainer") and not instanceof(item, "DrainableComboItem");
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
