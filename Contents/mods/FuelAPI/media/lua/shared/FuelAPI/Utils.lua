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

function Utils.GetSandboxBarrelRandomQuantity()
    local value = false;
    if SandboxVars.FuelAPI then
        value = SandboxVars.FuelAPI.BarrelRandomQuantity;
    end
    return SandboxVars.FuelAPI.BarrelRandomQuantity;
end

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
