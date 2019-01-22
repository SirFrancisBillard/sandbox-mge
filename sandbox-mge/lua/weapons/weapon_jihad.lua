AddCSLuaFile()

sound.Add({
	name = "Jihad.Scream",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 150, -- literally as loud as Saturn V taking off
	pitch = {100},
	sound = {"arena/jihad/jihad_1.wav", "arena/jihad/jihad_2.wav"}
})

sound.Add({
	name = "Jihad.Islam",
	channel = CHAN_AUTO,
	volume = 1.0,
	level = 100,
	pitch = {100},
	sound = {"arena/music/islam.wav"}
})

SWEP.PrintName = "Jihad Bomb"
SWEP.Instructions = [[
<color=green>[PRIMARY FIRE]</color> Sacrifice yourself for Allah.

<color=red>Allahu akbar.</color>]]

SWEP.ViewModel = "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModelPos = Vector(0.759, 0, -1.04)
SWEP.ViewModelAng = Vector(0, 0, 0)

SWEP.HoldType = "slam"

function SWEP:Reload()
	return false
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

	util.PrecacheModel("models/Humans/Charple01.mdl")
	util.PrecacheModel("models/Humans/Charple02.mdl")
	util.PrecacheModel("models/Humans/Charple03.mdl")
	util.PrecacheModel("models/Humans/Charple04.mdl")
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 2)

	self.Owner:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)

	if SERVER then
		-- todo: consider moving these first four functions outside of SERVER to minimize networking?
		-- update: moved the gesture to shared but kept the sound to sync which sound it plays

		-- BroadcastLua([[Entity(]] .. self.Owner:EntIndex() .. [[):AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)]])

		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self.Owner:EmitSound("Jihad.Scream")

		SafeRemoveEntityDelayed(self, 0.99)
		local ply = self.Owner
		timer.Simple(1, function()
			if not IsValid(ply) or not ply:Alive() then return end
			local pos = ply:GetPos()

			ParticleEffect("explosion_huge", pos, vector_up:Angle())
			ply:EmitSound(Sound("^phx/explode0" .. math.random(0, 6) .. ".wav"))

			util.Decal("Rollermine.Crater", pos, pos - Vector(0, 0, 500), ply)
			util.Decal("Scorch", pos, pos - Vector(0, 0, 500), ply)

			ply:SetModel("models/Humans/Charple0" .. math.random(1, 4) .. ".mdl")
			ply:SetColor(color_white)

			util.BlastDamage(ply, ply, pos, 1000, 230)

			timer.Simple(1.2, function()
				if not pos then return end

				sound.Play(Sound("Jihad.Islam"), pos)
			end)
		end)
	end
end

function SWEP:CanSecondaryAttack() return false end
function SWEP:SecondaryAttack() end

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
