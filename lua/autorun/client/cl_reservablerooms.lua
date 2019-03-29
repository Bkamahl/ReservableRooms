local rrColor = Color(255,0,255)

net.Receive( "reservableRoomUserFeedBack", function()
	chat.AddText( rrColor, "[ReservableRooms] ", Color( 255, 255, 255 ), net.ReadString() .. "." )
end )