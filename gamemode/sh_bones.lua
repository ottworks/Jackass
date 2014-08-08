--[[
:::,,,,,,,,,,,,,,,,,,.............................................,,,,,,,::~=???
::,,,,,,,,,,,,,,,,,,,.................................................,,,,,:~=+?
::::,,,,,,,,,,,,,,......................................................,,,::~==
,,,,,,,,,,,,,,,,,........................................................,,,,:~=
,,,,,,,,,,,,,,,,,........................................................,,,,:::
,,,,,,:,,,,,,,,,..........................................................,,,,::
,,,,:::,,,,,,,,,,.........................................................,,,,,,
,::::::::::,,,,...........................................................,,,,,,
::~~~~~~~::,,,..,.......,.................................................,,,,,,
:~~~~~~~~~:,,,,,,,,,,,,,,,................................................,,,,,,
~~~~~~~~~~~::~~::::::::,,,,,,.............................................,,,,,,
::~~~~~~~~~~~~~~,.........................................................,,,,,,
,:~~~~~~~~~~:~,......,~+++,...............................................,,,,,,
,,,,::~~~~~:,,......~??+:,................................................,,,,,,
....,,,::::,......~??=,...................................................,,,,,,
.................=?II,,..................................................,,,,,,,
.,............,,=+III,,................................................,,,,,,,,,
,,,,,,,,,....,,,=?I7=,,..............:~,..............................,,,,,,,,,,
:::::::,,,,,,,,:?I77=,..............,~~=:.............................,,,,,,,,,,
...,,,,,.....=~+I777+,.............:=??=,,.........................,.,,,,,,,,,::
,..,,,,,....:7777777I+=,,.......:=???I?=:~~,.....................,.,,,,,,,,,::::
,,,,,,,.....=I77777777I?=:,:,,:~?III?,,,,.:,.....................,,,,,,,,,,:::::
,,,,::,,,,,:=I77777III+~:,,:~,:+II?:,.....,,,......................,,,,:::::::::
,,,:~~,::~~~=I7777IIII+:,..,:???I?,.......,~~,,....................,,:::::::::::
,,,~=~~~~~~~~=IIIIIII?=:,,,+IIII?,........~==~:,....................,:::::::::::
,,:::~~~~~~~~~~+~==++~:,,:~?III?:,........+??+++=,...................,,,::::::::
,,::~~~~~~~~~~~~~::~:::::+IIII?=,.........++??+=+++=,.................,,::::::,:
:::~~~~~~~~~:,,,::??=~:==?III?=:,,.,,,...~????++=+II?+==~:+?++:,......,,::::::::
,::~~~~~~:,,,.....~~,,,+IIII=~~~::=+?:,:+++?+++??????+++?????II:,,....,,:::,,,,,
,,::~~:::,,..,.....~:.,?III=::~==~:::::~===+++????III??+?????I=:,,.....,,,,,,,,:
.,,:::,,....,......,~:+III+==~~=:,,,,,,,,:~=+++?IIIII??????I+:::~,,,.,..,,,,,,,:
.,,,:,,....,,,,....,?~II7I+??===,...,,,,,,~=++++?+=~~~~+?+==,,,,:==:,,,,,,,,,::~
..,,::,,,,,,,,.....,+:IIIII?~:+:,,.,~:::::~=====~~=~=????+~~,::,,:~=:,,...,,,,::
...,,:::~~:,,::::,,,++:??7I+??=~~,,:=+??++?++===~~===??????=~:,,..:~~======::~=?
...,,:::~~~~:,......:+,,.:I++???+~=+=::::+++++=~::~+?I??==~~:,,...,::~::~=,...,~
...,:~~~::~~~~:,,...,+,,,,,,:=??=~??++++III?+?~~+++??I?+~~:,,,.....,:...,:+++++?
...,~~==~~:::~~~~~,,.~~,:~,,,,,,,,=?+??I7II?+~==??+?I??+~~::::,.....:,:=+++++?+?
...,~==+++~~::::~~~~::,,,..,,:~~:,,~+??????+~~~===+?????+??+=~:,....,~=+??????++
...,:=+++==~:,,,,,,::,,,,,,,,,...,~~+?????+=~==?++?III????=~:,.,,,,,,:~++++++?++
.......,,,,,,....,,,,..:~=,,,,,,~~:::=????=~?I?+=??II?==::,,....,,,,,,:~======++
.......,~==~:,,,,,,,,,,:+IIII+~:~~~=~~=??+++=?++?II?~:,,,,,,....,,,,,,,:~~~~~~~~
.......,~~~~:,,,,,,,,,,++=I77=~?I?===?I77777IIIIII?~:,,,.,,,....,,,,,,:~++??++++
........,:~::,,,:,,,::~??+?77??I777I=+I777777IIIII~:,,,..........,,,,,,,,,,.....
........~~~::,,,,:::::~+?++?II777777777777777777I=,,,............,,,,,,........,
......,,=+=~+I?+::::::::=??????IIII7777777777III+?77IIIIII??+:,,,,,,,,....,:,..:
7777777777777??,::::::::,~+++?????IIII77777777I=+?=?????????????++??+=???I777?=~
=~~+??~=77?~,,:,,,::::::,,=:::=?IIIII777777I?+?+~?I===~~=+?+++++===++?II77777777
:~=?+~I7+~,,~?~::::::,,,,.,:=+?III7777777I=~=+??+~+II==~:::~=====++++??IIII77777
~=~:=7I+~:,~+~~:::::::::,,,:~+++?+=~==~===::~=====:=II==~::::++??+?????IIIII7II?
~::?I+~:::++=~~:::::::::,,,==???+====+++==~::===~~+~~=~~~+=~+??IIIIIIIIII????++~
:~=??~::~:+=~~~~~~~~~~~~:,,~==++======+++++==~==:,,,,,:~~=~=?III+=~=+=+?+++===+:
--]]
local meta = FindMetaTable("Entity")
if not meta then return end

