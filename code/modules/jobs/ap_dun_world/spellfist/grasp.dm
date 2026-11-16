// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/obj/effect/proc_holder/spell/invoked/ap_spell/grasp_of_psydon

	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "grasp_of_psydon"
	name = "Grasp of Psydon"

	desc = "Slam your open palm forward, sending forth tendrils of arcyne force to a target area up to 5 paces away on the same level. After a brief telegraph, all targets in the area are yanked toward you. \
		At 3+ momentum: consumes 3 to deal extra blunt damage to the aimed bodypart on each yanked target.\n\n\
		'Push forth your hand with your conduit open, and imagine, with His will, seizing upon the very object or person you desire within your grasp, then, pull your hand backward. Close, and clench your fist, pushing forward slightly, opening your conduit again, and you shall seize your enemy from afar, and pull them toward you.'"
	sound = list('sound/combat/wooshes/punch/punchwoosh (1).ogg','sound/combat/wooshes/punch/punchwoosh (2).ogg','sound/combat/wooshes/punch/punchwoosh (3).ogg')
	glow_intensity = GLOW_INTENSITY_LOW

	range = 5

	releasedrain = 15

	invocations = list("Iqbid!")
	invocation_type = INVOCATION_SHOUT

	chargetime = 0.5 SECONDS
	chargedrain = 0


	recharge_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane



	var/area_of_effect = 1
	var/pull_distance = 7
	var/telegraph_delay = 0.8 SECONDS
	var/base_damage = 15
	var/empowered_damage = 40
	var/momentum_cost = 3

/obj/effect/proc_holder/spell/invoked/ap_spell/grasp_of_psydon/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Damage: [base_damage] blunt (+[empowered_damage] at [momentum_cost]+ momentum)")
	return stats


/obj/effect/proc_holder/spell/invoked/ap_spell/grasp_of_psydon/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE

	var/turf/caster_turf = get_turf(H)
	if(T.z != caster_turf.z)
		to_chat(H, span_warning("The tendrils can't reach across planes!"))
		return FALSE

	var/empowered = FALSE
	var/datum/status_effect/buff/ap_arcyne_momentum/M = H.has_status_effect(/datum/status_effect/buff/ap_arcyne_momentum)
	if(M && M.stacks >= momentum_cost)
		M.consume_stacks(momentum_cost)
		empowered = TRUE
		to_chat(H, span_notice("[momentum_cost] momentum released - empowered grasp!"))

	H.emote("attack", forced = TRUE)

	for(var/turf/affected_turf in get_hear(area_of_effect, T))
		if(affected_turf.density)
			continue
		new /obj/effect/temp_visual/grasp_telegraph(affected_turf)

	playsound(T, 'sound/magic/webspin.ogg', 50, TRUE)

	addtimer(CALLBACK(src, PROC_REF(resolve_grasp), H, T, empowered), telegraph_delay)
	return TRUE

/obj/effect/temp_visual/grasp_telegraph
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	duration = 1 SECONDS

/obj/effect/proc_holder/spell/invoked/ap_spell/grasp_of_psydon/proc/resolve_grasp(mob/living/carbon/human/H, turf/center, empowered = FALSE)
	if(!can_continue(H) || !center || H.z != center.z || get_dist(H, center) > range)
		return

	var/turf/caster_turf = get_turf(H)
	playsound(center, 'sound/combat/grabbreak.ogg', 80, TRUE)

	var/hit_count = 0
	for(var/mob/living/victim in range(area_of_effect, center))
		if(victim == H || victim.stat == DEAD)
			continue
		if(victim.anti_magic_check())
			victim.visible_message(span_warning("The tendrils of force can't seem to latch onto [victim]!"))
			playsound(get_turf(victim), 'sound/magic/magic_nulled.ogg', 100)
			continue
		if(victim.anti_magic_check())
			victim.visible_message(span_warning("[victim] breaks free of the tendrils!"))
			continue
		var/def_zone = H.zone_selected || BODY_ZONE_CHEST
		if(ap_arcyne_strike(H, victim, null, base_damage, def_zone, BCLASS_BLUNT, spell_name = "Grasp of Psydon") == AP_STRIKE_BLOCKED)
			continue
		if(empowered)
			if(ap_arcyne_strike(H, victim, null, empowered_damage, def_zone, BCLASS_BLUNT, spell_name = "Grasp of Psydon (Empowered)") == AP_STRIKE_BLOCKED)
				continue
		victim.throw_at(caster_turf, pull_distance, 4)

		victim.visible_message(span_warning("[victim] is yanked toward [H] by tendrils of arcyne force!"))
		new /obj/effect/temp_visual/grasp_telegraph/long(get_turf(victim))
		hit_count++

	if(hit_count)
		H.visible_message(span_danger("[H] clenches [H.p_their()] fist, pulling [hit_count > 1 ? "enemies" : "an enemy"] toward [H.p_them()]!"))

	log_combat(H, null, "used Grasp of Psydon[empowered ? " (empowered)" : ""]")

/obj/effect/temp_visual/grasp_telegraph/long
	duration = 2 SECONDS
