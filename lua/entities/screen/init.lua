-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self["Model"])
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:GetPhysicsObject():Wake()
	self:SetMode(0)
	self["Subscribed"] = {}
	self:SetMaxHealth(self["DefaultHealth"])
	self:SetHealth(self:GetMaxHealth())

	timer.Simple(0,function()
		if !IsValid(self) then return end
		local ply = self:Getowning_ent()
		if !IsValid(ply) then return end
		self:CPPISetOwner(ply)
	end)
end

util.AddNetworkString("Screen")
function ENT:Use(ply)
	if self:Getowning_ent() != ply then return end
	
	local str
	local camera = self:GetCamera()
	if IsValid(camera) then
		str = camera.Key
	end

	net.Start("Screen")
	net.WriteEntity(self)
	net.WriteString(str or "")
	net.WriteTable(ply.Cameras or {})
	net.Send(ply)
end

util.AddNetworkString("Screen:Camera")
net.Receive("Screen:Camera",function(_,ply)
	local ent = net.ReadEntity()
	ent:SetMode(1)
	ent:SetCamera(SpyCamerasByKeys[net.ReadString()])
end)

SubscribedScreens = SubscribedScreens or {}
util.AddNetworkString("Screen:Subscribe")
net.Receive("Screen:Subscribe",function(_,ply)
	local cam = net.ReadEntity()

	if !cam["Subscribed"] then return end
	cam["Subscribed"][ply] = true

	local t = SubscribedScreens[ply]
	if !t then
		t = {}
		SubscribedScreens[ply] = t
	end
	table.insert(t,cam)
end)

util.AddNetworkString("Screen:UnSubscribe")
net.Receive("Screen:UnSubscribe",function(_,ply)
	local cam = net.ReadEntity()

	if !cam["Subscribed"] then return end
	cam["Subscribed"][ply] = nil

	local tab = SubscribedScreens[ply]
	table.RemoveByValueI(tab,cam)

	if #tab == 0 then
		SubscribedScreens[ply] = nil
	end
end)

hook.Add("EntityRemoved","SubscribedScreens",function(cam)
	if !cam["IsScreen"] then return end

	for ply, v in pairs(cam["Subscribed"]) do
		local t = SubscribedScreens[ply]
		if t then
			table.RemoveByValueI(t,cam)
		end
	end
end)

hook.Add("PlayerDisconnected","SubscribedScreens",function(ply)
	if !SubscribedScreens[ply] then return end

	for k,v in ipairs(SubscribedScreens[ply]) do
		v["Subscribed"][ply] = nil
	end
	SubscribedScreens[ply] = nil
end)

/*
hook.Add("PostGamemodeLoaded","SetupVisibility",function(ply)
	local entMeta = FindMetaTable("Entity")
	local plyMeta = FindMetaTable("Player")

	local isValid = entMeta["IsValid"]
	local getPos = entMeta["GetPos"]
	//local isPlayer = entMeta["IsPlayer"]
	//local getShootPos = plyMeta["GetShootPos"]
	local getCamera = entMeta["GetDTEntity"]
	local getDestroyed = entMeta["GetDTBool"]

	function GAMEMODE:SetupPlayerVisibility(ply)
		local screens = SubscribedScreens[ply] //ply["SubscribedScreens"]
		if screens then
			for k, v in ipairs(screens) do
				local cam = getCamera(v,0) //v:GetCamera()
				if !isValid(cam) then continue end
				//if cam:GetDestroyed() then continue end
				if getDestroyed(cam,0) then continue end
				AddOriginToPVS(getPos(cam))
			end
		end
		
		local specData = FSpecData[ply]
		if specData then
			local ent = specData[1]
			if isValid(ent) then
				AddOriginToPVS(getPos(ent))
			else
				local pos = specData[2]
				if pos then
					AddOriginToPVS(pos)
				end
			end
		end
	end
end)
*/

local entMeta = FindMetaTable("Entity")
local isValid = entMeta["IsValid"]
local getPos = entMeta["GetPos"]
local getCamera = entMeta["GetDTEntity"]
local getDestroyed = entMeta["GetDTBool"]
hook.Add("SetupPlayerVisibility", "CCTV Cameras", function(ply)
	local screens = SubscribedScreens[ply]
	if screens then
		for k, v in ipairs(screens) do
			local cam = getCamera(v,0)
			if !isValid(cam) then continue end
			if getDestroyed(cam,0) then continue end
			AddOriginToPVS(getPos(cam))
		end
	end
end)

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health()-dmg:GetDamage())
	if self:Health() > 0 then return end

	self:Remove()
end