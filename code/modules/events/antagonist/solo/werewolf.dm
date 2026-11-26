/datum/round_event_control/antagonist/solo/werewolf
	name = "Verevolfs"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	roundstart = TRUE
	antag_flag = ROLE_WEREWOLF
	shared_occurence_type = SHARED_HIGH_THREAT

	denominator = 50

	base_antags = 1
	maximum_antags = 2
	min_players = 15
	weight = 1

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/werewolf
	antag_datum = /datum/antagonist/werewolf

	restricted_roles = DEFAULT_ANTAG_BLACKLISTED_ROLES

/datum/round_event/antagonist/solo/werewolf

/datum/round_event/antagonist/solo/werewolf/setup()
	. = ..()
	SSgamemode.offer_werewolf_latejoin(src)

/datum/controller/subsystem/gamemode/proc/is_latejoin_villain_job(datum/job/job)
	return job && !job.antag_job && !(job.title in DEFAULT_ANTAG_BLACKLISTED_ROLES)

/// Apply a slot already reserved by an explicit latejoin request.
/datum/controller/subsystem/gamemode/proc/assign_latejoin_werewolf(mob/living/carbon/human/character, datum/job/job, client/latejoin_client, datum/mind/latejoin_mind)
	if(!SSticker.IsRoundInProgress() || QDELETED(character) || !latejoin_client || character.client != latejoin_client)
		return FALSE
	if(!latejoin_mind || character.mind != latejoin_mind || latejoin_mind.current != character || latejoin_mind.assigned_role != job.title || latejoin_mind.picking || !character.can_werewolf())
		return FALSE
	for(var/datum/antagonist/antag as anything in latejoin_mind.antag_datums)
		if(!(antag.antag_flags & FLAG_FAKE_ANTAG))
			return FALSE

	return !!latejoin_mind.add_antag_datum(/datum/antagonist/werewolf)
