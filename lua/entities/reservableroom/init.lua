ENT.Type = "brush" -- Need to basic define entity, server ent, no need for client or shared
ENT.Base = "base_gmodentity" -- Ent base

function ENT:Initialize() -- Start entity init
	self:SetSolid(SOLID_BBOX) -- No idea what BBOX is, uh, idk, it works, all that matters
	self:SetTrigger(true) -- Allows running things like StartTouch
end

function ENT:SetupDataTables()
	self:NetworkVar( "Float", 0, "RID" )
end

local function itWasAPlayer(ent, claimedPlayers)
	if !table.HasValue(claimedPlayers, ent) then
		ent:KillSilent()
		ent:SendLua("chat.AddText(Color(255,0,255),\"[ReservableRooms] \", Color(255,255,255),\"You are not allowed in " .. claimedPlayers[1]:GetName() .. "'s room.\")")
	end
end

local function itWasAProp(ent, claimedPlayers)
	if ent:CPPIGetOwner():IsPlayer() then
		if !table.HasValue(claimedPlayers, ent:CPPIGetOwner()) then
			ent:Remove()
		end
	end
end

function ENT:StartTouch(ent, claimedPlayers)
	local claimedPlayers = self:GetVar("ClaimedPlayers", {})
	if table.Count(claimedPlayers) != 0 then
		if ent:IsPlayer() then itWasAPlayer(ent, claimedPlayers)
		else itWasAProp(ent, claimedPlayers) end
	elseif ent:IsPlayer() then
		ent:SendLua("chat.AddText(Color(255,0,255),\"[ReservableRooms] \", Color(255,255,255),\"This room is unclaimed, if other players aren't using it, use !claim " .. self:GetRID() .. " to claim this room.\")")
	end
end