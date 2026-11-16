// Resolve the Lamplighter's short staff patterns through native armor checks.
/obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike
	var/damage = 20
	var/blade_class = BCLASS_BLUNT
	var/windup_time = 0.8 SECONDS
	var/sweep_step = 0
	var/strike_sound
	var/telegraph_type = /obj/effect/temp_visual/special_intent/warning
	var/swipe_state

/obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike/proc/get_sweep_bands()
	return list(list(list(0, 1)))

/obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike/proc/get_pattern_offsets()
	return list(list(0, 1))

/obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike/proc/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
	return

/obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike/cast(list/targets, mob/living/user)
	owner = user
	var/turf/origin = get_turf(user)
	if(!origin)
		return FALSE
	var/facing = user.dir
	var/list/pattern = list()
	var/list/warnings = list()
	for(var/list/offset in get_pattern_offsets())
		var/dx = offset[1]
		var/dy = offset[2]
		switch(facing)
			if(SOUTH)
				dx = -offset[1]
				dy = -offset[2]
			if(EAST)
				dx = offset[2]
				dy = -offset[1]
			if(WEST)
				dx = -offset[2]
				dy = offset[1]
		var/turf/T = locate(origin.x + dx, origin.y + dy, origin.z)
		if(!T || T.density || !(T in view(2, origin)))
			continue
		pattern |= T
		var/obj/effect/temp_visual/warning = new telegraph_type(T)
		warnings += warning
	if(!length(pattern))
		return FALSE
	sleep(windup_time)
	QDEL_LIST(warnings)
	if(!can_continue(user) || get_turf(user) != origin)
		return TRUE
	playsound(origin, strike_sound, 65, TRUE)
	for(var/turf/T in pattern)
		if(!(T in view(2, origin)))
			continue
		for(var/mob/living/victim in T)
			if(victim == user || victim.stat == DEAD || victim.anti_magic_check())
				continue
			var/zone = check_zone(user.zone_selected)
			var/flag = blade_class == BCLASS_BURN ? "fire" : "blunt"
			var/blocked = victim.run_armor_check(zone, flag, damage = damage, blade_dulling = blade_class)
			victim.apply_damage(damage, blade_class == BCLASS_BURN ? BURN : BRUTE, zone, blocked)
			on_hit_target(user, victim, facing)
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/toggle_oil
	name = "Toggle Oil Ignition"
	desc = "Switch your oil strike between coating foes and igniting their oil stacks."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "oilsplash"
	recharge_time = 1 SECONDS
	releasedrain = 0
	invocation_type = "none"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/toggle_oil/cast(list/targets, mob/living/user)
	for(var/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/strike in user.mind?.spell_list)
		strike.toggle_alt_mode(user)
	for(var/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/strike in user.mind?.spell_list)
		strike.toggle_alt_mode(user)
	return TRUE

/obj/effect/temp_visual/special_intent/warning
	icon = 'icons/effects/telegraph.dmi'
	icon_state = "warning"
	layer = ABOVE_MOB_LAYER
	duration = 0.8 SECONDS
