/datum/customizer/organ/penis
	abstract_type = /datum/customizer/organ/penis
	name = "Penis"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = MALE

/datum/customizer/organ/penis/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer/organ/penis/get_available_choices(datum/preferences/prefs, datum/customizer_entry/entry)
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	if(!istype(penis_entry) || !penis_entry.penis_taur_mode)
		var/list/normal_choices = ..()
		normal_choices = normal_choices.Copy()
		if(prefs?.has_selected_insect_tail())
			normal_choices += /datum/customizer_choice/organ/penis/bee_tail
		return normal_choices
	// Taur mode has its own artwork-backed list, including for species whose normal choice is plain.
	var/datum/customizer/organ/penis/anthro/taur_customizer = CUSTOMIZER(/datum/customizer/organ/penis/anthro)
	var/list/choices = list()
	for(var/choice_type in taur_customizer.customizer_choices)
		// Covering is chosen separately; don't offer duplicate slit-labelled shapes.
		if(choice_type in list(/datum/customizer_choice/organ/penis/equine_slit, /datum/customizer_choice/organ/penis/equine_knotted_slit))
			continue
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
		var/supported = length(choice.sprite_accessories) > 0
		for(var/accessory_type in choice.sprite_accessories)
			var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(accessory_type)
			if(!istype(accessory) || !accessory.has_taur_artwork())
				supported = FALSE
				break
		if(supported)
			choices += choice_type
	var/obj/item/bodypart/taur/taur_type = prefs?.taur_type
	if(ispath(taur_type, /obj/item/bodypart/taur) && initial(taur_type.supports_ovipositor))
		choices += /datum/customizer_choice/organ/penis/ovipositor_ant
	return choices

/datum/customizer/organ/penis/sanitize_choice(datum/preferences/prefs, datum/customizer_entry/entry)
	if(!istype(entry, /datum/customizer_entry/organ/penis))
		return
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	if(penis_entry.penis_taur_mode)
		// Migrate the label without changing the saved covering, artwork, or knot mechanics.
		switch(entry.customizer_choice_type)
			if(/datum/customizer_choice/organ/penis/equine_slit)
				entry.customizer_choice_type = /datum/customizer_choice/organ/penis/equine
			if(/datum/customizer_choice/organ/penis/equine_knotted_slit)
				entry.customizer_choice_type = /datum/customizer_choice/organ/penis/equine_knotted
	var/list/choices = get_available_choices(prefs, entry)
	if(!length(choices) || (entry.customizer_choice_type in choices))
		return
	entry.customizer_choice_type = choices[1]
	var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(entry.customizer_choice_type)
	var/old_colors = entry.accessory_colors
	choice.set_accessory_type(prefs, choice.default_accessory, entry)
	// Shapes share two color keys; validate old colors against the new accessory before keeping them.
	var/datum/sprite_accessory/accessory = SPRITE_ACCESSORY(entry.accessory_type)
	if(length(color_string_to_list(old_colors)) == accessory.color_keys)
		entry.accessory_colors = old_colors

/proc/sheath_type_preference_label(sheath_type)
	switch(sheath_type)
		if(SHEATH_TYPE_NORMAL)
			return "Sheath"
		if(SHEATH_TYPE_SLIT)
			return "Slit"
	return "None"

/datum/customizer_choice/organ/penis
	/// Restrict sizes to the selected accessory artwork.
	var/min_penis_size = MIN_PENIS_SIZE
	var/allows_sheath_customization = TRUE
	var/allows_taur_mode = TRUE
	abstract_type = /datum/customizer_choice/organ/penis
	name = "Penis"
	organ_type = /obj/item/organ/penis
	organ_slot = ORGAN_SLOT_PENIS
	organ_dna_type = /datum/organ_dna/penis
	customizer_entry_type = /datum/customizer_entry/organ/penis

/datum/customizer_choice/organ/penis/make_default_customizer_entry(datum/preferences/prefs, customizer_type, changed_entry = TRUE)
	var/datum/customizer_entry/organ/penis/entry = ..()
	var/obj/item/organ/penis/organ_path = organ_type
	entry.sheath_type = initial(organ_path.sheath_type)
	entry.penis_size = clamp(entry.penis_size, min_penis_size, MAX_PENIS_SIZE)
	return entry

