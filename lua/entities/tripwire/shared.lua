-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

ENT.Type = "anim"
ENT.Base = "_benlib_ent"

ENT.Category = "CCTV"
ENT.PrintName = "Alarmanlage"
ENT.Spawnable = false

//ENT.RenderGroup = RENDERGROUP_BOTH

ENT["MaxRange"] = 75

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"owning_ent")
	self:NetworkVar("Int",0,"Range")
	self:NetworkVar("Bool",0,"Destroyed")
	
	if CLIENT then
		self:NetworkVarNotify("Range",function(ent,name,old,new)
			self:SetRenderBounds(
				self:OBBMins() + Vector(-(new+4), 0, 0 ),
				self:OBBMaxs()
			)
		end)
	end
end

local s = 2
local mins, maxs, startOff = Vector(-s,-s,-s), Vector(s,s,s), Vector(-4,0,8.2)
local a = Vector(0,0,8.2)
function ENT:DoTrace()
	a["x"] = -4 -self:GetRange()

	return util.TraceHull({
		["start"] = self:LocalToWorld(startOff),
		["endpos"] = self:LocalToWorld(a),
		["mins"] = mins,
		["maxs"] = maxs,
		["filter"] = self, //self.Whitelist or self,
	})
end

local price
function ENT:GetRepairPrice()
	if !price then
		local class = string.lower(self:GetClass())
		for i=1, #DarkRPEntities do
			local item = DarkRPEntities[i]
			if item["ent"] != class then continue end
			price = item["price"]
			return price
		end
	end
	return price
end

function ENT:WriteWhitelist()
	local t = self.Whitelist
	net.WriteUInt(#t,7)
	for k,v in ipairs(t) do
		net.WriteEntity(v)
	end
end

function ENT:ReadWhitelist()
	local t = {}
	self.Whitelist = t
	local t2 = {}
	self.WhitelistKeys = t2
	for i=1, net.ReadUInt(7) do
		local e = net.ReadEntity()
		t[i] = e
		t2[e] = true
	end
end