local ReservableRoomsVersion = "13"

local IgnoredPropsClass = {"gmod_button", "prop_door_rotating", "func_door", "func_viscluster", "info_player_start", "func_detail", "trigger_teleport", "prop_static", "npc_grenade_bugbait", "npc_grenade_frag", "reservableroom", "physgun_beam", "predicted_viewmodel", "manipulate_flex" }
local ReservableRooms = {} -- Create a table for the RID keys and ents

local IOwnAnotherRoom = false
local otherFunctionsAreRunning = false -- Using this var as a way to prevent auto refresh from breaking things just in case
local refreshFriendsTimer = 2.5 -- Time in seconds to wait before refreshing every room's owner's friends if there is an owner
local whatsInTheBoxCount = 0

function sendMsgToPlayer( ply, text )
    ply:SendLua("chat.AddText(Color(255,0,255),\"[ReservableRooms] \", Color(255,255,255),\"" .. text .. "\")")
end

local function adminClearRoom( ply, id )
	otherFunctionsAreRunning = true
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		if isnumber( tonumber(id) ) && table.HasValue(table.GetKeys(ReservableRooms), id) then
			local ent = ReservableRooms[id]
			
			ent:SetVar("ClaimedPlayers", {})
			sendMsgToPlayer( ply, "You have cleared the allowed player list of room " .. id .. ".")
		else sendMsgToPlayer( ply, "Please provide a valid room ID.") end
	else sendMsgToPlayer( ply, "You must be admin+ to use this command!") end
	otherFunctionsAreRunning = false
end