/datum/customizer_choice/organ/penis/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	penis_entry.penis_size = sanitize_integer(penis_entry.penis_size, min_penis_size, MAX_PENIS_SIZE, DEFAULT_PENIS_SIZE)
	penis_entry.sheath_type = sanitize_integer(penis_entry.sheath_type, SHEATH_TYPE_NONE, SHEATH_TYPE_SLIT, SHEATH_TYPE_NONE)
	penis_entry.ovipositor = !!penis_entry.ovipositor
	penis_entry.egg_settings = sanitize_oviposition_settings(penis_entry.egg_settings)
	penis_entry.penis_taur_mode = !!penis_entry.penis_taur_mode
	if(!allows_taur_mode)
		penis_entry.penis_taur_mode = FALSE
	if(!allows_sheath_customization)
		penis_entry.sheath_type = SHEATH_TYPE_NONE

/datum/customizer_choice/organ/penis/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/penis/penis_dna = organ_dna
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	penis_dna.penis_size = clamp(penis_entry.penis_size, min_penis_size, MAX_PENIS_SIZE)
	penis_dna.functional = penis_entry.functional
	penis_dna.sheath_type = allows_sheath_customization ? penis_entry.sheath_type : SHEATH_TYPE_NONE
	penis_dna.egg_settings = penis_entry.ovipositor ? sanitize_oviposition_settings(penis_entry.egg_settings) : null
	penis_dna.penis_taur_mode = allows_taur_mode && penis_entry.penis_taur_mode

/datum/customizer_choice/organ/penis/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	dat += "<br>Penis size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=penis_size''>[find_key_by_value(GLOB.named_penis_sizes, penis_entry.penis_size)]</a>"
	dat += "<br>Functional: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=functional''>[penis_entry.functional ? "YES" : "NO"]</a>"
	if(allows_sheath_customization)
		dat += "<br>Sheath: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=sheath_type''>[sheath_type_preference_label(penis_entry.sheath_type)]</a>"
	else
		dat += "<br>Sheath: None"
	if(allows_taur_mode)
		dat += "<br><span title='Uses taur genital sprites when available'>Penis Taur Mode: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=penis_taur_mode'>[penis_entry.penis_taur_mode ? "Enabled" : "Disabled"]</a></span>"

	if(!islist(penis_entry.egg_settings))
		penis_entry.egg_settings = default_oviposition_settings()
	oviposition_pref_choices(dat, penis_entry.egg_settings, customizer_type, penis_entry.ovipositor, "Ovipositor")

/datum/customizer_choice/organ/penis/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/penis/penis_entry = entry
	if(!islist(penis_entry.egg_settings))
		penis_entry.egg_settings = default_oviposition_settings()
	switch(href_list["customizer_task"])
		if("penis_taur_mode")
			if(!allows_taur_mode)
				return
			penis_entry.penis_taur_mode = !penis_entry.penis_taur_mode
			var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
			customizer.sanitize_choice(prefs, entry)
		if("penis_size")
			var/list/available_sizes = list()
			for(var/size_name in GLOB.named_penis_sizes)
				var/size_value = GLOB.named_penis_sizes[size_name]
				if(size_value >= min_penis_size && size_value <= MAX_PENIS_SIZE)
					available_sizes[size_name] = size_value
			var/named_size = input(user, "Choose your penis size:", "Character Preference", find_key_by_value(available_sizes, penis_entry.penis_size)) as anything in available_sizes
			if(isnull(named_size))
				return
			var/new_size = available_sizes[named_size]
			penis_entry.penis_size = sanitize_integer(new_size, min_penis_size, MAX_PENIS_SIZE, DEFAULT_PENIS_SIZE)
		if("functional")
			penis_entry.functional = !penis_entry.functional
		if("sheath_type")
			if(!allows_sheath_customization)
				return
			switch(penis_entry.sheath_type)
				if(SHEATH_TYPE_NONE)
					penis_entry.sheath_type = SHEATH_TYPE_NORMAL
				if(SHEATH_TYPE_NORMAL)
					penis_entry.sheath_type = SHEATH_TYPE_SLIT
				else
					penis_entry.sheath_type = SHEATH_TYPE_NONE
		if("ovi_toggle")
			penis_entry.ovipositor = !penis_entry.ovipositor
		else
			oviposition_pref_topic(user, href_list["customizer_task"], penis_entry.egg_settings)

