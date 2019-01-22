AddCSLuaFile()

game.AddAmmoType({name = "m16generic"})
if CLIENT then
	language.Add("m16generic_ammo", "Bullets")
end

SWEP.PrintName = "Assault Rifle"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE]</color> Fire a bullet.
Bullets become less accurate the longer they are fired.
Accuracy can be regained by not firing.
<color=green>[SECONDARY FIRE]</color> Launch a grenade.
Grenades will explode upon contact with surfaces.]]

SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "m16generic"

SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.1
SWEP.Primary.Damage = 12
SWEP.Primary.NumShots = 1
SWEP.Primary.Recoil = 12

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Secondary.Delay = 3
SWEP.Secondary.TakeAmmo = 6

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.CSMuzzleFlashes = true

SWEP.IronSightsPos = Vector(-0.921, 0, -1.16)
SWEP.IronSightsAng = Vector(1.6, -0.7, 0)

local ShootSound = Sound("Weapon_M4A1.Single")
local NadeSound = Sound("weapons/grenade_launcher1.wav")
local MaxConeModifier = 0.08

function SWEP:Initialize()
	self.BaseClass.Initialize(self)

	self:SetHoldType("ar2")
	self.cone_modifier = 0
end

function SWEP:CanPrimaryAttack()
	return self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 and not self.reloading
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	self:ShootEffects()
	self:EmitSound(ShootSound)

	local bullet = {}
	bullet.Num = self.Primary.NumShots
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(self.Primary.Cone + self.cone_modifier, self.Primary.Cone + self.cone_modifier, 0)
	bullet.Tracer = 1
	bullet.Force = 20
	bullet.Damage = self.Primary.Damage
	bullet.AmmoType = "Pistol"

	self.Owner:FireBullets(bullet)
	self.Owner:ViewPunch(Angle(-0.5, math.random(-0.2, 0.2), 0))

	self.cone_modifier = math.min(MaxConeModifier, self.cone_modifier + 0.01)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) > self.Primary.DefaultClip then
		self.Owner:SetAmmo(self.Primary.DefaultClip, self.Primary.Ammo)
	end

	self.Owner:RemoveAmmo(1, self.Primary.Ammo)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self.needs_reload = true
	end
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:SecondaryAttack()
	-- not a typo, they use the same conditions
	if not self:CanPrimaryAttack() then return end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)

	self:ShootEffects()
	self:EmitSound(NadeSound)

	if SERVER then
		local nade = ents.Create("ent_impactgrenade")

		if not IsValid(nade) then return end

		nade:SetOwner(self.Owner)
		nade:SetPos(self.Owner:EyePos())
		nade:SetAngles(self.Owner:EyeAngles())
		nade:Spawn()

		local phys = nade:GetPhysicsObject()
		if not IsValid(phys) then nade:Remove() return end

		local velocity = self.Owner:GetAimVector()
		velocity = velocity * 4000
		phys:ApplyForceCenter(velocity)
	end

	self.Owner:RemoveAmmo(math.Clamp(self.Secondary.TakeAmmo, 1, self.Owner:GetAmmoCount(self.Primary.Ammo)), self.Primary.Ammo)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) < 1 then
		self.needs_reload = true
	end
end

function SWEP:Reload()
	if not IsFirstTimePredicted() or self.Owner:GetAmmoCount(self.Primary.Ammo) >= self.Primary.DefaultClip or self.reloading then return end

	self:SendWeaponAnim(ACT_VM_RELOAD)
	self.Owner:GetViewModel():SetPlaybackRate(1.5)
	self.Owner:SetAnimation(PLAYER_RELOAD)

	self.reload_timer = CurTime() + (self:SequenceDuration() * (2 / 3))
	self.reloading = true
end

function SWEP:Think()
	self.cone_modifier = math.max(0, self.cone_modifier - (FrameTime() / 25))

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
	local Offset = self.IronSightsPos

	if self.IronSightsAng then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x)
		ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y)
		ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z)
	end

	local r = ang:Right()
	local u = ang:Up()
	local f = ang:Forward()

	pos = pos + Offset.x * r
	pos = pos + Offset.y * f
	pos = pos + Offset.z * u

	return pos, ang
end
