AddCSLuaFile()
ENT.Base = 'base_anim'
ENT.Spawnable = false
ENT.Author = 'Shark_vil'
ENT.BoneIndexWingL = nil
ENT.BoneIndexWingR = nil
ENT.WingAnimationSpeed = 3.5
ENT.WingRotationMax = 40
ENT.Speed = 120
ENT.BoneWingAngX_Up = true
ENT.BoneWingAng = Angle(0, 0, 0)
ENT.RandomTeam = false
ENT.EnemyAll = true
ENT.BeeTeam = BEE_TEAM_ENUM.NONE
ENT.UpdateEnemyTime = 0
ENT.UpdateRandomTime = 0
ENT.MovePosTarget = nil
ENT.EnemyTarget = NULL
ENT.EnemyLastDist = nil
ENT.CurrentAngleRatio = 0
ENT.TakeDamageDelay = 0
ENT.CurrentAngle = Angle()

local _CurTime = CurTime
local _util_TraceLine = util.TraceLine
local _IsValid = IsValid
local _Vector = Vector
local _math_random = math.random
local _ents_GetAll = ents.GetAll
local _ents_FindByClass = ents.FindByClass
local _ipairs = ipairs
local _FrameTime = FrameTime
local _math_sqrt = math.sqrt
local _string_find = string.find
local _collision_min = Vector(-10, -10, 0)
local _collision_max = Vector(10, 10, 10)
local _cvar_ai_ignoreplayers = GetConVar('ai_ignoreplayers')
local _cvar_ai_disabled = GetConVar('ai_disabled')

function ENT:Initialize()
	self:SetModel('models/lucian/props/stupid_bee.mdl')
	self:SetCollisionBounds(_collision_min, _collision_max)
	self:SetHealth(100)
	if SERVER then
		self:SetMaxHealth(100)
	end
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:Activate()
	self:PhysicsInitShadow()
	self:PhysWake()

	self:SetPos(self:GetPos() + _Vector(0, 0, 10))

	if CLIENT then
		timer.Simple(.25, function()
			if not _IsValid(self) then return end
			for i = 1, self:GetBoneCount() do
				local bone_name = self:GetBoneName(i)
				print(bone_name)
				if bone_name == 'wing_L' then
					self.BoneIndexWingL = i
				elseif bone_name == 'wing_R' then
					self.BoneIndexWingR = i
				end
			end
		end)
	end

	self:InitTeam()
	self:EmitSound('sfx_bee_fly')
end

function ENT:InitTeam()
	if self.RandomTeam then
		self.BeeTeam = table.Random({BEE_TEAM_ENUM.RED, BEE_TEAM_ENUM.BLUE})
		if self.BeeTeam == BEE_TEAM_ENUM.RED then
			self:SetColor(Color(255, 148, 148))
		else
			self:SetColor(Color(136, 158, 255))
		end
	end
end

function ENT:Think()
	if CLIENT then
		if not self.BoneIndexWingL or not self.BoneIndexWingR then return end

		if self.BoneWingAngX_Up then
			self.BoneWingAng.x = self.BoneWingAng.x + self.WingAnimationSpeed
			if self.BoneWingAng.x > self.WingRotationMax then
				self.BoneWingAngX_Up = false
			end
		else
			self.BoneWingAng.x = self.BoneWingAng.x - self.WingAnimationSpeed
			if self.BoneWingAng.x < -self.WingRotationMax then
				self.BoneWingAngX_Up = true
			end
		end

		self:ManipulateBoneAngles(self.BoneIndexWingL, self.BoneWingAng)
		self:ManipulateBoneAngles(self.BoneIndexWingR, self.BoneWingAng)
	else
		if _cvar_ai_disabled:GetBool() then
			return
		end

		if self.UpdateEnemyTime < _CurTime() then
			self.EnemyTarget = NULL
			self.EnemyLastDist = nil
			self.UpdateEnemyTime = _CurTime() + 3

			local bee_pos = self:GetPos()

			if not self.EnemyAll then
				for _, enemy in _ipairs(_ents_FindByClass('ent_bee*')) do
					if _IsValid(enemy) and enemy ~= self and enemy:Health() > 0 and self:IsVisibleTarget(enemy) then
						local dist = bee_pos:DistToSqr(enemy:GetPos())
						if (not self.EnemyLastDist or self.EnemyLastDist < dist) and (not self.RandomTeam or self.BeeTeam ~= enemy.BeeTeam) then
							self.EnemyTarget = enemy
							self.EnemyLastDist = dist
						end
					end
				end
			else
				for _, enemy in _ipairs(_ents_GetAll()) do
					if _IsValid(enemy) and enemy ~= self and (enemy.Base == 'ent_bee' or (not _cvar_ai_ignoreplayers:GetBool() and enemy:IsPlayer() and enemy:Alive()) or ((enemy:IsNPC() or enemy:IsNextBot()) and enemy:Health() > 0)) and self:IsVisibleTarget(enemy) then
						local dist = bee_pos:DistToSqr(enemy:GetPos())
						if (not self.EnemyLastDist or self.EnemyLastDist < dist) and (not self.RandomTeam or self.BeeTeam ~= enemy.BeeTeam) then
							self.EnemyTarget = enemy
							self.EnemyLastDist = dist
						end
					end
				end
			end
		end

		if not self:IsVisibleTarget(self.EnemyTarget) then
			self.UpdateEnemyTime = 0

			if self.UpdateRandomTime < _CurTime() then
				local center = self:LocalToWorld(self:OBBCenter())
				local tr = _util_TraceLine({
					start = center,
					endpos = center + _Vector(_math_random(-1000, 1000), _math_random(-1000, 1000), _math_random(-1000, 1000)),
					filter = function(ent)
						if not _string_find(ent:GetClass(), 'ent_bee') then return true end
					end
				})

				if tr.HitPos:DistToSqr(self:GetPos()) >= 40000 then
					self.MovePosTarget = tr.HitPos
					self.UpdateRandomTime = _CurTime() + 5
				else
					self.MovePosTarget = nil
				end
			end

			if self.MovePosTarget then
				self:MoveToVector(self.MovePosTarget, _FrameTime() * self.Speed)
				if self:GetPos():DistToSqr(self.MovePosTarget) <= 625 then
					self.UpdateRandomTime = 0
					self.MovePosTarget = nil
				end
			end
		else
			self:MoveToVector(self.EnemyTarget:LocalToWorld(self.EnemyTarget:OBBCenter()), _FrameTime() * self.Speed)
			self:DamageEnemy()
		end
	end

	self:NextThink(_CurTime())

	return true