/datum/customizer_entry/organ/penis
	var/penis_taur_mode = FALSE
	var/penis_size = DEFAULT_PENIS_SIZE
	var/functional = TRUE
	var/sheath_type = SHEATH_TYPE_NONE
	var/ovipositor = FALSE
	var/list/egg_settings

/datum/customizer/organ/penis/human
	customizer_choices = list(/datum/customizer_choice/organ/penis/human)

/datum/customizer/organ/penis/anthro
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro,
		/datum/customizer_choice/organ/penis/knotted,
		/datum/customizer_choice/organ/penis/equine,
		/datum/customizer_choice/organ/penis/equine_knotted,
		/datum/customizer_choice/organ/penis/equine_slit,
		/datum/customizer_choice/organ/penis/equine_knotted_slit,
		/datum/customizer_choice/organ/penis/tapered_mammal,
		/datum/customizer_choice/organ/penis/tapered_double_mammal,
		/datum/customizer_choice/organ/penis/tapered,
		/datum/customizer_choice/organ/penis/tapered_knot,
		/datum/customizer_choice/organ/penis/tapered_knot_mammal,
		/datum/customizer_choice/organ/penis/tapered_double,
		/datum/customizer_choice/organ/penis/tapered_double_knot,
		/datum/customizer_choice/organ/penis/tapered_double_knot_mammal,
		/datum/customizer_choice/organ/penis/barbed,
		/datum/customizer_choice/organ/penis/barbed_knotted,
		/datum/customizer_choice/organ/penis/tentacle,
		)

/datum/customizer/organ/penis/lamia
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/tapered,
		/datum/customizer_choice/organ/penis/tapered_knot,
		/datum/customizer_choice/organ/penis/tapered_double,
		/datum/customizer_choice/organ/penis/tapered_double_knot,
		/datum/customizer_choice/organ/penis/tentacle,
		)

/datum/customizer/organ/penis/canine
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro,
		/datum/customizer_choice/organ/penis/knotted,
		/datum/customizer_choice/organ/penis/tapered_knot_mammal,
		)

/datum/customizer/organ/penis/feline
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro,
		/datum/customizer_choice/organ/penis/barbed,
		/datum/customizer_choice/organ/penis/barbed_knotted,
		)

/datum/customizer/organ/penis/lizard
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro,
		/datum/customizer_choice/organ/penis/tapered,
		/datum/customizer_choice/organ/penis/tapered_knot,
		/datum/customizer_choice/organ/penis/tapered_double,
		/datum/customizer_choice/organ/penis/tapered_double_knot,
		)

/datum/customizer/organ/penis/equine
	customizer_choices = list(
		/datum/customizer_choice/organ/penis/human_anthro,
		/datum/customizer_choice/organ/penis/equine,
		/datum/customizer_choice/organ/penis/equine_knotted,
		/datum/customizer_choice/organ/penis/equine_slit,
		/datum/customizer_choice/organ/penis/equine_knotted_slit,
		)

/datum/customizer_choice/organ/penis/human
	name = "Plain Penis"
	organ_type = /obj/item/organ/penis
	sprite_accessories = list(/datum/sprite_accessory/penis/human)
	allows_accessory_color_customization = FALSE

/datum/customizer_choice/organ/penis/human_anthro
	name = "Plain Penis"
	organ_type = /obj/item/organ/penis
	sprite_accessories = list(/datum/sprite_accessory/penis/human)
	allows_accessory_color_customization = TRUE

/datum/customizer_choice/organ/penis/knotted
	name = "Knotted Penis"
	organ_type = /obj/item/organ/penis/knotted
	sprite_accessories = list(
		/datum/sprite_accessory/penis/knotted,
		)

/datum/customizer_choice/organ/penis/equine
	name = "Equine Penis"
	organ_type = /obj/item/organ/penis/equine
	sprite_accessories = list(
		/datum/sprite_accessory/penis/flared,
		)

