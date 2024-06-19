AddCSLuaFile()
ENT.Base = 'base_anim'
ENT.Spawnable = false
ENT.Author = 'Shark_vil'

function ENT:Initialize()
	self:SetNoDraw(true)

	timer.Simple(0, function()
		if not IsValid(self) then return end

		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then
			local spawn_pos_R = self:GetPos() + Vector(100, 0, 10)
			local spawn_pos_B = self:GetPos() + Vector(-100, 0, 10)
			undo.Create('BEE WAR')

			for i = 1, 10 do
				local ent = ents.Create('ent_bee_team')
				ent:SetPos(spawn_pos_R)
				ent:Spawn()

				undo.AddEntity(ent)

				spawn_pos_R.y = spawn_pos_R.y + 15

				timer.Simple(.1, function()
					if not IsValid(ent) then return end
					ent.BeeTeam = BEE_TEAM_ENUM.RED
					ent:InitTeam()
				end)
			end

			for i = 1, 10 do
				local ent = ents.Create('ent_bee_team')
				ent:SetPos(spawn_pos_B)
				ent:Spawn()

				undo.AddEntity(ent)

				spawn_pos_B.y = spawn_pos_B.y + 15

				timer.Simple(.1, function()
					if not IsValid(ent) then return end
					ent.BeeTeam = BEE_TEAM_ENUM.BLUE
					ent:InitTeam()
				end)
			end

			undo.SetPlayer(owner)
			undo.Finish()
		end

		SafeRemoveEntity(self)
	end)
end