--- Hopefully TIS fix this eventually
--- line 809 of ISVehicleMenu -> Hardcoded check for Base.PetrolCan
--- if typeToItem["Base.PetrolCan"] and part:getContainerContentAmount() < part:getContainerCapacity() then

require 'Vehicles/ISUI/ISVehicleMenu';

local ISVehicleMenu_FillPartMenu = ISVehicleMenu.FillPartMenu;
function ISVehicleMenu.FillPartMenu(playerIndex, context, slice, vehicle, ...)
    ISVehicleMenu_FillPartMenu(playerIndex, context, slice, vehicle, ...);

    local playerObj = getSpecificPlayer(playerIndex);
    if playerObj:DistToProper(vehicle) >= 4 then
        return
    end
    local typeToItem = VehicleUtils.getItems(playerIndex)
    for i=1,vehicle:getPartCount() do
        local part = vehicle:getPartByIndex(i-1)
        if not vehicle:isEngineStarted() and part:isContainer() and (part:getContainerContentType() == "Gasoline" or part:getContainerContentType() == "Gasoline Storage") then

            local fuelItem = ISVehiclePartMenu.getGasCanNotEmpty(playerObj, typeToItem);
            if fuelItem and fuelItem:getTags():contains("CustomFuelContainer") and part:getContainerContentAmount() < part:getContainerCapacity() then
                if slice then
                    slice:addSlice(getText("ContextMenu_VehicleAddGas"), getTexture("media/ui/vehicles/vehicle_add_gas.png"), ISVehiclePartMenu.onAddGasoline, playerObj, part)
                else
                    context:addOption(getText("ContextMenu_VehicleAddGas"), playerObj,ISVehiclePartMenu.onAddGasoline, part)
                end
            end
        end
    end
end