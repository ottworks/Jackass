GM.Name = "Jackass"
GM.Author = "Ott, RzDat"
GM.Email = "N/A"
GM.Website = "https://github.com/DaaOtt/Jackass"

include("sh_bones.lua")
include("sh_buyables.lua")
include("sh_spawnmenu.lua")

function GM:Initialize()

end 

function GM:PlayerFootstep(ply)
	return IsValid(ply:GetRagdollEntity())
end