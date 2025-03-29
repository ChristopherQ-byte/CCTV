-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

if DarkRP and !Camera_AddedToDarkRPEntities then
	Camera_AddedToDarkRPEntities = true
	DarkRP.AddEntity("Kamera",{
		ent = "spycam",
		model = "models/tools/camera/camera.mdl",
		price = 2500,
		max = 2,
		cmd = "buy_sb_camera",
	})
end

ENT.Type = "anim"
ENT.Base = "_benlib_ent"

ENT.Category = "CCTV"
ENT.PrintName = "Kamera"
ENT.Spawnable = true

ENT["Model"] = Model("models/tools/camera/camera.mdl")

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"owning_ent")
	self:NetworkVar("Bool",0,"Destroyed")
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