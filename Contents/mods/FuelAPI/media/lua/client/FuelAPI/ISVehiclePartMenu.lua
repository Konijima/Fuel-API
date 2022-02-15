require 'Vehicles/ISUI/ISVehiclePartMenu';

if not getActivatedMods():contains("TreadsFuelTypesFramework") then --- In order to not double functions - Tread
	local Utils = require("FuelAPI/Utils");

	local ISVehiclePartMenu_getGasCanNotEmpty = ISVehiclePartMenu.getGasCanNotEmpty;
	function ISVehiclePartMenu.getGasCanNotEmpty(playerObj, typeToItem, fuelType, ...) -- added fuelType - Tread
		
	-------------------Tread	
		if fuelType == nil then fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
		local fuelItem -- I moved declaration out of IF I added below - Tread
		if fuelType == "Gasoline" then
			fuelItem = ISVehiclePartMenu_getGasCanNotEmpty(playerObj, typeToItem, ...);
		end
	---------------------------------------------

		if not fuelItem then

			print("ISVehiclePartMenu_getGasCanNotEmpty");

			local equipped = playerObj:getPrimaryHandItem();
			if equipped and Utils.PredicateNotEmpty(equipped) and fuelType == Utils.GetItemFuelType(equipped) then --- add check for fuel type - Tread
				return equipped;
			end

			for fullType, items in pairs(typeToItem) do
				local gasCan = nil;
				local usedDelta = 1.1;
				for _,item in ipairs(typeToItem[fullType]) do
					if Utils.PredicateNotEmpty(item) and fuelType == Utils.GetItemFuelType(item) and item:getUsedDelta() < usedDelta then --- add check for fuel type - Tread
						gasCan = item;
						usedDelta = gasCan:getUsedDelta();
					end
				end
				if gasCan then return gasCan; end
			end

			return nil;

		else
			return fuelItem;
		end
	end

	local ISVehiclePartMenu_getGasCanNotFull = ISVehiclePartMenu.getGasCanNotFull;
	function ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem, fuelType, ...) -- added fuelType - Tread


	-------------------Tread	    
		if fuelType == nil then fuelType = "Gasoline" end --- If function was called without fuelType, use default - Tread
		local fuelItem -- I moved declaration out of IF I added below - Tread
		
		if fuelType == "Gasoline" then
			fuelItem = ISVehiclePartMenu_getGasCanNotFull(playerObj, typeToItem, ...);
		end
	----------------------------------------------------

		if not fuelItem then

			print("ISVehiclePartMenu_getGasCanNotFull");

			local equipped = playerObj:getPrimaryHandItem()
			if equipped and Utils.PredicateNotFull(equipped) and fuelType == Utils.GetItemFuelType(equipped) then --- add check for fuel type - Tread
				return equipped;
			elseif equipped and Utils.PredicateEmpty(equipped) and equipped:getTags():contains("EmptyFuelContainer") then --- add check for fuel type - Tread
				return equipped;
			end

			for fullType, items in pairs(typeToItem) do
				local gasCan = nil;
				local usedDelta = -1;
				for _,item in ipairs(typeToItem[fullType]) do
					if fuelType == Utils.GetItemFuelType(item) or item:getTags():contains("EmptyFuelContainer") then	--- Added this check - Tread
						if Utils.PredicateNotFull(item) and item:getUsedDelta() > usedDelta then
							gasCan = item;
							usedDelta = gasCan:getUsedDelta();
						end																						--- end of check above - Tread
					end	
				end
				if gasCan then return gasCan; end

				for _,item in ipairs(typeToItem[fullType]) do
					if Utils.PredicateEmpty(item) then
						return item;
					end
				end
			end

			return nil;

		else
			return fuelItem;
		end
	end

	-------------Tread - New Native overwrites ------------------

	function ISVehiclePartMenu.onAddGasoline(playerObj, part, fuelItem, fuelType)
		if playerObj:getVehicle() then
			ISVehicleMenu.onExit(playerObj)
		end
	--	local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
	--	local item = ISVehiclePartMenu.getGasCanNotEmpty(playerObj, typeToItem)		-- why would we allow another run of it?
		if fuelItem then --- swapped Item into fuelItem here and all lines below - Tread
			ISVehiclePartMenu.toPlayerInventory(playerObj, fuelItem)
			ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
			ISInventoryPaneContextMenu.equipWeapon(fuelItem, true, false, playerObj:getPlayerNum())
			ISTimedActionQueue.add(ISAddGasolineToVehicle:new(playerObj, part, fuelItem, 50, fuelType))
		end
	end


	function ISVehiclePartMenu.onTakeGasoline(playerObj, part, fuelItem, fuelType)
		if playerObj:getVehicle() then
			ISVehicleMenu.onExit(playerObj)
		end
	--	local typeToItem = VehicleUtils.getItems(playerObj:getPlayerNum())
	--	local item = ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem) 		-- why would we allow another run of it?
		if fuelItem then  --- swapped Item into fuelItem here and all below - Tread
			ISVehiclePartMenu.toPlayerInventory(playerObj, fuelItem)
			ISTimedActionQueue.add(ISPathFindAction:pathToVehicleArea(playerObj, part:getVehicle(), part:getArea()))
			ISInventoryPaneContextMenu.equipWeapon(fuelItem, false, false, playerObj:getPlayerNum())
			ISTimedActionQueue.add(ISTakeGasolineFromVehicle:new(playerObj, part, fuelItem, 50, fuelType))
		end
	end
end
