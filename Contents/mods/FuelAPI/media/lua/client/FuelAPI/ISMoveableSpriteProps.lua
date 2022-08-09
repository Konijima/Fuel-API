require 'Moveables/ISMoveableSpriteProps';

local FuelAPIUtils = require("FuelAPI/Utils");
local CustomFuelObject = require("FuelAPI/CustomFuelObject");

local ISMoveableSpriteProps_canPickUpMoveableInternal = ISMoveableSpriteProps.canPickUpMoveableInternal;
function ISMoveableSpriteProps:canPickUpMoveableInternal( _character, _square, _object, _isMulti, ... )
    local canPickUp = ISMoveableSpriteProps_canPickUpMoveableInternal(self, _character, _square, _object, _isMulti, ...);

    if instanceof(_object, "IsoObject") then
        local customFuelObject = CustomFuelObject:new(_object);
        if customFuelObject then
            if customFuelObject:getFuelAmount() > 0 and not SandboxVars.FuelAPI.BarrelCanPickupFull then
                canPickUp = false;
            end
        end
    end

    return canPickUp;
end

local ISMoveableSpriteProps_getInfoPanelDescription = ISMoveableSpriteProps.getInfoPanelDescription;
function ISMoveableSpriteProps:getInfoPanelDescription( _square, _object, _player, _mode, ... )
    local infoTable = ISMoveableSpriteProps_getInfoPanelDescription(self, _square, _object, _player, _mode, ...);

    if instanceof(_object, "IsoObject") then
        local customFuelObject = CustomFuelObject:new(_object);
        if customFuelObject then
            infoTable = ISMoveableSpriteProps.addLineToInfoTable( infoTable, getText("ContextMenu_FuelName") .. ":", 255, 255, 255, customFuelObject:getFuelAmount() .. "/" .. customFuelObject.fuelCapacity, 100, 255, 0 );

            if customFuelObject:getFuelAmount() > 0 and not SandboxVars.FuelAPI.BarrelCanPickupFull then
                infoTable = ISMoveableSpriteProps.addLineToInfoTable( infoTable, "- "..getText("IGUI_BarrelHasFuel"), 255, 0, 0 );
            end
        end
    end

    return infoTable;
end

local ISMoveableSpriteProps_pickUpMoveableInternal = ISMoveableSpriteProps.pickUpMoveableInternal;
function ISMoveableSpriteProps:pickUpMoveableInternal( _character, _square, _object, ... )
    local data;

    local customFuelObject = CustomFuelObject:new(_object);
    if customFuelObject and SandboxVars.FuelAPI.BarrelCanPickupFull then
        local objModData = _object:getModData();
        for k, v in pairs(objModData) do
            data = data or {};
            data[k] = v;
        end
    end

    local item = ISMoveableSpriteProps_pickUpMoveableInternal(self, _character, _square, _object, ...);
    if instanceof(item, "InventoryItem") and data then
        local itemModData = item:getModData();
        for k, v in pairs(data) do
            itemModData[k] = v;
        end
    end

    return item;
end
