require 'Vehicles/TimedActions/ISAddGasolineToVehicle';

local Utils = require("FuelAPI/Utils");

local ISAddGasolineToVehicle_update = ISAddGasolineToVehicle.update;
function ISAddGasolineToVehicle:update(...)
    ISAddGasolineToVehicle_update(self, ...);

    if self.item:getTags():contains("CustomFuelContainer") then
        local litresTaken = self.amountSent - self.tankStart;
        local usedDelta = self.itemStart - litresTaken / Utils.GetProperLitres(self.item);
        self.item:setUsedDelta(usedDelta);
    end
end

local ISAddGasolineToVehicle_start = ISAddGasolineToVehicle.start;
function ISAddGasolineToVehicle:start(...)
    ISAddGasolineToVehicle_start(self, ...);

    if self.item:getTags():contains("CustomFuelContainer") then
        local litres = Utils.GetProperLitres(self.item);
        local add = self.part:getContainerCapacity() - self.tankStart;
        local take = math.min(add, self.itemStart * litres);
        self.tankTarget = self.tankStart + take;
        self.itemTarget = self.itemStart - take / litres;

        self.action:setTime(take * 50);

        print("ISAddGasolineToVehicle_start Litres:" .. litres);
    end
end
