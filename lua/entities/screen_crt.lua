-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

if DarkRP and !ScreenCRT_AddedToDarkRPEntities then
	ScreenCRT_AddedToDarkRPEntities = true
	DarkRP.AddEntity("CRT Monitor",{
		ent = "screen_crt",
		model = "models/props_lab/monitor01a.mdl",
		price = 500,
		max = 2,
		cmd = "buy_sb_screen_crt",
	})
end

if SERVER then AddCSLuaFile() end

ENT.Base = "screen"
ENT.Category = "CCTV"
ENT.PrintName = "CRT Monitor"
ENT.Spawnable = true

ENT["3D2DPos"] = Vector(12.4,0,3.8)
ENT["3D2DAng"] = Angle(0,90,85.5)
ENT["3D2DW"] = 200
ENT["3D2DH"] = 164
ENT["Model"] = Model("models/props_lab/monitor01a.mdl")
