require 'ISUI/ISWorldObjectContextMenu';

local Utils = require("FuelAPI/Utils");

local FuelTypesModActive = nil
if getActivatedMods():contains("TreadsFuelTypesFramework") then FuelTypesModActive = true end --- check if my mod is active - Tread

local ISWorldObjectContextMenu_fetch = ISWorldObjectContextMenu.fetch;
ISWorldObjectContextMenu.fetch = function(v, player, doSquare, ...)
    ISWorldObjectContextMenu_fetch(v, player, doSquare, ...);

    local playerObj = getSpecificPlayer(player);
    ---@type ItemContainer
    local playerInv = playerObj:getInventory();

    if v:getPipedFuelAmount() > 0 and (playerInv:containsEvalRecurse(Utils.PredicateEmpty) or playerInv:containsEvalRecurse(Utils.PredicateNotFull)) then
        haveFuel = v;
    end
	
	-----------Tread -- another overwriting of haveFuel objects - skip ones with custom fuel
	if haveFuel then --- gets rid of default "take fuel from pump" option
		haveFuelAPI = haveFuel
		haveFuel = nil
	end
	if haveFuelAPI and haveFuelAPI:getModData().RSFuelType ~= nil then --- custom Fuel Objects have no Fuel Pump menu
		haveFuelAPI = nil
	end
	--------------------------------------
end

----------------Tread -- added clear fetch to clear custom haveFuelAPI -----
local ISWorldObjectContextMenu_clearFetch = ISWorldObjectContextMenu.clearFetch;
ISWorldObjectContextMenu.clearFetch  = function()
	ISWorldObjectContextMenu_clearFetch();
	haveFuelAPI = nil;
end
----------------------------------------------------------------------------


local ISWorldObjectContextMenu_createMenu = ISWorldObjectContextMenu.createMenu;
function ISWorldObjectContextMenu.createMenu(player, worldobjects, x, y, test, ...)
    local context = ISWorldObjectContextMenu_createMenu(player, worldobjects, x, y, test, ...);

    if test == true then return true; end

    local playerObj = getSpecificPlayer(player);
    ---@type ItemContainer
    local playerInv = playerObj:getInventory();

    local fuelItem = playerInv:getFirstEvalRecurse(Utils.PredicateNotEmptyPetrol); --- Tread - look for gasoline items only

    --- Add fuel to generator
    if context and generator then
        local option = context:getOptionFromName(getText("ContextMenu_GeneratorAddFuel"));
        if not option and fuelItem and not generator:isActivated() and generator:getFuel() < 100 then
            context:addOptionOnTop(getText("ContextMenu_GeneratorAddFuel"), worldobjects, ISWorldObjectContextMenu.onAddFuel, fuelItem, generator, player);
        end
    end

    --- Burn corpse
    local corpse = IsoObjectPicker.Instance:PickCorpse(x, y) or body;
    if context and corpse then
        local option = context:getOptionFromName(getText("ContextMenu_Burn_Corpse")); --- there was a mistake here, I changed GeneratorAddFuel -> Burn Corpse - Tread
        if not option and fuelItem and (playerInv:containsTypeRecurse("Lighter") or playerInv:containsTypeRecurse("Matches")) then
            context:addOptionOnTop(getText("ContextMenu_Burn_Corpse"), worldobjects, ISWorldObjectContextMenu.onBurnCorpse, player, corpse);
        end
    end
	
	--- Tread -- Take fuel from pump - custom options (for different fuel types) -- could be gated behind active mods check
	if haveFuelAPI and ((SandboxVars.AllowExteriorGenerator and haveFuelAPI:getSquare():haveElectricity()) or (SandboxVars.ElecShutModifier > -1 and GameTime:getInstance():getNightsSurvived() < SandboxVars.ElecShutModifier)) then
		local fuelCans = playerInv:getAllEvalRecurse(Utils.PredicateNotFull)	
		for _, fuelType in pairs(FuelTypesTableRS["All"]) do --- Tread - add menu option per every Fuel Type
			local fuelTypeCans = {}
			if fuelType ~= "LPG" then	--- Tread - special items for Propane
				fuelTypeCans = Utils.FilterItemsByTag(fuelCans, ("FuelType_" .. fuelType))
				if not fuelTypeCans or #fuelTypeCans < 1 then
					fuelTypeCans[1] = playerInv:getFirstEvalRecurse(Utils.PredicateEmptyWithBase);
				end
			elseif not FuelTypesModActive or UtilsRS.PropaneOnGasStations() == 1 then --- Allow "fuelling" Propane Tanks if my mod is off or has proper setting 
				fuelTypeCans[1] = playerInv:getFirstEvalRecurse(Utils.PredicatePropaneTankNotFull);
			end	
			if fuelTypeCans and #fuelTypeCans >=1 then
				local PumpText = getText("ContextMenu_TakeGasFromPump");
				if FuelTypesModActive then
					PumpText = string.format(getText("IGUI_RS_PumpSiphonFrom"), getText("IGUI_RSFuelType_" .. fuelType)) --- Change text if using my mod - Tread
				elseif fuelType ~= "Gasoline" then
					PumpText = PumpText .. " - " .. fuelType	
				end
				context:addOptionOnTop(PumpText, worldobjects, ISWorldObjectContextMenu.onTakeFuel, playerObj, haveFuelAPI, fuelType);
			end
		end
	end
	-------------------------------------------------------------------------------------------
    return context;
