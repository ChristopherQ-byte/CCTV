-- [[ THIS CODE IS WRITTEN BY BENN20002 (76561198114067146) DONT COPY OR STEAL! ]] -- 

function EFFECT:Init(effectData)
	local ent = effectData:GetEntity()
	if !IsValid(ent) then return end

	local pos = ent:GetPos()
	
	ent:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav")

	local pe = ParticleEmitter(pos,false)
	for i=1, 30 do
		local p = pe:Add("effects/spark",pos)
		if !p then continue end
		p:SetDieTime(1)
		p:SetStartAlpha(255)
		p:SetEndAlpha(0)
		p:SetStartSize(3)
		p:SetEndSize(0)
		p:SetGravity(Vector(0,0,-500))
		p:SetVelocity(VectorRand() * 50 + Vector(0,0,150))
	end
	pe:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render() end