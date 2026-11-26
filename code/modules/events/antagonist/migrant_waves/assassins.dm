/datum/round_event_control/antagonist/migrant_wave/assassins
	name = "Assassin Migration"
	typepath = /datum/round_event/migrant_wave/assassins
	wave_type = /datum/migrant_wave/assassin
	max_occurrences = 2

	weight = 10

	earliest_start = 0 SECONDS

	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
	)

/datum/round_event/migrant_wave/assassins/start()
	var/datum/job/assassin_job = SSjob.GetJob("Assassin")
	if(!assassin_job || assassin_job.total_positions >= 2)
		return
	assassin_job.total_positions++
	assassin_job.spawn_positions = min(assassin_job.spawn_positions + 1, 2)
	SSrole_class_handler.assassins_in_round = TRUE
	for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
		if(!player.client)
			continue
		to_chat(player, span_danger("Graggar demands blood, assassins flock to [SSmapping.map_adjustment.realm_name]. An assassin slot has been opened."))
