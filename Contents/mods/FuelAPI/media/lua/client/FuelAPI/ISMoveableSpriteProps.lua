require 'Moveables/ISMoveableSpriteProps';

local ISMoveableSpriteProps_canPickUpMoveableInternal = ISMoveableSpriteProps.canPickUpMoveableInternal;
function ISMoveableSpriteProps:canPickUpMoveableInternal( _character, _square, _object, _isMulti, ... )
    local canPickUp = ISMoveableSpriteProps_canPickUpMoveableInternal(self, _character, _square, _object, _isMulti, ...);

    if instanceof(_object, "IsoObject") then
        local props = _object:getProperties();
        if props and props:Val("CustomName") == "Barrel" then
            local modData = _object:getModData();
            if modData.fuelAmount and tonumber(modData.fuelAmount) > 0 then
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
        local props = _object:getProperties();
        if props and props:Val("CustomName") == "Barrel" then
            local modData = _object:getModData();
            if modData and modData.fuelAmount and tonumber(modData.fuelAmount) > 0 then
                infoTable = ISMoveableSpriteProps.addLineToInfoTable( infoTable, "- "..getText("IGUI_BarrelHasFuel"), 255, 0, 0 );
            end
        end
    end

    return infoTable;
end