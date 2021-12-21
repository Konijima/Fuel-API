require 'Camping/ISUI/ISCampingMenu';

local Utils = require("FuelAPI/Utils");

local function doCampingMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true; end

    local playerObj = getSpecificPlayer(player);

    if playerObj:getVehicle() then return; end

    local petrol = nil;
    local lighter = nil;
    local matches = nil;
    local lightFromPetrol = nil;

    local containers = ISInventoryPaneContextMenu.getContainers(playerObj);
    for i=1,containers:size() do
        local container = containers:get(i-1);
        for j=1,container:getItems():size() do
            local item = container:getItems():get(j-1);
            local type = item:getType()
            if type == "Lighter" then
                lighter = item
            elseif type == "Matches" then
                matches = item
            elseif Utils.PredicateNotEmpty(item) then
                petrol = item;
            end
        end
    end

    for i,v in ipairs(worldobjects) do
        local campfire = ISCampingMenu.campfire;
        if (lighter or matches) and petrol and campfire and
                not campfire.isLit and
                campfire.fuelAmt > 0 then
            lightFromPetrol = campfire;
        end
    end

    if lightFromPetrol and (lighter or matches) then
        local subContext = context:getOptionFromName(campingText.lightCampfire);
        if subContext and subContext.subOption then
            subContext = context:getSubInstance(subContext.subOption);
        else
            local lightOption = context:addOption(campingText.lightCampfire, worldobjects, nil);
            subContext = ISContextMenu:getNew(context);
            context:addSubMenu(lightOption, subContext);
        end

        if subContext and lighter then
            subContext:addOptionOnTop(petrol:getName()..' + '..lighter:getName(), worldobjects, ISCampingMenu.onLightFromPetrol, player, lighter, petrol, lightFromPetrol);
        end
        if subContext and matches then
            subContext:addOptionOnTop(petrol:getName()..' + '..matches:getName(), worldobjects, ISCampingMenu.onLightFromPetrol, player, matches, petrol, lightFromPetrol);
        end
    end

end
Events.OnFillWorldObjectContextMenu.Add(doCampingMenu);