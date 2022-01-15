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

    --- use custom take time
    local pumpCurrent = tonumber(self.fuelStation:getPipedFuelAmount());
    local itemCurrent = math.floor(self.petrolCan:getUsedDelta() / self.petrolCan:getUseDelta() + 0.001);
    local itemMax = math.floor(1 / self.petrolCan:getUseDelta() + 0.001);
    local take = math.min(pumpCurrent, itemMax - itemCurrent);
    self.action:setTime(take * Utils.GetSandboxFuelTransferSpeed());

    if self.petrolCan:getTags():contains("CustomFuelContainer") then
        self:setOverrideHandModels(nil, self.petrolCan:getStaticModel());
    end

end
