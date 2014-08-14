surface.CreateFont("JackassMoney", {
	font = "321impact",
	size = 48,
	outline = true,
	antialias = false,
})
require("easings")
local w = ScrW()
local h = ScrH()
local money = {
	prefix = "$",
	font = "JackassMoney",
	w = w / 32,
	h = h / 32,
	c = Color(255, 255, 255),
}
local profit = {
	prefix = "+$",
	font = "JackassMoney",
	w = w / 32 - 24,
	h = h / 32 + 48,
	c = Color(0, 128, 0),
	a = 255,
}
local profit2 = setmetatable({}, {__index = profit})
local ease = 0
local easing = false



net.Receive("stunt_begin", function()
	profit2 = setmetatable({}, {__index = profit})
	easing = false
	ease = 0
end)

net.Receive("stunt_success", function(len)
	easing = true
	ease = 0
	surface.PlaySound("jackass/chaching.wav")
end)

net.Receive("stunt_failure", function(len)
	profit2.c = Color(255, 110, 110)
	timer.Simple(2, function()
		if not IsValid(LocalPlayer():GetRagdollEntity()) then
			profit2.a = 0 
		end
	end)
	surface.PlaySound("buttons/weapon_cant_buy.wav")
end)



function format_int(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

local function drawmoney()
	draw.SimpleText(money.prefix .. format_int(LocalPlayer():GetNWInt("money")), money.font, money.w, money.h, money.c, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(profit2.prefix .. format_int(LocalPlayer():GetRagdollEntity():GetNWInt("profits")), profit2.font, profit2.w, profit2.h, Color(profit2.c.r, profit2.c.g, profit2.c.b, profit2.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
	if easing then
		profit2.h = profit.h - easings.easeInBack(ease, 0.5, 0, 1) * 48
		profit2.a = profit.a - easings.easeInBack(ease, 0.5, 0, 1) * 255
		ease = ease + FrameTime()
		if ease >= 0.5 then
			easing = false
		end
	end
end
hook.Add("HUDPaint", "drawmoney", drawmoney) 

local function calcopacity(dist)
	dist = math.min(dist, 1500)
	return (2 - (dist / 1000)) * 255
end

function GM:HUDDrawTargetID()
	for _, ply in pairs(player.GetAll()) do
		if not IsValid(ply) then continue end
		if ply == LocalPlayer() then continue end
		local text = "ERROR"
		local font = "TargetID"
		local ragdoll = Entity(-1)
		text = ply:Nick() 
		ragdoll = IsValid(ply:GetRagdollEntity()) and ply:GetRagdollEntity() or ply
		local pos = ply:GetShootPos():ToScreen() 
		pos.y = pos.y - 20
		draw.DrawText(text, "TargetID", pos.x, pos.y, Color(255, 128, 0, calcopacity(ragdoll:GetPos():Distance(LocalPlayer():GetPos()))), TEXT_ALIGN_CENTER)
	end
end