end

local ISWorldObjectContextMenu_onTakeFuel = ISWorldObjectContextMenu.onTakeFuel;
function ISWorldObjectContextMenu.onTakeFuel(worldobjects, playerObj, fuelStation, fuelType, ...) --- Tread added fuel type
    ---@type ItemContainer
    local inventory = playerObj:getInventory();
	if fuelType == nil then fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
    -- Prefer an equipped EmptyPetrolCan/PetrolCan, then the fullest PetrolCan, then any EmptyPetrolCan.
    local petrolCan = nil
    local equipped = playerObj:getPrimaryHandItem()
    if equipped and equipped:getTags():contains("CustomFuelContainer") and instanceof(equipped, "DrainableComboItem") and fuelType == Utils.GetItemFuelType(equipped) then
        petrolCan = equipped
    elseif equipped and equipped:getTags():contains("CustomFuelContainer") and not instanceof(equipped, "DrainableComboItem") then
        petrolCan = equipped
    end

    if not petrolCan then
        local cans = inventory:getAllEvalRecurse(Utils.PredicateNotFull)
		cans = Utils.FilterItemsByTag(cans, ("FuelType_" .. fuelType))  --- Tread - Include Tag requirement
        local usedDelta = -1
		for i=1, #cans do ---# instead of :size() - Tread
			local petrolCan2 = cans[i] --- i-1 into i - Tread
			if petrolCan2:getUsedDelta() < 1 and petrolCan2:getUsedDelta() > usedDelta then
				petrolCan = petrolCan2
				usedDelta = petrolCan:getUsedDelta()
			end
		end
    end
    if not petrolCan then
        petrolCan = inventory:getFirstEvalRecurse(Utils.PredicateEmpty);
    end
	
	if fuelType == "LPG" then petrolCan = inventory:getFirstEvalRecurse(Utils.PredicatePropaneTankNotFull) end  --- Overwrite IF LPG - Tread
	
    if petrolCan and luautils.walkAdj(playerObj, fuelStation:getSquare()) then
        ISInventoryPaneContextMenu.equipWeapon(petrolCan, false, false, playerObj:getPlayerNum());
        ISTimedActionQueue.add(ISTakeFuel:new(playerObj, fuelStation, petrolCan, 100, fuelType));  --- Tread - added fuelType
    else
        return ISWorldObjectContextMenu_onTakeFuel(worldobjects, playerObj, fuelStation, ...);
    end
end

local ISWorldObjectContextMenu_onBurnCorpse = ISWorldObjectContextMenu.onBurnCorpse;
function ISWorldObjectContextMenu.onBurnCorpse(worldobjects, player, corpse, ...)
    local burnStart = false;
    local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory();
    if corpse:getSquare() and luautils.walkAdj(playerObj, corpse:getSquare()) then
        if playerInv:containsTypeRecurse("Lighter") then
            ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), playerInv:getFirstTypeRecurse("Lighter"), true, false);
        elseif playerObj:getInventory():containsTypeRecurse("Matches") then
            ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), playerInv:getFirstTypeRecurse("Matches"), true, false);
        end
        ISWorldObjectContextMenu.equip(playerObj, playerObj:getSecondaryHandItem(), playerInv:getFirstEvalRecurse(Utils.PredicateNotEmptyPetrol), false, false); --- Tread - look for gasoline items only
        ISTimedActionQueue.add(ISBurnCorpseAction:new(playerObj, corpse, 110));
        burnStart = true;
    end

    if not burnStart then
       return ISWorldObjectContextMenu_onBurnCorpse(worldobjects, player, corpse, ...);
    end
end
