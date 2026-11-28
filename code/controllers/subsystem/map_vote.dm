#define MAP_VOTE_STREAK_FILE "data/map_vote_streak.json"

SUBSYSTEM_DEF(map_vote)
	name = "Map Vote"
	flags = SS_NO_FIRE

	var/admin_override = FALSE
	var/already_voted = FALSE
	var/datum/map_config/next_map_config

	/// The streak entering this round.
	var/last_winner
	var/consecutive_wins = 0

/datum/controller/subsystem/map_vote/Initialize()
	if(fexists(MAP_VOTE_STREAK_FILE))
		try
			var/list/streak = json_decode(file2text(MAP_VOTE_STREAK_FILE))
			if(islist(streak) && istext(streak["map"]) && streak["map"] == SSmapping.current_map?.map_name && isnum(streak["wins"]) && streak["wins"] > 0)
				last_winner = streak["map"]
				consecutive_wins = streak["wins"]
		catch(var/exception/error)
			log_world("Could not load map vote streak: [error]")

	return ..()

/datum/controller/subsystem/map_vote/proc/save_streak(map_id, wins)
	rustg_file_write(json_encode(list("map" = map_id, "wins" = wins)), MAP_VOTE_STREAK_FILE)

/datum/controller/subsystem/map_vote/proc/send_map_vote_notice(...)
	var/static/last_message_at
	if(last_message_at == world.time)
		message_admins("Duplicate map vote notice in same tick.")
	last_message_at = world.time

	var/list/messages = args.Copy()
	to_chat(world, span_purple(examine_block("Map Vote\n<hr>\n[messages.Join("\n")]")))

/datum/controller/subsystem/map_vote/proc/get_valid_map_vote_choices(ignore_population = FALSE)
	var/connected_players = length(GLOB.clients)
	var/list/choices = list()

	for(var/map_id in config.maplist)
		var/datum/map_config/cfg = config.maplist[map_id]

		if(!cfg)
			continue
		if(!cfg.votable)
			continue
		if(!ignore_population)
			if(cfg.config_min_users > 0 && connected_players < cfg.config_min_users)
				continue
			if(cfg.config_max_users > 0 && connected_players > cfg.config_max_users)
				continue

		choices += map_id

	return choices

/// Recheck the original ballot at close. Allow population to fall to 80% of a map's minimum.
/datum/controller/subsystem/map_vote/proc/get_eligible_maps_at_close(list/ballot)
	var/connected_players = length(GLOB.clients)
	var/list/eligible_maps = list()
	for(var/map_id in ballot)
		var/datum/map_config/cfg = config.maplist[map_id]
		if(!cfg?.votable)
			continue
		if(cfg.config_min_users > 0 && connected_players < cfg.config_min_users * 0.8)
			continue
		eligible_maps += map_id
	return eligible_maps

/datum/controller/subsystem/map_vote/proc/finalize_map_vote(datum/vote/map_vote/map_vote, winning_option)
	if(already_voted)
		message_admins("Map vote already finalized.")
		return

	if(admin_override)
		send_map_vote_notice("Admin override active. Map not changed.")
		return

	// With no valid ballots, use the first eligible map or the configured default.
	var/map_id = winning_option || (length(map_vote.eligible_maps) ? map_vote.eligible_maps[1] : null)
	var/datum/map_config/winner_cfg = map_id ? config.maplist[map_id] : config.defaultmap
	if(!winner_cfg)
		send_map_vote_notice("No eligible map could be selected.")
		return

	var/voted_winner = map_vote.valid_ballots ? winning_option : null
	if(!set_next_map(winner_cfg, voted_winner))
		send_map_vote_notice("Failed to set next map.")
		return

	already_voted = TRUE

	var/list/messages = list("Map Selected - [span_bold(next_map_config.map_name)]", "")
	if(map_vote.cooldown_map)
		messages += "[map_vote.cooldown_map] led the tally again after winning at least [MAP_VOTE_COOLDOWN_WINS] votes in a row. [winning_option] gets the next round because its [map_vote.valid_tally[winning_option]] votes are at least [MAP_VOTE_COOLDOWN_PERCENT]% of the leader's [map_vote.valid_tally[map_vote.cooldown_map]] votes."
	if(!map_id)
		messages += "No ballot maps remained eligible, so the default map was selected."
	else if(length(map_vote.choices) == 1)
		messages += "Only one map was eligible, so voting was skipped."
	else if(!voted_winner)
		messages += "No valid ballots were cast. The first eligible map was selected."
	messages += "The next round will be played on [span_bold(next_map_config.map_name)]."

	send_map_vote_notice(arglist(messages))

/datum/controller/subsystem/map_vote/proc/set_next_map(datum/map_config/change_to, voted_winner)
	if(!change_to.MakeNextMap())
		message_admins("Failed to write next_map.json for [change_to.map_name]!")
		return FALSE

	next_map_config = change_to
	var/wins = voted_winner ? (voted_winner == last_winner ? consecutive_wins + 1 : 1) : 0
	save_streak(voted_winner, wins)
	return TRUE

/datum/controller/subsystem/map_vote/proc/revert_next_map()
	save_streak(last_winner, consecutive_wins)
	already_voted = FALSE
	admin_override = FALSE
	send_map_vote_notice("Next map reverted. Voting re-enabled.")

/datum/controller/subsystem/map_vote/proc/get_streak_text()
	var/rules = "Each player has one vote. If a map leads again after winning at least [MAP_VOTE_COOLDOWN_WINS] votes in a row, the eligible runner-up gets the next round if it has at least [MAP_VOTE_COOLDOWN_PERCENT]% as many votes as the leader."
	var/streak = last_winner ? "[last_winner] entered this round with [consecutive_wins] consecutive vote win(s)." : "No map entered this round with a winning streak."
	return boxed_message("Map Vote Rotation\n<hr>[rules]\n[streak]")

#undef MAP_VOTE_STREAK_FILE
