local EnableReservableRooms = true

if EnableReservableRooms == true then
	
	local EnableDoorSystem = true
	local reservableDoorClass = "func_door"
	local reservableDoorName = "garagedoor"
	local reservableDoorNameBreak = "_"
	
	-- No touch after thissssssss
	
	local clientOwnsRoom = false
	local ReservableRoomDoorsAvailable = {}
	local ReservableRoomsVersion = 16
	local TotalAmountOfReservableRooms = 0
	local whatsInTheBoxCount = 0
	
	util.AddNetworkString( "reservableRoomUserFeedBack" )

	local function checkRoomOwnerShip( ply, n )
		clientOwnsRoom = false
		local entsThatCameBackPos = 0
		
		for k, v in pairs(ents.FindByClass("reservableroom")) do
			if IsValid(v:GetOwner()) then
				if v:GetOwner() == ply then
					entsThatCameBackPos = entsThatCameBackPos + 1
				end
			end
		end
		
		if entsThatCameBackPos != 0 then
			clientOwnsRoom = true
		end
	end

	local function lockReservableDoor( ply, lu, n, c )
		if EnableDoorSystem == true then
			checkRoomOwnerShip(ply)
			if clientOwnsRoom == true then
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if v:GetOwner() == ply then
						if lu == 1 then
							if c == 1 then
								v:GetDoorEnt():Fire("close")
							end
							v:GetDoorEnt():Fire("lock")
							if n != 0 then
								net.Start( "reservableRoomUserFeedBack" )
									net.WriteString("You have locked your door")
								net.Send( ply )
							end
						else
							v:GetDoorEnt():Fire("unlock")
							if n != 0 then
								net.Start( "reservableRoomUserFeedBack" )
									net.WriteString("You have unlocked your door")
								net.Send( ply )
							end
						end
					end
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString("You do not own a room")
				net.Send( ply )
			end
		end
	end
	
	local function whatsInTheBox( ply, ent )
		local whatsInTheBoxC = ents.FindInBox(ent:OBBMins(), ent:OBBMaxs())
		whatsInTheBoxCount = 0
		
		for i = 1, #whatsInTheBoxC do
			if whatsInTheBoxC[i]:IsPlayer() then
				if whatsInTheBoxC[i] != ply then
					whatsInTheBoxCount = whatsInTheBoxCount + 1
				end
			elseif IsValid(whatsInTheBoxC[i]:CPPIGetOwner()) and whatsInTheBoxC[i]:GetClass() != "reservableroom" then
				if whatsInTheBoxC[i]:CPPIGetOwner() != ply then
					whatsInTheBoxCount = whatsInTheBoxCount + 1
				end
			end
		end
		
		if whatsInTheBoxCount != 0 then
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString("There is someone or something in this room")
			net.Send( ply )
		end
	end

	local function reserveReservableRoom( cru, ply, id )
		if cru == 1 then
			checkRoomOwnerShip( ply )
			if clientOwnsRoom == false then
				if id <= TotalAmountOfReservableRooms then
					for k, v in pairs(ents.FindByClass("reservableroom")) do
						if v:GetRID() == id then
							if !IsValid(v:GetOwner()) then
								whatsInTheBox( ply, v )
								if whatsInTheBoxCount == 0 then
									v:SetOwner(ply)
									lockReservableDoor(ply, 1, 0, 1)
									net.Start( "reservableRoomUserFeedBack" )
										net.WriteString("You have claimed room " .. tostring(id))
									net.Send( ply )
								end
							else
								net.Start( "reservableRoomUserFeedBack" )
									net.WriteString(v:GetOwner():GetName() .. " already claimed this room")
								net.Send( ply )
							end
						end
					end
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString("Please enter a valid room number")
					net.Send( ply )
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString("You already own a room")
				net.Send( ply )
			end
		elseif cru == 2 then
			checkRoomOwnerShip( ply )
			if clientOwnsRoom == true then
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if v:GetOwner() == ply then
						lockReservableDoor(ply, 2, 0, 0)
						v:SetOwner(nil)
						net.Start( "reservableRoomUserFeedBack" )
							net.WriteString("You have un-claimed your room")
						net.Send( ply )
					end
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString("You do not own a room")
				net.Send( ply )
			end
		else
			if ply:IsAdmin() or ply:IsSuperAdmin() then
				if id <= TotalAmountOfReservableRooms then
					for k, v in pairs(ents.FindByClass("reservableroom")) do
						if v:GetRID() == id then
							v:GetDoorEnt():Fire("unlock")
							v:SetOwner(nil)
							net.Start( "reservableRoomUserFeedBack" )
								net.WriteString("You have cleared room " .. tostring(id))
							net.Send( ply )
						end
					end
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString("Please enter a valid room number")
					net.Send( ply )
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString("You have to be an admin to use this command")
				net.Send( ply )
			end
		end
	end

	hook.Add( "EntityKeyValue", "findAndCacheAvailableReservableRoomEnts", function( ent, key, value )
		if(ent:GetClass() == "reservableroom" && key == "RID") then
			ent:SetRID(tonumber(value))
			TotalAmountOfReservableRooms = TotalAmountOfReservableRooms + 1
		end
		
		if EnableDoorSystem == true then
			if(ent:GetClass() == reservableDoorClass && key == "targetname") then
				local doorNumSplit = string.Split(string.lower(value),reservableDoorNameBreak)
				
				if doorNumSplit[1] == reservableDoorName then
					ReservableRoomDoorsAvailable[tonumber(doorNumSplit[2])] = ent
				end
			end
		end
	end)

	hook.Add( "Initialize", "startReservableRoomTimers", function()
		if EnableDoorSystem == true then
			timer.Simple( 1, function()
				for k, v in pairs(ReservableRoomDoorsAvailable) do
					for ke, va in pairs(ents.FindByClass("reservableroom") ) do
						if k == va:GetRID() then
							va:SetDoorEnt(v)
						end
					end
				end
				table.Empty(ReservableRoomDoorsAvailable)
			end)
		end
	end)

	hook.Add( "PlayerSay", "playerSayReservableRoomCommand", function( ply, text )
		local plySaySplit = string.Split(string.lower(text)," ")
		
		if plySaySplit[1] == "!claim" then reserveReservableRoom( 1, ply, tonumber(plySaySplit[2]) ) end
		if plySaySplit[1] == "!clear" then reserveReservableRoom( 3, ply, tonumber(plySaySplit[2]) ) end
		if plySaySplit[1] == "!lockdoor" then lockReservableDoor( ply, 1, 1, 0) end
		if plySaySplit[1] == "!rrv" then
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString("This server is running ReservableRooms version " .. ReservableRoomsVersion)
			net.Send( ply )
		end
		if plySaySplit[1] == "!unclaim" then reserveReservableRoom( 2, ply ) end
		if plySaySplit[1] == "!unlockdoor" then lockReservableDoor( ply, 2, 1, 0) end
	end)
	
end