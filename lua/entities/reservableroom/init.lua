ENT.Type = "brush"
ENT.Base = "base_gmodentity"

function ENT:Initialize()
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "DoorEnt")
	self:NetworkVar( "Entity", 1, "Owner")
	self:NetworkVar( "Float", 0, "RID" )
end

function ENT:StartTouch(ent)
	if IsValid(self:GetOwner()) then
		local friends = self:GetOwner():CPPIGetFriends()
		table.insert(friends, self:GetOwner())
		if ent:IsPlayer() then
			if !table.HasValue(friends, ent) then
				net.Start( "reservableRoomUserFeedBack" )
					net.WriteString("You are not allowed in " .. self:GetOwner():GetName() .. "'s room")
				net.Send( ent )
				ent:KillSilent()
			end
		else
			if IsValid(ent:CPPIGetOwner()) then
				if !table.HasValue(friends, ent:CPPIGetOwner()) then
					ent:Remove()
				end
			end
		end
	else
		if ent:IsPlayer() then
			net.Start( "reservableRoomUserFeedBack" )
				net.WriteString("This room is unclaimed, if it is not being used by another player, you can claim it with !claim " .. tostring(self:GetRID()))
			net.Send( ent )
		end
	end
end