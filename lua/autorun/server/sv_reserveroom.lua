local IgnoredPropsClass = {"gmod_button", "prop_door_rotating", "func_door", "func_viscluster", "info_player_start", "func_detail", "trigger_teleport", "prop_static", "npc_grenade_bugbait", "npc_grenade_frag", "worldspawn", "reservableroom", "physgun_beam" }
local ReservableSpots = {} -- Create a table for the RID keys and ents

local IOwnAnotherSpot = false
local ranFromClaimed = false
local whatsInTheBoxCount = 0

local function adminClearSpot( ply, text )
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		local id = string.sub( text, 8 )
		local ent = ReservableSpots[id]
		
		ent:SetVar("ClaimedPlayers", {})
		ply:ChatPrint("You have cleared the allowed list of spot " .. id)
	else ply:ChatPrint("You must be admin+ to use this command!") end
end

local function doIAlreadyOwnASpot( ply )
	IOwnAnotherSpot = false
	for k, v in pairs( ReservableSpots ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if ply == claimedPlayers[1] then
			IOwnAnotherSpot = true
		end
	end
end

local function refreshPlyFriends( ply, ranFromClaimed, ent )
	-- Yes I know P goes after E, but it will cause problems the other way arround
	local plyFriends = ply:CPPIGetFriends()
	table.insert(plyFriends, ply) -- Add the player so that we don't remove them later on
	
	if ranFromClaimed == true then -- If this came from !claim then
		local claimedPlayers = ent:GetVar("ClaimedPlayers", {})
		
		for k, v in pairs( plyFriends ) do -- for every friend
			if (!table.HasValue(claimedPlayers, v)) then -- if not allowed
				table.insert(claimedPlayers, v) -- Add friends
			end
		end
		
		if claimedPlayers != plyFriends then -- If the allowed list is not the same as the players friends and self
			for k, v in pairs(claimedPlayers) do
				if(!table.HasValue(plyFriends, v)) then
					table.RemoveByValue(claimedPlayers, v) -- Remove the people that aren't friends
				end
			end
		end
		
		ranFromClaimed = false
		ent:SetVar("ClaimedPlayers", claimedPlayers)
	else -- If it came from !refreshfriends
		local didIRefresh = false
		for k, v in pairs( ReservableSpots ) do
			local claimedPlayers = v:GetVar("ClaimedPlayers", {})
			
			if claimedPlayers[1] == ply then
				didIRefresh = true
				for k, v in pairs( plyFriends ) do -- for every friend
					if (!table.HasValue(claimedPlayers, v)) then -- if not allowed
						table.insert(claimedPlayers, v) -- Add friends
					end
				end
			
			
				if claimedPlayers != plyFriends then -- If the allowed list is not the same as the players friends and self
					for k, v in pairs(claimedPlayers) do
						if(!table.HasValue(plyFriends, v)) then
							table.RemoveByValue(claimedPlayers, v) -- Remove the people that aren't friends
						end
					end
				end
				v:SetVar("ClaimedPlayers", claimedPlayers)
			end
		end
		if didIRefresh == true then ply:ChatPrint("You have refreshed the allowed players in your spot.")
		else ply:ChatPrint("You either do not own a spot or something else is wrong.") end
	end
end

local function whatsInTheBox( ent, vC1, vC2 )
	local whatsInTheBox = ents.FindInBox(ent:OBBMins(), ent:OBBMaxs())
	whatsInTheBoxCount = 0
	
	for i = 1, #whatsInTheBox do
		if ( !table.HasValue(IgnoredPropsClass, whatsInTheBox[i]:GetClass()) ) then
			whatsInTheBoxCount = whatsInTheBoxCount + 1
		end
	end
end

local function claimReservableSpot( ply, text )
	local id = string.sub( text, 8 )
	if id != "" then -- If they didn't just type !claim
		local ent = ReservableSpots[id]
		local claimedPlayers = ent:GetVar("ClaimedPlayers", {})
		
		doIAlreadyOwnASpot(ply)
		if IOwnAnotherSpot == false then
			if table.Count(claimedPlayers) == 0 then
				whatsInTheBox(ent)
				if whatsInTheBoxCount == 0 then
					ranFromClaimed = true
					table.insert(claimedPlayers, ply)
					ent:SetVar("ClaimedPlayers", claimedPlayers)
					refreshPlyFriends( ply, ranFromClaimed, ent ) -- Add the player's friends
					ply:ChatPrint("You have successfully claimed spot " .. id)
				else ply:ChatPrint("There is something or someone inside the area.") end
			else ply:ChatPrint(claimedPlayers[1]:GetName() .. " already claimed this spot.") end
		else ply:ChatPrint("You already claimed another spot.") end
		ranFromClaimed = false -- Extra sure that it goes back to being false for next run
	else ply:ChatPrint("Pleae provide a spot ID.") end
end

local function unclaimReservableSpot( ply )
	for k, v in pairs( ReservableSpots ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if claimedPlayers[1] == ply then
			v:SetVar("ClaimedPlayers", {})
			ply:ChatPrint("You have unclaimed your spot.")
		end
	end
end

hook.Add( "PlayerSay", "claimreservableroom", function( ply, text )
	if ( string.sub( string.lower( text ), 1, 6 ) == "!claim" ) then claimReservableSpot( ply, text ) end
	if ( string.sub( string.lower( text ), 1, 6 ) == "!clear" ) then adminClearSpot( ply, text ) end
	if ( string.sub( string.lower( text ), 1, 15 ) == "!refreshfriends" ) then refreshPlyFriends( ply ) end
	if ( string.sub( string.lower( text ), 1, 8 ) == "!unclaim" ) then unclaimReservableSpot( ply ) end
end)

hook.Add( "EntityKeyValue", "reservableroomfind", function( ent, key, value )
	-- Find and apply the RID keys and the ent to a table for future ref
	if(ent:GetClass() == "reservableroom" && key == "RID") then 
		ReservableSpots[value] = ent
	end
end)

hook.Add( "PlayerDisconnected", "unclaimWhenDC", function( ply )
	for k, v in pairs( ReservableSpots ) do
		local claimedPlayers = v:GetVar("ClaimedPlayers", {})
		
		if claimedPlayers[1] == ply then
			v:SetVar("ClaimedPlayers", {})
		end
	end
end)