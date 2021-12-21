require 'Camping/ISUI/ISBBQMenu';

local Utils = require("FuelAPI/Utils");

local function doBBQMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end

    local bbq = nil

    for _,object in ipairs(worldobjects) do
        local square = object:getSquare()
        if square then
            for i=1,square:getObjects():size() do
                local object2 = square:getObjects():get(i-1)
                if instanceof(object2, "IsoBarbecue") then
                    bbq = object2
                end
            end
        end
    end

    if not bbq then return; end

    local playerObj = getSpecificPlayer(player);
    local playerInv = playerObj:getInventory();

    local lighter = playerInv:getFirstTypeRecurse("Lighter");
    local matches = playerInv:getFirstTypeRecurse("Matches");
    local petrol = playerInv:getFirstEvalRecurse(Utils.PredicateNotEmpty);

    local lightFromPetrol = nil;
    if (lighter or matches) and petrol and not bbq:isLit() and bbq:hasFuel() then
        lightFromPetrol = bbq;
    end

    if lightFromPetrol then
        local subContext = context:getOptionFromName(campingText.lightCampfire);
        if subContext and subContext.subOption then
            subContext = context:getSubInstance(subContext.subOption);
        else
            local lightOption = context:addOption(campingText.lightCampfire, worldobjects, nil);
            subContext = ISContextMenu:getNew(context);
            context:addSubMenu(lightOption, subContext);
        end

        if subContext and lighter then
            subContext:addOptionOnTop(petrol:getName()..' + '..lighter:getName(), worldobjects, ISBBQMenu.onLightFromPetrol, player, lighter, petrol, lightFromPetrol);
        end
        if subContext and matches then
            subContext:addOptionOnTop(petrol:getName()..' + '..matches:getName(), worldobjects, ISBBQMenu.onLightFromPetrol, player, matches, petrol, lightFromPetrol);
        end
    end

end
Events.OnFillWorldObjectContextMenu.Add(doBBQMenu);
