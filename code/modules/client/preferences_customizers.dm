/// Species-local groups: no choices are added to the global customizer datums.
/// Identical type paths are also deduplicated (Construct and Doll have repeated entries).
/datum/preferences/proc/get_customizer_groups()
	var/list/groups = list()
	var/list/slot_groups = list()
	for(var/customizer_type in pref_species?.customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer)
			continue
		// Tailmaw is an independent override. No-sprite Tailmaw borrows the ordinary tail.
		var/slot = ispath(customizer_type, /datum/customizer/organ/tail/manticore) ? null : customizer.get_shared_organ_slot()
		var/group_key = slot ? slot_groups[slot] : null
		if(!group_key)
			group_key = customizer_type
			groups[group_key] = list()
			if(slot)
				slot_groups[slot] = group_key
		var/list/group = groups[group_key]
		group |= customizer_type
	return groups

/datum/preferences/proc/get_customizer_group(customizer_type)
	var/list/groups = get_customizer_groups()
	for(var/group_key in groups)
		var/list/group = groups[group_key]
		if(customizer_type in group)
			return group

/// Match legacy organ DNA precedence: last enabled entry, with manticore priority.
/// Existing entries, their disabled flags and all per-choice settings remain intact.
/datum/preferences/proc/get_customizer_group_entry(list/group)
	var/datum/customizer_entry/primary = get_customizer_entry_for_customizer_type(group[1])
	if(primary && (primary.group_selected_customizer in group))
		var/datum/customizer_entry/selected = get_customizer_entry_for_customizer_type(primary.group_selected_customizer)
		var/datum/customizer/selected_customizer = CUSTOMIZER(primary.group_selected_customizer)
		if(selected && selected_customizer.is_allowed(src))
			return selected
	var/datum/customizer_entry/selected
	var/manticore_selected = FALSE
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(!(entry.customizer_type in group) || entry.disabled)
			continue
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		var/datum/customizer_choice/organ/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/is_manticore = istype(choice, /datum/customizer_choice/organ/tail) && (ispath(choice.organ_type, /obj/item/organ/tail/manticore) || entry.accessory_type == /datum/sprite_accessory/tail/manticore)
		if(manticore_selected && !is_manticore)
			continue
		selected = entry
		manticore_selected = is_manticore
	return selected ? selected : primary

/datum/preferences/proc/customizer_group_allows_disabling(list/group)
	for(var/customizer_type in group)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer.allows_disabling)
			return FALSE
	return TRUE

/// Runtime/preview consumers see the selected alternative, not hidden saved alternatives.
/datum/preferences/proc/get_active_customizer_entries()
	var/list/entries = list()
	var/list/groups = get_customizer_groups()
	for(var/group_key in groups)
		var/list/group = groups[group_key]
		var/datum/customizer_entry/entry = get_customizer_group_entry(group)
		var/datum/customizer_entry/primary = get_customizer_entry_for_customizer_type(group_key)
		if(entry && !entry.disabled && !(length(group) > 1 && primary?.group_disabled))
			entries += entry
	// Keep legacy precedence when two independent controls generate the same organ slot.
	return customizer_entries & entries

/// Map labels to both the source control and choice, preserving distinct organ behavior.
/datum/preferences/proc/get_customizer_group_choices(list/group)
	var/list/choices = list()
	for(var/customizer_type in group)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer.is_allowed(src))
			continue
		var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
		for(var/choice_type in customizer.get_available_choices(src, entry))
			var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
			var/label = choice.name
			if(choices[label])
				label = "[label] ([customizer.name])"
			if(choices[label])
				label = "[label] ([length(choices) + 1])"
			choices[label] = list(customizer_type, choice_type)
	return choices

/// Validate the species-local selection before applying it.
/datum/preferences/proc/select_customizer_group_choice(list/group, customizer_type, choice_type)
	if(!(customizer_type in group))
		return FALSE
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	if(!entry || !customizer.is_allowed(src) || !(choice_type in customizer.get_available_choices(src, entry)))
		return FALSE
	var/datum/customizer_entry/primary = get_customizer_entry_for_customizer_type(group[1])
	if(entry.customizer_choice_type != choice_type)
		var/datum/customizer_entry/new_entry = customizer.create_customizer_entry(src, choice_type)
		new_entry.group_selected_customizer = entry.group_selected_customizer
		new_entry.group_disabled = entry.group_disabled
		customizer_entries[customizer_entries.Find(entry)] = new_entry
		if(entry == primary)
			primary = new_entry
		entry = new_entry
	primary.group_selected_customizer = customizer_type
	primary.group_disabled = FALSE
	// Explicit selection enables an optional choice; untouched legacy flags are preserved.
	entry.disabled = FALSE
	return TRUE

