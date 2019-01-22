AddCSLuaFile()

game.AddAmmoType({name = "goldengunbullets"})
if CLIENT then
	language.Add("goldengunbullets_ammo", "Bullets")
end

SWEP.PrintName = "Golden Gun"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE]</color> Fire a bullet.
Golden gun bullets are capable of instantly killing targets.

<color=yellow>Unlike what its name would suggest, this weapon is not actually made out of gold.</color>]]

SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "goldengunbullets"

SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.6
SWEP.Primary.Damage = 1337
SWEP.Primary.NumShots = 1
SWEP.Primary.Recoil = 12

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModelPos = Vector(0.759, 0, -1.04)
SWEP.ViewModelAng = Vector(0, 0, 0)

local ShootSound = Sound("Weapon_Deagle.Single")

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
	bullet.Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0)
	bullet.Tracer = 1
	bullet.Force = 20
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets(bullet)
	self.Owner:ViewPunch(Angle(-8, math.random(-4, 4), 0))

	if CLIENT then return end

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
