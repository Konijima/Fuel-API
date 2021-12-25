require 'ISUI/ISWorldObjectContextMenu';

local Utils = require("FuelAPI/Utils");

local ISWorldObjectContextMenu_fetch = ISWorldObjectContextMenu.fetch;
ISWorldObjectContextMenu.fetch = function(v, player, doSquare, ...)
    ISWorldObjectContextMenu_fetch(v, player, doSquare, ...);

    local playerObj = getSpecificPlayer(player);
    ---@type ItemContainer
    local playerInv = playerObj:getInventory();

    if v:getPipedFuelAmount() > 0 and (playerInv:containsEvalRecurse(Utils.PredicateEmpty) or playerInv:containsEvalRecurse(Utils.PredicateNotFull)) then
        haveFuel = v;
    end
end

local ISWorldObjectContextMenu_createMenu = ISWorldObjectContextMenu.createMenu;
function ISWorldObjectContextMenu.createMenu(player, worldobjects, x, y, test, ...)
    local context = ISWorldObjectContextMenu_createMenu(player, worldobjects, x, y, test, ...);

    if test == true then return true; end

    local playerObj = getSpecificPlayer(player);
    ---@type ItemContainer
    local playerInv = playerObj:getInventory();

    local fuelItem = playerInv:getFirstEvalRecurse(Utils.PredicateNotEmpty);

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
        local option = context:getOptionFromName(getText("ContextMenu_GeneratorAddFuel"));
        if not option and fuelItem and (playerInv:containsTypeRecurse("Lighter") or playerInv:containsTypeRecurse("Matches")) then
            context:addOptionOnTop(getText("ContextMenu_Burn_Corpse"), worldobjects, ISWorldObjectContextMenu.onBurnCorpse, player, corpse);
        end
    end

    return context;
end

local ISWorldObjectContextMenu_onTakeFuel = ISWorldObjectContextMenu.onTakeFuel;
function ISWorldObjectContextMenu.onTakeFuel(worldobjects, playerObj, fuelStation, ...)
    ---@type ItemContainer
    local inventory = playerObj:getInventory();

    -- Prefer an equipped EmptyPetrolCan/PetrolCan, then the fullest PetrolCan, then any EmptyPetrolCan.
    local petrolCan = nil
    local equipped = playerObj:getPrimaryHandItem()
    if equipped and equipped:getTags():contains("CustomFuelContainer") and instanceof(equipped, "DrainableComboItem") then
        petrolCan = equipped
    elseif equipped and equipped:getTags():contains("CustomFuelContainer") and not instanceof(equipped, "DrainableComboItem") then
        petrolCan = equipped
    end
    if not petrolCan then
        local cans = inventory:getAllEvalRecurse(Utils.PredicateNotFull)
        local usedDelta = -1
        for i=1,cans:size() do
            local petrolCan2 = cans:get(i-1)
            if petrolCan2:getUsedDelta() < 1 and petrolCan2:getUsedDelta() > usedDelta then
                petrolCan = petrolCan2
                usedDelta = petrolCan:getUsedDelta()
            end
        end
    end
    if not petrolCan then
        petrolCan = inventory:getFirstEvalRecurse(Utils.PredicateEmpty);
    end
    if petrolCan and luautils.walkAdj(playerObj, fuelStation:getSquare()) then
        ISInventoryPaneContextMenu.equipWeapon(petrolCan, false, false, playerObj:getPlayerNum());
        ISTimedActionQueue.add(ISTakeFuel:new(playerObj, fuelStation, petrolCan, 100));
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
        ISWorldObjectContextMenu.equip(playerObj, playerObj:getSecondaryHandItem(), playerInv:getFirstEvalRecurse(Utils.PredicateNotEmptyWithBase), false, false);
        ISTimedActionQueue.add(ISBurnCorpseAction:new(playerObj, corpse, 110));
        burnStart = true;
    end

    if not burnStart then
       return ISWorldObjectContextMenu_onBurnCorpse(worldobjects, player, corpse, ...);
    end
end
