ENT.Type = "brush" -- Need to basic define entity, server ent, no need for client or shared
ENT.Base = "base_gmodentity" -- Ent base

local IgnoredPropsClass = {"gmod_button", "prop_door_rotating", "func_door", "func_viscluster", "info_player_start", "func_detail", "trigger_teleport", "prop_static", "npc_grenade_bugbait", "npc_grenade_frag", "worldspawn", "reservableroom", "physgun_beam" }

function ENT:Initialize() -- Start enttiy init
    self:SetSolid(SOLID_BBOX) -- No idea what BBOX is, uh, idk, it works, all that matters
    self:SetTrigger(true) -- Allows running things like StartTouch
end

local function itWasAPlayer(ent, claimedPlayers)
	if !table.HasValue(claimedPlayers, ent) then
		ent:Kill()
		ent:SendLua("chat.AddText(Color(255,0,255),\"[ReservableRooms] \", Color(255,255,255),\"You are not allowed in this room.\")")
	end
end

local function itWasAProp(ent, claimedPlayers)
	if !table.HasValue(claimedPlayers, ent:CPPIGetOwner()) then
		if !table.HasValue(IgnoredPropsClass, ent:GetClass()) then
			ent:Remove()
		end
	end
end

function ENT:StartTouch(ent, claimedPlayers)
	local claimedPlayers = self:GetVar("ClaimedPlayers", {})
	if table.Count(claimedPlayers) != 0 then
		if ent:IsPlayer() then itWasAPlayer(ent, claimedPlayers)
		else itWasAProp(ent, claimedPlayers) end
	end
end