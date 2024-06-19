AddCSLuaFile()
DEFINE_BASECLASS('ent_bee')

function ENT:Initialize()
	self.RandomTeam = true
	self.EnemyAll = false
	self.BaseClass.Initialize(self)
end