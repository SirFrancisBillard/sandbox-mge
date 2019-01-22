AddCSLuaFile()

-- ! MGE VERSION !

SWEP.Base = "weapon_sck_base"

SWEP.PrintName = "Molotov Cocktail"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE] Throw.]]

SWEP.Slot = 2
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Spawnable = true	
SWEP.AdminSpawnable = true
SWEP.Category = "MGE Weapons"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "grenade"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/weapons/w_grenade.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.ViewModelBoneMods = {
	["ValveBiped.Grenade_body"] = {scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0)}
}

SWEP.VElements = {
	["bottle"] = {type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.361, 2.709, -2.474), angle = Angle(-9.539, -84.175, 180), size = Vector(1.011, 1.011, 1.011), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}}
}

SWEP.WElements = {
	["bottle"] = {type = "Model", model = "models/props_junk/GlassBottle01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.748, 1.988, -2.597), angle = Angle(-174.698, 67.234, -2.013), size = Vector(0.912, 1.029, 0.953), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {}}
}

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:CanSecondaryAttack()
	return false
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.8)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:EmitSound("npc/vort/claw_swing" .. math.random(1, 2) .. ".wav")

	if SERVER then
		local molly = ents.Create("ent_molotov")
		molly:SetPos(self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20)
		molly:SetOwner(self.Owner)
		molly:Spawn()
		molly:GetPhysicsObject():ApplyForceCenter(self.Owner:GetAimVector() * 1500)

		self:SendWeaponAnim(ACT_VM_DRAW)
	end
end

function SWEP:SecondaryAttack() end

