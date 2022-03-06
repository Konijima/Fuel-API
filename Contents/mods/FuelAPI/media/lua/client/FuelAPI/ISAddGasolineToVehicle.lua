require 'Vehicles/TimedActions/ISAddGasolineToVehicle';

if not getActivatedMods():contains("TreadsFuelTypesFramework") then
	local Utils = require("FuelAPI/Utils");

	local ISAddGasolineToVehicle_update = ISAddGasolineToVehicle.update;
	function ISAddGasolineToVehicle:update(...)
		ISAddGasolineToVehicle_update(self, ...);
		
		if getActivatedMods():contains("TreadsFuelTypesFramework") then
			local partType = getText("IGUI_RS_StorageAddTo")
			if self.part == self.part:getVehicle():getPartById("GasTank") then partType = getText("IGUI_RS_VehicleAddTo") end
			self.item:setJobType(string.format(partType, getText("IGUI_RSFuelType_" .. self.fuelType))) --- overwrite Job text
		end

		if self.item:getTags():contains("CustomFuelContainer") then
			local litresTaken = self.amountSent - self.tankStart;
			local usedDelta = self.itemStart - litresTaken / Utils.GetProperLitres(self.item);
			self.item:setUsedDelta(usedDelta);
		end
	end

	local ISAddGasolineToVehicle_start = ISAddGasolineToVehicle.start;
	function ISAddGasolineToVehicle:start(...)
		ISAddGasolineToVehicle_start(self, ...);
		
		if self.fuelType == nil then self.fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
		
		if self.item:getTags():contains("CustomFuelContainer") then
			local litres = Utils.GetProperLitres(self.item);
			local add = self.part:getContainerCapacity() - self.tankStart;
			local take = math.min(add, self.itemStart * litres);
			self.tankTarget = self.tankStart + take;
			self.itemTarget = self.itemStart - take / litres;

			self.action:setTime(take * Utils.GetSandboxFuelTransferSpeed());

			print("ISAddGasolineToVehicle_start Litres:" .. litres);
		end
	end

	------------Tread - Added all below ------------------------------------------
	local ISAddGasolineToVehicle_stop = ISAddGasolineToVehicle.stop;
	function ISAddGasolineToVehicle:stop(...)
		-------- Swap Storage Tank content type if Tank was empty and ANY amount was poured in - Tread
		if getActivatedMods():contains("TreadsFuelTypesFramework") and self.part:getModData().RSFuelType == "Empty" and self.tankStart < self.part:getContainerContentAmount() then
			RSFuelTypes.SwapFuelTypeRS(self.character, self.part, self.fuelType)
		end
		
		ISAddGasolineToVehicle_stop(self, ...);
	end

	local ISAddGasolineToVehicle_perform = ISAddGasolineToVehicle.perform;
	function ISAddGasolineToVehicle:perform(...)
		-------- Swap Storage Tank content type if Tank was empty and ANY amount was poured in - Tread
		if getActivatedMods():contains("TreadsFuelTypesFramework") and self.part:getModData().RSFuelType == "Empty" and self.tankStart < self.part:getContainerContentAmount() then
			RSFuelTypes.SwapFuelTypeRS(self.character, self.part, self.fuelType)
		end
		
		ISAddGasolineToVehicle_perform(self, ...);
	end


	function ISAddGasolineToVehicle:new(character, part, item, time, fuelType)
		local o = {}
		setmetatable(o, self)
		self.__index = self
		o.character = character
		o.vehicle = part:getVehicle()
		o.part = part
		o.item = item
		o.maxTime = time
		o.fuelType = fuelType
		return o
	end
end