/datum/preferences/proc/handle_customizer_group_topic(mob/user, list/href_list, list/group)
	var/datum/customizer_entry/primary = get_customizer_entry_for_customizer_type(group[1])
	var/datum/customizer_entry/entry = get_customizer_group_entry(group)
	switch(href_list["customizer_task"])
		if("toggle_missing")
			if(customizer_group_allows_disabling(group))
				if(!primary.group_selected_customizer)
					primary.group_selected_customizer = entry.customizer_type
					primary.group_disabled = entry.disabled
				primary.group_disabled = !primary.group_disabled
				if(!primary.group_disabled)
					entry.disabled = FALSE
		if("change_choice")
			var/list/choices = get_customizer_group_choices(group)
			var/chosen = tgui_input_list(user, "Choose your customization:", "Character Preference", choices)
			if(!chosen || !choices[chosen])
				return
			var/list/selection = choices[chosen]
			// Recheck after the modal: the user may have switched character slots or races.
			var/list/current_group = get_customizer_group(group[1])
			if(!current_group || current_group[1] != group[1] || get_customizer_entry_for_customizer_type(group[1]) != primary)
				return
			select_customizer_group_choice(current_group, selection[1], selection[2])

/// Bee and Insect tails share genital artwork outside taur mode.
/datum/preferences/proc/has_selected_insect_tail()
	if(taur_type)
		return FALSE
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry.disabled || !ispath(entry.customizer_type, /datum/customizer/organ/tail))
			continue
		var/list/group = get_customizer_group(entry.customizer_type)
		var/datum/customizer_entry/primary = group ? get_customizer_entry_for_customizer_type(group[1]) : null
		// Untouched legacy saves retain their existing dependent choices. Once a
		// consolidated selection is made, only the chosen ordinary tail counts.
		if(primary?.group_selected_customizer && length(group) > 1)
			if(primary.group_disabled || entry != get_customizer_group_entry(group))
				continue
		if(entry && (entry.accessory_type in list(/datum/sprite_accessory/tail/bee, /datum/sprite_accessory/tail/insect)))
			return TRUE
	return FALSE

/datum/preferences/proc/validate_customizer_entries()
	customizer_entries = SANITIZE_LIST(customizer_entries)
	listclearnulls(customizer_entries)
	var/datum/species/species = pref_species
	var/list/customizers = species.customizers
	// The enabled Wild-Kin snout previously overwrote the Lupian snout.
	if(istype(species, /datum/species/lupian))
		var/datum/customizer_entry/legacy_snout = get_customizer_entry_for_customizer_type(/datum/customizer/organ/snout/anthro)
		if(legacy_snout && !legacy_snout.disabled)
			var/datum/customizer_entry/lupian_snout = get_customizer_entry_for_customizer_type(/datum/customizer/organ/snout/lupian)
			customizer_entries -= lupian_snout
			legacy_snout.customizer_type = /datum/customizer/organ/snout/lupian
			legacy_snout.customizer_choice_type = /datum/customizer_choice/organ/snout/lupian
	/// Check if we have any customizer entries that don't match.
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		// Keep existing revenant appearances/settings when adding the Wild-Kin cloaca option.
		if(istype(species, /datum/species/dullahan) && entry.customizer_type == /datum/customizer/organ/vagina/animal)
			entry.customizer_type = /datum/customizer/organ/vagina/anthro
			if(entry.customizer_choice_type == /datum/customizer_choice/organ/vagina/animal)
				entry.customizer_choice_type = /datum/customizer_choice/organ/vagina/anthro
		// Preserve saved tail choices and colors when adding the fertility setting.
		if(entry.type == /datum/customizer_entry && ispath(entry.customizer_choice_type, /datum/customizer_choice/organ/tail))
			var/datum/customizer_entry/organ/tail/tail_entry = new
			tail_entry.customizer_type = entry.customizer_type
			tail_entry.customizer_choice_type = entry.customizer_choice_type
			tail_entry.accessory_type = entry.accessory_type
			tail_entry.accessory_colors = entry.accessory_colors
			tail_entry.disabled = entry.disabled
			customizer_entries[customizer_entries.Find(entry)] = tail_entry
			entry = tail_entry
		var/validated = FALSE
		for(var/customizer_type as anything in customizers)
			if(customizer_type != entry.customizer_type)
				continue
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			customizer.sanitize_choice(src, entry)
			if(!(entry.customizer_choice_type in customizer.get_available_choices(src, entry)))
				continue
			var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
			if(entry.type != customizer_choice.customizer_entry_type)
				continue
			validated = TRUE
			break

		if(!validated)
			customizer_entries -= entry

	/// Check if we have any missing customizer entries
	for(var/customizer_type as anything in customizers)
		var/found = FALSE
		for(var/datum/customizer_entry/entry as anything in customizer_entries)
			if(entry.customizer_type != customizer_type)
				continue
			found = TRUE
			break
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!found)
			if(customizer)
				customizer_entries += customizer.make_default_customizer_entry(src, FALSE)

	/// Validate the variables within customizer entries
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		customizer_choice.validate_entry(src, entry)

