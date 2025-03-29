-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SpyCamerasByKeys = {}
function ENT:Initialize()
	self:SetModel(self["Model"])
	//self:PhysicsInit(SOLID_VPHYSICS)
	local mins, maxs = self:GetModelBounds()
	self:PhysicsInitBox(mins,maxs)
	self:GetPhysicsObject():Wake()

	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	self:SetHealth(100)
	self:SetMaxHealth(100)

	local key = {}
	for i=1, 10 do key[i] = math.random(0,9) end
	self.Key = table.concat(key,"")
	SpyCamerasByKeys[self.Key] = self

	timer.Simple(0,function()
		if !IsValid(self) then return end

		local ply = self:Getowning_ent()
		if !IsValid(ply) then return end
			
		if !ply.Cameras then
			ply.Cameras = {}
		end

		ply.Cameras[self] = self.Key
		self:CPPISetOwner(ply)
	end)
end

function ENT:OnOwnerReJoin(ply)
	if !ply.Cameras then
		ply.Cameras = {}
	end

	ply.Cameras[self] = self.Key
end

util.AddNetworkString("Spycam")
function ENT:Use(ply)
	if self:Getowning_ent() != ply then return end

	if self:GetDestroyed() then
		net.Start("Security:Repair")
		net.WriteEntity(self)
		net.Send(ply)
	else
		net.Start("Spycam")
		net.WriteEntity(self)
		net.WriteString(self.Key)
		net.Send(ply)
	end
end

function ENT:OnRemove()
	local ply = self:Getowning_ent()
	if !IsValid(ply) then return end
	if !ply.Cameras then return end
	ply.Cameras[self] = nil
end

net.Receive("Spycam",function(_,ply)
	local camera = net.ReadEntity()

	if camera:Getowning_ent() != ply then return end

	local newKey = net.ReadString()
	
	SpyCamerasByKeys[camera.Key] = nil
	SpyCamerasByKeys[newKey] = camera
	camera.Key = newKey

	ply.Cameras[camera] = newKey
end)

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health()-dmg:GetDamage())
	if self:Health() > 0 then return end

	if self:GetDestroyed() then
		if self:Health() > -300 then return end
		self:Remove()
	else
		self:SetDestroyed(true)

		local effectData = EffectData()
		effectData:SetEntity(self)
		util.Effect("electric_destroy", effectData)
	end
end