/datum/customizer_choice/organ/penis/equine_knotted
	name = "Equine Knotted Penis"
	organ_type = /obj/item/organ/penis/equine_knotted
	sprite_accessories = list(
		/datum/sprite_accessory/penis/flared_knotted,
		)

/datum/customizer_choice/organ/penis/equine_slit
	name = "Equine Penis (Slit)"
	organ_type = /obj/item/organ/penis/equine_slit
	sprite_accessories = list(
		/datum/sprite_accessory/penis/flared,
		)

/datum/customizer_choice/organ/penis/equine_knotted_slit
	name = "Equine Knotted Penis (Slit)"
	organ_type = /obj/item/organ/penis/equine_knotted_slit
	sprite_accessories = list(
		/datum/sprite_accessory/penis/flared_knotted,
		)

/datum/customizer_choice/organ/penis/tapered_mammal
	name = "Tapered Penis (Mammal)"
	organ_type = /obj/item/organ/penis/tapered_mammal
	sprite_accessories = list(
		/datum/sprite_accessory/penis/tapered_mammal,
		)

/datum/customizer_choice/organ/penis/tapered
	name = "Tapered Penis"
	organ_type = /obj/item/organ/penis/tapered
	sprite_accessories = list(
		/datum/sprite_accessory/penis/tapered,
		)

/datum/customizer_choice/organ/penis/tapered_knot
	name = "Knotted Tapered Penis"
	organ_type = /obj/item/organ/penis/tapered_knotted
	sprite_accessories = list(
		/datum/sprite_accessory/penis/taperedknot,
		)

/datum/customizer_choice/organ/penis/tapered_knot_mammal
	name = "Knotted Tapered Penis (Mammal)"
	organ_type = /obj/item/organ/penis/tapered_knotted_mammal
	sprite_accessories = list(
		/datum/sprite_accessory/penis/taperedknot_mammal,
		)

/datum/customizer_choice/organ/penis/tapered_double
	name = "Hemi Tapered Penis"
	organ_type = /obj/item/organ/penis/tapered_double
	sprite_accessories = list(
		/datum/sprite_accessory/penis/hemi,
		)

/datum/customizer_choice/organ/penis/tapered_double_mammal
	name = "Hemi Tapered Penis (Mammal)"
	organ_type = /obj/item/organ/penis/tapered_mammal
	sprite_accessories = list(
		/datum/sprite_accessory/penis/hemi_mammal,
		)

/datum/customizer_choice/organ/penis/tapered_double_knot
	name = "Knotted Hemi Tapered Penis"
	organ_type = /obj/item/organ/penis/tapered_double_knotted
	sprite_accessories = list(
		/datum/sprite_accessory/penis/hemiknot,
		)

/datum/customizer_choice/organ/penis/tapered_double_knot_mammal
	name = "Knotted Hemi Tapered Penis (mammal)"
	organ_type = /obj/item/organ/penis/tapered_double_knotted_mammal
	sprite_accessories = list(
		/datum/sprite_accessory/penis/hemiknot,
		)

/datum/customizer_choice/organ/penis/barbed
	name = "Barbed Penis"
	organ_type = /obj/item/organ/penis/barbed
	sprite_accessories = list(
		/datum/sprite_accessory/penis/barbknot,
		)

/datum/customizer_choice/organ/penis/barbed_knotted
	name = "Barbed Knotted Penis"
	organ_type = /obj/item/organ/penis/barbed_knotted
	sprite_accessories = list(
		/datum/sprite_accessory/penis/barbknot,
		)

/datum/customizer_choice/organ/penis/tentacle
	name = "Tentacle Penis"
	organ_type = /obj/item/organ/penis/tentacle
	sprite_accessories = list(
		/datum/sprite_accessory/penis/tentacle,
		)

/datum/customizer_choice/organ/penis/bee_tail
	min_penis_size = SMALL_PENIS_SIZE
	name = "Ovipositor"
	organ_type = /obj/item/organ/penis/bee_tail
	sprite_accessories = list(/datum/sprite_accessory/penis/bee_tail)
	allows_sheath_customization = FALSE
	allows_taur_mode = FALSE

