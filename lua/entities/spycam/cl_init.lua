-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

include("shared.lua")

function ENT:Initialize()
	self.PixVis = util.GetPixelVisibleHandle()
end

local COLOR_RED = Color(255,0,0,150)
local COLOR_GREEN = Color(0,255,0,150)
local mat = Material("sprites/light_ignorez")
local vec = Vector(1.3,2.5,-2.4)

function ENT:Draw()
	self:DrawModel()

	local pos = self:LocalToWorld(vec)

	if util.PixelVisible(pos,4,self.PixVis) < .5 then return end

	render.SetMaterial(mat)
	render.DrawSprite(pos,6,6,self:GetDestroyed() and COLOR_RED or COLOR_GREEN)
end

net.Receive("Spycam",function()
	local camera = net.ReadEntity()
	local key = net.ReadString()

	local fr = Ben_Derma.Frame({
		["text"] = "Camera Frequenz",
		["w"] = 300,
		["h"] = 95,
	})

	local tb = Ben_Derma.TextEntry({
		["parent"] = fr,
		["text"] = "Frequenz",
		["w"] = fr:GetWide()-10,
		["y"] = 35,
	})
	tb:SetValue(key)

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Frequenz ändern",
		["w"] = fr:GetWide()-10,
		["y"] = 65,
	})
	function b:Click()
		net.Start("Spycam")
		net.WriteEntity(camera)
		net.WriteString(tb:GetValue())
		net.SendToServer()
		fr:Remove()
	end
end)
