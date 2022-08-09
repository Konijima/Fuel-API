local Utils = require("FuelAPI/Utils");
local AddFuelIntoCustomObjectAction = require("FuelAPI/AddFuelIntoCustomObjectAction");

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

function CustomFuelObject:reset()
    local modData = self.isoObject:getModData();
    modData.instanced = false;
end

function CustomFuelObject:addFuelIntoObject(playerObj, fuelCan)
    if fuelCan and luautils.walkAdj(playerObj, self.isoObject:getSquare()) then
        ISInventoryPaneContextMenu.equipWeapon(fuelCan, false, false, playerObj:getPlayerNum());
        ISTimedActionQueue.add(AddFuelIntoCustomObjectAction:new(playerObj, self, fuelCan, 100));
    end
end

function CustomFuelObject:addAllFuelIntoObject(playerObj, fuelCans)
    if fuelCans:size() > 0 and luautils.walkAdj(playerObj, self.isoObject:getSquare()) then
        for i = 0, fuelCans:size() - 1 do
            local fuelCan = fuelCans:get(i);
            ISInventoryPaneContextMenu.equipWeapon(fuelCan, false, false, playerObj:getPlayerNum());
            ISTimedActionQueue.add(AddFuelIntoCustomObjectAction:new(playerObj, self, fuelCan, 100));
        end
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
                ---@type IsoObject
                o.isoObject = isoObject;
                o.groupName = props:Val("GroupName");
                o.customName = props:Val("CustomName");
                o.textureName = isoObject:getTextureName();

                if not props:Val("fuelAmount") then
                    o.fuelCapacity = SandboxVars.FuelAPI.BarrelMaxCapacity or 400;
                else
                    o.fuelCapacity = tonumber(props:Val("fuelAmount"));
                end

                if modData and not modData.instanced then
                    modData.instanced = true;
                    modData.fuelAmount = -1; -- set empty & bypass randomization from game engine
                    if SandboxVars.FuelAPI.BarrelRandomQuantityPercent ~= 0 then
                        local randomAmount = ZombRand( o.fuelCapacity * SandboxVars.FuelAPI.BarrelRandomQuantityPercent );
                        if randomAmount == 0 then randomAmount = -1; end
                        modData.fuelAmount = randomAmount;
                    end
                    isoObject:transmitModData();
                end
                return o;
            end
        end
    end

    return nil;
end

---@param context ISContextMenu
local function onFillWorldObjectContextMenu(player, context, worldobjects, test)
    if test then return; end

    --- Find a custom fuel object
    local customFuelObject;
    for _, isoObject in ipairs(worldobjects) do
        local obj = CustomFuelObject:new(isoObject);
        if obj then
            customFuelObject = obj;
            break;
        end
    end

    if not customFuelObject then return; end

    local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory();

    --- Create tooltip for fuel item
    local function addFuelTooltip(option, petrolcan)
        local tooltip = ISToolTip:new();
        tooltip:setName(petrolcan:getDisplayName());
        local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_FuelName") .. ":") + 20;
        local capacity = 1 / petrolcan:getUseDelta();
        local fuelAmount = capacity * petrolcan:getUsedDelta();
        if fuelAmount == -1 then fuelAmount = 0; end
        tooltip:setTexture(petrolcan:getTexture():getName());
        tooltip.description = string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_FuelName"), tx, fuelAmount, capacity);
        tooltip.maxLineWidth = 512;
        option.toolTip = tooltip;
    end

    --- Add Petrol Option
    local petroCans = playerInv:getAllEvalRecurse(Utils.predicatePetrol);
    if petroCans:size() == 1 then
        local petroCan = petroCans:get(0);
        local option = context:addOptionOnTop(getText("ContextMenu_AddFuel"), customFuelObject, CustomFuelObject.addFuelIntoObject, playerObj, petroCan);
        addFuelTooltip(option, petroCan);

    elseif petroCans:size() > 1 then
        local addFuelOption = context:addOptionOnTop(getText("ContextMenu_AddFuel"));
        local addFuelContext = ISContextMenu:getNew(context);
        context:addSubMenu(addFuelOption, addFuelContext);
        if petroCans:size() > 1 then
            addFuelContext:addOption(getText("ContextMenu_AddAllFuel"), customFuelObject, CustomFuelObject.addAllFuelIntoObject, playerObj, petroCans);
        end
        for i = 0, petroCans:size() - 1 do
            local petroCan = petroCans:get(i);
            local option = addFuelContext:addOption(petroCan:getDisplayName(), customFuelObject, CustomFuelObject.addFuelIntoObject, playerObj, petroCan);
            addFuelTooltip(option, petroCan);
        end
    end

    --- Take Petrol Option
    local defaultOption = context:getOptionFromName(getText("ContextMenu_TakeGasFromPump"));
    if not defaultOption then
        local emptyPetrolCans = playerInv:getAllEvalRecurse(Utils.predicateEmptyPetrolOrNotFull);
        if emptyPetrolCans:size() > 0 and customFuelObject and not customFuelObject:isEmpty() then
            local option = context:addOptionOnTop(getText("ContextMenu_TakeGasFromPump"), worldobjects, ISWorldObjectContextMenu.onTakeFuel, playerObj, customFuelObject.isoObject);
            addFuelTooltip(option, emptyPetrolCans:get(0));
        end
    end

    --- Custom Object Tooltip
    if customFuelObject then
        local fullName = Translator.getMoveableDisplayName(customFuelObject:getFullName());
        local option = context:addOptionOnTop(fullName);
        local tooltip = ISToolTip:new();
        tooltip:setName(fullName);
        local tx = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_FuelName") .. ":") + 20;
        local fuelAmount = customFuelObject:getFuelAmount();
        if fuelAmount == -1 then
            fuelAmount = 0;
        end
        tooltip:setTexture(customFuelObject.textureName);
        tooltip.description = string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_FuelName"), tx, fuelAmount, customFuelObject.fuelCapacity);
        tooltip.maxLineWidth = 512;
        option.toolTip = tooltip;

        if isDebugEnabled() then
            local function reset()
                customFuelObject:reset();
            end
            context:addOption("[DEBUG] Reset Barrel", nil, reset)
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(onFillWorldObjectContextMenu);

-- Return the class for CustomFuelObject
return CustomFuelObject;
