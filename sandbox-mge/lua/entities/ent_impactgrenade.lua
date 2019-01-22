AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Undermounted Grenade"

ENT.Spawnable = false
ENT.Model = "models/Items/AR2_Grenade.mdl"

local SplodeDamage = 50
local SplodeRadius = 250

local color_white = color_white or Color(255, 255, 255)
local color_red = Color(255, 0, 0)

local SpriteMat = Material("sprites/light_glow02_add")

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysWake()

		util.SpriteTrail(self, 0, color_white, false, 4, 1, 0.2, 0.1, "trails/smoke.vmt")
	end

	function ENT:Detonate()
		local boom = EffectData()
		boom:SetOrigin(self:GetPos())
		boom:SetFlags(4)
		util.Effect("Explosion", boom, true, true)

		self:EmitSound(Sound("Arena.Explosion"))

		util.BlastDamage(self, self.Owner, self:GetPos(), SplodeRadius, SplodeDamage)

		self:Remove()
	end

	function ENT:PhysicsCollide(data, phys)
		self:Detonate()
	end
else -- CLIENT
	function ENT:Draw()
		render.SetMaterial(SpriteMat)
		render.DrawSprite(self:GetPos(), 24, 24, self:GetOwner() == LocalPlayer() and color_white or color_red)

		self:DrawModel()
	end
end
