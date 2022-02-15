local Utils = require("FuelAPI/Utils");
local AddFuelCustomObject = require("FuelAPI/AddFuelCustomObject");

------------ Tread's Fuel Types Framework - Addition ---------------

FuelTypesTableRS = FuelTypesTableRS or {}
FuelTypesTableRS["Gasoline"] =  {"Gasoline"}

local FuelTypesModActive = nil
if getActivatedMods():contains("TreadsFuelTypesFramework") then FuelTypesModActive = true end --- check if my mod is active - Tread

if not FuelTypesModActive then	---if my mod is missing then
	--FuelTypesTableRS["Empty"] = {"Gasoline", "Diesel"}  --- initiate so "Empty" state of objects work properly
	--FuelTypesTableRS["All"] = {"Gasoline", "Diesel", "LPG"} --- All fuel types available from pump -- can be removed if we gate filling items from fuel pump behind active mods check
	FuelTypesTableRS["Empty"] = {"Gasoline"}  --- Add here custom fuel types as in examples above.
	FuelTypesTableRS["All"] = {"Gasoline"} --- Add here custom fuel types as in examples above.
end
	
-------------------------------------------------------------------

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
                    o.fuelCapacity = Utils.GetSandboxBarrelDefaultQuantity();
                else
                    o.fuelCapacity = tonumber(props:Val("fuelAmount"));
                end

                if modData and not modData.instanced then
                    modData.instanced = true;
                    modData.fuelAmount = -1; -- set empty & bypass randomization from game engine
					modData.RSFuelType = "Empty" --- Tread - added starting (empty) fuel type
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
		
		
		local FittingFuelTypes = FuelTypesTableRS[customFuelObject.isoObject:getModData().RSFuelType] --- list all eligible Fuel Types
        
		for _, fuelType in pairs(FittingFuelTypes) do --- Tread - add menu option per eligible Fuel Type
			local AddText = getText("ContextMenu_AddFuel")
			if FuelTypesModActive then
				AddText = string.format(getText("IGUI_RS_ObjectAddTo"), getText("IGUI_RSFuelType_" .. fuelType)) --- Change text if using my mod - Tread
			end
			--local fuelCanToAdd = playerInv:getFirstEvalRecurse(Utils.PredicateNotEmpty);		--- Tread 
			local fuelCanToAdd = playerInv:getFirstTagEvalRecurse(("FuelType_" .. fuelType), Utils.PredicateNotEmpty);					--- later I pick first with fitting fuel type
			if fuelCanToAdd and not customFuelObject:isFull() then
				context:addOptionOnTop(AddText, customFuelObject, CustomFuelObject.addFuelIntoObject, playerObj, fuelCanToAdd);
			end
		end
		
		--local fuelCanToTake = playerInv:getFirstEvalRecurse(Utils.PredicateNotFullWithBase);		--- Tread  
		local fuelCanToTake= playerInv:getFirstTagEvalRecurse(("FuelType_" .. FittingFuelTypes[1]), Utils.PredicateNotEmpty);	--- later I pick first with fitting fuel type
		if not fuelCanToTake then
			fuelCanToTake = playerInv:getFirstEvalRecurse(Utils.PredicateEmptyWithBase);
		end
		
		local TakeText = getText("ContextMenu_TakeGasFromPump")
		if FuelTypesModActive then
			TakeText = string.format(getText("IGUI_RS_ObjectSiphonFrom"), getText("IGUI_RSFuelType_" .. FittingFuelTypes[1])) --- Change text if using my mod - Tread
		end
		if fuelCanToTake and not customFuelObject:isEmpty() then
			local defaultOption = context:getOptionFromName(TakeText);
			if not defaultOption then
				context:addOptionOnTop(TakeText, worldobjects, ISWorldObjectContextMenu.onTakeFuel, playerObj, customFuelObject.isoObject, FittingFuelTypes[1]); --- added fuel type
			end
		end
		

        if customFuelObject then
            local fullName = customFuelObject:getFullName();
            local option = context:addOptionOnTop(fullName);
            local tooltip = ISToolTip:new();
            tooltip:setName(fullName);
			local BarrelFuelType = getText("ContextMenu_FuelName") 
			if FuelTypesModActive then
				BarrelFuelType = getText("IGUI_RSFuelType2_" .. customFuelObject.isoObject:getModData().RSFuelType) --- Tread - show fuel Type in tooltip
			end
            local tx = getTextManager():MeasureStringX(tooltip.font, BarrelFuelType .. ":") + 20; --- Tread - show fuel Type in tooltip
            local fuelAmount = customFuelObject:getFuelAmount();
            if fuelAmount == -1 then
                fuelAmount = 0;
            end
            tooltip.description = string.format("%s: <SETX:%d> %d / %d", BarrelFuelType, tx, fuelAmount, customFuelObject.fuelCapacity); --- Tread - show fuel Type in tooltip
            tooltip.maxLineWidth = 512;
            option.toolTip = tooltip;
        end
    end
end
Events.OnFillWorldObjectContextMenu.Add(onPreFillWorldObjectContextMenu);

-- Return the class for CustomFuelObject
return CustomFuelObject;										