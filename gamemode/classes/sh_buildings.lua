--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

SF.Buildings = {}
SF.Buildings.stored = {}
SF.Buildings.buffer = {}

/* 
	Buildings loading and registering
*/

function SF.Buildings:LoadBuildings()
	SF:Msg("Loading Buildings...", 2)
	local files, folders = file.Find(SF.LoaderDir.."/buildings/*", "LUA", "namedesc")

	for k, v in pairs(files) do
		if (v != ".." and v != ".") then

			local baseName = string.sub(v, 1, -5)

			ENT = {Base = "base_building", Folder = SF.LoaderDir.."/buildings"}

			if (SERVER) then
				AddCSLuaFile(SF.LoaderDir.."/buildings/"..v)	
			end
			include(SF.LoaderDir.."/buildings/"..v)

			SF:Msg("Loading Building: "..baseName, 3)
			scripted_ents.Register(ENT, "building_"..baseName)
			
			self.stored[baseName] = ENT

			ENT = nil
		end
	end
end


SF.Buildings.reqMeta = {}
SF.Buildings.reqMeta.__index = SF.Buildings.reqMeta
AccessorFunc(SF.Buildings.reqMeta, "requiresTerritory", "RequiresTerritory", FORCE_BOOL)


function SF.Buildings.reqMeta:Init()
	self.building = false
	self.resources = {}
	self.functions = {}
	self.gold = 0
	self:SetRequiresTerritory(true)
end

function SF.Buildings.reqMeta:AttachBuilding(ent)
	if (!IsValid(ent)) then error("AttachBuilding Entity is '"..type(ent).."' Expected Entity") end
	self.building = ent
end

function SF.Buildings.reqMeta:AddResource(name, amount)
	self.resources[name] = amount
end

function SF.Buildings.reqMeta:AddGold(amount)
	self.gold = amount
end

function SF.Buildings.reqMeta:AddFunction(func)
	table.insert(self.functions, func)
end

function SF.Buildings.reqMeta:Check(faction, trace, ghost)

	if (self:GetRequiresTerritory()) then
		if (!faction:PosInTerritory(trace.HitPos)) then
			return false, "Position not in your territory"
		end
	end

	for _, func in pairs(self.functions) do
		local pass, msg = func(faction, trace, ghost)
		if (!pass) then
			return false, msg
		end
	end

	for res, amnt in pairs(self.resources) do
		if (!faction:HasResource(res, amnt)) then
			return false, "Not enough "..res
		end
	end

	if (!faction:HasGold(self.gold)) then
		return false, "Not enough Gold"
	end

	return true
end

function SF.Buildings:NewRequirements()
	local o = table.Copy(SF.Faction.metaClass)
	setmetatable(o, SF.Faction.metaClass)
	SF:Call("OnFactionCreated", o)
	table.insert(self.buffer, o)
	return o
end


SF:RegisterClass("shBuildings", SF.Buildings)

SF.Buildings:LoadBuildings()