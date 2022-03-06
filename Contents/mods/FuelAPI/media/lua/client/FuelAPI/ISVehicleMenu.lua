--- Hopefully TIS fix this eventually
--- line 809 of ISVehicleMenu -> Hardcoded check for Base.PetrolCan
--- if typeToItem["Base.PetrolCan"] and part:getContainerContentAmount() < part:getContainerCapacity() then

require 'Vehicles/ISUI/ISVehicleMenu';

if not getActivatedMods():contains("TreadsFuelTypesFramework") then --- In order to not double functions - Tread
	------------ Tread's Fuel Types Framework - Addition ---------------

	contentTypeTableRS = contentTypeTableRS or {}
	contentTypeTableRS["Gasoline Storage"] = true
	contentTypeTableRS["Gasoline"] = true

	--local FuelTypesModActive = nil
	--if getActivatedMods():contains("TreadsFuelTypesFramework") then FuelTypesModActive = true end --- check if my mod is active

	local function setContains(set, key) --- function for checking if value is in the table
		return set[key] ~= nil
	end
	-------------------------------------------------------------------

	local ISVehicleMenu_FillPartMenu = ISVehicleMenu.FillPartMenu;
	function ISVehicleMenu.FillPartMenu(playerIndex, context, slice, vehicle, ...)
		ISVehicleMenu_FillPartMenu(playerIndex, context, slice, vehicle, ...);

		local playerObj = getSpecificPlayer(playerIndex);
		if playerObj:DistToProper(vehicle) >= 4 then
			return
		end
		local typeToItem = VehicleUtils.getItems(playerIndex)
		for i=1,vehicle:getPartCount() do
			local part = vehicle:getPartByIndex(i-1)
	---------------------Tread ----------- commented line below + added rest of the code---------------------------------------		
		  --  if not vehicle:isEngineStarted() and part:isContainer() and (part:getContainerContentType() == "Gasoline" or part:getContainerContentType() == "Gasoline Storage") then
			local partContentType = part:getContainerContentType() --- not a problem if part is not container
			if part:isContainer() and setContains(contentTypeTableRS, partContentType) then --- if content type is listed in contentTypeTableRS table ...	
				
				local AcceptedFuelTypes = {"Gasoline"} --- init default option - Tread
	--[[		if FuelTypesModActive then
					AcceptedFuelTypes = RSFuelTypes.AcceptedFuelTypesTable(playerObj, part, partContentType) --- List accepted fuel types
					local partModDataFuelType = part:getModData().RSFuelType
					if part:getContainerContentAmount() == 0 and partModDataFuelType ~= "Empty" then --- Set "Empty" fuel type for suitable empty tanks
						for _, i in pairs(FuelTypesTableRS["Empty"]) do
							if i == partModDataFuelType then
								AcceptedFuelTypes = FuelTypesTableRS["Empty"]
								RSFuelTypes.SwapFuelTypeRS(playerObj, part, "Empty")
								break
							end
						end
					end
				else
	]]--
					if part == vehicle:getPartById("GasTank") and partContentType ~= "Gasoline" then
						AcceptedFuelTypes = {partContentType} --- if not Native swap accepted fuel type into tank Content Type
					end
	--			end
				
				-------------- Remove native Context menu options - Tread -----------------------
				local ContextMenuCleaningTable = {}
				ContextMenuCleaningTable[getText("ContextMenu_VehicleAddGas")] = true
				ContextMenuCleaningTable[getText("ContextMenu_VehicleSiphonGas")] = true
				if slice then
					slice:removeSliceByNames(ContextMenuCleaningTable)
				else
					context:removeOptionByNames(ContextMenuCleaningTable)
				end
				
	---------------------------------------------------------------------------------------------------------------------------
				for _, fuelType in pairs(AcceptedFuelTypes) do	--- Added this loop (to add option for pouring in all eligible fuel types - Tread
					local fuelItem = ISVehiclePartMenu.getGasCanNotEmpty(playerObj, typeToItem, fuelType); 
					if fuelItem and part:getContainerContentAmount() < part:getContainerCapacity() then --- checking custom tag here was unnecessary - your util function in getGasCan.... already did it
						local optionText = getText("ContextMenu_VehicleAddGas")
						if fuelType ~= "Gasoline" then optionText = optionText .. " - " .. fuelType end
						if slice then
							slice:addSlice(optionText, getTexture("media/ui/vehicles/vehicle_add_gas.png"), ISVehiclePartMenu.onAddGasoline, playerObj, part, fuelItem, fuelType) ---added fuelType as parameter - Tread
						else
							context:addOption(optionText, playerObj,ISVehiclePartMenu.onAddGasoline, part, fuelItem, fuelType) ---added fuelType as parameter - Tread
						end
					end
				end					--- end of loop - Tread
				
		---------- added part about siphoning (fuelType item needs to get added in a call) ---------------		
				if part:getContainerContentAmount() > 0 then
					--local fuelType = "Gasoline" --- init default option - Tread
					fuelType = AcceptedFuelTypes[1]
				
					local fuelItem = ISVehiclePartMenu.getGasCanNotFull(playerObj, typeToItem, fuelType);
					if fuelItem then
						local optionText = getText("ContextMenu_VehicleSiphonGas")
						if fuelType ~= "Gasoline" then optionText = optionText .. " - " .. fuelType end
						if slice then
							slice:addSlice(optionText, getTexture("media/ui/vehicles/vehicle_siphon_gas.png"), ISVehiclePartMenu.onTakeGasoline, playerObj, part, fuelItem, fuelType) ---added fuelType as parameter - Tread
						else
							context:addOption(optionText, playerObj, ISVehiclePartMenu.onTakeGasoline, part, fuelItem, fuelType) ---added fuelType as parameter - Tread
						end
					end
				end
			end
		end
	end
end
