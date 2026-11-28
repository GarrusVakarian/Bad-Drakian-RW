GLOBAL_LIST_INIT(quirks, init_subtypes_assoc(/datum/quirk))

/datum/quirk
	parent_type = /datum/customization_trait
	var/point_cost = 1
	var/warning_text
	/// The form inherits active traits without rerunning character setup.
	var/carries_to_beast_form = FALSE

/datum/quirk/New()
	. = ..()
	if(!istype(src, /datum/quirk/none))
		name += " ([point_cost] Q-Point[point_cost == 1 ? "" : "s"])"

/proc/apply_quirk(mob/living/carbon/human/recipient, datum/quirk/quirk_type)
	if(!quirk_type || istype(quirk_type, /datum/quirk/none))
		return FALSE
	var/applied = quirk_type.apply_generic_effects(recipient)
	if(applied)
		record_featured_object_stat(FEATURED_STATS_QUIRKS, quirk_type.name)
	return applied

/// Body-local settings that a compatible quirk needs in addition to its traits.
/datum/quirk/proc/copy_beast_form_settings(mob/living/carbon/human/original, mob/living/carbon/human/form)
	return

/mob/living/carbon/human
	/// Successfully applied character-creation quirks that support Beast Form and Lesser Shapeshift.
	var/list/datum/quirk/beast_form_quirks

/mob/living/carbon/human/proc/carry_beast_form_quirks(mob/living/carbon/human/form)
	for(var/datum/quirk/quirk as anything in beast_form_quirks)
		var/has_active_effect = FALSE
		for(var/trait in quirk.added_traits)
			if(HAS_TRAIT_FROM(src, trait, TRAIT_VIRTUE))
				ADD_TRAIT(form, trait, TRAIT_VIRTUE)
				has_active_effect = TRUE
		if(has_active_effect)
			LAZYOR(form.beast_form_quirks, quirk)
			quirk.copy_beast_form_settings(src, form)

/datum/quirk/none
	name = "None"
	desc = "No quirk chosen."
