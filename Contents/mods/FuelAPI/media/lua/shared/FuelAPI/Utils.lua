local function SplitString(str, delimiter)
    local result = {};
    for match in (str..delimiter):gmatch("(.-)%"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local Utils = {};

function Utils.GetSandboxFuelTransferSpeed()
    local value = 25;
    if SandboxVars.FuelAPI then
        local option = tonumber(SandboxVars.FuelAPI.FuelTransferSpeed);
        if option == 1 then
            value = 50;
        elseif option == 2 then
            value = 25;
        elseif option == 3 then
            value = 10;
        end
    end
    return value;
end

function Utils.GetSandboxBarrelDefaultQuantity()
    local value = 400;
    if SandboxVars.FuelAPI then
        value = tonumber(SandboxVars.FuelAPI.BarrelDefaultQuantity);
    end
    return value;
end

function Utils.GetSandboxCanPickupFullBarrel()
    local value = false;
    if SandboxVars.FuelAPI then
        value = SandboxVars.FuelAPI.CanPickupFullBarrel == 2;
    end
    return value;
end
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
    local diff = customCapacity / 10; --- Tread 1/0.125 into 10 - As it was fuelling/siphoning was strange. Sometimes you took/added +- 1 unit. For example tank got -4, item got +3. After pouring back tank got +4, item -3. In the end it worked ... but seemed like items and veh. parts used different units.
    return Vehicles.JerryCanLitres * diff;
end

--[[	--------- Tread - redone those functions into one with tag parameter - more flexibility --------
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
]]--
---@param item InventoryItem
function Utils.GetItemFromTypeTag(item, fuelType) --- redone grabbing by petrol tag into universal one
    local tags = item:getTags();
    for i=0, tags:size()-1 do
        local tag = tags:get(i);
        local splitted = SplitString(tag, "_");
        if splitted and #splitted == 3 and splitted[1] == fuelType then 
            return splitted[2] .. "." .. splitted[3];
        end;
    end
end

---------------------------------Tread --------- additions
function Utils.GetItemFuelType(item) --- Check Item Fuel Type (by tags) - Tread
    local tags = item:getTags();
    for i=0, tags:size()-1 do
        local tag = tags:get(i);
        local splitted = SplitString(tag, "_");
        if splitted and #splitted == 2 and splitted[1] == "FuelType" then 
            return splitted[2];
        end;
    end
	return false;
end

function Utils.GetFirstFuelMatch(itemsList, fuelType)
	for _, item in ipairs(itemsList) do
		if Utils.GetItemFuelType(item) == fuelType then return item end
	end
	return false
end

---@param item InventoryItem
function Utils.PredicateNotEmptyPetrol(item)
    return Utils.IsCustom(item) and instanceof(item, "DrainableComboItem") and item:getUsedDelta() > 0 and Utils.GetItemFuelType(item) == "Gasoline";
end

function Utils.FilterItemsByTag(itemList, Tag)
    local result = {}
    for i = 0, itemList:size() - 1 do
        ---@type InventoryItem
        local item = itemList:get(i)
        if item:getTags():contains(Tag) then
            table.insert(result, item)
        end
    end
    return result
end

function Utils.PredicatePropaneTankNotEmpty(item)
    return item:hasTag("FuelType_LPG") and item:getUsedDelta() > 0;
end

function Utils.PredicatePropaneTankNotFull(item)
    return item:hasTag("FuelType_LPG") and item:getUsedDelta() < 1;
end

return Utils;