local function doIAlreadyOwnARoom( ply )
	IOwnAnotherRoom = false
	for k, v in pairs( ReservableRooms ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if ply == claimedPlayers[1] then
			IOwnAnotherRoom = true
		end
	end
end

local function refreshPlyFriends( ply, ent )
	otherFunctionsAreRunning = true
	-- Yes I know P goes after E, but it will cause problems the other way around
	local plyFriends = ply:CPPIGetFriends()
	table.insert(plyFriends, ply) -- Add the player so that we don't remove them later on
	
	if ent != nil then
		local claimedPlayers = ent:GetVar("ClaimedPlayers", {})
		
		for k, v in pairs( plyFriends ) do -- for every friend
			if !table.HasValue(claimedPlayers, v) then -- if not allowed
				table.insert(claimedPlayers, v) -- Add friends
			end
		end
		
		if claimedPlayers != plyFriends then -- If the allowed list is not the same as the players friends and self
			for k, v in pairs(claimedPlayers) do
				if!table.HasValue(plyFriends, v) then
					table.RemoveByValue(claimedPlayers, v) -- Remove the people that aren't friends
				end
			end
		end
		
		ent:SetVar("ClaimedPlayers", claimedPlayers)
	else -- If it came from !refreshfriends
		local didIRefresh = false
		for k, v in pairs( ReservableRooms ) do
			local claimedPlayers = v:GetVar("ClaimedPlayers", {})
			
			if claimedPlayers[1] == ply then
				didIRefresh = true
				for k, v in pairs( plyFriends ) do -- for every friend
					if !table.HasValue(claimedPlayers, v) then -- if not allowed
						table.insert(claimedPlayers, v) -- Add friends
					end
				end
			
			
				if claimedPlayers != plyFriends then -- If the allowed list is not the same as the players friends and self
					for k, v in pairs(claimedPlayers) do
						if!table.HasValue(plyFriends, v) then
							table.RemoveByValue(claimedPlayers, v) -- Remove the people that aren't friends
						end
					end
				end
				v:SetVar("ClaimedPlayers", claimedPlayers)
			end
		end
		if didIRefresh == true then sendMsgToPlayer( ply, "You have refreshed the allowed players in your room.")
		else sendMsgToPlayer( ply, "You do not own a room.") end
	end
	otherFunctionsAreRunning = false
end

local function timerRefreshFriends()
	if otherFunctionsAreRunning != true then
		for k, v in pairs( ReservableRooms ) do
			local claimedPlayers = v:GetVar("ClaimedPlayers", {})
			
			if table.Count(claimedPlayers) != 0 then
				local plyFriends = claimedPlayers[1]:CPPIGetFriends()
				table.insert(plyFriends, claimedPlayers[1]) -- Add the player so that we don't remove them later on
				
				for k, v in pairs( plyFriends ) do -- for every friend
					if !table.HasValue(claimedPlayers, v) then -- if not allowed
						table.insert(claimedPlayers, v) -- Add friends
					end
				end
				
				if claimedPlayers != plyFriends then -- If the allowed list is not the same as the players friends and self
					for k, v in pairs(claimedPlayers) do
						if !table.HasValue(plyFriends, v) then
							table.RemoveByValue(claimedPlayers, v) -- Remove the people that aren't friends
						end
					end
				end
				v:SetVar("ClaimedPlayers", claimedPlayers)
			end
		end
		timer.Simple(refreshFriendsTimer, timerRefreshFriends)
	else timer.Simple(refreshFriendsTimer, timerRefreshFriends) end
end

local function whatsInTheBox( ply, ent )
	otherFunctionsAreRunning = true
	local whatsInTheBox = ents.FindInBox(ent:OBBMins(), ent:OBBMaxs())
	whatsInTheBoxCount = 0
	
	for i = 1, #whatsInTheBox do
		if !table.HasValue(IgnoredPropsClass, whatsInTheBox[i]:GetClass()) then
			if whatsInTheBox[i]:IsPlayer() then
				if whatsInTheBox[i] != ply then
					whatsInTheBoxCount = whatsInTheBoxCount + 1 
				end
			elseif !whatsInTheBox[i]:CPPIGetOwner():IsPlayer() then return else
				if whatsInTheBox[i]:CPPIGetOwner() != ply then
					whatsInTheBoxCount = whatsInTheBoxCount + 1
				end
			end
		end
	end
	otherFunctionsAreRunning = false
end

local function claimReservableRoom( ply, id )
	otherFunctionsAreRunning = true
	if isnumber( tonumber(id) ) && table.HasValue(table.GetKeys(ReservableRooms), id) then
		local ent = ReservableRooms[id]
		local claimedPlayers = ent:GetVar("ClaimedPlayers", {})
		
		doIAlreadyOwnARoom(ply)
		if IOwnAnotherRoom == false then
			if table.Count(claimedPlayers) == 0 then
				whatsInTheBox( ply, ent )
				if whatsInTheBoxCount == 0 then
					table.insert(claimedPlayers, ply)
					ent:SetVar("ClaimedPlayers", claimedPlayers)
					refreshPlyFriends( ply, ent ) -- Add the player's friends
					sendMsgToPlayer( ply, "You have successfully claimed room " .. id)
				else sendMsgToPlayer( ply, "There is something or someone inside the area.") end
			else sendMsgToPlayer( ply, claimedPlayers[1]:GetName() .. " already claimed this room.") end
		else sendMsgToPlayer( ply, "You already claimed another room.") end
	else sendMsgToPlayer( ply, "Pleae provide a valid room ID.") end
	otherFunctionsAreRunning = false
end

local function unclaimReservableRoom( ply )
	otherFunctionsAreRunning = true
	local IWasCalledBefore = 0
	for k, v in pairs( ReservableRooms ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if claimedPlayers[1] == ply then
			v:SetVar("ClaimedPlayers", {})
			sendMsgToPlayer( ply, "You have unclaimed your room.")
		else IWasCalledBefore = IWasCalledBefore + 1 end
	end
	if IWasCalledBefore == table.Count(ReservableRooms) then
		sendMsgToPlayer( ply, "You do not own a room.")
	end
	otherFunctionsAreRunning = false
end

hook.Add( "EntityKeyValue", "findReservableRoomsOnEntityInit", function( ent, key, value )
	-- Find and apply the RID keys and the ent to a table for future ref
	if(ent:GetClass() == "reservableroom" && key == "RID") then 
		ReservableRooms[value] = ent
	end
end)

hook.Add( "Initialize", "refreshPlyReservableRoomsFriendsOnT", function()
	timer.Simple(refreshFriendsTimer, timerRefreshFriends)
end)

hook.Add( "PlayerDisconnected", "unclaimReservableRoomOnDC", function( ply )
	for k, v in pairs( ReservableRooms ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if claimedPlayers[1] == ply then
			v:SetVar("ClaimedPlayers", {})
		end
	end
end)

hook.Add( "PlayerSay", "playerSayReservableRoomCommand", function( ply, text )
	local cmd = string.Split(string.lower(text)," ")
	
	if cmd[1] == "!claim" then claimReservableRoom( ply, cmd[2] ) end
	if cmd[1] == "!clear" then adminClearRoom( ply, cmd[2] ) end
	if cmd[1] == "!refreshfriends" then refreshPlyFriends( ply ) end
	if cmd[1] == "!rrv" then sendMsgToPlayer( ply, ply:GetName() .. " this server is running ReservableRooms version " .. ReservableRoomsVersion .. ".") end
	if cmd[1] == "!unclaim" then unclaimReservableRoom( ply ) end
end)