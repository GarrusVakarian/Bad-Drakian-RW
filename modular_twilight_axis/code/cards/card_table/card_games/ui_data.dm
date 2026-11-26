/datum/card_table_session/proc/build_card_data(list/cards, hidden = FALSE)
	var/list/out = list()
	for(var/i = 1, i <= cards.len, i++)
		var/list/card = cards[i]
		out += list(list(
			"index" = i,
			"label" = hidden ? "??" : card_table_card_label(card),
			"rank" = hidden ? "?" : card["rank"],
			"suit" = hidden ? "?" : card["suit"],
			"hidden" = hidden,
			"value" = hidden ? null : blackjack_card_nominal(card),
		))
	return out

/datum/card_table_session/proc/build_xylix_peek_cards(mob/user) as /list
	var/count = min(xylix_peek_count(user), deck.len)
	if(count <= 0)
		return list()
	var/list/cards = list()
	for(var/i = 1, i <= count, i++)
		cards += list(deck[i])
	return build_card_data(cards, FALSE)

/datum/card_table_session/proc/current_rules() as /list
	var/list/rules = list()
	switch(game_type)
		if(CARD_TABLE_GAME_BLACKJACK)
			rules += "Goal: get as close to 21 as you can without going over."
			rules += "Hit takes a card, Stand locks in your hand."
			rules += "The dealer is always one of the players. [dealer_rotation_label()]."
			switch(blackjack_variant)
				if(CARD_TABLE_BLACKJACK_GRON)
					rules += "Gronnic: aces count as 1; jacks, queens and kings count as 11."
				if(CARD_TABLE_BLACKJACK_VALORIA)
					rules += "Valorian: aces, jacks, queens and kings all count as 10."
				if(CARD_TABLE_BLACKJACK_GRENZELHOFT)
					rules += "Grenzelhoftian: aces count as 10, but two aces make 21; jacks, queens and kings count as 10."
				if(CARD_TABLE_BLACKJACK_KAZENGUN)
					rules += "Kazengunite: aces, jacks, queens and kings all count as 1."
				else
					rules += "Rockhillian: aces count as 11, but two aces make 21; jacks, queens and kings count as 10."
		if(CARD_TABLE_GAME_POKER)
			rules += "Goal: make the best hand."
			rules += "Betting: enter an amount. If it is no higher than the current bet, Bet checks or calls; if it is higher, it raises. All In raises by 100 chips and passes on later bets. Fold gives up your hand. Chips are for this game only."
			switch(poker_variant)
				if(CARD_TABLE_POKER_TEXAS)
					rules += "Raneshi: each player holds 2 cards, with 5 community cards on the table."
				if(CARD_TABLE_POKER_OMAHA)
					rules += "Valorian: use exactly 2 of your 4 cards and 3 of the 5 community cards."
				if(CARD_TABLE_POKER_STUD)
					rules += "Giza: each player gets 5 personal cards and can use the community cards. No swaps."
				else
					rules += "Rockhillian: each player gets 5 cards and may swap one card once."
			rules += "The dealer is always one of the players. [dealer_rotation_label()]."
			if(poker_uses_community_cards())
				rules += "Raneshi, Valorian and Giza: community cards are revealed one per round, with a new betting round after each card."
			else
				rules += "Rockhillian: there are no community cards; only the players' hands are compared."
	return rules

/datum/card_table_session/proc/build_ui_data(mob/user) as /list
	var/datum/card_table_player/me = player_for_user(user)
	var/list/player_rows = list()
	for(var/datum/card_table_player/player in players)
		var/list/player_row = player_public_data_for(player, me)
		var/show_hand = (stage == CARD_TABLE_STAGE_FINISHED || player == me)
		player_row["hand_value"] = (show_hand && game_type == CARD_TABLE_GAME_BLACKJACK) ? hand_value(player.hand) : null
		player_row["is_dealer"] = (player == dealer_player())
		player_rows += list(player_row)
	var/list/observer_rows = list()
	for(var/ckey in observers)
		var/mob/M = card_table_find_mob_by_ckey(ckey)
		if(M)
			observer_rows += card_table_display_name(M)
	var/list/my_hand = me ? build_card_data(me.hand, FALSE) : list()
	var/datum/card_table_player/table_dealer = dealer_player()
	var/my_player_index = player_index(me)
	var/is_host = my_player_index == 1
	var/xylix_level = me ? xylix_tier(user) : -1
	var/datum/card_table_player/poker_turn_player = poker_current_player()
	return list(
		"game_type" = game_type,
		"game_label" = game_label(),
		"poker_variant" = poker_variant,
		"poker_variant_label" = poker_variant_label(),
		"blackjack_variant" = blackjack_variant,
		"blackjack_variant_label" = blackjack_variant_label(),
		"dealer_rotates" = dealer_rotates,
		"dealer_rotation_label" = dealer_rotation_label(),
		"dealer_name" = table_dealer ? table_dealer.name : null,
		"rules" = current_rules(),
		"stage" = stage,
		"message" = message,
		"players" = player_rows,
		"observers" = observer_rows,
		"my_player_index" = my_player_index,
		"is_player" = !!me,
		"is_host" = is_host,
		"is_observer" = is_observer(user),
		"my_hand" = my_hand,
		"deck_count" = deck.len,
		"discard_count" = discard.len,
		"min_players" = min_players(),
		"max_players" = max_players(),
		"can_start" = (stage == CARD_TABLE_STAGE_LOBBY && is_host && game_type != CARD_TABLE_GAME_NONE && players.len >= min_players()),
		"can_pack" = can_pack(),
		"dealer_value" = (table_dealer && stage == CARD_TABLE_STAGE_FINISHED) ? hand_value(table_dealer.hand) : null,
		"community_cards" = (game_type == CARD_TABLE_GAME_POKER && poker_uses_community_cards()) ? build_card_data(community_cards, FALSE) : list(),
		"poker_turn" = (game_type == CARD_TABLE_GAME_POKER && stage == CARD_TABLE_STAGE_PLAYING) ? poker_turn_player?.name : null,
		"can_act_in_poker" = (game_type == CARD_TABLE_GAME_POKER && stage == CARD_TABLE_STAGE_PLAYING && me && me == poker_turn_player),
		"poker_current_bet" = (game_type == CARD_TABLE_GAME_POKER) ? poker_current_bet : 0,
		"poker_pot" = (game_type == CARD_TABLE_GAME_POKER) ? poker_pot : 0,
		"poker_betting_round" = (game_type == CARD_TABLE_GAME_POKER) ? poker_betting_round : 0,
		"blackjack_action_seq" = blackjack_action_seq,
		"blackjack_action_player_index" = blackjack_action_player_index,
		"blackjack_action_bust" = blackjack_action_bust,
		"my_value" = me ? hand_value(me.hand) : null,
		"xylix" = list(
			"enabled" = (stage == CARD_TABLE_STAGE_PLAYING && xylix_level >= CLERIC_T0),
			"tier" = xylix_level,
			"skill" = xylix_holy_skill(user),
			"caught_chance" = xylix_caught_chance(user),
			"can_choose" = xylix_can_choose_card(user),
			"cards" = xylix_level >= CLERIC_T0 ? build_xylix_peek_cards(user) : list(),
		),
	)
