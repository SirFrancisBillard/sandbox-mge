
local WEAPON = FindMetaTable("Weapon")

local function NameTimer(ent, id)
	return ent:EntIndex() .. "_" .. ent:GetClass() .. "_" .. id
end

function WEAPON:CreateTimer(id, time, func)
	return timer.Create(NameTimer(self, id), time, 1, func)
end

function WEAPON:ResetTimers()
	if type(self.Timers) ~= "table" then
		ErrorNoHalt("ResetTimers called on weapon without Timers table!")
		return
	end

	for k, v in pairs(self.Timers) do
		if timer.Exists(NameTimer(self, v)) then
			timer.Remove(NameTimer(self, v))
		end
	end
end

function WEAPON:SoundTimer(id, time, snd)
	return self:CreateTimer(id, time, function() if IsValid(self) then self:EmitSound(Sound(snd)) end end)
end