/datum/customizer_choice/organ/penis/ovipositor_ant
	min_penis_size = SMALL_PENIS_SIZE
	name = "Ovipositor"
	organ_type = /obj/item/organ/penis/ovipositor_ant
	sprite_accessories = list(/datum/sprite_accessory/penis/ovipositor_ant)
	allows_sheath_customization = FALSE

/datum/customizer/organ/testicles
	abstract_type = /datum/customizer/organ/testicles
	name = "Testicles"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = MALE

/datum/customizer/organ/testicles/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer_choice/organ/testicles
	abstract_type = /datum/customizer_choice/organ/testicles
	name = "Testicles"
	organ_type = /obj/item/organ/testicles
	organ_dna_type = /datum/organ_dna/testicles
	customizer_entry_type = /datum/customizer_entry/organ/testicles
	organ_slot = ORGAN_SLOT_TESTICLES
	var/can_customize_size = TRUE

/datum/customizer_choice/organ/testicles/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	testicles_entry.ball_size = sanitize_integer(testicles_entry.ball_size, MIN_TESTICLES_SIZE, MAX_TESTICLES_SIZE, DEFAULT_TESTICLES_SIZE)

/datum/customizer_choice/organ/testicles/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/testicles/testicles_dna = organ_dna
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	if(can_customize_size)
		testicles_dna.ball_size = testicles_entry.ball_size
	testicles_dna.virility = testicles_entry.virility

/datum/customizer_choice/organ/testicles/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	if(can_customize_size)
		dat += "<br>Ball size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ball_size''>[find_key_by_value(GLOB.named_ball_sizes, testicles_entry.ball_size)]</a>"
	dat += "<br>Virile: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=virile''>[testicles_entry.virility ? "Virile" : "Sterile"]</a>"

/datum/customizer_choice/organ/testicles/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/testicles/testicles_entry = entry
	switch(href_list["customizer_task"])
		if("ball_size")
			var/named_size = input(user, "Choose your ball size:", "Character Preference", find_key_by_value(GLOB.named_ball_sizes, testicles_entry.ball_size)) as anything in GLOB.named_ball_sizes
			if(isnull(named_size))
				return
			var/new_size = GLOB.named_ball_sizes[named_size]
			testicles_entry.ball_size = sanitize_integer(new_size, MIN_TESTICLES_SIZE, MAX_TESTICLES_SIZE, DEFAULT_TESTICLES_SIZE)
		if("virile")
			testicles_entry.virility = !testicles_entry.virility

/datum/customizer/organ/testicles/external
	customizer_choices = list(/datum/customizer_choice/organ/testicles/external)

/datum/customizer/organ/testicles/human
	customizer_choices = list(/datum/customizer_choice/organ/testicles/human)

/datum/customizer/organ/testicles/internal
	customizer_choices = list(/datum/customizer_choice/organ/testicles/internal)

/datum/customizer/organ/testicles/anthro
	customizer_choices = list(
		/datum/customizer_choice/organ/testicles/external,
		/datum/customizer_choice/organ/testicles/internal,
	)

/datum/customizer_choice/organ/testicles/external
	name = "Testicles"
	sprite_accessories = list(/datum/sprite_accessory/testicles/pair)

/datum/customizer_choice/organ/testicles/human
	name = "Testicles"
	sprite_accessories = list(/datum/sprite_accessory/testicles/pair)
	allows_accessory_color_customization = FALSE

/datum/customizer_choice/organ/testicles/internal
	name = "Internal testicles"
	organ_type = /obj/item/organ/testicles/internal
	sprite_accessories = null
	can_customize_size = FALSE

/datum/customizer_entry/organ/testicles
	var/ball_size = DEFAULT_TESTICLES_SIZE
	var/virility = TRUE

/datum/customizer/organ/breasts
	abstract_type = /datum/customizer/organ/breasts
	name = "Breasts"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = FEMALE

/datum/customizer/organ/breasts/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer_choice/organ/breasts
	abstract_type = /datum/customizer_choice/organ/breasts
	name = "Breasts"
	customizer_entry_type = /datum/customizer_entry/organ/breasts
	organ_type = /obj/item/organ/breasts
	organ_slot = ORGAN_SLOT_BREASTS
	organ_dna_type = /datum/organ_dna/breasts

