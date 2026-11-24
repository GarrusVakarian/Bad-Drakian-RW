// Tying someone's laces together with a needle. Walk and you're fine, run and you eat dirt.

#define LACES_TIE_BASE_TIME			5 SECONDS
#define LACES_TIE_TIME_PER_SKILL	0.6 SECONDS
#define LACES_TIE_MIN_TIME			1.5 SECONDS
#define LACES_PRICK_TIME			1 SECONDS
#define LACES_UNTIE_TIME			4 SECONDS
#define LACES_CUT_TIME				0.5 SECONDS
#define LACES_FUMBLE_FLOOR			-6
#define LACES_NEARFAIL_CEIL			5
#define LACES_TRIP_KNOCKDOWN		2 SECONDS
#define LACES_TRIP_GRACE			3 SECONDS
/// Steps closer together than this count as hurrying.
#define LACES_BRISK_GAP				0.5 SECONDS
/// How many hurried steps in a row you get away with at walk intent before going down.
#define LACES_BRISK_STEPS_TO_TRIP	5

/datum/intent/tie_laces
	name = "tie laces"
	desc = "Tie someone's laces together. Has to be done from behind, or on someone who can't see me."
	icon_state = "intwist"
	chargetime = 0
	noaa = TRUE
	dodgeable_intent = FALSE
	parriable_intent = FALSE
	misscost = 0
	no_attack = TRUE
	releasedrain = 0
	blade_class = BCLASS_PUNCH

/datum/status_effect/tied_laces
	id = "tied_laces"
	duration = -1
	tick_interval = -1
	needs_processing = FALSE
	alert_type = null // they're not supposed to know
	examine_text = "<span class='warning'>SUBJECTPRONOUN is standing in shoes that have been laced together!</span>"
	/// The shoes the laces were tied on. Take them off and the knot goes with them.
	var/obj/item/clothing/shoes/tied_shoes
	/// Hurried steps taken in a row. Walk briskly for too long and you go down.
	var/brisk_steps = 0
	var/last_step_time = 0
	COOLDOWN_DECLARE(trip_grace)

/datum/status_effect/tied_laces/on_creation(mob/living/new_owner, obj/item/clothing/shoes/shoes)
	tied_shoes = shoes
	return ..()

/datum/status_effect/tied_laces/on_apply()
	. = ..()
	if(!ishuman(owner) || QDELETED(tied_shoes))
		return FALSE
	var/mob/living/carbon/human/H = owner
	if(H.shoes != tied_shoes)
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(tied_shoes, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING), PROC_REF(on_shoes_gone))
	H.update_inv_shoes()

