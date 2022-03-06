--------------------------------- Code by Tread ----- (Trealak on Steam) ---------------------------------
------------ Developed For Tread's Fuel Types Framework and KONIJIMA's Fuel API compatibility ------------
------------------------------- Inspired by Dark Slayer EX's Item Tweaker --------------------------------

function FuelAPItweakDefaultItems()
------- Petrol ----- default items - add tags
	local PetrolCanEmpty = "Base.EmptyPetrolCan"
	local PetrolCan = "Base.PetrolCan"
	
	local ScriptPetrolCanEmpty = ScriptManager.instance:getItem(PetrolCanEmpty)
	local ScriptPetrolCan = ScriptManager.instance:getItem(PetrolCan)
	
	local ScriptPetrolCanEmptyTags = getScriptManager():getItemsTag(PetrolCanEmpty)
	local ScriptPetrolCanTags = getScriptManager():getItemsTag(PetrolCan)
	
	local StringPetrolCanEmptyTags = "Tags = CustomFuelContainer; EmptyFuelContainer; Gasoline_Base_PetrolCan; Diesel_FuelAPI_PetrolCanFullwDiesel" --- Custom Tags
	local StringPetrolCanTags = "Tags = CustomFuelContainer; FuelType_Gasoline; Empty_Base_EmptyPetrolCan" --- Custom Tags
	
	if ScriptPetrolCanEmptyTags ~= nil and ScriptPetrolCanEmptyTags[1] ~= nil then --- Ignore next loop if Item had no default tags
		for _, v in pairs(ScriptPetrolCanEmptyTags) do
			StringPetrolCanEmptyTags = (StringPetrolCanEmptyTags.. "; " .. v) --- Add original tags back
		end
	end
	--print('Tread tag test Empty: ' .. StringPetrolCanEmptyTags);
	
	if ScriptPetrolCanTags ~= nil and ScriptPetrolCanTags[1] ~= nil then --- Ignore next loop if Item had no default tags
		for _, v in ipairs(ScriptPetrolCanTags) do
			StringPetrolCanTags = (StringPetrolCanTags.. "; " .. v) --- Add original tags back
		end
	end
	--print('Tread tag test Petrol: ' .. StringPetrolCanTags);
	
	ScriptPetrolCanEmpty:DoParam(StringPetrolCanEmptyTags); --- Script Manager overwrites Tags
	ScriptPetrolCan:DoParam(StringPetrolCanTags);	--- Script Manager overwrites Tags

----LPG - add tags to propane tank
	local PropaneTank = "Base.PropaneTank"
	local ScriptPropaneTank = ScriptManager.instance:getItem(PropaneTank)
	local ScriptPropaneTankTags = getScriptManager():getItemsTag(PropaneTank)
	local StringPropaneTankTags = "Tags = CustomFuelContainer; FuelType_LPG" --- Custom Tags
	if ScriptPropaneTankTags ~= nil and ScriptPropaneTankTags[1] ~= nil then --- Ignore next loop if Item had no default tags
		for _, v in ipairs(ScriptPropaneTankTags) do
			StringPropaneTankTags = (StringPropaneTankTags.. "; " .. v) --- Add original tags back
		end
	end
	ScriptPropaneTank:DoParam(StringPropaneTankTags); --- Script Manager overwrites Tags
end

Events.OnGameBoot.Add(FuelAPItweakDefaultItems)