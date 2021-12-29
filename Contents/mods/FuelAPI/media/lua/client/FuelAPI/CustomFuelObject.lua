local Utils = require("FuelAPI/Utils");
local AddFuelCustomObject = require("FuelAPI/AddFuelCustomObject");

---@class CustomFuelObject
local CustomFuelObject = ISBaseObject:derive("CustomFuelObject");

function CustomFuelObject:getFullName()
    local fullName;
    if self.groupName then
        fullName = self.groupName .. "_" .. self.customName;
    else
        fullName = self.customName;
    end

    if fullName == getText(fullName) then
        if self.groupName then
            return self.groupName .. " " .. self.customName;
        else
            return self.customName;
        end
    else
        return getText(fullName);
    end

end

function CustomFuelObject:setFuelAmount(amount)
    local modData = self.isoObject:getModData();
    if amount == 0 then amount = -1 end
    modData.fuelAmount = amount;
    self.isoObject:transmitModData();
end

function CustomFuelObject:getFuelAmount()
    local modData = self.isoObject:getModData();
    return tonumber(modData.fuelAmount);
end

function CustomFuelObject:isFull()
    local modData = self.isoObject:getModData();
    return tonumber(modData.fuelAmount) >= tonumber(self.fuelCapacity);
end

function CustomFuelObject:isEmpty()
    local modData = self.isoObject:getModData();
    return not modData.fuelAmount or tonumber(modData.fuelAmount) <= 0;
end

function CustomFuelObject:addFuelIntoObject(playerObj, fuelCan)
    if fuelCan and luautils.walkAdj(playerObj, self.isoObject:getSquare()) then
        ISInventoryPaneContextMenu.equipWeapon(fuelCan, false, false, playerObj:getPlayerNum());
        ISTimedActionQueue.add(AddFuelCustomObject:new(playerObj, self, fuelCan, 100));
    end
end

---@param isoObject IsoObject
function CustomFuelObject:new(isoObject)
    local o = {};
    setmetatable(o, self);
    self.__index = self;

    if isoObject and instanceof(isoObject, "IsoObject") then
        local modData = isoObject:getModData();
        local sprite = isoObject:getSprite();
        if sprite then
            local props = sprite:getProperties();
            if props and props:Val("CustomName") == "Barrel" then
                o.groupName = props:Val("GroupName");
                o.customName = props:Val("CustomName");

                if not props:Val("fuelAmount") then
                    o.fuelCapacity = 400;
                else
                    o.fuelCapacity = tonumber(props:Val("fuelAmount"));
                end

                if modData and not modData.instanced then
                    modData.instanced = true;
                    modData.fuelAmount = -1; -- set empty & bypass randomization from game engine
                    isoObject:transmitModData();
                end

                ---@type IsoObject
                o.isoObject = isoObject;
                return o;
            end
        end
    end

    return nil;
end

---@param context ISContextMenu
local function onPreFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then return; end

    local customFuelObject;
    for i, isoObject in ipairs(worldobjects) do
        local obj = CustomFuelObject:new(isoObject);
        if obj then
            customFuelObject = obj;
            break;
        end
    end

    if customFuelObject then
        local playerObj = getSpecificPlayer(player);
        local playerInv = playerObj:getInventory();

        local fuelCanToAdd = playerInv:getFirstEvalRecurse(Utils.PredicateNotEmptyWithBase);
        if fuelCanToAdd and not customFuelObject:isFull() then
            context:addOptionOnTop(getText("ContextMenu_AddFuel"), customFuelObject, CustomFuelObject.addFuelIntoObject, playerObj, fuelCanToAdd);
        end

        local fuelCanToTake = playerInv:getFirstEvalRecurse(Utils.PredicateNotFullWithBase);
        if not fuelCanToTake then
            fuelCanToTake = playerInv:getFirstEvalRecurse(Utils.PredicateEmptyWithBase);
        end

        if fuelCanToTake and not customFuelObject:isEmpty() then
            local defaultOption = context:getOptionFromName(getText("ContextMenu_TakeGasFromPump"));
            if not defaultOption then
                context:addOptionOnTop(getText("ContextMenu_TakeGasFromPump"), worldobjects, ISWorldObjectContextMenu.onTakeFuel, playerObj, customFuelObject.isoObject);
            end
        end

        if customFuelObject then
            local fullName = customFuelObject:getFullName();
            local option = context:addOptionOnTop(fullName);
            local tooltip = ISToolTip:new();
            tooltip:setName(fullName);
            local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_FuelName") .. ":") + 20;
            local fuelAmount = customFuelObject:getFuelAmount();
            if fuelAmount == -1 then
                fuelAmount = 0;
            end
            tooltip.description = string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_FuelName"), tx, fuelAmount, customFuelObject.fuelCapacity);
            tooltip.maxLineWidth = 512;
            option.toolTip = tooltip;
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(onPreFillWorldObjectContextMenu);
