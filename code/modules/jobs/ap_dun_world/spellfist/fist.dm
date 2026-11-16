// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/obj/effect/proc_holder/spell/invoked/ap_spell/fist_of_psydon

	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "fist_of_psydon"
	name = "Fist of Psydon"

	desc = "Slam your fist downward, sending arcyne force crashing into a 3x3 target area up to 5 paces away. \
		Brief telegraph before the strike lands. Deals blunt damage to the aimed bodypart. \
		At 3+ momentum: consumes 3 to double damage. \
		Can be blocked by shields.\n\n\
		'Step forward, rotating your fist into the punch. And, as you strike, envision yourself repeating the same strike in your mynd, and open the arcyne conduit of your arms, but close that of your legs, so that all of your body's weight is behind the strike. Then, at the very last moment, close the conduit of your arms as well, and thus arrest the strike before it come out, and you shall strike as if the fist of Psydon Himself were behind the blow.'"

	glow_intensity = GLOW_INTENSITY_LOW

	range = 5

	releasedrain = 12

	invocations = list("Idrib!") // https://en.wiktionary.org/wiki/%D8%B6%D8%B1%D8%A8 -- "To strike, to beat, to hit" in Arabic
	invocation_type = INVOCATION_SHOUT

	chargetime = 0.5 SECONDS
	chargedrain = 0


	recharge_time = 12 SECONDS


	associated_skill = /datum/skill/magic/arcane

	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')

	var/base_damage = 40
	var/empowered_mult = 2
	var/momentum_cost = 3
	var/area_of_effect = 1 // 1-tile radius = 3x3
	var/telegraph_delay = TELEGRAPH_DODGEABLE

/obj/effect/proc_holder/spell/invoked/ap_spell/fist_of_psydon/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Damage: [base_damage] blunt ([base_damage * empowered_mult] at [momentum_cost]+ momentum)")
	return stats


/obj/effect/proc_holder/spell/invoked/ap_spell/fist_of_psydon/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE

	// Check and consume momentum for empowerment
	var/empowered = FALSE
	var/datum/status_effect/buff/ap_arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/ap_arcyne_momentum)
	if(M && M.stacks >= momentum_cost)
		M.consume_stacks(momentum_cost)
		empowered = TRUE
		to_chat(H, span_notice("[momentum_cost] momentum released — empowered strike!"))

	var/damage = empowered ? (base_damage * empowered_mult) : base_damage
	var/def_zone = H.zone_selected || BODY_ZONE_CHEST

	// Telegraph on 3x3 area
	for(var/turf/affected_turf in get_hear(area_of_effect, T))
		new /obj/effect/temp_visual/telegraph/air_strike(affected_turf)
	playsound(T, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 60, TRUE)
	H.emote("attackgrunt", forced = TRUE)

	sleep(telegraph_delay)

	if(!can_continue(H) || H.z != T.z || get_dist(H, T) > range)
		return

	// Resolve — visual + damage on 3x3
	var/hit_count = 0
	for(var/turf/affected_turf in get_hear(area_of_effect, T))
		new /obj/effect/temp_visual/kinetic_blast(affected_turf)
		for(var/mob/living/victim in affected_turf)
			if(victim == H || victim.stat == DEAD)
				continue
			if(victim.anti_magic_check())
				continue
			if(ap_arcyne_strike(H, victim, null, damage, def_zone, BCLASS_BLUNT, spell_name = "Fist of Psydon") == AP_STRIKE_BLOCKED)
				continue
			hit_count++

	playsound(T, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 100, TRUE)
	H.emote("attack", forced = TRUE)

	if(hit_count)
		H.visible_message(span_danger("[H] slams [H.p_their()] fist down, sending a shockwave of arcyne force crashing into the ground!"))
	else
		H.visible_message(span_notice("[H] slams [H.p_their()] fist down, sending a shockwave into empty ground!"))

	log_combat(H, null, "used Fist of Psydon[empowered ? " (empowered)" : ""]")
	return TRUE
