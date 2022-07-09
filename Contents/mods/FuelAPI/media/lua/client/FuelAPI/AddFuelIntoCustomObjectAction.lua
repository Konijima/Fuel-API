require "TimedActions/ISBaseTimedAction";

local Utils = require("FuelAPI/Utils");

local AddFuelIntoCustomObjectAction = ISBaseTimedAction:derive("AddFuelIntoCustomObjectAction");

function AddFuelIntoCustomObjectAction:isValid()
    return self.customFuelObject and not self.customFuelObject:isFull();
end

function AddFuelIntoCustomObjectAction:waitToStart()
    self.character:faceLocation(self.square:getX(), self.square:getY());
    return self.character:shouldBeTurning();
end

function AddFuelIntoCustomObjectAction:update()
    self.petrolCan:setJobDelta(self:getJobDelta());
    self.character:faceLocation(self.square:getX(), self.square:getY());

    local tankCurrent = math.floor(self.tankStart - (self.tankStart - self.tankTarget) * self:getJobDelta() + 0.001);
    local itemCurrent = math.floor(self.itemStart - (self.itemStart - self.itemTarget) * self:getJobDelta() + 0.001);
    local itemMax = math.floor(1 / self.petrolCan:getUseDelta() + 0.001);

    if (isDebugEnabled()) then
        print("tankCurrent:" .. tankCurrent .. " | itemCurrent" .. itemCurrent);
    end

    self.petrolCan:setUsedDelta(itemCurrent / itemMax);
    self.customFuelObject:setFuelAmount(tankCurrent);

    self.character:setMetabolicTarget(Metabolics.LightWork);
end

function AddFuelIntoCustomObjectAction:start()
    if Utils.predicateEmptyPetrol(self.petrolCan) then
        local emptyCan = self.petrolCan;
        local newType = emptyCan:getReplaceType("PetrolSource") or "Base.PetrolCan";
        self.petrolCan = self.character:getInventory():AddItem(newType);
        self.petrolCan:setUsedDelta(0)
        if self.character:getPrimaryHandItem() == emptyCan then
            self.character:setPrimaryHandItem(self.petrolCan);
        end
        if self.character:getSecondaryHandItem() == emptyCan then
            self.character:setSecondaryHandItem(self.petrolCan);
        end
        self.character:getInventory():Remove(emptyCan);
    end

    self.petrolCan:setJobType(getText("ContextMenu_AddFuel"));
    self.petrolCan:setJobDelta(0.0);

    local pumpCurrent = self.customFuelObject:getFuelAmount();
    if pumpCurrent == -1 then
        pumpCurrent = 0;
    end
    local itemCurrent = math.floor(self.petrolCan:getUsedDelta() / self.petrolCan:getUseDelta() + 0.001);
    local pumpMax = self.customFuelObject.fuelCapacity - pumpCurrent;
    local add = math.min(pumpMax, itemCurrent);
    self.action:setTime(add * 50);
    self.itemStart = itemCurrent;
    self.itemTarget = itemCurrent - add;
    self.tankStart = pumpCurrent;
    self.tankTarget = pumpCurrent + add;

    self:setActionAnim("refuelgascan");
    self:setOverrideHandModels(self.petrolCan:getStaticModel(), nil);
end

function AddFuelIntoCustomObjectAction:stop()
    self.petrolCan:setJobDelta(0.0);
    ISBaseTimedAction.stop(self);
end

function AddFuelIntoCustomObjectAction:perform()
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
function AddFuelIntoCustomObjectAction:new(character, customFuelObject, petrolCan, time)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    o.character = character;
    o.customFuelObject = customFuelObject;
    o.square = customFuelObject.isoObject:getSquare();
    o.petrolCan = petrolCan;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = time;
    return o;
end

return AddFuelIntoCustomObjectAction;