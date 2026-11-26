/datum/round_event_control/antagonist/solo/assassins
	name = "Assassins"
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
		TAG_BLOOD
	)
	roundstart = TRUE
	antag_flag = ROLE_ASSASSIN
	shared_occurence_type = SHARED_MINOR_THREAT

	restricted_roles = list(
		"Grand Duke",
		"Grand Duchess",
		"Consort",
		"Marshal",
		"Bandit",
		"Bishop",
		"Acolyte",
		"Martyr",
		"Templar",
		"Captain",
		"Knight Captain",
		"Watch Captain",
		"Master Warden",
		"Knight",
		"Court Magician",
		"Inquisitor",
		"Orthodoxist",
		"Absolver",
		"Vampire",
		"Vampire Lord",
		"Vampire Servant",
		"Vampire Guard",
		"Vampire Spawn",
		"Werewolf",
		"Lich",
		"Wretch",
		"Veteran",
		"Knight Captain",
		"Bandit"
	)

	base_antags = 2
	maximum_antags = 4
	allow_unfilled_candidates = TRUE

	earliest_start = 0 SECONDS
	max_occurrences = 2

	weight = 10

	typepath = /datum/round_event/antagonist/solo/assassins
	antag_datum = /datum/antagonist/assassin

/datum/round_event_control/antagonist/solo/assassins/trim_candidates(list/candidates)
	. = ..()
	var/datum/job/assassin_job = SSjob.GetJob("Assassin")
	for(var/mob/candidate as anything in .)
		if(!is_assassin_species_allowed(candidate, assassin_job) || is_already_assassin(candidate.mind))
			. -= candidate

/datum/round_event_control/antagonist/solo/assassins/proc/is_already_assassin(datum/mind/candidate)
	return candidate?.assigned_role == "Assassin" || candidate?.has_antag_datum(/datum/antagonist/assassin)

/datum/round_event_control/antagonist/solo/assassins/proc/is_assassin_species_allowed(mob/candidate, datum/job/assassin_job)
	if(QDELETED(candidate) || !assassin_job)
		return FALSE
	if(candidate.client && !assassin_job.is_species_allowed(candidate.client.prefs?.pref_species?.type))
		return FALSE
	if(ishuman(candidate))
		var/mob/living/carbon/human/character = candidate
		return assassin_job.is_species_allowed(character.dna?.species?.type)
	return isnewplayer(candidate) && !!candidate.client

/datum/round_event/antagonist/solo/assassins/start()
	var/datum/round_event_control/antagonist/solo/assassins/assassin_control = control
	var/datum/job/assassin_job = SSjob.GetJob("Assassin")
	var/filled_slots = 0
	for(var/datum/mind/antag_mind as anything in setup_minds)
		if(assassin_control.is_already_assassin(antag_mind))
			filled_slots++
			antag_mind.picking = FALSE
			continue
		var/mob/living/carbon/human/character = antag_mind.current
		var/datum/job/original_job = SSjob.GetJob(antag_mind.assigned_role)
		if(!ishuman(character) || !assassin_control.is_assassin_species_allowed(character, assassin_job) || !SSjob.AssignRole(character, "Assassin"))
			antag_mind.picking = FALSE
			if(antag_mind.special_role == ROLE_ASSASSIN)
				antag_mind.special_role = null
				antag_mind.restricted_roles = null
			continue
		if(character.client)
			SSrole_class_handler.cancel_class_handler(character.client.ckey)
		if(original_job)
			if(original_job.total_positions == 1)
				original_job.current_positions = max(original_job.current_positions, 1)
			else
				original_job.current_positions += 1
		if(antag_mind.add_antag_datum(/datum/antagonist/assassin))
			filled_slots++
			SSmapping.retainer.assassins |= character
			SSrole_class_handler.assassins_in_round = TRUE

	if(assassin_job && filled_slots < antag_count)
		var/latejoin_slots = min(2, antag_count - filled_slots)
		assassin_job.total_positions = max(assassin_job.total_positions, assassin_job.current_positions + latejoin_slots)
		SSrole_class_handler.assassins_in_round = TRUE
