require "TimedActions/ISBaseTimedAction";

local Utils = require("FuelAPI/Utils");

local AddFuelCustomObject = ISBaseTimedAction:derive("AddFuelCustomObject");

function AddFuelCustomObject:isValid()
    return self.customFuelObject and not self.customFuelObject:isFull();
end

function AddFuelCustomObject:waitToStart()
    self.character:faceLocation(self.square:getX(), self.square:getY());
    return self.character:shouldBeTurning();
end

function AddFuelCustomObject:update()
    self.petrolCan:setJobDelta(self:getJobDelta());
    self.character:faceLocation(self.square:getX(), self.square:getY());

    local tankCurrent = math.ceil(self.tankStart - (self.tankStart - self.tankTarget) * self:getJobDelta() + 0.001);
    local itemCurrent = math.floor(self.itemStart - (self.itemStart - self.itemTarget) * self:getJobDelta() + 0.001);
    local itemMax = math.floor(1 / self.petrolCan:getUseDelta() + 0.001);

    if (isDebugEnabled()) then
        print("tankCurrent:" .. tankCurrent .. " | itemCurrent" .. itemCurrent);
    end

    self.petrolCan:setUsedDelta(itemCurrent / itemMax);
    self.customFuelObject:setFuelAmount(tankCurrent);

    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function AddFuelCustomObject:start()

	self.fuelType = Utils.GetItemFuelType(self.petrolCan) or "Gasoline"; ---check contents of Gas Can, default to Gasoline if nil
	
    if Utils.PredicateEmptyWithBase(self.petrolCan) then
        local emptyCan = self.petrolCan;
   --     if self.petrolCan:getFullType() == "Base.EmptyPetrolCan" then						--- commented this out - Tread
   --         self.petrolCan = self.character:getInventory():AddItem("Base.PetrolCan");		--- commented this out - Tread
   --     else
            self.petrolCan = self.character:getInventory():AddItem(Utils.GetItemFromTypeTag(self.item, self.fuelType)); ------ changed to redone TypeTag check (using fuelType)
   --     end																				--- commented this out - Tread
        self.petrolCan:setUsedDelta(0);
        if self.character:getPrimaryHandItem() == emptyCan then
            self.character:setPrimaryHandItem(self.petrolCan);
        end
        if self.character:getSecondaryHandItem() == emptyCan then
            self.character:setSecondaryHandItem(self.petrolCan);
        end
        self.character:getInventory():Remove(emptyCan);
    end

    self.petrolCan:setJobType(getText("ContextMenu_AddFuel"));
	if getActivatedMods():contains("TreadsFuelTypesFramework") then
		self.petrolCan:setJobType(string.format(getText("IGUI_RS_ObjectAddTo"), getText("IGUI_RSFuelType_" .. self.fuelType))) --- overwrite Job text
	end	
    self.petrolCan:setJobDelta(0.0);

    local pumpCurrent = self.customFuelObject:getFuelAmount();
    if pumpCurrent == -1 then
        pumpCurrent = 0;
    end
    local itemCurrent = math.floor(self.petrolCan:getUsedDelta() / self.petrolCan:getUseDelta() + 0.001);
    local pumpMax = self.customFuelObject.fuelCapacity - pumpCurrent;
    local add = math.min(pumpMax, itemCurrent);
    self.action:setTime(add * Utils.GetSandboxFuelTransferSpeed());
    self.itemStart = itemCurrent;
    self.itemTarget = itemCurrent - add;
    self.tankStart = pumpCurrent;
    self.tankTarget = pumpCurrent + add;

    self:setActionAnim("refuelgascan");
    self:setOverrideHandModels(self.petrolCan:getStaticModel(), nil);
end

function AddFuelCustomObject:stop()
-------Tread - Added
	if self.customFuelObject:getFuelAmount() > self.tankStart and self.customFuelObject.isoObject:getModData().RSFuelType  ~= self.fuelType then
		self.customFuelObject.isoObject:getModData().RSFuelType = self.fuelType
		self.customFuelObject.isoObject:transmitModData();
	end
--------------------------------------
    self.petrolCan:setJobDelta(0.0);
	if self.petrolCan:getUsedDelta() <= 0 then --- Tread -- added this check, otherwise cancelling action at wrong moment results in 0 units, unusable item.
        self.petrolCan:Use();
    end
    ISBaseTimedAction.stop(self);
end

function AddFuelCustomObject:perform()
-------Tread - Added
	if self.customFuelObject:getFuelAmount() > self.tankStart and self.customFuelObject.isoObject:getModData().RSFuelType  ~= self.fuelType then
		self.customFuelObject.isoObject:getModData().RSFuelType = self.fuelType
		self.customFuelObject.isoObject:transmitModData();
	end
--------------------------------------
    self.petrolCan:setJobDelta(0.0);
    local itemMax = math.floor(1 / self.petrolCan:getUseDelta() + 0.001);
    self.petrolCan:setUsedDelta(self.itemTarget / itemMax);
    self.customFuelObject:setFuelAmount(self.tankTarget);

    if self.petrolCan:getUsedDelta() <= 0 then
        self.petrolCan:Use();
    end
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self);
end

---@param fuelStation CustomFuelObject
function AddFuelCustomObject:new(character, customFuelObject, petrolCan, time)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.customFuelObject = customFuelObject; --- Tread - In this case it is not isoObject yet
    o.square = customFuelObject.isoObject:getSquare();
    o.petrolCan = petrolCan;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return AddFuelCustomObject;