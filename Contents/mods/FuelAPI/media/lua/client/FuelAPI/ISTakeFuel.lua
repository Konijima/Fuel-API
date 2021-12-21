require 'TimedActions/ISTakeFuel';

local Utils = require("FuelAPI/Utils");

local ISTakeFuel_start = ISTakeFuel.start;
function ISTakeFuel:start(...)

    if self.petrolCan:getTags():contains("CustomFuelContainer") and not instanceof(self.petrolCan, "DrainableComboItem") then
        local emptyCan = self.petrolCan;
        self.petrolCan = self.character:getInventory():AddItem(Utils.GetPetrolItemFromTag(emptyCan));
        self.petrolCan:setUsedDelta(0);
        if self.character:getPrimaryHandItem() == emptyCan then
            self.character:setPrimaryHandItem(self.petrolCan);
        end
        if self.character:getSecondaryHandItem() == emptyCan then
            self.character:setSecondaryHandItem(self.petrolCan);
        end
        self.character:getInventory():Remove(emptyCan);
    end

    ISTakeFuel_start(self, ...);

    if self.petrolCan:getTags():contains("CustomFuelContainer") then
        self:setOverrideHandModels(nil, self.petrolCan:getStaticModel());
    end

end