/datum/preferences/proc/print_customizers_page()
	var/list/dat = list()
	. = dat
	if(!pref_species)
		return
	var/list/customizers = get_customizer_groups()
	if(!length(customizers))
		return
	dat += "<table width='100%'>"
	dat += "<td valign='top' width='33%'>"
	var/iterated_customizers = 0
	for(var/customizer_type in customizers)
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		if(!customizer)
			continue
		if(!customizer.is_allowed(src))
			continue
		var/list/group = customizers[customizer_type]
		var/merged = length(group) > 1
		var/datum/customizer_entry/entry = get_customizer_group_entry(group)
		var/datum/customizer_entry/primary = get_customizer_entry_for_customizer_type(customizer_type)
		if(!entry)
			stack_trace("Missing customizer entry in preferences for customizer [customizer_type]")
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/list/available_choices = merged ? get_customizer_group_choices(group) : customizer.get_available_choices(src, entry)
		var/disabled = entry.disabled || (merged && primary.group_disabled)
		var/allows_disabling = merged ? customizer_group_allows_disabling(group) : customizer.allows_disabling

		var/customizer_link

		if(disabled)
			customizer_link = "href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=toggle_missing'"
		else
			if(allows_disabling)
				customizer_link = "href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=toggle_missing' class='linkOn'"
			else
				customizer_link = ""

		dat += "<table align='center'; width='100%'; height='100px'; style='background-color:#1c1313'><td width=100%>"
		var/group_name = merged ? capitalize(customizer.get_shared_organ_slot()) : customizer.name
		dat += "<a [customizer_link]>[group_name]</a>"
		if(!disabled)
			var/choice_link
			if(length(available_choices) > 1)
				choice_link = "href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=change_choice'"
			else
				choice_link = "class='linkOff'"
			if(length(available_choices) > 1)
				dat += "<br><a [choice_link]>[choice.name]</a>"

			var/list/choice_list = choice.show_pref_choices(src, entry, entry.customizer_type)
			if(choice_list)
				dat += choice_list

		dat += "</td></table><br>"
		iterated_customizers += 1
		if(iterated_customizers >= 5)
			dat += "</td><td valign='top' width='33%'>"
			iterated_customizers = 0
	dat += "</td></table>"
	return

/// We dont associate the entries just to be safer for save/load, so we can't lookup easily and we do this.
/datum/preferences/proc/get_customizer_entry_for_customizer_type(customizer_type)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry.customizer_type == customizer_type)
			return entry

/// Gets an associative list of organ slots to organ dna created from organ customization
/datum/preferences/proc/get_organ_dna_list()
	var/list/organ_list = list()
	for(var/datum/customizer_entry/entry as anything in get_active_customizer_entries())
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		var/datum/organ_dna/dna = customizer_choice.create_organ_dna(entry, src)
		if(!dna)
			continue
		var/slot = customizer_choice.get_organ_slot()
		var/datum/organ_dna/existing_dna = organ_list[slot]
		if(slot == ORGAN_SLOT_TAIL && existing_dna && ispath(existing_dna.organ_type, /obj/item/organ/tail/manticore) && !ispath(dna.organ_type, /obj/item/organ/tail/manticore))
			qdel(dna)
			continue
		organ_list[slot] = dna

	return organ_list

/datum/preferences/proc/customize_organ(obj/item/organ/organ)
	for(var/datum/customizer_entry/entry as anything in get_active_customizer_entries())
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		if(!(customizer_choice.get_organ_slot() == organ.slot))
			continue
		customizer_choice.customize_organ(organ, entry)

/datum/preferences/proc/apply_customizers_to_character(mob/living/carbon/human/human)
	for(var/datum/customizer_entry/entry as anything in get_active_customizer_entries())
		var/datum/customizer_choice/customizer_choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		var/datum/customizer/customizer = CUSTOMIZER(entry.customizer_type)
		if(!customizer.is_allowed(src))
			continue
		if(entry.disabled)
			continue
		customizer_choice.apply_customizer_to_character(human, src, entry)

