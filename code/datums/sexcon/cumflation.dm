/// Both receiving the effect and seeing its examine text require this account preference.
/proc/cumflation_content_enabled(mob/participant)
	return !!participant?.client?.prefs?.cumflation_content

/mob/living/carbon/human/proc/stuffed_threshold_multiplier()
	var/multiplier = 1
	if(HAS_TRAIT(src, TRAIT_BIGGUY) || HAS_TRAIT(src, TRAIT_LARGE_FRAME))
		multiplier += 0.5
	var/obj/item/bodypart/taur/taur_parts = get_taur_tail()
	if(istype(taur_parts))
		multiplier += 0.5
	return multiplier

/// Called only when new fluid/leakage arrives or the preference is enabled, not by metabolism.
/mob/living/carbon/human/proc/check_stuffed_input(new_input = FALSE)
	if(QDELETED(src) || !cumflation_content_enabled(src))
		return FALSE
	var/datum/status_effect/debuff/stuffed/existing = has_status_effect(/datum/status_effect/debuff/stuffed)
	if(istype(existing))
		if(new_input)
			existing.refresh()
		return TRUE
	var/multiplier = stuffed_threshold_multiplier()
	var/datum/status_effect/creampie_leak/leak = has_status_effect(/datum/status_effect/creampie_leak/long)
	if(!istype(leak))
		leak = has_status_effect(/datum/status_effect/creampie_leak)
	var/qualifies = FALSE
	if(istype(leak))
		leak.sync_leak_clock()
		qualifies = leak.duration - world.time >= (540 SECONDS) * multiplier
	if(!qualifies && reagents)
		var/fluid_volume = 0
		for(var/datum/reagent/erpjuice/fluid in reagents.reagent_list)
			fluid_volume += fluid.volume
		qualifies = fluid_volume > 45 * multiplier
	if(!qualifies)
		return FALSE
	return !!apply_status_effect(/datum/status_effect/debuff/stuffed)

/mob/living/carbon/human/proc/stuffed_examine_line(mob/viewer)
	if(!cumflation_content_enabled(viewer) || !has_status_effect(/datum/status_effect/debuff/stuffed))
		return null
	return "<span style='color:#d8cf8a'>Their distended belly looks full to the brim!</span>"

/datum/reagent/erpjuice/on_mob_add(mob/living/recipient)
	. = ..()
	if(ishuman(recipient))
		var/mob/living/carbon/human/H = recipient
		H.check_stuffed_input(TRUE)

/datum/reagent/erpjuice/on_merge(data, amount)
	. = ..()
	if(!isnum(amount) || amount <= 0 || !istype(holder) || QDELETED(holder) || !ishuman(holder.my_atom))
		return
	var/mob/living/carbon/human/H = holder.my_atom
	H.check_stuffed_input(TRUE)

/datum/status_effect/debuff/stuffed
	id = "stuffed"
	duration = 15 MINUTES
	tick_interval = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/debuff/stuffed
	effectedstats = list(STATKEY_SPD = -6)

/datum/status_effect/debuff/stuffed/on_apply()
	if(!cumflation_content_enabled(owner))
		// Failed applications still run removal; there is no stat penalty to restore.
		effectedstats = list()
		return FALSE
	. = ..()
	if(.)
		RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(washed))

/datum/status_effect/debuff/stuffed/on_remove()
	UnregisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT)
	return ..()

/datum/status_effect/debuff/stuffed/process(wait)
	// A disconnected player keeps their existing effect; a later explicit opt-out clears it.
	if(owner?.client && !cumflation_content_enabled(owner))
		qdel(src)
		return
	return ..()

/datum/status_effect/debuff/stuffed/proc/washed(datum/source, strength)
	SIGNAL_HANDLER
	if(strength >= CLEAN_WEAK && !QDELETED(owner))
		owner.remove_status_effect(src)

/atom/movable/screen/alert/status_effect/debuff/stuffed
	name = "Stuffed"
	desc = "Your body feels overfull. Speed is reduced by 6. Washing your body clears this effect."
	icon_state = "debuff"

/client/verb/toggle_cumflation_content()
	set category = "Options"
	set name = "Toggle Cumflation Content"
	set hidden = 1
	if(!prefs)
		return
	prefs.cumflation_content = !prefs.cumflation_content
	prefs.save_preferences()
	if(ishuman(mob))
		var/mob/living/carbon/human/H = mob
		if(prefs.cumflation_content)
			H.check_stuffed_input()
		else
			H.remove_status_effect(/datum/status_effect/debuff/stuffed)
	to_chat(src, "Cumflation content is now [prefs.cumflation_content ? "enabled" : "disabled"].")
