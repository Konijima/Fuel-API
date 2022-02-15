require 'Vehicles/TimedActions/ISTakeGasolineFromVehicle';

if not getActivatedMods():contains("TreadsFuelTypesFramework") then

	local Utils = require("FuelAPI/Utils");

	local ISTakeGasolineFromVehicle_update = ISTakeGasolineFromVehicle.update;
	function ISTakeGasolineFromVehicle:update(...)
		ISTakeGasolineFromVehicle_update(self, ...);
		
		if getActivatedMods():contains("TreadsFuelTypesFramework") then
			local partType = getText("IGUI_RS_StorageSiphonFrom")
			if self.part == self.part:getVehicle():getPartById("GasTank") then partType = getText("IGUI_RS_VehicleSiphonFrom") end
			self.item:setJobType(string.format(partType, getText("IGUI_RSFuelType_" .. self.fuelType))) --- overwrite Job text
		end

		if self.item:getTags():contains("CustomFuelContainer") then
			local litresTaken = self.tankStart - self.amountSent;
			local usedDelta = self.itemStart + litresTaken / Utils.GetProperLitres(self.item);
			self.item:setUsedDelta(usedDelta);
		end
	end

	local ISTakeGasolineFromVehicle_start = ISTakeGasolineFromVehicle.start;
	function ISTakeGasolineFromVehicle:start(...)
		
		if self.fuelType == nil then self.fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
		
		if self.item:getTags():contains("CustomFuelContainer") and not instanceof(self.item, "DrainableComboItem") then
			local wasPrimary = self.character:getPrimaryHandItem() == self.item;
			local wasSecondary = self.character:getSecondaryHandItem() == self.item;
			self.character:getInventory():DoRemoveItem(self.item);
			self.item = self.character:getInventory():AddItem(Utils.GetItemFromTypeTag(self.item, self.fuelType)); --- changed to redone TypeTag check (using fuelType)
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

			self.action:setTime(take * Utils.GetSandboxFuelTransferSpeed());

			print("ISTakeGasolineFromVehicle_start Litres:" .. litres);
		end


	end

	------------Tread - Added all below ------------------------------------------
	function ISTakeGasolineFromVehicle:stop()
		local currentDelta = self.item:getUsedDelta()
		
		if currentDelta <= 0 then --- makes item empty if not filled with any units
			self.item:Use()
		elseif  currentDelta < 1 and currentDelta > (1 - self.item:getUseDelta()) then
			self.item:setUsedDelta(1);
		end

		self.item:setJobDelta(0)
		ISBaseTimedAction.stop(self)
	end

	function ISTakeGasolineFromVehicle:perform()
		self.item:setJobDelta(0)
		self.item:setUsedDelta(self.itemTarget)
		
		local currentDelta = self.item:getUsedDelta()
		
		if currentDelta <= 0 then --- makes item empty if not filled with any units
			self.item:Use()
		elseif  currentDelta < 1 and currentDelta > (1 - self.item:getUseDelta()) then
			self.item:setUsedDelta(1);
		end
		
		
		local args = { vehicle = self.vehicle:getId(), part = self.part:getId(), amount = self.tankTarget } 
		sendClientCommand(self.character, 'vehicle', 'setContainerContentAmount', args)
		print('take fluid level=' .. self.part:getContainerContentAmount() .. ' usedDelta=' .. self.item:getUsedDelta())
		-- needed to remove from queue / start next.
		
		ISBaseTimedAction.perform(self)
	end


	function ISTakeGasolineFromVehicle:new(character, part, item, time, fuelType)
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