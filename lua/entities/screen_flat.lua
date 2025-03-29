-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

if DarkRP and !ScreenFlat_AddedToDarkRPEntities then
	ScreenFlat_AddedToDarkRPEntities = true
	DarkRP.AddEntity("Bildschirm",{
		ent = "screen_flat",
		model = "models/props_phx/rt_screen.mdl",
		price = 1500,
		max = 2,
		cmd = "buy_sb_screen_flat",
	})
end

if SERVER then AddCSLuaFile() end

ENT.Base = "screen"
ENT.Category = "CCTV"
ENT.PrintName = "Fernseher"
ENT.Spawnable = true

ENT["3D2DPos"] = Vector(6.1,0,19)
ENT["3D2DAng"] = Angle(0,90,90)
ENT["3D2DW"] = 560
ENT["3D2DH"] = 335
ENT["Model"] = Model("models/props_phx/rt_screen.mdl")