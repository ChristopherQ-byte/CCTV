-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

if DarkRP and !ScreenFlat_AddedToDarkRPEntities then
	ScreenFlat_AddedToDarkRPEntities = true
	DarkRP.AddEntity("Monitor",{
		ent = "screen_monitor",
		model = "models/cs_office/computer_monitor.mdl",
		price = 750,
		max = 2,
		cmd = "buy_sb_screen_monitor",
	})
end

if SERVER then AddCSLuaFile() end

ENT.Base = "screen"
ENT.Category = "CCTV"
ENT.PrintName = "Monitor"
ENT.Spawnable = true

ENT["3D2DPos"] = Vector(3.3,0,16.75)
ENT["3D2DAng"] = Angle(0,90,90)
ENT["3D2DW"] = 210
ENT["3D2DH"] = 160
ENT["Model"] = Model("models/cs_office/computer_monitor.mdl")