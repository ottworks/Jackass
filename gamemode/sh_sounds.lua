local hips = 0
local gut = 1
local right_shoulder = 2
local left_shoulder = 3
local left_elbow = 4
local left_wrist = 5
local right_elbow = 6
local right_wrist = 7
local right_hip_joint = 8
local right_knee = 9
local head = 10
local left_hip_joint = 11
local left_knee = 12
local left_ankle = 13
local right_ankle = 14

SOUNDS = {
	male = {
		generic = {
			"vo/npc/male01/ow01.wav",
			"vo/npc/male01/ow02.wav",
			"vo/npc/male01/pain01.wav",
			"vo/npc/male01/pain02.wav",
			"vo/npc/male01/pain03.wav",
			"vo/npc/male01/pain04.wav",
			"vo/npc/male01/pain05.wav",
			"vo/npc/male01/pain06.wav",
			"vo/npc/male01/pain07.wav",
			"vo/npc/male01/pain08.wav",
			"vo/npc/male01/pain09.wav",
			"vo/npc/male01/no02.wav",
			"vo/npc/male01/startle01.wav",
			"vo/npc/male01/startle02.wav",
			"vo/npc/barney/ba_ohshit03.wav",
		},
		[gut] = {
			"vo/npc/male01/hitingut01.wav", 
			"vo/npc/male01/hitingut02.wav", 
			"vo/npc/male01/mygut02.wav"
		},
		arm = {
			"vo/npc/male01/myarm01.wav",
			"vo/npc/male01/myarm02.wav",
		},
		leg = {
			"vo/npc/male01/myleg01.wav",
			"vo/npc/male01/myleg02.wav",
		},
		settled = {
			"vo/npc/male01/question18.wav",
			"vo/npc/male01/moan01.wav",
			"vo/npc/male01/moan02.wav",
			"vo/npc/male01/moan03.wav",
			"vo/npc/male01/moan04.wav",
			"vo/npc/male01/gordead_ans19.wav"
		},
		jumping = {
			"vo/canals/male01/stn6_incoming.wav",
			"vo/coast/odessa/male01/nlo_cheer01.wav",
			"vo/coast/odessa/male01/nlo_cheer02.wav",
			"vo/coast/odessa/male01/nlo_cheer03.wav",
			"vo/coast/odessa/male01/nlo_cheer04.wav",
			"vo/npc/male01/cit_dropper04.wav",
			"vo/npc/male01/headsup01.wav",
			"vo/npc/male01/headsup02.wav",

		}
	},
	sfx = {
		breakage = {
			"jackass/bonecrack1.wav",
			"jackass/bonecrack5.wav",
			"jackass/decap1.wav",
			"jackass/decap2.wav",
			"jackass/decap3.wav",
			"jackass/decap4.wav",
		},
		hittage = {
			"jackass/fall1.wav",
			"jackass/fall2.wav",
			"jackass/fall3.wav",
			"jackass/fall4.wav",
			"jackass/fall5.wav",
		}
	}
}


for i = 2, 7 do
	SOUNDS.male[i] = SOUNDS.male.arm
end
for i = 8, 14 do
	if i ~= 10 then
		SOUNDS.male[i] = SOUNDS.male.leg
	end
end

for i = 0, 14 do
	SOUNDS.male.generic[i] = generic
end
setmetatable(SOUNDS.male, {__index = SOUNDS.male.generic})

function randomsound(t, bone)
	local a = table.Copy(t[bone])
	table.Add(a, t.generic)
	return table.Random(a or {}) or ""
end

if SERVER then
	for i = 1, #SOUNDS.sfx.breakage do
		resource.AddFile("sound/" .. SOUNDS.sfx.breakage[i])
	end
	for i = 1, #SOUNDS.sfx.hittage do
		resource.AddFile("sound/" .. SOUNDS.sfx.hittage[i])
	end
end