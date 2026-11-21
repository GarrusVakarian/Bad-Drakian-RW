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
	min_players = 25
	weight = 1

	earliest_start = 0 SECONDS

	typepath = /datum/round_event/antagonist/solo/werewolf
	antag_datum = /datum/antagonist/werewolf

	restricted_roles = DEFAULT_ANTAG_BLACKLISTED_ROLES

/datum/round_event/antagonist/solo/werewolf

/datum/round_event/antagonist/solo/werewolf/setup()
	. = ..()
	SSgamemode.offer_werewolf_latejoin(src)

/datum/controller/subsystem/gamemode/proc/try_assign_latejoin_werewolf(mob/living/carbon/human/character, datum/job/job)
	if(werewolf_latejoin_slots <= 0 || !job || job.antag_job || (job.title in DEFAULT_ANTAG_BLACKLISTED_ROLES))
		return
	if(!SSticker.IsRoundInProgress())
		return

	var/client/latejoin_client = character.client
	var/datum/mind/latejoin_mind = character.mind
	if(!latejoin_mind || !(ROLE_WEREWOLF in latejoin_client?.prefs?.be_special))
		return
	if(is_banned_from(latejoin_client.ckey, list(ROLE_SYNDICATE, ROLE_WEREWOLF)))
		return

	// The ban lookup can yield while another player joins.
	if(werewolf_latejoin_slots <= 0 || !SSticker.IsRoundInProgress() || QDELETED(character))
		return
	if(character.client != latejoin_client || character.mind != latejoin_mind || latejoin_mind.current != character || latejoin_mind.assigned_role != job.title)
		return
	if(!(ROLE_WEREWOLF in latejoin_client.prefs?.be_special) || latejoin_mind.picking || !character.can_werewolf())
		return
	for(var/datum/antagonist/antag as anything in latejoin_mind.antag_datums)
		if(!(antag.antag_flags & FLAG_FAKE_ANTAG))
			return

	werewolf_latejoin_slots--
	if(!latejoin_mind.add_antag_datum(/datum/antagonist/werewolf))
		werewolf_latejoin_slots++
