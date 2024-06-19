BEE_TEAM_ENUM = {
	NONE = 0,
	RED = 1,
	BLUE = 2,
}

if SERVER then
	resource.AddWorkshop('545462989')

	hook.Add('PlayerSpawnedNPC', 'BeeSpawnerSetOwner', function(ply, npc)
		if npc:GetClass() == 'ent_bee_war' then
			npc:SetOwner(ply)
		end
	end)
end

if CLIENT then
	language.Add('ent_bee', 'BEE')
	language.Add('ent_bee_team', 'BEE (Team)')
	language.Add('ent_bee_solo', 'BEE (Solo)')

	-- Скачивание модели NPC для особо тупых
	hook.Add('InitPostEntity', 'Beeeeeeeee_Check_ValidModelSubscribe', function()
		if game.SinglePlayer() and not util.IsValidModel('models/lucian/props/stupid_bee.mdl') and not steamworks.IsSubscribed('545462989') then
			steamworks.FileInfo('545462989', function(result)
				if not result or result.banned or result.disabled then return end

				steamworks.DownloadUGC('545462989', function(path)
					xpcall(function()
						game.MountGMA(path)
					end, function() end)
				end)
			end)
		end
	end)
end

list.Set('NPC', 'ent_bee', {
	Name = 'BEE',
	Class = 'ent_bee',
	Category = 'Fun'
})

list.Set('NPC', 'ent_bee_team', {
	Name = 'BEE (Team)',
	Class = 'ent_bee_team',
	Category = 'Fun'
})

list.Set('NPC', 'ent_bee_solo', {
	Name = 'BEE (Solo)',
	Class = 'ent_bee_solo',
	Category = 'Fun'
})

list.Set('NPC', 'ent_bee_war', {
	Name = 'BEE WAR',
	Class = 'ent_bee_war',
	Category = 'Fun'
})

sound.Add({
	name = 'sfx_bee_fly',
	channel = CHAN_BODY,
	volume = 1.0,
	level = 100,
	pitch = {80, 130},
	sound = Sound('bee_war/bee_flying.wav'),
})

sound.Add({
	name = 'sfx_bee_die',
	channel = CHAN_BODY,
	volume = 1.0,
	level = 140,
	pitch = 90,
	sound = Sound('bee_war/bee_die.wav'),
})

sound.Add({
	name = 'sfx_bee_hit',
	channel = CHAN_BODY,
	volume = 1.0,
	level = 100,
	pitch = 120,
	sound = Sound('bee_war/sfx_hit.wav'),
})

if SERVER then

else

end