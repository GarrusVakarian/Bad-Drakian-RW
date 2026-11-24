/datum/round_event_control/antagonist/solo/dreamwalker
	name = "Dreamwalker"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	//Can roll at any time.
	roundstart = FALSE
	antag_flag = ROLE_DREAMWALKER
	shared_occurence_type = SHARED_MINOR_THREAT

	denominator = 80

	base_antags = 1
	maximum_antags = 2
	min_players = 20

	weight = 18
	max_occurrences = 2

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/dreamwalker
	antag_datum = /datum/antagonist/dreamwalker

	restricted_roles = DEFAULT_ANTAG_BLACKLISTED_ROLES

/datum/round_event_control/antagonist/solo/dreamwalker/trim_candidates(list/candidates)
	. = ..()
	for(var/mob/candidate as anything in .)
		if(isseelie(candidate))
			. -= candidate
			continue
		var/datum/mind/candidate_mind = candidate.mind
		var/datum/job/candidate_job = SSjob.GetJob(candidate_mind.assigned_role)
		if(candidate_job?.antag_job)
			. -= candidate
			continue
		// The shared antagonist filter exempts these roles because they carry FLAG_FAKE_ANTAG.
		if(candidate_mind.has_antag_datum(/datum/antagonist/assassin) || candidate_mind.has_antag_datum(/datum/antagonist/aspirant) || candidate_mind.has_antag_datum(/datum/antagonist/zombie))
			. -= candidate

/datum/round_event/antagonist/solo/dreamwalker
