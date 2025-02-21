if SERVER then
	util.AddNetworkString("TTTCFacelessCooldown")
end

local extraCooldown = 60

local function FacelessFunction(ply)
	-- Traces a line from the players shoot position to 100 units
	local trace = ply:GetEyeTrace()
	local target = trace.Entity

	if not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive() and target:HasClass() then
		if SERVER then
			timer.Simple(0.1, function()
				local phr = ply:GetCustomClass()
				local thr = target:GetCustomClass()
				local cd = target:GetClassCooldown() + extraCooldown
				local cdT = target:GetClassCooldownTS() or CurTime()

				ply:UpdateClass(thr)

				target:UpdateClass(phr)
				target:SetClassCooldown(cd)
				target:SetClassCooldownTS(cdT)

				net.Start("TTTCFacelessCooldown")
				net.Send(target)
			end)
		end
	else
		return true -- skip cooldown
	end
end

local function ChargeFaceless(ply)
	if CLIENT then
		local trace = ply:GetEyeTrace()
		local target = trace.Entity

		return not trace.HitWorld and IsValid(target) and target:IsPlayer() and target:Alive()
	end
end

CLASS.AddClass("FACELESS", {
		color = Color(0, 0, 0, 255),
		onDeactivate = FacelessFunction,
		onCharge = ChargeFaceless,
		time = 0, -- skip timer, this will skip onActivate too! Use onDeactivate instead
		cooldown = 90,
		charging = 1,
		lang = {
			name = {
				en = "Faceless",
				de = "Gesichtsloser",
				fr = "Sans visage",
				tr = "Meçhul",
				ru = "Безликий"
			},
			desc = {
				en = "He himself has no special abilities, but he is able to steal the class of another person.",
				de = "Er selbst hat keine besonderen Fähigkeiten, kann aber die eines anderen stehlen.",
				fr = "Lui-même n'a pas de capacités particulières, mais il est capable de voler la classe d'une autre personne.",
				tr = "Kendisinin özel yeteneği yok ama başka birinin rolünü çalma yeteneğine sahip.",
				ru = "Сам он особых способностей не имеет, но способен украсть класс другого человека."
			}
		}
})

if CLIENT then
	net.Receive("TTTCFacelessCooldown", function(len)
		local ply = LocalPlayer()
		local cd = ply:GetClassCooldown() + extraCooldown
		local cdT = ply:GetClassCooldownTS() or CurTime()

		ply:SetClassCooldown(cd)
		ply:SetClassCooldownTS(cdT)
	end)
end
