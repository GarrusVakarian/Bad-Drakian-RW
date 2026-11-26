/datum/card_table_session/proc/poker_player_in_hand(datum/card_table_player/player)
	return player_is_active(player) && !player.poker_folded

/datum/card_table_session/proc/poker_uses_community_cards()
	return poker_variant == CARD_TABLE_POKER_TEXAS || poker_variant == CARD_TABLE_POKER_OMAHA || poker_variant == CARD_TABLE_POKER_STUD

/datum/card_table_session/proc/poker_active_hands_count()
	var/count = 0
	for(var/datum/card_table_player/player in players)
		if(poker_player_in_hand(player))
			count++
	return count

/datum/card_table_session/proc/poker_next_betting_index(start_index)
	if(!players.len)
		return 0
	for(var/offset = 0, offset < players.len, offset++)
		var/check_index = start_index + offset
		while(check_index > players.len)
			check_index -= players.len
		var/datum/card_table_player/player = players[check_index]
		if(poker_player_in_hand(player) && !player.ready && !player.poker_all_in)
			return check_index
	return 0

/datum/card_table_session/proc/poker_reset_betting_round()
	poker_current_bet = 10
	for(var/datum/card_table_player/player in players)
		if(poker_player_in_hand(player) && !player.poker_all_in)
			player.ready = FALSE
			player.poker_bet = 0
		else if(poker_player_in_hand(player))
			player.ready = TRUE
	poker_turn_index = poker_next_betting_index(dealer_index + 1)
	poker_betting_round = community_cards.len
	return poker_turn_index

/datum/card_table_session/proc/poker_after_betting_round()
	if(poker_active_hands_count() <= 1)
		poker_finish()
		return
	if(!poker_uses_community_cards())
		poker_finish()
		return
	while(community_cards.len < 5)
		var/list/new_card = draw_one()
		if(!new_card)
			break
		community_cards += list(new_card)
		if(poker_reset_betting_round())
			message = "Community card [community_cards.len]/5 revealed. A new betting round begins."
			return
	poker_finish()

/datum/card_table_session/proc/poker_current_player() as /datum/card_table_player
	if(poker_turn_index < 1 || poker_turn_index > players.len)
		return null
	var/datum/card_table_player/player = players[poker_turn_index]
	if(!poker_player_in_hand(player) || player.ready || player.poker_all_in)
		return null
	return player

/datum/card_table_session/proc/poker_next_turn()
	if(poker_active_hands_count() <= 1)
		poker_finish()
		return
	for(var/offset = 1, offset <= players.len, offset++)
		var/check_index = poker_turn_index + offset
		while(check_index > players.len)
			check_index -= players.len
		var/datum/card_table_player/next_player = players[check_index]
		if(poker_player_in_hand(next_player) && !next_player.ready && !next_player.poker_all_in)
			poker_turn_index = check_index
			return
	poker_after_betting_round()

/datum/card_table_session/proc/poker_check(mob/user)
	return poker_bet(user, poker_current_bet)

/datum/card_table_session/proc/poker_bet(mob/user, amount, all_in = FALSE)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || !player || player != poker_current_player())
		return FALSE
	amount = text2num("[amount]")
	if(isnull(amount))
		return FALSE
	amount = clamp(round(amount), poker_current_bet, 100000)
	var/raised = amount > poker_current_bet
	if(raised)
		poker_current_bet = amount
		for(var/datum/card_table_player/other in players)
			if(poker_player_in_hand(other) && !other.poker_all_in)
				other.ready = FALSE

	var/delta = amount - player.poker_bet
	poker_pot += delta
	player.poker_total_bet += delta
	player.poker_bet = amount
	player.ready = TRUE
	player.poker_all_in = all_in
	if(all_in)
		message = "[player.name] goes all in."
	else if(raised)
		message = "[player.name] bets [amount]."
	else
		message = "[player.name] calls."
	poker_next_turn()
	return TRUE

/datum/card_table_session/proc/poker_all_in(mob/user)
	return poker_bet(user, poker_current_bet + 100, TRUE)

/datum/card_table_session/proc/poker_fold(mob/user)
	var/datum/card_table_player/player = player_for_user(user)
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || !player || player != poker_current_player())
		return FALSE
	player.poker_folded = TRUE
	player.ready = TRUE
	player.result = "Fold"
	message = "[player.name] folds."
	poker_next_turn()
	return TRUE

