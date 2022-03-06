--------------------------------- Code by Tread ----- (Trealak on Steam) ---------------------------------
------------------------------- Developed For Tread's Fuel Types Framework -------------------------------
if not getActivatedMods():contains("TreadsFuelTypesFramework") then --- In order to not double functions - Tread
	require "ISUI/ISPanel"
	require "ISUI/ISContextMenu"
	require "ISUI/ISRadialMenu.lua"

	------------------------------------- Context and Radial menu utils --------------------------------------
	function ISContextMenu:getOptionIdFromName(name)
		local matchTable = {}
		for i,v in ipairs(self.options) do
			if v.name == name then
			   matchTable[#matchTable + 1] = i
			end
		end
		return matchTable;
	end

	function ISContextMenu:removeOptionsById(matchTable)
		for _, Id in ipairs(matchTable) do
			table.insert(self.optionPool, self.options[Id])
			table.remove(self.options, Id)
			self.numOptions = self.numOptions - 1
		end
		self:calcHeight()
	end

	function ISContextMenu:removeOptionByNames(ContextMenuCleaningTable) --- Removes option from context menu based on its text
		for name, _ in pairs(ContextMenuCleaningTable) do
			local Id = self:getOptionIdFromName(name)
			if Id then self:removeOptionsById(Id) end
		end
	end

	function ISRadialMenu:removeSliceByNames(ContextMenuCleaningTable) --- Removes slice from Radial menu based on its text
		local notMatchTable = {}
		for name, _ in pairs(ContextMenuCleaningTable) do
			for _,v in ipairs(self.slices) do
				if v.text == name then
					v.text = nil
				end
			end
		end
		for _,v in pairs(self.slices) do
			if v.text ~= nil then
				notMatchTable[#notMatchTable + 1] = v
			end
		end
		self:clear()
		for _,v in ipairs(notMatchTable) do
				self:addSlice(v.text, v.texture, v.command[1], v.command[2], v.command[3],v.command[4], v.command[5], v.command[6], v.command[7])
		end
	end
end