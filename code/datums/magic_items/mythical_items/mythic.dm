#define INFERNAL_FLAME_COOLDOWN 20 SECONDS
#define FREEZING_COOLDOWN 20 SECONDS
#define REWIND_COOLDOWN 20 SECONDS
#define CHAOS_COOLDOWN 10 SECONDS
//T4 Enchantments
/datum/magic_item/mythic/infernalflame
	confirmed_hits_only = TRUE
	offensive_cooldown = INFERNAL_FLAME_COOLDOWN
	name = "infernal flame"
	description = "It glows with white hot heat."
	var/last_used
	var/warned

/datum/magic_item/mythic/infernalflame/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	return trigger_offensive_effect(fired_from, firer, target)

/datum/magic_item/mythic/freezing
	confirmed_hits_only = TRUE
	offensive_cooldown = FREEZING_COOLDOWN
	name = "freezing"
	description = "It feels ice cold."
	var/last_used
	var/warned

/datum/magic_item/mythic/freezing/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	return trigger_offensive_effect(fired_from, firer, target)

/datum/magic_item/mythic/briarcurse
	name = "Briar's curse"
	description = "Its grip seems thorny. Must hurt to use."
	var/last_used

/datum/magic_item/mythic/briarcurse/on_apply(obj/item/i)
	.=..()
	i.force = i.force + 10
	i.force_wielded = i.force_wielded + 10

/datum/magic_item/mythic/briarcurse/on_hit(obj/item/source, atom/target, mob/living/user, proximity_flag, click_parameters)
	.=..()
	if(isliving(target))
		var/mob/living/carbon/H = user
		H.adjustBruteLoss(10)
		to_chat(user, span_notice("[source] gouges you with it's sharp edges!"))

/datum/magic_item/mythic/rewind
	name = "Temporal Rewind"
	description = "Its seems both old and new at the same time."
	var/last_used
	var/active_item = FALSE
	var/warned = FALSE

/datum/magic_item/mythic/rewind/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	.=..()
	if(!try_start_cooldown(user, REWIND_COOLDOWN))
		return
	else
		var/turf/target_turf = get_turf(user)
		active_item = TRUE
		last_used = world.time
		sleep(5 SECONDS)
		to_chat(user, span_notice("[source] rewinds you back in time!"))
		do_teleport(user, target_turf, channel = TELEPORT_CHANNEL_QUANTUM)

/datum/magic_item/mythic/rewind/on_hit_response(obj/item/I, mob/living/carbon/human/owner, mob/living/carbon/human/attacker)
	if(!try_start_cooldown(owner, REWIND_COOLDOWN))
		return
	if(!active_item)
		var/turf/target_turf = get_turf(owner)
		active_item = TRUE
		last_used = world.time
		sleep(5 SECONDS)
		to_chat(owner, span_notice("[I] rewinds you back in time!"))
		do_teleport(owner, target_turf, channel = TELEPORT_CHANNEL_QUANTUM)
		active_item = FALSE


/datum/magic_item/mythic/chaos_storm
	confirmed_hits_only = TRUE
	offensive_cooldown = CHAOS_COOLDOWN
	name = "chaos storm"
	description = "Its crackles with unpredictable chaotic energy."
	var/last_used

/datum/magic_item/mythic/infernalflame/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	if(!apply_offensive_fire(target, 10))
		return FALSE
	target.visible_message(span_danger("[source] sets [target] on fire!"))
	return TRUE

/datum/magic_item/mythic/freezing/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	var/datum/status_effect/freon/freezing/applied = target.apply_status_effect(/datum/status_effect/freon/freezing)
	if(!istype(applied) || QDELETED(applied))
		return FALSE
	target.visible_message(span_danger("[source] freezes [target] solid!"))
	return TRUE

/datum/magic_item/mythic/chaos_storm/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	var/health_before = target.health
	switch(rand(1,5))
		if(1)
			if(!apply_offensive_fire(target, 5))
				return FALSE
			target.apply_damage(15, BURN)
			to_chat(target, span_warning("Chaotic flames engulf you!"))
		if(2)
			target.apply_damage(10, BRUTE)
			if(target.health >= health_before)
				return FALSE
			target.Knockdown(20)
			target.drop_all_held_items()
			to_chat(target, span_warning("Chaotic force slams into you!"))
		if(3)
			if(!target.electrocute_act(12, source, 1) || target.health >= health_before)
				return FALSE
			to_chat(target, span_warning("Chaotic lightning courses through you!"))
		if(4)
			var/datum/status_effect/offbalance = target.OffBalance(2.5 SECONDS)
			if(!istype(offbalance) || QDELETED(offbalance))
				return FALSE
			to_chat(target, span_warning("Chaotic energy disrupts your coordination!"))
		if(5)
			target.confused += 2 SECONDS
			to_chat(target, span_warning("Chaotic energy scrambles your thoughts!"))
	return TRUE

#undef INFERNAL_FLAME_COOLDOWN
#undef FREEZING_COOLDOWN
#undef REWIND_COOLDOWN
#undef CHAOS_COOLDOWN