/datum/preferences/proc/handle_customizer_topic(mob/user, href_list)
	//needs_update = TRUE
	var/customizer_type = text2path(href_list["customizer"])
	var/datum/customizer_entry/entry = get_customizer_entry_for_customizer_type(customizer_type)
	if(!entry)
		return
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
	var/list/group = get_customizer_group(customizer_type)
	if(!group)
		return
	if(length(group) > 1 && (href_list["customizer_task"] in list("toggle_missing", "change_choice")))
		handle_customizer_group_topic(user, href_list, group)
		validate_customizer_entries()
		if(ishuman(user))
			var/mob/living/carbon/human/humanized = user
			humanized.update_body_parts(TRUE)
		return
	switch(href_list["customizer_task"])
		if("toggle_missing")
			if(customizer.allows_disabling)
				entry.disabled = !entry.disabled
		if("change_choice")
			var/list/choice_list = list()
			for(var/choice_type in customizer.get_available_choices(src, entry))
				var/datum/customizer_choice/iter_choice = CUSTOMIZER_CHOICE(choice_type)
				choice_list[iter_choice.name] = choice_type
			var/chosen_input = tgui_input_list(user, "Choose your [LOWER_TEXT(customizer.name)]:", "Character Preference", choice_list)
			if(!chosen_input)
				return
			var/choice_type = choice_list[chosen_input]
			if(!(choice_type in customizer.get_available_choices(src, entry)))
				return
			if(choice_type == choice.type)
				return
			var/datum/customizer_entry/new_entry = customizer.create_customizer_entry(src, choice_type)
			if(istype(entry, /datum/customizer_entry/organ/penis) && istype(new_entry, /datum/customizer_entry/organ/penis))
				var/datum/customizer_entry/organ/penis/old_penis_entry = entry
				var/datum/customizer_entry/organ/penis/new_penis_entry = new_entry
				new_penis_entry.penis_taur_mode = old_penis_entry.penis_taur_mode
			if(istype(entry, /datum/customizer_entry/organ/vagina) && istype(new_entry, /datum/customizer_entry/organ/vagina))
				var/datum/customizer_entry/organ/vagina/old_vagina_entry = entry
				var/datum/customizer_entry/organ/vagina/new_vagina_entry = new_entry
				new_vagina_entry.vagina_taur_enabled = old_vagina_entry.vagina_taur_enabled
			customizer_entries -= entry
			customizer_entries += new_entry
		else
			choice.handle_topic(user, href_list, src, entry, customizer_type)
	// Tail appearance changes can make the insect-tail genital choice available or invalid.
	validate_customizer_entries()
	if(ishuman(user))
		var/mob/living/carbon/human/humanized = user
		humanized.update_body_parts(TRUE)

/datum/preferences/proc/reset_all_customizer_accessory_colors()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.reset_accessory_colors(src, entry)

/datum/preferences/proc/randomize_all_customizer_accessories()
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
		choice.randomize_entry(entry, src)

/datum/preferences/proc/ShowCustomizers(mob/user)
	var/list/dat = list()
	dat += "<style>span.color_holder_box{display: inline-block; width: 20px; height: 8px; border:1px solid #000; padding: 0px;}</style>"
	dat += print_customizers_page()
	var/datum/browser/popup = new(user, "customization", "<div align='center'>Customization</div>", 630, 730)
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/get_hair_color()
	var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair)
	if(entry)
		return entry.hair_color
	else
		return "FFFFFF"

/datum/preferences/proc/get_facial_hair_color()
	var/datum/customizer_entry/hair/entry = get_customizer_entry_of_type(/datum/customizer_entry/hair/facial)
	if(entry)
		return entry.hair_color
	else
		return "FFFFFF"

/datum/preferences/proc/get_eye_color()
	var/datum/customizer_entry/organ/eyes/entry = get_customizer_entry_of_type(/datum/customizer_entry/organ/eyes)
	if(entry)
		return entry.eye_color
	else
		return "FFFFFF"

/datum/preferences/proc/get_chest_color()
	var/list/zone_list = body_markings[BODY_ZONE_CHEST]
	if(!zone_list)
		return null
	for(var/marking_name in zone_list)
		var/datum/body_marking/marking = GLOB.body_markings[marking_name]
		if(!marking.covers_chest)
			continue
		var/marking_color = zone_list[marking_name]
		return marking_color
	return null

/datum/preferences/proc/get_customizer_entry_of_type(entry_type)
	for(var/datum/customizer_entry/entry as anything in customizer_entries)
		if(entry.type == entry_type)
			return entry
	return null

/datum/preferences/proc/genderize_customizer_entries()
	clear_hair_preview_cache()
	customizer_entries = SANITIZE_LIST(customizer_entries)
	var/datum/species/species = pref_species
	var/list/customizers = species.customizers

	/// Check if we have any missing customizer entries
	for(var/datum/customizer/customizer_type as anything in customizers)
		if(customizer_type.gender_enabled == null)
			continue
		for(var/datum/customizer_entry/entry as anything in customizer_entries)
			if(entry.customizer_type != customizer_type)
				continue
			if(customizer_type.gender_enabled == gender)
				entry.disabled = FALSE
			else
				entry.disabled = TRUE
			break
