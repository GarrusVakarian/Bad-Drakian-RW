/datum/sex_action/aural
	handles_user_climax = TRUE
	name = "Fuck their ears"
	stamina_cost = 1.0
	category = SEX_CATEGORY_PENETRATE
	user_sex_part = SEX_PART_COCK
	user_needs_functional = TRUE
	target_sex_part = SEX_PART_EARS
	// add the sex_part_ears ??? whats that used for let me check. ok its used to see where cum ends up? got it
	knot_on_finish = TRUE

/datum/sex_action/aural/shows_on_menu(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	return TRUE

/datum/sex_action/aural/can_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user == target)
		return FALSE
	if(!check_location_accessible(user, user, BODY_ZONE_PRECISE_GROIN, TRUE, TRUE))
		return FALSE
	if(!check_location_accessible(user, target, BODY_ZONE_PRECISE_EARS, TRUE, TRUE))
		return FALSE
	return TRUE

/datum/sex_action/aural/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] shoves [user.p_their()] cock into [target]'s ear!"))
	playsound(target, list('sound/misc/mat/insert (1).ogg','sound/misc/mat/insert (2).ogg'), 20, TRUE, ignore_walls = FALSE)

/datum/sex_action/aural/proc/apply_force_effects(mob/living/carbon/human/target, force)
	var/obj/item/organ/ears/ears = target.getorganslot(ORGAN_SLOT_EARS)
	if(!ears ||  ears.damage_multiplier <= 0)
		return

	var/blurriness = 0
	var/ringing_volume = 0
	switch(force)
		if(SEX_FORCE_LOW)
			ringing_volume = 10
		if(SEX_FORCE_MID)
			blurriness = 2
			ringing_volume = 20
		if(SEX_FORCE_HIGH)
			blurriness = 5
			ringing_volume = 35
		if(SEX_FORCE_EXTREME)
			blurriness = 8
			ringing_volume = 50
		if(SEX_FORCE_LUDICROUS)
			blurriness = 10
			ringing_volume = 65

	if(blurriness > target.eye_blurry)
		target.set_blurriness(blurriness)

	if(ringing_volume && world.time >= target.mob_timers["aural_ringing"])
		target.mob_timers["aurual_ringing"] = world.time + 10 SECONDS
		target.playsound_local(target, 'sound/combat/bombard/flash_ring.ogg', ringing_volume, FALSE)

/datum/sex_action/aural/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	apply_force_effects(target, user.sexcon.force)
	if(!user.sexcon.do_knot_action)
		user.sexcon_action_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] fucks [target]'s ear."))
	else
		user.sexcon_action_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] knot-fucks [target]'s ear."))
	user.sexcon.intercourse_noise(target)
	user.sexcon.do_thrust_animate(target)

	if(HAS_TRAIT(user, TRAIT_DEATHBYSNUSNU) || (user.STASTR > 12))
		if(istype(user.rmb_intent, /datum/rmb_intent/strong))
			user.sexcon.try_skull_crack(target)
			if(HAS_TRAIT(target, TRAIT_POPPABLE))
				user.sexcon.try_brain_crush(target)
	
	user.sexcon.perform_sex_action(user, 2, 0, TRUE)
	if(user.sexcon.check_active_ejaculation())
		user.visible_message(span_love("[user] cums into [target]'s ear!"))
		for(var/i = 1; i <= user.sexcon.get_load_bursts(); i++)
			user.sexcon.cum_into(splashed_user = target, orifice = SEX_PART_EARS, consume_charge = i == 1 ? TRUE : FALSE)
			sleep(10)
		if(!target.has_status_effect(/datum/status_effect/knot_fucked_stupid))
			target.apply_status_effect(/datum/status_effect/knot_fucked_stupid)

	if(user.sexcon.considered_limp())
		user.sexcon.perform_sex_action(target, 1.2, 4, FALSE)
	else
		user.sexcon.perform_sex_action(target, 2.4, !user.sexcon.do_knot_action ? 9 : 14, FALSE)
	target.sexcon.handle_passive_ejaculation() 

/datum/sex_action/aural/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.visible_message(span_warning("[user] pulls [user.p_their()] cock out [target]'s ear."))

/datum/sex_action/aural/is_finished(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.sexcon.finished_check())
		return TRUE
	return FALSE
