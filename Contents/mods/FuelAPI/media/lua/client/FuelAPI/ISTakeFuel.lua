require 'TimedActions/ISTakeFuel';

local Utils = require("FuelAPI/Utils");

local ISTakeFuel_start = ISTakeFuel.start;
function ISTakeFuel:start(...)

	if self.fuelType == nil then self.fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
	
    if self.petrolCan:getTags():contains("CustomFuelContainer") and not instanceof(self.petrolCan, "DrainableComboItem") then
        local emptyCan = self.petrolCan;
        self.petrolCan = self.character:getInventory():AddItem(Utils.GetItemFromTypeTag(self.petrolCan, self.fuelType)); ------ changed to redone TypeTag check (using fuelType)
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
	
	if getActivatedMods():contains("TreadsFuelTypesFramework") then
		self.petrolCan:setJobType(string.format(getText("IGUI_RS_ObjectSiphonFrom"), getText("IGUI_RSFuelType_" .. self.fuelType))) --- overwrite Job text
	end

    if self.petrolCan:getTags():contains("CustomFuelContainer") then
        self:setOverrideHandModels(nil, self.petrolCan:getStaticModel());
    end

end

------------Tread - Added all below ------------------------------------------
local ISTakeFuel_stop = ISTakeFuel.stop;
function ISTakeFuel:stop(...)
	if self.fuelStation:getModData().RSFuelType and self.fuelType ~= "LPG" and  self.fuelStation:getModData().fuelAmount <= 0 then --- Tread - Object has Fuel Type parameter and is empty
			self.fuelStation:getModData().RSFuelType = "Empty" --- Tread - Set Barrel to Empty Fuel type
			self.fuelStation:transmitModData();
	end
	
	local currentDelta = self.petrolCan:getUsedDelta()
	
	if currentDelta <= 0 then --- makes item empty if not filled with any units
		self.petrolCan:Use()
	elseif  currentDelta < 1 and currentDelta > (1 - self.petrolCan:getUseDelta()) then
		self.petrolCan:setUsedDelta(1);
	end
	
ISTakeFuel_stop(self, ...);
end
local ISTakeFuel_perform = ISTakeFuel.perform;
function ISTakeFuel:perform(...)
	if self.fuelStation:getModData().RSFuelType and self.fuelType ~= "LPG" and  self.fuelStation:getModData().fuelAmount <= 0 then --- Tread - Object has Fuel Type parameter and is empty
			self.fuelStation:getModData().RSFuelType = "Empty" --- Tread - Set Barrel to Empty Fuel type
			self.fuelStation:transmitModData();
	end
	
	local currentDelta = self.petrolCan:getUsedDelta()
	
	if currentDelta <= 0 then --- makes item empty if not filled with any units
		self.petrolCan:Use()
	elseif  currentDelta < 1 and currentDelta > (1 - self.petrolCan:getUseDelta()) then
		self.petrolCan:setUsedDelta(1);
	end
	
ISTakeFuel_perform(self, ...);
end

function ISTakeFuel:new(character, fuelStation, petrolCan, time, fuelType)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character;
    o.fuelStation = fuelStation; --- Tread - In this case it already is isoObject
	o.square = fuelStation:getSquare();
	o.petrolCan = petrolCan;
	o.stopOnWalk = true;
	o.stopOnRun = true;
	o.maxTime = time;
	o.fuelType = fuelType
	return o;
end