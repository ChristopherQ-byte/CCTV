-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

include("shared.lua")

function ENT:Initialize()
	local rt = GetRenderTargetEx("Screen_"..self:EntIndex(),self["3D2DW"],self["3D2DH"],RT_SIZE_LITERAL,MATERIAL_RT_DEPTH_SHARED,32768,CREATERENDERTARGETFLAGS_HDR,IMAGE_FORMAT_DEFAULT)
	self["RT"] = rt

	local mat = CreateMaterial("Screen_"..self:EntIndex().."_"..os.time(),"UnlitGeneric")
	mat:SetTexture("$basetexture",rt)
	self["Mat"] = mat

	self["Queue"] = {self}
end

local function noSignal(rt)
	render.PushRenderTarget(rt)
		render.Clear(0,0,0,0,true,true)
		cam.Start2D()
			local w, h = rt:Width(), rt:Height()
			local factor = math.Round(w / 5)
			factor = factor - factor%2.5
			draw.SimpleText("Kein Signal","Font_"..factor,w/2,h/2,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		cam.End2D()
	render.PopRenderTarget()
end

local renderPos, renderAng
CurrentlyRenderingForScreen = false
local renderQueue = {}
local origin, angle = Vector(10,0,0), Angle(0,0,0)

local plyMeta = FindMetaTable("Player")
local entMeta = FindMetaTable("Entity")

/*
local oldGetPos
local function overrideGetPos(self)
	if self == LocalPlayer() then
		return renderPos
	else
		return oldGetPos(self)
	end
end

local oldEyePos
local function overrideEyePos(self)
	if self == LocalPlayer() then
		return renderPos
	else
		return oldEyePos(self)
	end
end

local oldGetAimVector
local function overrideGetAimVector(self)
	if self == LocalPlayer() then
		return renderAng:Forward()
	else
		return oldGetAimVector(self)
	end
end
*/

hook.Add("ShouldDrawLocalPlayer","Spycam",function() if CurrentlyRenderingForScreen then return true end end)
hook.Add("PreRender","Spycams",function()
	for i=#renderQueue, 1, -1 do
		local tab = renderQueue[i]
		local screen, camera = tab[1], tab[2]
		local rt = screen["RT"]
		render.PushRenderTarget(rt)
			render.Clear(0, 0, 0, 255)
			render.ClearDepth()
			render.ClearStencil()

			CurrentlyRenderingForScreen = true

			renderPos, renderAng = camera:LocalToWorld(origin), camera:LocalToWorldAngles(angle)
			
			/*
			oldGetPos = plyMeta["GetPos"]
			plyMeta["GetPos"] = overrideGetPos
			
			oldEyePos = plyMeta["EyePos"]
			plyMeta["EyePos"] = overrideEyePos
			
			oldGetAimVector = plyMeta["GetAimVector"]
			plyMeta["GetAimVector"] = overrideGetAimVector
			*/

			cam.Start2D()
			render.RenderView({
				["origin"] = renderPos,
				["angles"] = renderAng,
				
				["x"] = 0,
				["y"] = 0,
				["w"] = rt:Width(),
				["h"] = rt:Height(),
				["fov"] = 120,
				//["zfar"] = 2500,
				
				["drawhud"] = false,
				["drawviewmodel"] = false,
			})
			cam.End2D()

			/*
			plyMeta["GetPos"] = oldGetPos
			plyMeta["EyePos"] = oldEyePos
			plyMeta["GetAimVector"] = oldGetAimVector
			*/
			CurrentlyRenderingForScreen = false
		
		render.PopRenderTarget()
		renderQueue[i] = nil
	end
end)

function ENT:Think()
	self:SetNextClientThink(CurTime() + (1/(Ben_Derma.GetSetting("Camera_FPS") or 10)))

	if !self:ShouldDraw3D2D() then
		if self.Subscribed then
			net.Start("Screen:UnSubscribe")
			net.WriteEntity(self)
			net.SendToServer()
			self.Subscribed = nil
		end

		return true
	end

	if !self.Subscribed then
		net.Start("Screen:Subscribe")
		net.WriteEntity(self)
		net.SendToServer()
		self.Subscribed = true
	end

	local mode = self:GetMode()
	if mode == 0 then
		noSignal(self["RT"])
	elseif mode == 1 then 
		local camera = self:GetCamera()
		if IsValid(camera) and !camera:GetDestroyed() then
			if Ben_Derma.GetSetting("Camera_DontBlur") or LocalPlayer():GetEyeTrace().Entity == self then
				local q = self["Queue"]
				q[2] = camera
				table.insert(renderQueue,q)
				if self["Blurred"] then self["Blurred"] = false end
			else
				if !self["Blurred"] then
					render.BlurRenderTarget(self["RT"],3,3,10)
					self["Blurred"] = true
				end
			end
		else
			noSignal(self["RT"])
		end
	end

	return true
end

function ENT:DrawTranslucent()
	self:DrawModel()

	if !self:ShouldDraw3D2D() then return end

	local w, h = self["3D2DW"], self["3D2DH"]

	cam.Start3D2D(self:LocalToWorld(self["3D2DPos"]),self:LocalToWorldAngles(self["3D2DAng"]),.1)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(-w/2,-h/2,w,h)

		surface.SetMaterial(self["Mat"])
		surface.SetDrawColor(255,255,255)

		surface.DrawTexturedRect(-w/2,-h/2,w,h)
	cam.End3D2D()
end

net.Receive("Screen",function()
	local ent = net.ReadEntity()
	local str = net.ReadString()
	local myCams = net.ReadTable()

	local fr = Ben_Derma.Frame({
		["text"] = ent.PrintName,
		["w"] = 400,
		["h"] = 400,
	})

	local s = (fr:GetWide()-15) / 2
	local p
	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "Kamera",
		["y"] = 35,
		["w"] = s,
	})
	function b:Click()
		if IsValid(p) then p:Remove() end
		p = vgui.Create("DPanel",fr)
		p:SetSize(fr:GetWide()-10,fr:GetTall()-70)
		p:SetPos(5,65)
		function p:Paint() end

		local pnl = Ben_Derma.SubPanel({
			["parent"] = p,
			["text"] = "Verbundene Kamera",
			["w"] = p:GetWide(),
			["h"] = 85,
			["x"] = 0,
			["y"] = 0,
		})

		local tb = Ben_Derma.TextEntry({
			["parent"] = pnl,
			["x"] = 8,
			["w"] = pnl:GetWide()-13,
			["y"] = 25,
			["text"] = "Kamera-ID",
		})
		if IsValid(ent:GetCamera()) then
			tb:SetValue(str)
		end

		local b = Ben_Derma.Button({
			["parent"] = pnl,
			["x"] = 8,
			["w"] = pnl:GetWide()-13,
			["y"] = 55,
			["text"] = "Kamera-ID ändern",
		})
		function b:Clickable()
			return #tb:GetValue() > 0 and tb:GetValue() != str
		end
		function b:ClickFailed()
			if #tb:GetValue() == 0 then
				Notify("Keine Kamera-ID eingegeben!",0,5)
			else
				Notify("Kamera-ID ist identisch!",0,5)
			end
		end
		function b:Click()
			str = tb:GetValue()
			net.Start("Screen:Camera")
			net.WriteEntity(ent)
			net.WriteString(str)
			net.SendToServer()

			Notify("Kamera-ID geändert!",2,5)
		end
		local setCamButton = b

		// Own Cams
		local pnl = Ben_Derma.SubPanel({
			["parent"] = p,
			["text"] = "Deine Kameras",
			["w"] = p:GetWide(),
			["h"] = p:GetTall()-90,
			["x"] = 0,
			["y"] = 90,
		})

		local List = Ben_Derma.ScrollPanel({
			["parent"] = pnl,
			["w"] = pnl:GetWide()-13,
			["h"] = pnl:GetTall()-30,
			["x"] = 8,
			["y"] = 25,
			["autoResizeChildrenToW"] = true,
		})
		local cams = ents.FindByClass("spycam")
		for i=1, #cams do
			local camera = cams[i]
			if !myCams[camera] then continue end
			
			local b = Ben_Derma.Button({
				["text"] = myCams[camera],
			})
			function b:Clickable()
				return tb:GetValue() != myCams[camera]
			end
			function b:ClickFailed()
				Notify("Kamera bereits aktiv!",0,5)
			end

			function b:Click()
				tb:SetValue(myCams[camera])
				setCamButton:Click()
			end
			List:Add(b)
		end
		if #List.Canvas:GetChildren() == 0 then
			local p = Ben_Derma.SubPanel({
				["text"] = "Du hast keine eigenen Kameras",
				["h"] = 25,
			})
			List:Add(p)
		end

	end
	b:Click()

	local b = Ben_Derma.Button({
		["parent"] = fr,
		["text"] = "YouTube",
		["y"] = 35,
		["w"] = s,
		["x"] = s + 10,
	})
	function b:Clickable() return false end
	function b:ClickFailed() Notify("Noch nicht verfügbar..",0,5) end
end)

local dist = 300^2
function ENT:ShouldDraw3D2D()
	return LocalPlayer():EyePos():DistToSqr(self:GetPos()) < dist
end