/datum/customizer_choice/organ/breasts/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	breasts_entry.breast_size = sanitize_integer(breasts_entry.breast_size, MIN_BREASTS_SIZE, MAX_BREASTS_SIZE, DEFAULT_BREASTS_SIZE)

/datum/customizer_choice/organ/breasts/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/breasts/breasts_dna = organ_dna
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	breasts_dna.breast_size = breasts_entry.breast_size
	breasts_dna.lactating = breasts_entry.lactating

/datum/customizer_choice/organ/breasts/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	dat += "<br>Breast size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=breast_size''>[find_key_by_value(GLOB.named_breast_sizes, breasts_entry.breast_size)]</a>"
	dat += "<br>Lactation: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=lactating''>[breasts_entry.lactating ? "Enabled" : "Disabled"]</a>"

/datum/customizer_choice/organ/breasts/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/breasts/breasts_entry = entry
	switch(href_list["customizer_task"])
		if("breast_size")
			var/named_size = input(user, "Choose your breast size:", "Character Preference", find_key_by_value(GLOB.named_breast_sizes, breasts_entry.breast_size)) as anything in GLOB.named_breast_sizes
			if(isnull(named_size))
				return
			var/new_size = GLOB.named_breast_sizes[named_size]
			breasts_entry.breast_size = sanitize_integer(new_size, MIN_BREASTS_SIZE, MAX_BREASTS_SIZE, DEFAULT_BREASTS_SIZE)
		if("lactating")
			breasts_entry.lactating = !breasts_entry.lactating

/datum/customizer_entry/organ/breasts
	var/breast_size = DEFAULT_BREASTS_SIZE
	var/lactating = FALSE

/datum/customizer/organ/breasts/human
	customizer_choices = list(/datum/customizer_choice/organ/breasts/human)

/datum/customizer_choice/organ/breasts/human
	sprite_accessories = list(/datum/sprite_accessory/breasts/pair, /datum/sprite_accessory/breasts/pecs, /datum/sprite_accessory/breasts/pecs/nippleless)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/breasts/animal
	customizer_choices = list(/datum/customizer_choice/organ/breasts/animal)

/datum/customizer_choice/organ/breasts/animal
	sprite_accessories = list(
		/datum/sprite_accessory/breasts/pair,
		/datum/sprite_accessory/breasts/quad,
		/datum/sprite_accessory/breasts/sextuple,
		/datum/sprite_accessory/breasts/pecs,
		/datum/sprite_accessory/breasts/pecs/nippleless,
		)

/datum/customizer/organ/vagina
	abstract_type = /datum/customizer/organ/vagina
	name = "Vagina"
	allows_disabling = TRUE
	default_disabled = TRUE
	gender_enabled = FEMALE

/datum/customizer/organ/vagina/is_allowed(datum/preferences/prefs)
	return TRUE

/datum/customizer/organ/vagina/sanitize_choice(datum/preferences/prefs, datum/customizer_entry/entry)
	// Move older Oviduct selections into the original appearance picker without resetting them.
	if(entry.customizer_choice_type == /datum/customizer_choice/organ/vagina/bee_tail)
		entry.customizer_choice_type = default_choice

/datum/customizer_choice/organ/vagina
	abstract_type = /datum/customizer_choice/organ/vagina
	name = "Vagina"
	customizer_entry_type = /datum/customizer_entry/organ/vagina
	organ_type = /obj/item/organ/vagina
	organ_slot = ORGAN_SLOT_VAGINA
	organ_dna_type = /datum/organ_dna/vagina

/datum/customizer_entry/organ/vagina
	var/vagina_taur_enabled = TRUE
	var/fertility = TRUE
	var/egg_layer = FALSE
	var/list/egg_settings

/datum/customizer_choice/organ/vagina/validate_entry(datum/preferences/prefs, datum/customizer_entry/entry)
	..()
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	vagina_entry.egg_layer = !!vagina_entry.egg_layer
	vagina_entry.egg_settings = sanitize_oviposition_settings(vagina_entry.egg_settings)
	vagina_entry.vagina_taur_enabled = !!vagina_entry.vagina_taur_enabled