end

function ENT:OnRemove()
	self:StopSound('sfx_bee_fly')
end

function ENT:OnTakeDamage(dmginfo)
	local new_healt = self:Health() - dmginfo:GetDamage()
	self:SetHealth(new_healt)

	if new_healt <= 0 then
		self:StopSound('sfx_bee_fly')
		self:StopSound('sfx_bee_hit')
		self:EmitSound('sfx_bee_die')
		hook.Call('OnNPCKilled', GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor())
		self:Remove()
	end
end

function ENT:IsVisibleTarget(target)
	if not _IsValid(target) then return false end

	local tr = _util_TraceLine({
		start = self:LocalToWorld(self:OBBCenter()),
		endpos = target:LocalToWorld(target:OBBCenter()),
		filter = function(ent) 
			if ent ~= self then return true end
		end
	})

	return tr.Entity == target
end

function ENT:DamageEnemy()
	if _IsValid(self.EnemyTarget) and self:GetPos():DistToSqr(self.EnemyTarget:GetPos()) <= 2500 and self.TakeDamageDelay < _CurTime() then
		self.TakeDamageDelay = _CurTime() + 1.5
		local damage_info = DamageInfo()
		damage_info:SetDamage(_math_random(5, 15))
		damage_info:SetAttacker(self)
		damage_info:SetInflictor(self)
		damage_info:SetDamageType(DMG_SLASH)
		self.EnemyTarget:TakeDamageInfo(damage_info)
		if self.EnemyTarget.Base ~= 'ent_bee' then
			self.EnemyTarget:EmitSound('sfx_bee_hit')
		end
	end
end

function ENT:MoveToVector(target_vector, delta_time)
	local current_vector = self:GetPos()
	local forward = -(current_vector - target_vector):GetNormalized()

	if self.CurrentTargetVector ~= target_vector or self.CurrentTargetForward ~= forward then
		self.CurrentAngleRatio = 0
		self.CurrentAngle = self:GetAngles()
	end

	self.CurrentTargetVector = target_vector
	self.CurrentTargetForward = forward

	self:SetPos(self:MoveTowards(current_vector, target_vector, delta_time))

	self.CurrentAngleRatio = self.CurrentAngleRatio + 0.1
	if self.CurrentAngleRatio >= 1 then
		self:SetAngles(forward:Angle())
	else
		self:SetAngles(LerpAngle(self.CurrentAngleRatio, self.CurrentAngle, forward:Angle()))
	end
end

function ENT:Magnitude(vec)
	local magnitude = vec
	magnitude = magnitude.x ^ 2 + magnitude.y ^ 2 + magnitude.z ^ 2
	magnitude = _math_sqrt(magnitude)

	return magnitude
end

function ENT:MoveTowards(current_vector, target_vector, delta_time)
	local direction_vector = target_vector - current_vector
	local magnitude = self:Magnitude(direction_vector)
	if magnitude <= delta_time or magnitude == 0 then return target_vector end

	return current_vector + direction_vector / magnitude * delta_time
end