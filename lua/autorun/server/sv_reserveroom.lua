-- You can change these
local doorEnable = true
local doorType = "func_door"
local doorName = "garagedoor"
local doorNumSep = "_"
-- What to seperate the numbers and the normal name such as garagedoor_12
-- the _ would seperate the number allowing to use the number
local refreshFriendsTimer = 2.5 -- Time in seconds to wait before refreshing every room's owner's friends if there is an owner

-- Try and not touch past here
local ReservableRooms = {}
local ReservableRoomsDoors = {}
local ReservableRoomsVersion = 15
local IOwnAnotherRoom = false
local otherFunctionsAreRunning = false
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

local function setDoorLock( ply, lou, rfs )
	doIAlreadyOwnARoom( ply )
	if IOwnAnotherRoom != false then
		for k, v in pairs( ReservableRooms ) do
			local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
			if ply == claimedPlayers[1] then
				local garageKey = tonumber(k)
				for k, v in pairs(table.GetKeys(ReservableRoomsDoors)) do
					if lou == 1 then
						if tonumber(v) == garageKey then
							if rfs != 1 then
								ReservableRoomsDoors[v]:Fire("lock")
								sendMsgToPlayer( ply, "You have successfully locked your door." )
							else
								ReservableRoomsDoors[v]:Fire("close")
								ReservableRoomsDoors[v]:Fire("lock")
							end
						end
					else
						if tonumber(v) == garageKey then
							ReservableRoomsDoors[v]:Fire("unlock")
							if rfs != 1 then
								sendMsgToPlayer( ply, "You have successfully unlocked your door." )
							end
						end
					end
				end
			end
		end
	else
		if rfs != 1 then
			sendMsgToPlayer( ply, "You don't have a reserved room." )
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
	local whatsInTheBox = ents.FindInBox(ent:OBBMins(), ent:OBBMaxs())
	whatsInTheBoxCount = 0
	
	for i = 1, #whatsInTheBox do
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
					if doorEnable == true then setDoorLock( ply, 1, 1 ) end
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
			if doorEnable == true then setDoorLock( ply, 2, 1 ) end
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
		ent:SetRID(value)
	end
	
	if doorEnable == true then
		if(ent:GetClass() == doorType && key == "targetname") then
			local cmdtwo = string.Split(string.lower(value), doorNumSep )
			if cmdtwo[1] == doorName then ReservableRoomsDoors[cmdtwo[2]] = ent end
		end
	end
end)

hook.Add( "Initialize", "refreshPlyReservableRoomsFriendsOnT", function()
	timer.Simple(refreshFriendsTimer, timerRefreshFriends)
end)

hook.Add( "PlayerDisconnected", "unclaimReservableRoomOnDC", function( ply )
	for k, v in pairs( ReservableRooms ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if claimedPlayers[1] == ply then
			if doorEnable == true then setDoorLock( ply, 2, 1 ) end
			v:SetVar("ClaimedPlayers", {})
		end
	end
end)

hook.Add( "PlayerSay", "playerSayReservableRoomCommand", function( ply, text )
	local cmd = string.Split(string.lower(text)," ")
	
	if cmd[1] == "!claim" then claimReservableRoom( ply, cmd[2] ) end
	if cmd[1] == "!clear" then adminClearRoom( ply, cmd[2] ) end
	if cmd[1] == "!lockdoor" and doorEnable == true then setDoorLock( ply, 1 ) end
	if cmd[1] == "!refreshfriends" then refreshPlyFriends( ply ) end
	if cmd[1] == "!rrv" then sendMsgToPlayer( ply, "This server is running ReservableRooms version " .. ReservableRoomsVersion .. ".") end
	if cmd[1] == "!unclaim" then unclaimReservableRoom( ply ) end
	if cmd[1] == "!unlockdoor" and doorEnable == true then setDoorLock( ply, 2 ) end
end)