/obj/effect/proc_holder/spell/self/zombie_seek
	name = "Seek the Lyving"
	desc = "Sniff out the nearest lyving player you can infect."
	panel = "Deadite"
	recharge_time = 15 SECONDS
	is_cdr_exempt = TRUE
	associated_skill = null
	ignore_cockblock = TRUE
	antimagic_allowed = TRUE
	breaks_invisibility = FALSE
	hide_charge_effect = TRUE
	action_icon = 'icons/mob/actions/zombie_spells.dmi'
	action_icon_state = "seekliving"
	action_background_icon_state = "spell"

/obj/effect/proc_holder/spell/self/zombie_seek/Click()
	if(!cast_check())
		return FALSE
	choose_targets()
	return TRUE

/obj/effect/proc_holder/spell/self/zombie_seek/start_recharge()
	last_process_time = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/effect/proc_holder/spell/self/zombie_seek/can_cast(mob/user = usr)
	if(!ishuman(user) || user.stat >= UNCONSCIOUS || !(src in user.mind?.spell_list))
		return FALSE
	var/datum/antagonist/zombie/zombie = user.mind?.has_antag_datum(/datum/antagonist/zombie)
	return zombie?.has_turned && charge_counter >= recharge_time

// This is an innate sense, so magic curses and casting requirements do not apply.
/obj/effect/proc_holder/spell/self/zombie_seek/cast_check(skipcharge, mob/user = usr)
	if(!can_cast(user))
		return FALSE
	if(!skipcharge)
		charge_counter = 0
		last_process_time = world.time
	START_PROCESSING(SSfastprocess, src)
	return TRUE

/obj/effect/proc_holder/spell/self/zombie_seek/cast(list/targets, mob/living/carbon/human/user)
	var/turf/source_turf = get_turf(user)
	var/mob/living/carbon/human/closest
	var/closest_dist = INFINITY
	for(var/mob/living/carbon/human/target as anything in GLOB.human_list)
		if(target == user || !target.mind?.key || target.stat >= DEAD || (target.mob_biotypes & MOB_UNDEAD) || HAS_TRAIT(target, TRAIT_ZOMBIE_IMMUNE))
			continue
		var/turf/target_turf = get_turf(target)
		if(!target_turf || !source_turf || target_turf.z != source_turf.z)
			continue
		var/distance = get_dist(source_turf, target_turf)
		if(distance < closest_dist)
			closest = target
			closest_dist = distance
	if(!closest)
		to_chat(user, span_warning("I cannot smell any lyving prey..."))
		return TRUE
	var/direction = get_dir(source_turf, get_turf(closest))
	to_chat(user, span_cult("[pick("Flesh", "Food", "Lyving prey")] [closest_dist] meters away[direction ? ", [dir2text(direction)]" : ", right here"]..."))
	user.playsound_local(user, 'sound/misc/notice.ogg', 30, TRUE)
	return TRUE
