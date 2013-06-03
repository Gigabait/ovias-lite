--[[
	Ovias
	Copyright © Slidefuse LLC - 2012
]]--

AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self:GetOviasModel())
	self.isBuilt = false
	self:SetAngles(Angle(0, math.random(-180, 180), 0))

	self.foundationHull = ents.Create("ov_hull")
	self.foundationHull:SetPos(self:GetPos())
	self.foundationHull:SetAngles(self:GetAngles())
	self.foundationHull:SetParent(self)
	self.foundationHull:Activate()

	self.modelMins, self.modelMaxs = self:OBBMins(), self:OBBMaxs()

	self:SharedInit()

end

function ENT:Think()

	if (!self:GetBuilt()) then

		if (!self.calledPreBuild) then
			self:CreateFoundation()
			self:PreBuild()
			self.calledPreBuild = true
			self.startBuildTime = CurTime()
			self.endBuildTime = CurTime() + self:GetBuildTime()
			netstream.Start(player.GetAll(), "ovB_StartBuild", {ent = self})
		end

		self:Build()

		if (CurTime() >= self.endBuildTime) then
			self:SetBuilt(true)
		end

		return
	end
	
	if (!self.calledPostBuild) then
		self:PostBuild()
		self.calledPostBuild = true
		SF:Msg("Calling postBuild")
	end

end

function ENT:CreateFoundation()

	// Lets find the four corners and trace for the lowest possible height.
	local mins, maxs = self:WorldSpaceAABB()
	local z = maxs.z
	local testPoints = {
		Vector(mins.x, maxs.y, z),
		Vector(maxs.x, maxs.y, z),
		Vector(mins.x, mins.y, z),
		Vector(maxs.x, mins.y, z)
	}

	local distance = (maxs.z - mins.z)*2

	local maxHeight = -10000
		for _, tp in pairs(testPoints) do
		local t = SF.Util:SimpleTrace(tp, tp - Vector(0, 0, distance))
		if (t.HitPos.z >= maxHeight) then
			maxHeight = t.HitPos.z
		end
	end

	local pos = self:GetPos()
	self:SetPos(Vector(pos.x, pos.y, maxHeight+3))

	self:CalculateFoundation()
	self.foundationHull:ApplyPhysicsMesh(self.foundationPhysicsMeshTable)
end

function ENT:PostBuild() end

function ENT:PreBuild() end

function ENT:Build() 

end