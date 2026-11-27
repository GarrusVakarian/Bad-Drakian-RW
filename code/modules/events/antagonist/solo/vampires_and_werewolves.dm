/datum/round_event_control/antagonist/solo/vampires_and_werewolves
	name = "Vampires and Verevolves"
	tags = list(
		TAG_COMBAT,
		TAG_HAUNTED,
		TAG_VILLIAN,
	)
	roundstart = TRUE
	antag_flag = ROLE_NBEAST
	candidate_role_bans = list(ROLE_NBEAST, ROLE_VAMPIRE, ROLE_WEREWOLF)
	shared_occurence_type = SHARED_HIGH_THREAT
	denominator = 40 // this is the lower chance higher threat version

	base_antags = 2
	maximum_antags = 4

	earliest_start = 0 SECONDS

	weight = 1		//Disabled cus vampires too strong.
	max_occurrences = 1

	typepath = /datum/round_event/antagonist/solo/vampires_and_werewolves

	restricted_roles = DEFAULT_ANTAG_BLACKLISTED_ROLES

/datum/round_event_control/antagonist/solo/vampires_and_werewolves/trim_candidates(list/candidates)
	. = ..()
	// Candidates below 15 PQ can still fill the vampire half of the event.
	var/vampire_slots = FLOOR(get_antag_amount() / 2, 1)
	var/list/vampire_only = list()
	for(var/mob/candidate as anything in .)
		if(!meets_antagonist_min_pq(candidate.ckey, ROLE_WEREWOLF))
			vampire_only += candidate
	while(length(vampire_only) > vampire_slots)
		. -= pick_n_take(vampire_only)

/datum/round_event/antagonist/solo/vampires_and_werewolves
	var/leader = FALSE

/datum/round_event/antagonist/solo/vampires_and_werewolves/start()
	var/vampire = FALSE
	var/list/remaining = setup_minds.Copy()
	while(length(remaining))
		var/datum/mind/antag_mind = remaining[1]
		if(!vampire && !meets_antagonist_min_pq(antag_mind.current?.ckey || antag_mind.key, ROLE_WEREWOLF))
			for(var/datum/mind/eligible as anything in remaining)
				if(meets_antagonist_min_pq(eligible.current?.ckey || eligible.key, ROLE_WEREWOLF))
					antag_mind = eligible
					break
		remaining -= antag_mind
		if(vampire)
			add_vampire(antag_mind)
		else
			add_werewolf(antag_mind)
		vampire = !vampire

/datum/round_event/antagonist/solo/vampires_and_werewolves/proc/add_werewolf(datum/mind/antag_mind)
	if(!antag_mind.add_antag_datum(/datum/antagonist/werewolf))
		antag_mind.picking = FALSE
		if(antag_mind.special_role == antag_flag)
			antag_mind.special_role = null
			antag_mind.restricted_roles = null

/datum/round_event/antagonist/solo/vampires_and_werewolves/proc/add_vampire(datum/mind/antag_mind)
	if(!leader)
		var/datum/job/J = SSjob.GetJob(antag_mind.current?.job)
		J?.current_positions = max(J?.current_positions-1, 0)
		antag_mind.current.unequip_everything()
		antag_mind.add_antag_datum(antag_datum)
		leader = TRUE
		return
	else
		if(!antag_mind.has_antag_datum(/datum/antagonist/vampire))
			var/datum/job/J = SSjob.GetJob(antag_mind.current?.job)
			J?.current_positions = max(J?.current_positions-1, 0)
			antag_mind.current.unequip_everything()
			antag_mind.add_antag_datum(/datum/antagonist/vampire)
		return