if SERVER then
	util.AddNetworkString("renderbones")
	function meta:SetRenderBones(bool)
		self.spooky = bool
		net.Start("renderbones")
			net.WriteEntity(self)
			net.WriteBit(bool)
		net.Broadcast()
	end
end

function meta:GetRenderBones()
	return self.spooky
end

if CLIENT then
	net.Receive("renderbones", function(len)
		local ent = net.ReadEntity()
		local bool = net.ReadBit()
		ent.spooky = bool
		if bool then
			if not table.HasValue(skeletons, ent) then
				table.insert(skeletons, ent)
			end
		else
			print(table.RemoveByValue(skeletons, ent))
		end
	end)
	local model = ClientsideModel("models/Gibs/HGIBS.mdl", RENDERGROUP_OPAQUE)
	local bonemat = Material("widgets/bone.png",  "unlitsmooth")
	local smallbonemat = Material("widgets/bone_small.png", "unlitsmooth" )
	local skullmat = Material("pp/copy", "unlitgeneric")
	skeletons = skeletons or {}
	local function rattlebones()
		cam.IgnoreZ(true)
		for i = 1, #skeletons do
			if not IsValid(skeletons[i]) then 
				table.remove(skeletons, i) 
				break 
			elseif not skeletons[i]:GetRenderBones() then
				table.remove(skeletons, i) 
				break
			end
			local ply = skeletons[i]
			local breakpoint = ply:GetNWInt("BreakPoint")
			for k=0, ply:GetNWInt("physcount")-1 do
				local bone = ply:TranslatePhysBoneToBone(k)
				--if ( ply:GetBoneParent( bone ) <= 0 ) then continue end
				--if ( !ply:BoneHasFlag( bone, BONE_USED_BY_HITBOX ) ) then continue end
				local pos, ang = ply:GetBonePosition(bone)
				local size = ply:BoneLength(bone)
				local pos2 = ply:GetBonePosition(ply:GetBoneParent(bone)) or pos + ang:Forward() * size

				if size > 10 then 
					render.SetMaterial(bonemat) 
				else 
					render.SetMaterial(smallbonemat) 
				end

				local damage = ply:GetNWInt("BoneDamage" .. k)
				damage = math.floor(damage / (breakpoint / 4)) * (breakpoint / 4)
				render.DrawBeam(pos, pos2, size * 0.2, 0, 1, Color(255, 255 - (damage / breakpoint) * 255, 255 - (damage / breakpoint) * 255))
			end
			local pos, ang = LocalToWorld(Vector(3.7, -1.3, 0), Angle(0, -90, -90), ply:GetBonePosition(6))
			local damage = ply:GetNWInt("BoneDamage10")
			render.ModelMaterialOverride(skullmat)
				model:SetRenderOrigin( pos );
				model:SetRenderAngles( ang );
				model:SetupBones();
					render.SetColorModulation(0.5, 0.5, 0.5)
					model:SetModelScale(0.9, 0)
					model:DrawModel()
					model:SetModelScale(0.8, 0)
					render.SetColorModulation(1, 1 - (damage / breakpoint), 1 - (damage / breakpoint))
					model:DrawModel();	
			render.ModelMaterialOverride()
		end
		cam.IgnoreZ(false)
		model:SetRenderOrigin(Vector())
	end
	hook.Add("PostDrawTranslucentRenderables", "rattlemebones", rattlebones)
end
