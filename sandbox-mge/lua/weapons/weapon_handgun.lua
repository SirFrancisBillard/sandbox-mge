AddCSLuaFile()

game.AddAmmoType({name = "handgunbullets"})
if CLIENT then
	language.Add("handgunbullets_ammo", "Bullets")
end

SWEP.PrintName = "Handgun"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE]</color> Fire a bullet.]]

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "handgunbullets"

SWEP.Primary.Cone = 0.03
SWEP.Primary.Delay = 0.2
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Recoil = 0.12

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModelPos = Vector(0.759, 0, -1.04)
SWEP.ViewModelAng = Vector(0, 0, 0)

SWEP.Timers = {"MagOut", "MagIn", "MagHit"}

local ShootSound = Sound("Weapon_Pistol.Single")

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self:SetHoldType("pistol")
end

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and not self.reloading
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:ShootEffects()
	self:EmitSound(ShootSound)

	local bullet = {}
	bullet.Num = self.Primary.NumShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
	bullet.Tracer = 1
	bullet.Force = 20
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets(bullet)
	--self.Owner:ViewPunch(Angle(-0.8, math.random(-0.4, 0.4), 0))

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

	self:SoundTimer("MagOut", 0.05, "arena/weapons/handling/pistol_magout.wav")
	self:SoundTimer("MagIn", 0.5, "arena/weapons/handling/pistol_magin.wav")
	self:SoundTimer("MagHit", 0.85, "arena/weapons/handling/pistol_maghit.wav")

	self.reload_timer = CurTime() + self:SequenceDuration() + 0.1
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
end

function SWEP:Deploy()
	self.reloading = false
	self.reload_timer = 0

	return self.BaseClass.Deploy(self)
end

function SWEP:Holster()
	self:ResetTimers()

	return self.BaseClass.Holster(self)
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
