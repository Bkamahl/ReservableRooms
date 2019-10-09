-- yes I know theres a more optimized way to do a lot of this stuff

local EnableReservableRooms = true

if EnableReservableRooms == true then

	local ReservableRoomsVersion = 20

	local entsInRoom = 0

	util.AddNetworkString( "reservableRoomUserFeedBack" )

	local function checkRoomDoors()
		local rooms = util.JSONToTable(file.Read ( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ))

		for k, v in pairs( rooms ) do
			if v[8] then
				local doorEntity = nil
				for ke, doorent in pairs( ents.FindByName( tostring( v[8] ) ) ) do
					doorEntity = doorent
				end

				for key, roomEnt in pairs( ents.FindByClass( "reservableroom" ) ) do
					if roomEnt:GetRID() == tonumber(v[1]) then
						roomEnt:SetDoorEnt( doorEntity )
					end
				end
			end
		end
	end

	concommand.Add( "addreservableroom", function( ply, cmd, args )
		local rooms = util.JSONToTable(file.Read ( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ))

		if !IsValid(ply) then
			local argsIsValidCount = 0
			for k, v in pairs( args ) do
				if v and tonumber(v) then
					argsIsValidCount = argsIsValidCount + 1
				end
			end
			
			if argsIsValidCount == 7 then
				local room = {}
				if args[8] then
					room = {args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]}
				else
					room = {args[1], args[2], args[3], args[4], args[5], args[6], args[7]}
				end
				table.insert(rooms, room)
				file.Write( "ReservableRooms/" .. game.GetMap() .. ".txt", util.TableToJSON( rooms, false ) )

				local reservableRoom = ents.Create( "reservableroom" )
				reservableRoom:SetPos( Vector(0, 0, 0) )
				reservableRoom:Spawn()
				reservableRoom:SetRID( room[1] )
				reservableRoom:SetCollisionBounds( Vector( room[2], room[3], room[4] ) , Vector( room[5], room[6], room[7] ))

				checkRoomDoors()

				print( "You have created a room." )
			else
				print("Please enter the command correctly.")
			end
		else
			if ply:IsAdmin() or ply:IsSuperAdmin() then
				local argsIsValidCount = 0
				for k, v in pairs( args ) do
					if v and tonumber(v) then
						argsIsValidCount = argsIsValidCount + 1
					end
				end
				
				if argsIsValidCount == 7 then
					local room = {}
					if args[8] then
						room = {args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]}
					else
						room = {args[1], args[2], args[3], args[4], args[5], args[6], args[7]}
					end
					table.insert(rooms, room)
					file.Write( "ReservableRooms/" .. game.GetMap() .. ".txt", util.TableToJSON( rooms, false ) )

					local reservableRoom = ents.Create( "reservableroom" )
					reservableRoom:SetPos( Vector(0, 0, 0) )
					reservableRoom:Spawn()
					reservableRoom:SetRID( room[1] )
					reservableRoom:SetCollisionBounds( Vector( room[2], room[3], room[4] ) , Vector( room[5], room[6], room[7] ))
					
					checkRoomDoors()

					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "You have created a room." )
					net.Send( ply )
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "Please enter the command correctly." )
					net.Send( ply )
				end			
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "You are not admin." )
				net.Send( ply )
			end
		end
	end)

	concommand.Add( "removereservableroom", function( ply, cmd, args )
		if !IsValid(ply) then
			if args[1] and tonumber(args[1]) then
				local roomExists = false
				for k, v in pairs( ents.FindByClass( "reservableroom" ) ) do
					if v:GetRID() == tonumber(args[1]) then
						roomExists = true
						v:Remove()
					end
				end
				
				if roomExists then
					print("You have removed the specified room.")
					
					local rooms = util.JSONToTable(file.Read ( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ))
					for k, v in pairs(rooms) do
						if v[1] == args[1] then
							rooms[k] = nil
						end
					end
					file.Write( "ReservableRooms/" .. game.GetMap() .. ".txt", util.TableToJSON( rooms, false ) )
				else
					print("The specified room does not exist.")
				end
			else
				print("Please enter the command correctly.")
			end
		else
			if ply:IsAdmin() or ply:IsSuperAdmin() then
				if args[1] and tonumber(args[1]) then
					local roomExists = false
					for k, v in pairs( ents.FindByClass( "reservableroom" ) ) do
						if v:GetRID() == tonumber(args[1]) then
							roomExists = true
							v:Remove()
						end
					end
					
					if roomExists then
						net.Start( "reservableRoomUserFeedBack" )
							net.WriteString( "You have removed the specified room." )
						net.Send( ply )
						
						local rooms = util.JSONToTable(file.Read ( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ))
						for k, v in pairs(rooms) do
							if v[1] == args[1] then
								rooms[k] = nil
							end
						end
						file.Write( "ReservableRooms/" .. game.GetMap() .. ".txt", util.TableToJSON( rooms, false ) )
					else
						net.Start( "reservableRoomUserFeedBack" )
							net.WriteString( "The specified room does not exist." )
						net.Send( ply )
					end
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "Please enter the command correctly." )
					net.Send( ply )
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "You are not admin." )
				net.Send( ply )
			end
		end
	end)

	local function checkDIR()
		if  !file.Exists( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ) then
			file.CreateDir( "ReservableRooms" )
			local rooms = {}
			file.Write( "ReservableRooms/" .. game.GetMap() .. ".txt", util.TableToJSON( rooms, false ) )
		end
	end

	local function createRooms()
		local rooms = util.JSONToTable(file.Read ( "ReservableRooms/" .. game.GetMap() .. ".txt", "DATA" ))

		for k, v in pairs( rooms ) do
			local reservableRoom = ents.Create( "reservableroom" )
			reservableRoom:SetPos( Vector(0, 0, 0) )
			reservableRoom:Spawn()
			reservableRoom:SetRID( v[1] )
			reservableRoom:SetCollisionBounds( Vector( v[2], v[3], v[4] ) , Vector( v[5], v[6], v[7] ))
		end
	end
	
	hook.Add("InitPostEntity", "ReservableRoomsInitPostEntityHook", function()
		checkDIR()
		createRooms()
		checkRoomDoors()
	end)
	
	local function checkIfRoomIsClear( ply, id )
		for k, v in pairs(ents.FindByClass("reservableroom")) do
			if v:GetRID() == tonumber(id) then
				entsInRoom = 0
				
				local entsInRoomChecker = ents.FindInBox(v:OBBMins(), v:OBBMaxs())
				
				for i = 1, #entsInRoomChecker do
					if entsInRoomChecker[i]:IsPlayer() then
						if entsInRoomChecker[i] != ply then
							entsInRoom = entsInRoom + 1
						end
					elseif IsValid(entsInRoomChecker[i]:CPPIGetOwner()) and entsInRoomChecker[i]:GetClass() != "reservableroom" then
						if entsInRoomChecker[i]:CPPIGetOwner() != ply then
							entsInRoom = entsInRoom + 1
						end
					end
				end
			end
		end
	end
	
	local function lockRRoomDoor(ply)
		local ownsRoom = false
		for k, v in pairs(ents.FindByClass("reservableroom")) do
			if v:GetOwner() == ply then
				ownsRoom = true
			end
		end
		
		if ownsRoom then
			local doorExists = false
			for k, v in pairs(ents.FindByClass("reservableroom")) do
				if v:GetOwner() == ply then
					if IsValid(v:GetDoorEnt()) then
						doorExists = true
					end
				end
			end
			
			if doorExists then
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if v:GetOwner() == ply then
						v:GetDoorEnt():Fire("lock")
					end
				end
				
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "You have locked your door." )
				net.Send( ply )
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "There is no door for this room." )
				net.Send( ply )
			end
		else
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "You do not own a door." )
			net.Send( ply )
		end
	end
	
	local function unlockRRoomDoor(ply)
		local ownsRoom = false
		for k, v in pairs(ents.FindByClass("reservableroom")) do
			if v:GetOwner() == ply then
				ownsRoom = true
			end
		end
		
		if ownsRoom then
			local doorExists = false
			for k, v in pairs(ents.FindByClass("reservableroom")) do
				if v:GetOwner() == ply then
					if IsValid(v:GetDoorEnt()) then
						doorExists = true
					end
				end
			end
			
			if doorExists then
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if v:GetOwner() == ply then
						v:GetDoorEnt():Fire("unlock")
					end
				end
				
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "You have unlocked your door." )
				net.Send( ply )
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "There is no door for this room." )
				net.Send( ply )
			end
		else
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "You do not own a door." )
			net.Send( ply )
		end
	end
	
	local function reserveReservableRoom( ply, id )
		if isnumber(id) and id then
			local roomIsValid = false
			for k, v in pairs(ents.FindByClass("reservableroom")) do
				if tonumber(id) == v:GetRID() then
					roomIsValid = true
				end
			end
			if roomIsValid then
				local alreadyOwnsRoom = false
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if v:GetOwner() == ply then
						alreadyOwnsRoom = true
					end
				end
				if alreadyOwnsRoom == false then
					checkIfRoomIsClear( ply, id )
					if entsInRoom == 0 then
						local roomAlreadyOwned = false
						for k, v in pairs(ents.FindByClass("reservableroom")) do
							if v:GetRID() == tonumber(id) then
								if IsValid(v:GetOwner()) then
									roomAlreadyOwned = true
								end
							end
						end
						if roomAlreadyOwned == false then
							for k, v in pairs(ents.FindByClass("reservableroom")) do
								if v:GetRID() == tonumber(id) then
									v:SetOwner(ply)
									if IsValid(v:GetDoorEnt()) then
										v:GetDoorEnt():Fire("close")
									end
								end
							end
							lockRRoomDoor( ply )
							net.Start( "reservableRoomUserFeedBack" )
								net.WriteString( "You have claimed room "..id.."." )
							net.Send( ply )
						else
							net.Start( "reservableRoomUserFeedBack" )
								net.WriteString( "Someone already owns this room." )
							net.Send( ply )
						end
					else
						net.Start( "reservableRoomUserFeedBack" )
							net.WriteString( "There is something or someone in this room." )
						net.Send( ply )
					end
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "You already own a room." )
					net.Send( ply )
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "Please enter a correct ID." )
				net.Send( ply )
			end
		else
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "Please enter a correct ID." )
			net.Send( ply )
		end
	end
	
	local function clearReservableRoom( ply, id )
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if isnumber(id) and id then
				local roomIsValid = false
				for k, v in pairs(ents.FindByClass("reservableroom")) do
					if tonumber(id) == v:GetRID() then
						roomIsValid = true
					end
				end
				if roomIsValid then
					for k, v in pairs(ents.FindByClass("reservableroom")) do
						if v:GetRID() == tonumber(id) then
							v:SetOwner(nil)
						end
					end
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "You have cleared room "..id.."."				)
					net.Send( ply )
				else
					net.Start( "reservableRoomUserFeedBack" )
						net.WriteString( "Please enter a correct ID." )
					net.Send( ply )
				end
			else
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString( "Please enter a correct ID." )
				net.Send( ply )
			end
		else
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "You are not >= admin." )
			net.Send( ply )
		end
	end
	
	local function unclaimReservableRoom( ply )
		local ownsRoom = false
		for k, v in pairs(ents.FindByClass("reservableroom")) do
			if v:GetOwner() == ply then
				ownsRoom = true
			end
		end
		
		if ownsRoom then
			unlockRRoomDoor( ply )
			for k, v in pairs(ents.FindByClass("reservableroom")) do
				if v:GetOwner() == ply then
					v:SetOwner(nil)
				end
			end
			
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "You have unclaimed your room." )
			net.Send( ply )
		else
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "You do not own a room." )
			net.Send( ply )
		end
	end
	
	hook.Add( "PlayerSay", "playerSayReservableRoomCommand", function( ply, text )
		local plySaySplit = string.Split(string.lower(text)," ")
		
		if plySaySplit[1] == "!claim" then reserveReservableRoom( ply, tonumber(plySaySplit[2]) ) return "" end
		if plySaySplit[1] == "!clear" then clearReservableRoom( ply, tonumber(plySaySplit[2]) ) return "" end
		if plySaySplit[1] == "!lockdoor" then lockRRoomDoor( ply ) return "" end
		if plySaySplit[1] == "!rrv" then
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString( "This server is running ReservableRooms version "..ReservableRoomsVersion.."." )
			net.Send( ply )
			return ""
		end
		if plySaySplit[1] == "!unclaim" then unclaimReservableRoom( ply ) return "" end
		if plySaySplit[1] == "!unlockdoor" then unlockRRoomDoor( ply ) return "" end
	end)
	
	hook.Add( "PlayerDisconnected", "playerLeftUnReserveRoomHook", function( ply )
		unclaimReservableRoom( ply )
	end)

end