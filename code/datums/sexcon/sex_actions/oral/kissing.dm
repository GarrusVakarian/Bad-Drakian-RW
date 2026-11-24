/datum/sex_action/kissing
	name = "Make out with them"
	check_same_tile = FALSE
	user_sex_part = SEX_PART_JAWS
	target_sex_part = SEX_PART_JAWS

/datum/sex_action/kissing/on_start(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	user.sexcon.start_kissing_oxygen_healing(target)
	user.visible_message(span_warning("[user] starts making out with [target]..."))

/datum/sex_action/kissing/on_perform(mob/living/carbon/human/user, mob/living/carbon/human/target)
	user.sexcon_action_message(user.sexcon.spanify_force("[user] [user.sexcon.get_generic_force_adjective()] makes out with [target]..."))
	if(user.sexcon.force > SEX_FORCE_MID)
		user.sexcon.oralcourse_noise(target)
	else
		user.sexcon.make_sucking_noise()

	user.sexcon.perform_sex_action(user, 1, 2, TRUE)
	user.sexcon.handle_passive_ejaculation()

	user.sexcon.perform_sex_action(target, 1, 2, TRUE)
	target.sexcon.handle_passive_ejaculation()

/datum/sex_action/kissing/on_finish(mob/living/carbon/human/user, mob/living/carbon/human/target)
	..()
	user.sexcon.kissing_oxygen_session++
	user.visible_message(span_warning("[user] stops making out with [target] ..."))

/// A separate clock keeps oxygen recovery independent of panel speed and action duration.
/datum/sex_controller/proc/start_kissing_oxygen_healing(mob/living/carbon/human/recipient)
	kissing_oxygen_session++
	addtimer(CALLBACK(src, PROC_REF(kissing_oxygen_tick), recipient, kissing_oxygen_session), 1 SECONDS)

/datum/sex_controller/proc/kissing_oxygen_tick(mob/living/carbon/human/recipient, session, notice_sent = FALSE)
	if(session != kissing_oxygen_session || current_action != /datum/sex_action/kissing || desire_stop)
		return
	if(panel_tackle_pin && !panel_action_still_active(panel_action_session))
		return
	if(QDELETED(user) || QDELETED(recipient) || target != recipient || !user.client || user.sexcon != src)
		return
	// Temporary ineligibility skips healing but retains the clock. The main action loop
	// owns cancellation; a brief failed check must not leave a valid action without recovery.
	var/can_heal = !QDELETED(recipient.sexcon) && recipient.client?.prefs?.sexable && can_perform_action(current_action, user.incapacitated())
	if(can_heal && Adjacent_Or_Closet(recipient) && !user.is_mouth_covered() && !recipient.is_mouth_covered())
		if(recipient.stat != DEAD && !HAS_TRAIT(user, TRAIT_NOBREATH) && recipient.getOxyLoss() > 0 && world.time >= recipient.sexcon.kissing_oxygen_next_heal)
			// Claim the recipient's next interval before applying healing, regardless of initiator.
			recipient.sexcon.kissing_oxygen_next_heal = world.time + 1 SECONDS
			var/oxygen_before = recipient.getOxyLoss()
			recipient.adjustOxyLoss(-1.5)
			if(!notice_sent && recipient.getOxyLoss() < oxygen_before)
				to_chat(user, span_info(span_italics("I ease a little air into their lungs.")))
				to_chat(recipient, span_info(span_italics("I feel a little air reach my lungs.")))
				notice_sent = TRUE
	addtimer(CALLBACK(src, PROC_REF(kissing_oxygen_tick), recipient, session, notice_sent), 1 SECONDS)
