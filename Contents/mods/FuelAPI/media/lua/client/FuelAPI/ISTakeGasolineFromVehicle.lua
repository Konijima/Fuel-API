require 'Vehicles/TimedActions/ISTakeGasolineFromVehicle';

local Utils = require("FuelAPI/Utils");

local ISTakeGasolineFromVehicle_update = ISTakeGasolineFromVehicle.update;
function ISTakeGasolineFromVehicle:update(...)
    ISTakeGasolineFromVehicle_update(self, ...);

    if self.item:getTags():contains("CustomFuelContainer") then
        local litresTaken = self.tankStart - self.amountSent;
        local usedDelta = self.itemStart + litresTaken / Utils.GetProperLitres(self.item);
        self.item:setUsedDelta(usedDelta);
    end
end

local ISTakeGasolineFromVehicle_start = ISTakeGasolineFromVehicle.start;
function ISTakeGasolineFromVehicle:start(...)

    if self.item:getTags():contains("CustomFuelContainer") and not instanceof(self.item, "DrainableComboItem") then
        local wasPrimary = self.character:getPrimaryHandItem() == self.item;
        local wasSecondary = self.character:getSecondaryHandItem() == self.item;
        self.character:getInventory():DoRemoveItem(self.item);
        self.item = self.character:getInventory():AddItem(Utils.GetPetrolItemFromTag(self.item));
        self.item:setUsedDelta(0);
        if wasPrimary then
            self.character:setPrimaryHandItem(self.item);
        end
        if wasSecondary then
            self.character:setSecondaryHandItem(self.item);
        end
    end

    ISTakeGasolineFromVehicle_start(self, ...);

    if self.item:getTags():contains("CustomFuelContainer") then
        local litres = Utils.GetProperLitres(self.item);
        local add = (1.0 - self.itemStart) * litres;
        local take = math.min(add, self.tankStart);
        self.tankTarget = self.tankStart - take;
        self.itemTarget = self.itemStart + take / litres;

        self.action:setTime(take * 50);

        print("ISTakeGasolineFromVehicle_start Litres:" .. litres);
    end

end
