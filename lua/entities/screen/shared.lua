-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

ENT.Type = "anim"
ENT.Base = "_benlib_ent"

ENT.Category = "CCTV"
ENT.PrintName = "Bildschirm Base"
ENT.Spawnable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT["3D2DPos"] = Vector(0,0,0)
ENT["3D2DAng"] = Angle(0,0,0)
ENT["3D2DW"] = 0
ENT["3D2DH"] = 0
ENT["Model"] = Model("models/props_phx/rt_screen.mdl")
ENT["IsScreen"] = true
ENT["DefaultHealth"] = 500

function ENT:SetupDataTables()
	self:NetworkVar("Entity",1,"owning_ent")
	self:NetworkVar("Int",0,"Mode") // 0: Off, 1: Camera, 2: MediaLib
	self:NetworkVar("Entity",0,"Camera")
end