/datum/customizer_choice/organ/vagina/imprint_organ_dna(datum/organ_dna/organ_dna, datum/customizer_entry/entry, datum/preferences/prefs)
	..()
	var/datum/organ_dna/vagina/vagina_dna = organ_dna
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	vagina_dna.fertility = vagina_entry.fertility
	vagina_dna.egg_settings = vagina_entry.egg_layer ? sanitize_oviposition_settings(vagina_entry.egg_settings) : null
	vagina_dna.vagina_taur_enabled = vagina_entry.vagina_taur_enabled

/datum/customizer_choice/organ/vagina/generate_pref_choices(list/dat, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	dat += "<br>Fertile: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=fertile''>[vagina_entry.fertility ? "Fertile" : "Sterile"]</a>"
	if(!islist(vagina_entry.egg_settings))
		vagina_entry.egg_settings = default_oviposition_settings()
	oviposition_pref_choices(dat, vagina_entry.egg_settings, customizer_type, vagina_entry.egg_layer, "Egg layer")
	dat += "<br><span title='Show vagina sprites on taur bodies'>Taur Vagina: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=vagina_taur_enabled'>[vagina_entry.vagina_taur_enabled ? "Enabled" : "Disabled"]</a></span>"

/datum/customizer_choice/organ/vagina/handle_topic(mob/user, list/href_list, datum/preferences/prefs, datum/customizer_entry/entry, customizer_type)
	..()
	var/datum/customizer_entry/organ/vagina/vagina_entry = entry
	if(!islist(vagina_entry.egg_settings))
		vagina_entry.egg_settings = default_oviposition_settings()
	switch(href_list["customizer_task"])
		if("fertile")
			vagina_entry.fertility = !vagina_entry.fertility
		if("vagina_taur_enabled")
			vagina_entry.vagina_taur_enabled = !vagina_entry.vagina_taur_enabled
		if("ovi_toggle")
			vagina_entry.egg_layer = !vagina_entry.egg_layer
		else
			oviposition_pref_topic(user, href_list["customizer_task"], vagina_entry.egg_settings)


/datum/customizer/organ/vagina/human
	customizer_choices = list(/datum/customizer_choice/organ/vagina/human)

/datum/customizer_choice/organ/vagina/human
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/gaping,
		/datum/sprite_accessory/vagina/hairy,
		/datum/sprite_accessory/vagina/trimmed,
		/datum/sprite_accessory/vagina/bee_tail,
		)
	allows_accessory_color_customization = FALSE

/datum/customizer/organ/vagina/human_anthro
	customizer_choices = list(/datum/customizer_choice/organ/vagina/human_anthro)

/datum/customizer_choice/organ/vagina/human_anthro
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/gaping,
		/datum/sprite_accessory/vagina/hairy,
		/datum/sprite_accessory/vagina/trimmed,
		/datum/sprite_accessory/vagina/bee_tail,
		)
	allows_accessory_color_customization = TRUE

/datum/customizer/organ/vagina/animal
	customizer_choices = list(/datum/customizer_choice/organ/vagina/animal)

/datum/customizer_choice/organ/vagina/animal
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/gaping,
		/datum/sprite_accessory/vagina/hairy,
		/datum/sprite_accessory/vagina/trimmed,
		/datum/sprite_accessory/vagina/spade,
		/datum/sprite_accessory/vagina/furred,
		/datum/sprite_accessory/vagina/bee_tail,
		)

/datum/customizer/organ/vagina/anthro
	customizer_choices = list(/datum/customizer_choice/organ/vagina/anthro)

/datum/customizer_choice/organ/vagina/anthro
	sprite_accessories = list(
		/datum/sprite_accessory/vagina/human,
		/datum/sprite_accessory/vagina/gaping,
		/datum/sprite_accessory/vagina/hairy,
		/datum/sprite_accessory/vagina/trimmed,
		/datum/sprite_accessory/vagina/spade,
		/datum/sprite_accessory/vagina/furred,
		/datum/sprite_accessory/vagina/cloaca,
		/datum/sprite_accessory/vagina/bee_tail,
		)

/datum/customizer_choice/organ/vagina/bee_tail
	name = "Oviduct"
	organ_type = /obj/item/organ/vagina
	sprite_accessories = list(/datum/sprite_accessory/vagina/bee_tail)
	allows_accessory_color_customization = TRUE