/datum/card_table_session/proc/poker_discard(mob/user, card_index)
	var/datum/card_table_player/player = player_for_user(user)
	card_index = text2num("[card_index]")
	if(stage != CARD_TABLE_STAGE_PLAYING || game_type != CARD_TABLE_GAME_POKER || poker_variant != CARD_TABLE_POKER_DRAW || !player || player != poker_current_player() || player.draws_used >= 1)
		return FALSE
	if(card_index != round(card_index) || card_index < 1 || card_index > player.hand.len)
		return FALSE
	var/list/new_card = draw_one()
	if(!new_card)
		return FALSE
	discard += list(player.hand[card_index])
	player.hand[card_index] = new_card
	for(var/datum/card_table_player/viewer in players)
		var/list/seen = xylix_seen_cards[xylix_reveal_key(viewer.ckey, player.ckey)]
		if(seen)
			seen -= card_index
	player.draws_used = 1
	message = "[player.name] swaps a card."
	return TRUE

/// Scores a five-card hand by category followed by the relevant ranks in tie-break order.
/datum/card_table_session/proc/poker_score(list/hand)
	if(length(hand) != 5)
		return 0
	var/list/counts = new /list(14)
	var/first_suit
	var/flush = TRUE
	for(var/list/card in hand)
		var/rank = card_table_card_rank_value(card)
		counts[rank]++
		if(!first_suit)
			first_suit = card["suit"]
		else if(first_suit != card["suit"])
			flush = FALSE

	var/list/singles = list()
	var/list/pairs = list()
	var/trips = 0
	var/quads = 0
	for(var/rank = 14, rank >= 2, rank--)
		switch(counts[rank])
			if(1)
				singles += rank
			if(2)
				pairs += rank
			if(3)
				trips = rank
			if(4)
				quads = rank

	var/straight_high = 0
	if(singles.len == 5)
		if(singles[1] - singles[5] == 4)
			straight_high = singles[1]
		else if(singles[1] == 14 && singles[2] == 5 && singles[5] == 2)
			straight_high = 5

	if(flush && straight_high)
		return poker_rank_score(8, list(straight_high))
	if(quads)
		return poker_rank_score(7, list(quads) + singles)
	if(trips && pairs.len)
		return poker_rank_score(6, list(trips) + pairs)
	if(flush)
		return poker_rank_score(5, singles)
	if(straight_high)
		return poker_rank_score(4, list(straight_high))
	if(trips)
		return poker_rank_score(3, list(trips) + singles)
	if(pairs.len == 2)
		return poker_rank_score(2, pairs + singles)
	if(pairs.len)
		return poker_rank_score(1, pairs + singles)
	return poker_rank_score(0, singles)

/// Packs up to five ranks into base 15 so the category dominates every tie-break.
/datum/card_table_session/proc/poker_rank_score(category, list/ranks)
	var/score = category
	for(var/i in 1 to 5)
		score = score * 15 + (i <= ranks.len ? ranks[i] : 0)
	return score

/datum/card_table_session/proc/poker_score_for_player(datum/card_table_player/player)
	if(!poker_uses_community_cards())
		return poker_score(player.hand)
	var/private_count = player.hand.len
	var/list/available = player.hand + community_cards
	var/best = 0
	if(available.len < 5)
		return 0
	for(var/a in 1 to available.len - 4)
		for(var/b in a + 1 to available.len - 3)
			for(var/c in b + 1 to available.len - 2)
				// Valorian poker requires exactly two personal and three community cards.
				if(poker_variant == CARD_TABLE_POKER_OMAHA && (b > private_count || c <= private_count))
					continue
				for(var/d in c + 1 to available.len - 1)
					for(var/e in d + 1 to available.len)
						best = max(best, poker_score(list(available[a], available[b], available[c], available[d], available[e])))
	return best

/datum/card_table_session/proc/poker_finish()
	var/best_score = -1
	var/list/winners = list()
	for(var/datum/card_table_player/player in players)
		if(!poker_player_in_hand(player))
			continue
		var/score = poker_score_for_player(player)
		if(score > best_score)
			best_score = score
			winners = list(player)
		else if(score == best_score)
			winners += player
	var/list/winner_names = list()
	for(var/datum/card_table_player/player in players)
		if(!poker_player_in_hand(player))
			continue
		if(player in winners)
			player.result = winners.len > 1 ? "Tie" : "Winner"
			winner_names += player.name
		else
			player.result = "Lost"
	stage = CARD_TABLE_STAGE_FINISHED
	if(!winners.len)
		message = "Nobody wins the hand."
	else if(winners.len == 1)
		message = "[winner_names[1]] wins the hand."
	else
		message = "[jointext(winner_names, ", ")] tie for the hand."
