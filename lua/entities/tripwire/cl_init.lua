-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

include("shared.lua")

function ENT:Initialize()
	timer.Simple(1,function()
		if !IsValid(self) then return end
		self:SetRange(self:GetRange())
	end)
	self.PixVis1 = util.GetPixelVisibleHandle()
	self.PixVis2 = util.GetPixelVisibleHandle()
end

local COLOR_RED = Color(255,0,0,255)
local mat = Material("sprites/light_ignorez")
local dist = 300^2
function ENT:Draw()
	self:DrawModel()
	if self:GetDestroyed() then return end
	if LocalPlayer():EyePos():DistToSqr(self:GetPos()) > dist then return end
	
	local start = self:LocalToWorld(Vector(-4.5,0,8.2))
	local tr = self:DoTrace()
	local stop = tr.HitPos or self:LocalToWorld(Vector(-3 -self:GetRange(),0,8.2))

	render.SetMaterial(mat)

	if util.PixelVisible(start,5,self.PixVis1) > .99 then
		render.DrawSprite(start,5,5,COLOR_RED)
	end

	local s = tr.Hit and 3 or 1
	if util.PixelVisible(stop,s,self.PixVis2) > .75 then
		render.DrawSprite(stop,s,s,COLOR_RED)
	end
	
	render.DrawLine(start,stop,COLOR_RED,true)
end

local COLOR_GREEN = Color(0,255,0,10)
net.Receive("Tripwire",function()
	local ent = net.ReadEntity()
	local cps = net.ReadBool()
	ent:ReadWhitelist()

	local whitelist = ent.Whitelist

	local fr = Ben_Derma.Frame({
		["text"] = "Alarmanlage",
		["w"] = 300,
		["h"] = 350,
	})

	// Range
	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["text"] = "Reichweite",
		["w"] = fr:GetWide()-10,
		["h"] = 85,
		["y"] = 35,
	})

	local slid = Ben_Derma.Slider({
		["parent"] = p,
		["w"] = p:GetWide()-13,
		["x"] = 8,
		["y"] = 25,
		["min"] = 10,
		["max"] = ent["MaxRange"],
		["decimals"] = 0,
		["start"] = ent:GetRange(),
	})

	local s = (p:GetWide()-18)/2
	
	local b = Ben_Derma.Button({
		["parent"] = p,
		["text"] = "Automatisch",
		["w"] = s,
		["x"] = 8,
		["y"] = 55,
	})
	function b:Click()
		local oldRange = ent:GetRange()
		ent:SetRange(ent["MaxRange"])
		local tr = ent:DoTrace()
		ent:SetRange(oldRange)
		if !tr.Hit then
			slid:SetSlideX(1)
		else
			local dist = tr["StartPos"] - tr.HitPos
			slid:SetValue(dist:Length()-1)
		end
	end

	local b = Ben_Derma.Button({
		["parent"] = p,
		["text"] = "Speichern",
		["w"] = s,
		["x"] = s + 13,
		["y"] = 55,
	})
	function b:Click()
		net.Start("Tripwire")
		net.WriteEntity(ent)
		net.WriteUInt(slid:GetValue(),32)
		net.SendToServer()
		//fr:Remove()
	end


	// Whitelist
	local p = Ben_Derma.SubPanel({
		["parent"] = fr,
		["text"] = "Whitelist",
		["w"] = fr:GetWide()-10,
		["h"] = fr:GetTall()-130,
		["y"] = 125,
	})
	local sw = Ben_Derma.Switch({
		["parent"] = p,
		["w"] = 165,
		["text"] = "Staatsbeamte",
		["x"] = p:GetWide()-170,
		["y"] = 2.5,
		["start"] = cps,
	})
	function sw:OnValueChanged(new)
		net.Start("Tripwire:Whitelist")
		net.WriteEntity(ent)
		net.WriteBool(new)
		ent:WriteWhitelist()
		net.SendToServer()
	end
	local tb = Ben_Derma.TextEntry({
		["parent"] = p,
		["text"] = "Suche",
		["w"] = p:GetWide()-13,
		["x"] = 8,
		["y"] = 25,
	})
	local List = Ben_Derma.ScrollPanel({
		["parent"] = p,
		["x"] = 8,
		["y"] = 55,
		["h"] = p:GetTall()-30-30,
		["w"] = p:GetWide()-13,
		["autoResizeChildrenToW"] = true,
	})

	local function makeList(search)
		List:Clear()
		local plys = player.GetAll()
		for i=1, #plys do
			local ply = plys[i]
			if ply == LocalPlayer() then continue end
			if search and #search > 0 then
				if !string.find(ply:Name(),search) then continue end
			end

			local b = Ben_Derma.Button({
				["text"] = ply:Name(), 
			})
			function b:PrePaint(w,h)
				if table.HasValue(whitelist,ply) then
					draw.RoundedBox(0,0,0,w,h,COLOR_GREEN)
				end
			end
			function b:Click()
				if table.HasValue(whitelist,ply) then
					table.RemoveByValue(whitelist,ply)
				else
					table.insert(whitelist,ply)
				end
				
				net.Start("Tripwire:Whitelist")
				net.WriteEntity(ent)
				net.WriteBool(sw:GetValue())
				net.WriteUInt(#whitelist,7)
				ent:WriteWhitelist()
				net.SendToServer()
			end
			List:Add(b)
		end
		if List:IsEmpty() then
			local p = Ben_Derma.SubPanel({
				["h"] = 25,
				["text"] = "Kein Ergebnis",
			})
			List:Add(p)
		end
	end
	makeList()
	function tb:OnValueChanged(new)
		makeList(new)
	end
end)

net.Receive("Security:Repair",function()
	local ent = net.ReadEntity()
	local fr = Ben_Derma.Frame({
		["text"] = "Reparieren",
		["w"] = 250,
		["h"] = 65,
	})

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Für "..DarkRP.formatMoney(ent:GetRepairPrice()).." reparieren",
		["w"] = fr:GetWide()-10,
		["y"] = 35,
	})

	function b:Clickable() return LocalPlayer():GetMoney() >= ent:GetRepairPrice() end
	function b:ClickFailed() Notify("Du hast nicht genug Geld auf der Hand!",0,5) end
	function b:Click()
		net.Start("Security:Repair")
		net.WriteEntity(ent)
		net.SendToServer()
		fr:Remove()
	end
end)