/datum/status_effect/tied_laces/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	if(tied_shoes)
		UnregisterSignal(tied_shoes, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
		tied_shoes = null
	owner.update_inv_shoes()

/datum/status_effect/tied_laces/proc/on_shoes_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/tied_laces/proc/on_move(datum/source, atom/old_loc, movement_dir, forced)
	SIGNAL_HANDLER
	if(forced || !isturf(owner.loc) || owner.loc == old_loc)
		return
	if(owner.throwing || owner.buckled || owner.moving_from_pull || (owner.movement_type & FLYING))
		return
	if(!(owner.mobility_flags & MOBILITY_STAND))
		return
	// Keep count of how many hurried steps they've taken in a row. A pause resets it.
	if(world.time - last_step_time <= LACES_BRISK_GAP)
		brisk_steps++
	else
		brisk_steps = 0
	last_step_time = world.time
	if(!COOLDOWN_FINISHED(src, trip_grace))
		return
	switch(owner.m_intent)
		if(MOVE_INTENT_RUN)
			trip()
		if(MOVE_INTENT_WALK)
			if(brisk_steps >= LACES_BRISK_STEPS_TO_TRIP)
				trip()

/datum/status_effect/tied_laces/proc/trip()
	COOLDOWN_START(src, trip_grace, LACES_TRIP_GRACE)
	brisk_steps = 0
	owner.visible_message(span_danger("[owner] trips over [owner.p_their()] own laces and goes down hard!"), \
		span_userdanger("My laces are tied together! I trip and fall flat on my face!"))
	playsound(owner, "bodyfall", 80, TRUE)
	owner.Knockdown(LACES_TRIP_KNOCKDOWN)
	owner.log_message("tripped over their tied laces", LOG_ATTACK, color="white")

/datum/status_effect/tied_laces/proc/get_overlay()
	var/mutable_appearance/laces = mutable_appearance('icons/roguetown/mob/tiedlaces.dmi', "tiedlaces", -(SHOES_LAYER - 0.1))
	var/mob/living/carbon/human/H = owner
	if(istype(H) && H.dna?.species && (OFFSET_SHOES in H.dna.species.offset_features))
		laces.pixel_x += H.dna.species.offset_features[OFFSET_SHOES][1]
		laces.pixel_y += H.dna.species.offset_features[OFFSET_SHOES][2]
	return laces

/// Same rule as pickpocketing: from behind, or on someone who can't see what I'm doing.
/mob/living/carbon/human/proc/laces_victim_unaware()
	return IsUnconscious() || eyesclosed || eye_blind || eye_blurry || !(mobility_flags & MOBILITY_STAND)

/obj/item/needle/proc/tie_laces(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	if(!istype(victim) || !istype(user))
		return FALSE
	if(victim == user)
		to_chat(user, span_warning("I'm not tying my own laces together."))
		return FALSE
	if(!(user.zone_selected in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)))
		to_chat(user, span_warning("I need to go for [victim.p_their()] feet."))
		return FALSE
	if(!victim.get_bodypart(BODY_ZONE_L_LEG) || !victim.get_bodypart(BODY_ZONE_R_LEG) || victim.get_taur_tail())
		to_chat(user, span_warning("[victim] doesn't have two feet I could tie together."))
		return FALSE
	if(victim.has_status_effect(/datum/status_effect/tied_laces))
		to_chat(user, span_warning("[victim.p_their(TRUE)] laces are already tied together."))
		return FALSE
	if(victim.shoes && stringamt < 1)
		to_chat(user, span_warning("The needle has no thread left!"))
		return FALSE
	if(!laces_checks(victim, user))
		return FALSE

	var/skill = user.get_pickpocket_skill()
	var/obj/item/clothing/shoes/shoes = victim.shoes
	var/tie_time = shoes ? max(LACES_TIE_MIN_TIME, LACES_TIE_BASE_TIME - (skill * LACES_TIE_TIME_PER_SKILL)) : LACES_PRICK_TIME
	to_chat(user, span_notice("I crouch by [victim]'s feet..."))
	if(!do_after(user, tie_time, target = victim))
		return FALSE
	if(!laces_checks(victim, user))
		return FALSE

	if(!victim.shoes)
		prick_foot(victim, user)
		return TRUE
	if(victim.shoes != shoes || victim.has_status_effect(/datum/status_effect/tied_laces) || stringamt < 1)
		return FALSE

	// Same contested roll as a pickpocket: thieving + fortune vs perception + speed.
	var/unaware = victim.laces_victim_unaware()
	var/thief_score = roll("[skill + 1]d6") + round((user.STALUC - 10) / 3)
	var/victim_score
	if(unaware)
		victim_score = round(victim.STAPER * 0.35)
	else
		victim_score = victim.STAPER + round((victim.STASPD - 10) / 3)
	var/margin = thief_score - victim_score

	if(margin < 0)
		victim.log_message("has had an attempted lace tying by [key_name(user)]", LOG_ATTACK, color="white", meta = list(LOG_META_ATTACKER = user.ckey))
		user.log_message("has attempted to tie the laces of [key_name(victim)]", LOG_ATTACK, color="white", meta = list(LOG_META_TARGET = victim.ckey))
		if(margin < LACES_FUMBLE_FLOOR)
			user.visible_message(span_danger("[user] is caught fiddling with [victim]'s laces!"))
			victim.balloon_alert(victim, "my laces!")
			to_chat(victim, span_danger("[user] is messing with my laces!"))
		else
			to_chat(user, span_warning("[victim] shifts [victim.p_their()] feet. I can't finish the knot without being noticed."))
			victim.balloon_alert(victim, "...?")
			to_chat(victim, span_warning("Something brushes against my ankles..."))
		user.changeNext_move(CLICK_CD_MELEE)
		return TRUE

	use(1)
	victim.apply_status_effect(/datum/status_effect/tied_laces, shoes)
	playsound(victim, "rustle", 30, TRUE, -4)
	to_chat(user, span_green("I tie [victim]'s laces together."))
	if(margin < LACES_NEARFAIL_CEIL)
		to_chat(victim, span_warning("I feel a faint tug at my [shoes.name]..."))
	victim.log_message("has had their laces tied together by [key_name(user)]", LOG_ATTACK, color="white", meta = list(LOG_META_ATTACKER = user.ckey))
	user.log_message("has tied the laces of [key_name(victim)] together", LOG_ATTACK, color="white", meta = list(LOG_META_TARGET = victim.ckey))
	user.grant_pickpocket_xp(victim, user.STAINT)
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE

/// Stuff that has to hold both before and after the do_after.
/obj/item/needle/proc/laces_checks(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	if(!user.Adjacent(victim))
		return FALSE
	if(victim.cmode)
		to_chat(user, span_warning("[victim] is too alert for that."))
		return FALSE
	var/list/mobsbehind = cone(victim, list(turn(victim.dir, 180)), list(user))
	if(!victim.laces_victim_unaware() && !mobsbehind.Find(user))
		to_chat(user, span_warning("They can see me!"))
		return FALSE
	return TRUE

/// No shoes, no laces. They get the pointy end instead.
/obj/item/needle/proc/prick_foot(mob/living/carbon/human/victim, mob/living/carbon/human/user)
	var/obj/item/bodypart/foot = victim.get_bodypart(check_zone(user.zone_selected))
	victim.apply_damage(2, BRUTE, foot)
	playsound(victim, 'sound/foley/sewflesh.ogg', 40, TRUE, -4)
	to_chat(user, span_warning("No laces to tie - I prick [victim]'s bare foot instead."))
	to_chat(victim, span_danger("Ow! Something pricks my foot!"))
	victim.fullscreen_redflash("redflash1")
	var/old_color = victim.color
	animate(victim, color = "#ff4040", time = 1, flags = ANIMATION_PARALLEL)
	animate(color = old_color, time = 4)
	log_combat(user, victim, "pricked the foot of", src)
	user.changeNext_move(CLICK_CD_MELEE)

/// Bare hand unties it, a knife cuts it. Returns TRUE if the click was spent on the laces.
/mob/living/carbon/human/proc/try_free_laces(mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || user.cmode)
		return FALSE
	if(!(user.zone_selected in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)))
		return FALSE
	if(!has_status_effect(/datum/status_effect/tied_laces))
		return FALSE
	var/cutting = FALSE
	if(tool)
		if(tool.associated_skill != /datum/skill/combat/knives || !tool.get_sharpness())
			return FALSE
		cutting = TRUE
	else if(user.used_intent?.type != INTENT_HELP)
		return FALSE
	free_laces(user, tool, cutting)
	return TRUE

/mob/living/carbon/human/proc/free_laces(mob/living/carbon/human/user, obj/item/tool, cutting)
	var/whose = (user == src) ? "[user.p_their()]" : "[src]'s"
	if(cutting)
		if(!do_after(user, LACES_CUT_TIME, target = src))
			return
		if(!remove_status_effect(/datum/status_effect/tied_laces))
			return
		playsound(src, 'sound/combat/wooshes/bladed/wooshsmall (1).ogg', 50, TRUE)
		user.visible_message(span_notice("[user] slices through the thread tying [whose] laces together with [tool]."), \
			span_notice("I cut the thread with [tool]."))
		return
	user.visible_message(span_notice("[user] starts picking at the knot in [whose] laces."), \
		span_notice("I start picking at the knot..."))
	if(!do_after(user, LACES_UNTIE_TIME, target = src))
		return
	if(!remove_status_effect(/datum/status_effect/tied_laces))
		return
	playsound(src, "rustle", 40, TRUE, -2)
	user.visible_message(span_notice("[user] unties [whose] laces."), span_notice("I get the knot undone."))

#undef LACES_TIE_BASE_TIME
#undef LACES_TIE_TIME_PER_SKILL
#undef LACES_TIE_MIN_TIME
#undef LACES_PRICK_TIME
#undef LACES_UNTIE_TIME
#undef LACES_CUT_TIME
#undef LACES_FUMBLE_FLOOR
#undef LACES_NEARFAIL_CEIL
#undef LACES_TRIP_KNOCKDOWN
#undef LACES_TRIP_GRACE
#undef LACES_BRISK_GAP
#undef LACES_BRISK_STEPS_TO_TRIP
