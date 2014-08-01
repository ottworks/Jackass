local PSTATS = {
	{name = "unique_id", type = "varchar(255)"},
	{name = "money", type = "int"},
	{name = "playtime", type = "int"}
}

local function stats_nametype(o)
	local result = ""
	for i = 1, #o do
		result = result .. o[i].name .. " " .. o[i].type .. ", "
	end
	result = string.sub(result, 1, -3)
	return result
end

local function stats_name(o)
	local result = ""
	for i = 1, #o do
		result = result .. o[i].name .. ", "
	end
	result = string.sub(result, 1, -3)
	return result
end

local function stats_quotename(o)
	local result = ""
	for i = 1, #o do
		result = result .. "'"..o[i].name.."', "
	end
	result = string.sub(result, 1, -3)
	return result
end

local function stats_defaults(o, omit)
	local result = ""
	for i = 1, #o do
		if i > omit then
			if o[i].type == "int" or o[i].type == "double" then
				result = result .. 0 .. ", "
			elseif o[i].type == "varchar(255)" then
				result = result .. "''" .. ", "
			end
		end
	end
	result = string.sub(result, 1, -3)
	return result
end


function sql_tables_exist()
	if sql.TableExists("ja_player_info") then
		print("The player table exists! Checking if stats are updated.")
		for i = 1, #PSTATS do
			local result = sql.Query("SELECT "..PSTATS[i].name.." FROM ja_player_info")
			if result == false then
				print("Stat "..PSTATS[i].name.." doesn't exist, adding column.")
				local result = sql.Query("ALTER TABLE ja_player_info ADD "..PSTATS[i].name.." "..PSTATS[i].type)
			end
		end
	else
		local query = "CREATE TABLE ja_player_info("..stats_nametype(PSTATS)..")"
		local result = sql.Query(query)
		if sql.TableExists("ja_player_info") then
			print("Success! Created the table\n")
		else
			print("Something went wrong creating the table!\n")
			print(sql.LastError(result) .. "\n")
		end
	end
end

function sql_player_exists(ply)
	local steamID = ply:GetNWString("SteamID")
	local result = sql.Query("SELECT "..stats_name(PSTATS).." FROM ja_player_info WHERE unique_id = '"..steamID.."'")
	if result then
		local tab = result[1]
		if count(tab) == #PSTATS then
			sql_value_stats(ply)
		else
			sql_del_player(steamID)
			sql_new_player(steamID, ply)
		end
	else
		print("Error fetching stats! Creating new player.")
		sql_new_player(steamID, ply)
	end
end

function sql_new_player(steamID, ply)
	sql.Query("INSERT INTO ja_player_info ("..stats_quotename(PSTATS)..") VALUES ('"..steamID.."', " .. stats_defaults(PSTATS, 1) .. ")")
	local result = sql.Query("SELECT "..stats_name(PSTATS).." FROM ja_player_info WHERE unique_id = '"..steamID.."'")
	if result then
		print("Player account created!\n")
	else
		print("Something went wrong with creating a player's info!\n")
		print(sql.LastError())
	end
end

function sql_del_player(steamID)
	sql.Query("DELETE FROM ja_player_info WHERE unique_id='"..steamID.."'")
	print("Deleted player "..steamID)
end

function sql_initialize()
	sql_tables_exist()
end
hook.Add("Initialize", "sql_Initialize", sql_initialize)

function sql_PlayerInitialSpawn(ply)
	timer.Create("SteamID_delay", 1, 1, function()
		local steamID = ply:SteamID()
		ply:SetNWString("SteamID", steamID)
		sql_player_exists(ply)
		timer.Create("SaveStat_" .. steamID, 10, 0, function()
				sql_save_stats(ply) 
			end)
	end)
end
hook.Add("PlayerInitialSpawn", "sql_PlayerInitialSpawn", sql_PlayerInitialSpawn)

function sql_value_stats(ply)
	local steamID = ply:SteamID()
	for i = 1, #PSTATS do
		if PSTATS[i].type == "int" then
			ply:SetNWInt(PSTATS[i].name, sql.QueryValue("SELECT "..PSTATS[i].name.." FROM ja_player_info WHERE unique_id = '"..steamID.."'"))
		elseif PSTATS[i].type == "varchar(255)" then
			ply:SetNWString(PSTATS[i].name, sql.QueryValue("SELECT "..PSTATS[i].name.." FROM ja_player_info WHERE unique_id = '"..steamID.."'"))
		elseif PSTATS[i].type == "double" then
			ply:SetNWFloat(PSTATS[i].name, sql.QueryValue("SELECT "..PSTATS[i].name.." FROM ja_player_info WHERE unique_id = '"..steamID.."'"))
		end
	end
end

function sql_save_stats(ply)
	ply:SetNWInt("playtime", ply:GetNWInt("playtime") + 10)
	local unique_id = ply:GetNWString("unique_id")
	for i = 1, #PSTATS do
		if PSTATS[i].type == "int" then
			sql.Query("UPDATE ja_player_info SET "..PSTATS[i].name.." = '"..ply:GetNWInt(PSTATS[i].name).."' WHERE unique_id = '"..unique_id.."'")
		elseif PSTATS[i].type == "double" then
			sql.Query("UPDATE ja_player_info SET "..PSTATS[i].name.." = '"..ply:GetNWFloat(PSTATS[i].name).."' WHERE unique_id = '"..unique_id.."'")
		end
	end
end
