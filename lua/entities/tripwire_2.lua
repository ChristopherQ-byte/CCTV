-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

if DarkRP and !Tripwire1_AddedToDarkRPEntities then
	Tripwire1_AddedToDarkRPEntities = true
	DarkRP.AddEntity("Alarmanlage (Simpel)",{
		ent = "tripwire_1",
		model = "models/Items/battery.mdl",
		price = 1000,
		max = 2,
		cmd = "buy_sb_tripwire_1",
	})
end

if SERVER then AddCSLuaFile() end

ENT.Base = "tripwire"
ENT.Category = "CCTV"
ENT.PrintName = "Alarmanlage (Erweitert)"
ENT.Spawnable = true

ENT.Notify = true