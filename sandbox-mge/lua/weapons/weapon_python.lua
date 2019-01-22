AddCSLuaFile()

game.AddAmmoType({name = "pythonbullets"})
if CLIENT then
	language.Add("pythonbullets_ammo", "Bullets")
end

SWEP.PrintName = "Python Revolver"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE]</color> Fire a bullet.
<color=green>[SECONDARY FIRE]</color> Fan the hammer.
Fanning provides a greater fire rate with heavily reduced accuracy.]]

SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "pythonbullets"

SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Damage = 40
SWEP.Primary.NumShots = 1
SWEP.Primary.Recoil = 12

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Secondary.Delay = 0.3
SWEP.Secondary.Cone = 0.06

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

local DefaultPos = Vector(1.44, 0, -1.88)
local DefaultAng = Vector(0, 0, 0)

local IronPos = Vector(-3.401, 0, -4.56)
local IronAng = Vector(0, 0, 0)

SWEP.ViewModelPos = DefaultPos
SWEP.ViewModelAng = DefaultAng

local ShootSound = Sound("Weapon_357.Single")

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self:SetHoldType("revolver")
end

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and not self.reloading
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:ShootEffects()
	self:EmitSound(ShootSound)

	local bullet = {}
	bullet.Num = self.Primary.NumShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Tracer = 1
	bullet.Force = 20
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = "Pistol"

	if self.Owner:KeyDown(IN_ATTACK2) then
		self:SetNextPrimaryFire(CurTime() + self.Secondary.Delay)
		bullet.Spread = Vector(self.Secondary.Cone, self.Secondary.Cone, 0)
	else
		self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
		bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
	end

	self.Owner:FireBullets(bullet)
	self.Owner:ViewPunch(Angle(-3, math.random(-1.5, 1.5), 0))

	if self.Owner:GetAmmoCount(self.Primary.Ammo) > self.Primary.DefaultClip then
		self.Owner:SetAmmo(self.Primary.DefaultClip, self.Primary.Ammo)
	end

	self.Owner:RemoveAmmo(1, self.Primary.Ammo)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self.needs_reload = true
	end
end

function SWEP:CanSecondaryAttack() return false end

function SWEP:Reload()
	if not IsFirstTimePredicted() or self.Owner:GetAmmoCount(self.Primary.Ammo) >= self.Primary.DefaultClip or self.reloading then return end

	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:GetViewModel():SetPlaybackRate(1.5)
	self.Owner:SetAnimation(PLAYER_RELOAD)

	self.reload_timer = CurTime() + (self:SequenceDuration() * (2 / 3))
	self.reloading = true
end

function SWEP:Think()
	if self.needs_reload then
		self.needs_reload = false
		self:Reload()
	end

	if self.reloading and self.reload_timer <= CurTime() then
		self.reloading = false
		self.reload_timer = 0

		self.Owner:SetAmmo(self.Primary.DefaultClip, self.Primary.Ammo)
	end

	if CLIENT then
		if not self.Owner:KeyDown(IN_ATTACK2) or self.reloading then
			self.ViewModelPos = LerpVector(FrameTime() * 5, self.ViewModelPos, DefaultPos)
			self.ViewModelAng = LerpVector(FrameTime() * 5, self.ViewModelAng, DefaultAng)
		else
			self.ViewModelPos = LerpVector(FrameTime() * 5, self.ViewModelPos, IronPos)
			self.ViewModelAng = LerpVector(FrameTime() * 5, self.ViewModelAng, IronAng)
		end
	end
end

function SWEP:Deploy()
	self.reloading = false
	self.reload_timer = 0

	return self.BaseClass.Deploy(self)
end

function SWEP:GetViewModelPosition(pos, ang)
	local Offset = self.ViewModelPos

	if self.ViewModelAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), self.ViewModelAng.x)
		ang:RotateAroundAxis(ang:Up(), self.ViewModelAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.ViewModelAng.z)
	end

	local r = ang:Right()
	local u = ang:Up()
	local f = ang:Forward()

	pos = pos + Offset.x * r
	pos = pos + Offset.y * f
	pos = pos + Offset.z * u

	return pos, ang
end
