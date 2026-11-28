/datum/vote/map_vote
	name = "Map"
	default_message = "Vote for next round's map!"
	count_method = VOTE_COUNT_METHOD_SINGLE
	winner_method = VOTE_WINNER_METHOD_SIMPLE
	display_statistics = TRUE

	var/list/eligible_maps
	var/list/valid_tally
	var/valid_ballots = 0
	var/cooldown_map

/datum/vote/map_vote/is_accessible_vote()
	// Register the vote at startup even if no maps meet their population limits yet.
	return !!length(SSmap_vote.get_valid_map_vote_choices(ignore_population = TRUE))

/datum/vote/map_vote/create_vote(mob/vote_creator)
	choices.Cut()
	default_choices = SSmap_vote.get_valid_map_vote_choices()
	. = ..()
	if(!.)
		return FALSE

	if(length(choices) == 1)
		get_simple_winner()
		finalize_vote(null)
		return FALSE
	if(length(choices) == 0)
		to_chat(world, span_boldannounce("A map vote was called, but there are no maps to vote for! \
			Players, complain to the admins. Admins, complain to the coders."))
		return FALSE

	return TRUE

/datum/vote/map_vote/toggle_votable()
	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))

/datum/vote/map_vote/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/map_vote/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(SSmap_vote.next_map_config)
		return "The next map has already been selected."

	// The below case will be caught in create_vote() if the vote is being forced
	// This ensures proper map rotation if there aren't enough votable maps for whatever reason
	if(forced)
		return VOTE_AVAILABLE

	var/list/new_choices = SSmap_vote.get_valid_map_vote_choices()
	var/num_choices = length(new_choices)
	if(num_choices <= 1)
		return "There [num_choices == 1 ? "is only one map" : "are no maps"] to choose from."

	return VOTE_AVAILABLE

/datum/vote/map_vote/get_vote_result(list/non_voters)
	// Even if we have default no vote off,
	// if our default map is null for some reason, we shouldn't continue
	if(CONFIG_GET(flag/default_no_vote))
		return ..()

	for(var/non_voter_ckey in non_voters)
		var/client/non_voter_client = non_voters[non_voter_ckey]

		var/their_preferred_map = non_voter_client?.prefs?.preferred_map

		// No preferred map = abstain
		if(isnull(their_preferred_map) || (non_voter_ckey in choices_by_ckey))
			continue

		if(their_preferred_map in choices)
			choices[their_preferred_map] += 1
			choices_by_ckey[non_voter_ckey] = their_preferred_map

	return ..()

/datum/vote/map_vote/get_simple_winner()
	eligible_maps = SSmap_vote.get_eligible_maps_at_close(choices)
	valid_tally = list()
	valid_ballots = 0
	cooldown_map = null

	// The per-player selections are the ballot record, including saved preferences.
	for(var/ckey in choices_by_ckey)
		var/map_id = choices_by_ckey[ckey]
		if(map_id in eligible_maps)
			valid_tally[map_id] = (valid_tally[map_id] || 0) + 1
			valid_ballots++

	var/winner
	var/alternative
	var/winner_votes = 0
	var/alternative_votes = 0
	for(var/map_id in eligible_maps)
		var/votes = valid_tally[map_id] || 0
		// Preserve ballot order as the tiebreaker.
		if(votes > winner_votes)
			winner = map_id
			winner_votes = votes
		if(map_id != SSmap_vote.last_winner && votes > alternative_votes)
			alternative = map_id
			alternative_votes = votes

	if(!winner)
		return list()

	if(winner == SSmap_vote.last_winner && SSmap_vote.consecutive_wins >= MAP_VOTE_COOLDOWN_WINS && alternative && alternative_votes * 100 >= winner_votes * MAP_VOTE_COOLDOWN_PERCENT)
		cooldown_map = winner
		return list(alternative)

	return list(winner)

/datum/vote/map_vote/get_result_text(list/all_winners, real_winner, list/non_voters)
	var/title_text = span_bold(override_question || "Map Vote")
	var/list/results = list("Valid ballots: [valid_ballots]")
	if(display_statistics)
		for(var/map_id in choices)
			var/count = (map_id in eligible_maps) ? "[valid_tally[map_id] || 0] vote(s)" : "ineligible at close"
			results += "[span_bold(map_id)]: [count]"

	return fieldset_block(title_text, results.Join("\n"), "boxed_message purple_box")

/datum/vote/map_vote/finalize_vote(winning_option)
	SSmap_vote.finalize_map_vote(src, winning_option)
