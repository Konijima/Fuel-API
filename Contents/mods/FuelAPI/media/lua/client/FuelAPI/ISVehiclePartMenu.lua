require 'Vehicles/ISUI/ISVehiclePartMenu';

local Utils = require("FuelAPI/Utils");

local ISVehiclePartMenu_getGasCanNotEmpty = ISVehiclePartMenu.getGasCanNotEmpty;
function ISVehiclePartMenu.getGasCanNotEmpty(playerObj, typeToItem, ...)
    local fuelItem = ISVehiclePartMenu_getGasCanNotEmpty(playerObj, typeToItem, ...);

    if not fuelItem then

        print("ISVehiclePartMenu_getGasCanNotEmpty");

        local equipped = playerObj:getPrimaryHandItem();
        if equipped and Utils.PredicateNotEmpty(equipped) then
            return equipped;
        end

        for fullType, items in pairs(typeToItem) do
            local gasCan = nil;
            local usedDelta = 1.1;
            for _,item in ipairs(typeToItem[fullType]) do
                if Utils.PredicateNotEmpty(item) and item:getUsedDelta() < usedDelta then
                    gasCan = item;
                    usedDelta = gasCan:getUsedDelta();
                end
            end
            if gasCan then return gasCan; end
        end

        return nil;

    else
        return fuelItem;
    end
end

local ISVehiclePartMenu_getGasCanNotFull = ISVehiclePartMenu.getGasCanNotFull;
function ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem, ...)
    local fuelItem = ISVehiclePartMenu_getGasCanNotFull(playerObj, typeToItem, ...);

    if not fuelItem then

        print("ISVehiclePartMenu_getGasCanNotFull");

        local equipped = playerObj:getPrimaryHandItem()
        if equipped and Utils.PredicateNotFull(equipped) then
            return equipped;
        elseif equipped and Utils.PredicateEmpty(equipped) then
            return equipped;
        end

        for fullType, items in pairs(typeToItem) do
            local gasCan = nil;
            local usedDelta = -1;
            for _,item in ipairs(typeToItem[fullType]) do
                if Utils.PredicateNotFull(item) and item:getUsedDelta() > usedDelta then
                    gasCan = item;
                    usedDelta = gasCan:getUsedDelta();
                end
            end
            if gasCan then return gasCan; end

            for _,item in ipairs(typeToItem[fullType]) do
                if Utils.PredicateEmpty(item) then
                    return item;
                end
            end
        end

        return nil;

    else
        return fuelItem;
    end
end