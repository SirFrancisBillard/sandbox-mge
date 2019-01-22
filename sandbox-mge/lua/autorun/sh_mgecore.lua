AddCSLuaFile()

local ValidClasses = {
	["soldier"] = {hp = 150, speed = 0.8, weps = {"weapon_assaultrifle", "weapon_handgun"}},
	["cowboy"] = {hp = 200, speed = 1.2, weps = {"weapon_python", "weapon_dynamite"}},
	["rapper"] = {hp = 100, speed = 1.6, weps = {"weapon_uzi", "weapon_lean"}}, -- shieet
	["demoman"] = {hp = 100, speed = 1, weps = {"weapon_stickylauncher", "weapon_grenadelauncher"}},
	["pyro"] = {hp = 125, speed = 1, weps = {"weapon_flamethrower", "weapon_molotov"}},
}

local DefaultClass = "soldier"

hook.Add("ScalePlayerDamage", "MGE.RestrictDamage", function(ply, hit, dmg)
	local atk = dmg:GetAttacker()
	if IsValid(ply) and IsValid(atk) and atk:IsPlayer() then
		if ply:GetNWBool("mge_active") ~= atk:GetNWBool("mge_active") then
			dmg:ScaleDamage(0) -- mge cant hurt non-mge and vice versa
		end
	end
end)

hook.Add("Move", "MGE.ModifySpeed", function(ply, mv, cmd)
	if not IsValid(ply) or not ply:GetNWBool("mge_active") then return end
	local speed = mv:GetMaxSpeed() * ValidClasses[ply:GetNWString("mge_class", DefaultClass)].speed
	mv:SetMaxSpeed(speed)
	mv:SetMaxClientSpeed(speed)
end)

if SERVER then
	hook.Add("PlayerSay", "MGE.ServerChatCommands", function(ply, text, team)
		if string.sub(string.lower(text), 1, 4) == "!mge" then
			local InMGE = ply:GetNWBool("mge_active")
			ply:SetNWBool("mge_active", not InMGE)
			ply:ChatPrint(InMGE and "You are now in MGE!" or "You have left MGE.")
			if not ply.ShownHelpMGE then
				ply:ChatPrint("Type \"!mgehelp\" for help.")
				ply.ShownHelpMGE = true
			end
			return ""
		elseif string.sub(string.lower(text), 1, 9) == "!mgeclass" then
			local class = string.Split(string.lower(text), " ")[2]
			if not ValidClasses[class] then
				ply:ChatPrint("Invalid class!")
				return
			end
			ply:SetNWString("mge_class", class)
			ply:ChatPrint("You will change classes when you respawn.")
		end
	end)

	hook.Add("PlayerSpawn", "MGE.GiveClassStuff", function(ply)
		timer.Simple(0, function()
			if IsValid(ply) and ply:IsPlayer() then
				ply:StripWeapons()
				if not ValidClasses[ply:GetNWString("mge_class")] then
					ply:SetNWString("mge_class", DefaultClass)
				end
			end
		end)
	end)
else
	hook.Add("OnPlayerChat", "MGE.ClientChatCommands", function(ply, strText, bTeam, bDead)
		if ply ~= LocalPlayer() then return end
		strText = string.lower(strText)

		if strText == "!mgehelp" then
			local classes = ""
			for k, v in pairs(ValidClasses) do
				classes = classes .. k .. " "
			end
			ply:ChatPrint("Valid classes: " .. classes)
			ply:ChatPrint("Type \"!mgeclass <class>\" to change your class.")
			return true
		end
	end)

	local model = ClientsideModel("models/headcrabclassic.mdl")
	model:SetNoDraw(true)

	hook.Add("PostPlayerDraw", "MGE.DrawHats", function(ply)
		if not IsValid(ply) or not ply:Alive() then return end

		local attach_id = ply:LookupAttachment("eyes")
		if not attach_id then return end -- fucking ponies

		local attach = ply:GetAttachment(attach_id)

		if not attach then return end

		local pos = attach.Pos
		local ang = attach.Ang

		model:SetModelScale(1.1, 0)
		pos = pos + (ang:Forward() * 2.5)
		ang:RotateAroundAxis(ang:Right(), 20)

		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()
	end)
end
