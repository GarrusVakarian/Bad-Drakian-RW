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
	min_players = 15
	allow_unfilled_candidates = TRUE

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

/datum/round_event/antagonist/solo/dreamwalker/start()
	. = ..()
	for(var/datum/mind/candidate as anything in setup_minds)
		if(candidate.has_antag_datum(/datum/antagonist/dreamwalker))
			return
	SSgamemode.offer_latejoin_villain_slots(ROLE_DREAMWALKER, 1)

/mob/living/carbon/human
	var/tmp/latejoin_dreamwalker_pending = FALSE
	var/tmp/druid_doctrine_pending = FALSE

/mob/living/carbon/human/proc/queue_latejoin_dreamwalker()
	latejoin_dreamwalker_pending = TRUE
	RegisterSignal(src, list(COMSIG_MOB_LOGOUT, COMSIG_MIND_TRANSFER, COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(cancel_latejoin_dreamwalker))

/mob/living/carbon/human/proc/cancel_latejoin_dreamwalker()
	SIGNAL_HANDLER
	if(!latejoin_dreamwalker_pending)
		return
	latejoin_dreamwalker_pending = FALSE
	UnregisterSignal(src, list(COMSIG_MOB_LOGOUT, COMSIG_MIND_TRANSFER, COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	SSgamemode.latejoin_villain_slots[ROLE_DREAMWALKER]++

/mob/living/carbon/human/proc/finish_latejoin_dreamwalker()
	if(!latejoin_dreamwalker_pending || druid_doctrine_pending || SSrole_class_handler.class_select_handlers[ckey])
		return
	if(!client || !mind || mind.current != src || mind.picking || stat == DEAD || !SSticker.IsRoundInProgress() || isseelie(src) || mind.has_antag_datum(/datum/antagonist/assassin) || mind.has_antag_datum(/datum/antagonist/aspirant) || mind.has_antag_datum(/datum/antagonist/zombie))
		cancel_latejoin_dreamwalker()
		to_chat(src, span_warning("Your Dreamwalker assignment failed. You joined as your chosen job."))
		return
	for(var/datum/antagonist/antag as anything in mind.antag_datums)
		if(!(antag.antag_flags & FLAG_FAKE_ANTAG))
			cancel_latejoin_dreamwalker()
			to_chat(src, span_warning("Your Dreamwalker assignment failed. You joined as your chosen job."))
			return
	latejoin_dreamwalker_pending = FALSE
	UnregisterSignal(src, list(COMSIG_MOB_LOGOUT, COMSIG_MIND_TRANSFER, COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	if(mind.add_antag_datum(/datum/antagonist/dreamwalker))
		add_credit()
	else
		SSgamemode.latejoin_villain_slots[ROLE_DREAMWALKER]++
		to_chat(src, span_warning("Your Dreamwalker assignment failed. You joined as your chosen job."))
