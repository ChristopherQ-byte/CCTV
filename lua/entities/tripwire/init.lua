-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SpyCamerasByKeys = {}
AllSpyCameras = {}
function ENT:Initialize()
	self:SetModel("models/Items/battery.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:GetPhysicsObject():Wake()
	self:EnableCustomCollisions(true)
	self:SetTrigger(true)

	self.Whitelist = {} //{self}
	self.WhitelistKeys = {} //{self}
	self.WhitelistCPs = false
	self.Touching = 0

	self:SetRange(self["MaxRange"]/2)
	self:GenCollision()

	self:SetHealth(50)
	self:SetMaxHealth(50)

	timer.Simple(0,function()
		if !IsValid(self) then return end
		
		local ply = self:Getowning_ent()
		if !IsValid(ply) then return end

		self:CPPISetOwner(ply)
		table.insert(self.Whitelist,ply)
		self.WhitelistKeys[ply] = true
	end)
end

ENT["PP_KeepSolid"] = true
function ENT:StartTouch()
	local tr = self:DoTrace()
	local ent = tr.Entity
	if IsValid(ent) and !self.WhitelistKeys[ent] and (!ent:IsPlayer() or Either(self.WhitelistCPs,!ent:isCP(),true)) then
		self:StartAlarm()
	end
end

function ENT:EndTouch()
	local tr = self:DoTrace()

	local ent = tr.Entity
	if !(IsValid(ent) and !self.WhitelistKeys[ent] and (!ent:IsPlayer() or Either(self.WhitelistCPs,!ent:isCP(),true))) then
		self:StopAlarm()
	end
end

function ENT:GenCollision()
	local x0 = -4.5-(self:GetRange()) -- Define the min corner of the box
	local y0 = -2
	local z0 = 0
	local x1 = 2 -- Define the max corner of the box
	local y1 = 2
	local z1 = 10

	self:PhysicsInitConvex({
		Vector( x0, y0, z0 ),
		Vector( x0, y0, z1 ),
		Vector( x0, y1, z0 ),
		Vector( x0, y1, z1 ),
		Vector( x1, y0, z0 ),
		Vector( x1, y0, z1 ),
		Vector( x1, y1, z0 ),
		Vector( x1, y1, z1 )
	})
end

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health()-dmg:GetDamage())

	if self:Health() > 0 then return end
	if self:GetDestroyed() then return end
	self:SetDestroyed(true)

	self:StopAlarm()
	self.SoundEnd = 0

	local effectData = EffectData()
	effectData:SetOrigin(self:GetPos())
	util.Effect("electric_destroy", effectData)
end

util.AddNetworkString("Tripwire")
util.AddNetworkString("Security:Repair")
function ENT:Use(ply)
	if self:Getowning_ent() != ply then return end
	
	if self:GetDestroyed() then
		net.Start("Security:Repair")
		net.WriteEntity(self)
		net.Send(ply)
	else
		net.Start("Tripwire")
		net.WriteEntity(self)
		net.WriteBool(self.WhitelistCPs)
		self:WriteWhitelist()
		net.Send(ply)
	end
end

net.Receive("Tripwire",function(_,ply)
	local ent = net.ReadEntity()
	ent:SetRange(math.Clamp(net.ReadUInt(8),1,ent["MaxRange"]))
	ent:GenCollision()
end)

util.AddNetworkString("Tripwire:Whitelist")
net.Receive("Tripwire:Whitelist",function(_,ply)
	local ent = net.ReadEntity()
	if self:Getowning_ent() != ply then return end
	ent.WhitelistCPs = net.ReadBool()
	ent:ReadWhitelist()
end)

net.Receive("Security:Repair",function(_,ply)
	local ent = net.ReadEntity()
	local cost = ent:GetRepairPrice()
	if ply:GetMoney() < cost then return end
	ply:TakeMoney(cost)
	ent:SetDestroyed(false)
	ent:SetHealth(ent:GetMaxHealth())
end)

// ALARM
sound.Add({
	["name"] = "tripwire_alarm",
	["volume"] = .8,
	["level"] = 80,
	["sound"] = "ambient/alarms/alarm1.wav",
})

function ENT:StartAlarm()
	if self.AlarmPlaying then return end
	self.AlarmPlaying = true

	if self.SoundEnd then
		self.SoundEnd = nil
	else
		self:EmitSound("tripwire_alarm")
		local ply = self:Getowning_ent()
		if IsValid(ply) and self["Notify"] then
			Notify(ply,"Deine Alarmanlage wurde ausgelößt!",1,5)
		end
	end
end

function ENT:StopAlarm()
	if !self.AlarmPlaying then return end
	self.AlarmPlaying = false

	self.SoundEnd = CurTime() + 2
end

function ENT:Think()
	local soundEnd = self.SoundEnd
	if soundEnd and soundEnd < CurTime() then
		self:StopSound("tripwire_alarm")
		self.SoundEnd = nil
	end

	self:NextThink(CurTime() + .5)
	return true
end

function ENT:OnRemove()
	self:StopSound("tripwire_alarm")
end