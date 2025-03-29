-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] --

if DarkRP and !Tripwire2_AddedToDarkRPEntities then
	Tripwire2_AddedToDarkRPEntities = true
	DarkRP.AddEntity("Alarmanlage (Erweitert)",{
		ent = "tripwire_2",
		model = "models/Items/battery.mdl",
		price = 5500,
		max = 2,
		cmd = "buy_sb_tripwire_2",
	})
end

if SERVER then AddCSLuaFile() end

ENT.Base = "tripwire"
ENT.Category = "CCTV"
ENT.PrintName = "Alarmanlage (Simpel)"
ENT.Spawnable = true

ENT.Notify = false