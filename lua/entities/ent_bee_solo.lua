AddCSLuaFile()
DEFINE_BASECLASS('ent_bee')

function ENT:Initialize()
	self.RandomTeam = false
	self.EnemyAll = true
	self.BaseClass.Initialize(self)
end