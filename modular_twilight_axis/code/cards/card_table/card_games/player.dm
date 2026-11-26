/datum/card_table_player
	var/ckey
	var/name
	var/list/hand = list()
	var/standing = FALSE
	var/busted = FALSE
	var/ready = FALSE
	var/draws_used = 0
	var/poker_folded = FALSE
	var/poker_all_in = FALSE
	var/poker_bet = 0
	var/poker_total_bet = 0
	var/result = null
	var/left = FALSE
	var/is_spirit = FALSE

/datum/card_table_session/proc/player_public_data_for(datum/card_table_player/player, datum/card_table_player/viewer)
	if(!player)
		return list()
	var/show_hand = (stage == CARD_TABLE_STAGE_FINISHED || player == viewer)
	var/list/seen
	if(!show_hand && viewer && player.ckey)
		seen = xylix_seen_cards[xylix_reveal_key(viewer.ckey, player.ckey)]
	var/list/hand_data = list()
	for(var/i = 1, i <= player.hand.len, i++)
		var/list/card = player.hand[i]
		var/revealed = show_hand || (i in seen)
		hand_data += list(list(
			"index" = i,
			"label" = revealed ? card_table_card_label(card) : "??",
			"rank" = revealed ? card["rank"] : "?",
			"suit" = revealed ? card["suit"] : "?",
			"hidden" = !revealed,
		))
	return list(
		"name" = player.name,
		"hand" = hand_data,
		"hand_count" = player.hand.len,
		"standing" = player.standing,
		"busted" = player.busted,
		"ready" = player.ready,
		"draws_used" = player.draws_used,
		"poker_folded" = player.poker_folded,
		"poker_all_in" = player.poker_all_in,
		"poker_bet" = player.poker_bet,
		"poker_total_bet" = player.poker_total_bet,
		"result" = player.result,
		"left" = player.left,
		"is_spirit" = player.is_spirit,
	)
