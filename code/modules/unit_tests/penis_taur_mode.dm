/datum/unit_test/penis_taur_mode/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/penis/penis = allocate(/obj/item/organ/penis/knotted)
	penis.Insert(human)
	penis.set_accessory_type(/datum/sprite_accessory/penis/knotted)
	var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(penis.accessory_type)
	human.Taurize(/obj/item/bodypart/taur/horse)
	var/obj/item/bodypart/taur/taur = human.get_taur_tail()
	TEST_ASSERT_EQUAL(taur.owner, human, "The test taur body must be attached to its owner.")

	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "Taur mode must default to off.")
	var/normal_key = penis.get_icon_cache_key()
	penis.penis_taur_mode = TRUE
	TEST_ASSERT_NOTEQUAL(normal_key, penis.get_icon_cache_key(), "Toggling taur mode must invalidate the organ cache.")
	TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "sheath_0", "A relaxed sheathed penis should use the taur sheath.")
	penis.erect_state = ERECT_STATE_PARTIAL
	TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "sheath_1", "A partially erect penis should use the open taur sheath.")
	penis.sheath_type = SHEATH_TYPE_SLIT
	TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "slit_1", "A slit should use the available taur slit artwork.")
	penis.erect_state = ERECT_STATE_HARD
	TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "knotted_2_1", "A fully erect penis should use the selected type and size.")
	penis.penis_size = MIN_PENIS_SIZE
	TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "knotted_1_1", "Tiny must reuse Small taur artwork instead of disappearing.")
	penis.penis_size = DEFAULT_PENIS_SIZE


	var/list/appearances = accessory.get_appearance(penis, null, "#FFFFFF#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 1, "Taur artwork should produce one behind-body overlay.")
	var/mutable_appearance/appearance = appearances[1]
	var/icon/rendered = icon(appearance.icon)
	TEST_ASSERT_EQUAL(rendered.Width(), 64, "Taur rendering must preserve the wide canvas.")
	TEST_ASSERT_EQUAL(rendered.Height(), 32, "Taur rendering must preserve the normal canvas height.")

	penis.set_egg_settings(default_oviposition_settings())
	var/datum/organ_dna/penis/dna = penis.create_organ_dna()
	TEST_ASSERT(dna.penis_taur_mode, "Organ DNA must retain taur mode.")
	TEST_ASSERT_NOTNULL(dna.egg_settings, "Taur customization must preserve existing oviposition settings in DNA.")
	var/obj/item/organ/penis/recreated = dna.create_organ()
	TEST_ASSERT(recreated.penis_taur_mode, "Recreated organs must retain taur mode.")
	TEST_ASSERT_NOTNULL(recreated.egg_settings, "Recreated taur organs must retain existing oviposition settings.")
	TEST_ASSERT_EQUAL(recreated.penis_size, penis.penis_size, "Recreated organs must retain size.")
	qdel(recreated)
	qdel(dna)

	var/datum/customizer_entry/organ/penis/entry = new
	TEST_ASSERT(!entry.penis_taur_mode, "Old/new preference entries must default to disabled.")
	entry.penis_taur_mode = TRUE
	var/savefile/saved = new
	saved["entry"] << entry
	var/datum/customizer_entry/organ/penis/loaded
	saved["entry"] >> loaded
	TEST_ASSERT(loaded.penis_taur_mode, "Character saves must retain taur mode.")
	qdel(entry)
	qdel(loaded)

	var/taur_key = penis.get_icon_cache_key()
	taur.drop_limb(TRUE)
	qdel(taur)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "Non-taur bodies must use normal sprites.")
	TEST_ASSERT_NOTEQUAL(taur_key, penis.get_icon_cache_key(), "Removing a taur body must change the effective rendering cache key.")
	human.Taurize(/obj/item/bodypart/taur/lamia)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "Serpentine bodies must use normal sprites.")
	human.Taurize(/obj/item/bodypart/taur/horse)
	var/datum/sprite_accessory/penis/human/plain = SPRITE_ACCESSORY(/datum/sprite_accessory/penis/human)
	TEST_ASSERT_NULL(plain.get_taur_icon_state(penis), "Unsupported plain penis artwork must fall back to normal sprites.")
	penis.Remove(human)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "Detached organs must use normal sprites.")

/datum/unit_test/penis_taur_choices/Run()
	var/datum/customizer/organ/penis/customizer = CUSTOMIZER(/datum/customizer/organ/penis/human)
	var/datum/customizer_entry/organ/penis/entry = new
	var/list/normal_choices = customizer.get_available_choices(null, entry)
	TEST_ASSERT_EQUAL(length(normal_choices), 1, "Normal human customization must retain its single plain choice.")
	entry.penis_taur_mode = TRUE
	var/list/taur_choices = customizer.get_available_choices(null, entry)
	TEST_ASSERT(length(taur_choices) > 1, "Taur mode must offer supported shapes even when the species normally only offers plain.")
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/human_anthro in taur_choices), "Plain artwork must not appear in the taur list.")
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/tapered_knot in taur_choices), "Knotted tapered artwork must not appear in the taur list.")
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/tapered_double in taur_choices), "Hemi artwork must not appear in the taur list.")
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/equine_slit in taur_choices), "Slit-labelled equine duplicates must not appear in the taur list.")
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/equine_knotted_slit in taur_choices), "Slit-labelled knotted equine duplicates must not appear in the taur list.")
	TEST_ASSERT(/datum/customizer_choice/organ/penis/equine_knotted in taur_choices, "Equine knot mechanics must remain available with shared flared artwork.")
	entry.customizer_choice_type = /datum/customizer_choice/organ/penis/equine_slit
	entry.accessory_type = /datum/sprite_accessory/penis/flared
	entry.sheath_type = SHEATH_TYPE_SLIT
	entry.accessory_colors = "#123456#654321"
	customizer.sanitize_choice(null, entry)
	TEST_ASSERT_EQUAL(entry.customizer_choice_type, /datum/customizer_choice/organ/penis/equine, "Saved taur equine slit choices must migrate to equine.")
	TEST_ASSERT_EQUAL(entry.sheath_type, SHEATH_TYPE_SLIT, "Migration must preserve the selected covering.")
	TEST_ASSERT_EQUAL(entry.accessory_colors, "#123456#654321", "Migration must preserve colors.")
	entry.customizer_choice_type = /datum/customizer_choice/organ/penis/equine_knotted_slit
	entry.accessory_type = /datum/sprite_accessory/penis/flared_knotted
	customizer.sanitize_choice(null, entry)
	TEST_ASSERT_EQUAL(entry.customizer_choice_type, /datum/customizer_choice/organ/penis/equine_knotted, "Saved knotted equine slit choices must retain knot mechanics.")
	TEST_ASSERT_EQUAL(entry.sheath_type, SHEATH_TYPE_SLIT, "Knotted migration must preserve the selected covering.")
	for(var/choice_type in taur_choices)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(choice_type)
		for(var/accessory_type in choice.sprite_accessories)
			var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(accessory_type)
			TEST_ASSERT(accessory.has_taur_artwork(), "Every taur choice must have complete shape artwork.")
	entry.penis_taur_mode = FALSE
	TEST_ASSERT_EQUAL(length(customizer.get_available_choices(null, entry)), 1, "Disabling taur mode must restore the species' normal choice list.")
	qdel(entry)

/datum/unit_test/bee_tail_penis/Run()
	var/datum/customizer_choice/organ/penis/choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/organ/penis/bee_tail)
	var/datum/customizer_entry/organ/penis/entry = new
	entry.customizer_choice_type = choice.type
	entry.accessory_type = /datum/sprite_accessory/penis/bee_tail
	entry.accessory_colors = "#FFFFFF"
	entry.penis_size = MAX_PENIS_SIZE
	entry.sheath_type = SHEATH_TYPE_SLIT
	entry.penis_taur_mode = TRUE
	choice.validate_entry(null, entry)
	TEST_ASSERT_EQUAL(entry.penis_size, MAX_PENIS_SIZE, "The Bee-tail accessory must retain Large selections.")
	entry.penis_size = SMALL_PENIS_SIZE
	choice.validate_entry(null, entry)
	TEST_ASSERT_EQUAL(entry.penis_size, SMALL_PENIS_SIZE, "Existing Small Bee-tail selections must retain their size.")
	TEST_ASSERT_EQUAL(entry.sheath_type, SHEATH_TYPE_NONE, "Generic coverings must not replace the Bee-tail artwork.")
	TEST_ASSERT(!entry.penis_taur_mode, "The Bee-tail accessory must remain outside taur mode.")
	qdel(entry)

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/penis/penis = allocate(/obj/item/organ/penis/bee_tail)
	penis.Insert(human)
	var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(penis.accessory_type)
	var/obj/item/organ/tail/tail = allocate(/obj/item/organ/tail/cat)
	tail.Insert(human)
	TEST_ASSERT(!accessory.is_visible(penis, null, human), "Other tail types must not display Bee-tail artwork.")
	tail.set_accessory_type(/datum/sprite_accessory/tail/bee)
	TEST_ASSERT(!accessory.is_visible(penis, null, human), "A relaxed Bee-tail penis must remain hidden.")
	TEST_ASSERT_NULL(accessory.get_appearance(penis, null, "#FFFFFF"), "Relaxed must hide both Bee-tail layers.")
	penis.erect_state = ERECT_STATE_PARTIAL
	TEST_ASSERT(accessory.is_visible(penis, null, human), "A regular Bee tail must allow the accessory without taur mode.")
	for(var/erection in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD))
		penis.erect_state = erection
		TEST_ASSERT_EQUAL(accessory.get_icon_state(penis, null, human), "bee_tail_penis_small_base", "All erection states must reuse the supplied Small pose.")
		TEST_ASSERT_EQUAL(accessory.is_visible(penis, null, human), erection != ERECT_STATE_NONE, "Bee-tail visibility must follow arousal.")
	var/list/appearances = accessory.get_appearance(penis, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "The Bee-tail sprite must render its base and authored UP layer.")
	var/mutable_appearance/appearance = appearances[1]
	var/mutable_appearance/top_appearance = appearances[2]
	TEST_ASSERT(top_appearance.layer > -BODY_FRONT_LAYER, "The UP layer must draw above the Bee tail's front layer.")
	TEST_ASSERT_EQUAL(appearance.layer, -BODY_BEHIND_LAYER, "The base artwork must retain its behind-body layer.")
	var/icon/rendered = icon(appearance.icon)
	TEST_ASSERT_EQUAL(rendered.Width(), 32, "Bee-tail rendering must retain its native 32px canvas.")
	TEST_ASSERT_EQUAL(rendered.Height(), 32, "Bee-tail rendering must retain the normal 32px height.")
	var/small_key = penis.get_icon_cache_key()
	penis.penis_size = DEFAULT_PENIS_SIZE
	TEST_ASSERT_NOTEQUAL(small_key, penis.get_icon_cache_key(), "Average must not reuse Small's organ rendering cache.")
	var/datum/sprite_accessory/penis/bee_tail/bee_accessory = accessory
	TEST_ASSERT_EQUAL(bee_accessory.get_bee_tail_icon_state(penis.penis_size), "bee_tail_penis_average_base", "Select the matching size and layer state.")
	TEST_ASSERT_EQUAL(bee_accessory.get_bee_tail_icon_state(penis.penis_size, TRUE), "bee_tail_penis_average_up", "Select the matching size and layer state.")
	appearances = accessory.get_appearance(penis, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "Average must render both supplied layers.")
	var/average_key = penis.get_icon_cache_key()
	penis.penis_size = MAX_PENIS_SIZE
	TEST_ASSERT_NOTEQUAL(average_key, penis.get_icon_cache_key(), "Large must not reuse Average's organ rendering cache.")
	TEST_ASSERT_EQUAL(bee_accessory.get_bee_tail_icon_state(penis.penis_size), "bee_tail_penis_large_base", "Select the matching size and layer state.")
	TEST_ASSERT_EQUAL(bee_accessory.get_bee_tail_icon_state(penis.penis_size, TRUE), "bee_tail_penis_large_up", "Select the matching size and layer state.")
	appearances = accessory.get_appearance(penis, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "Large must render both supplied layers.")
	var/bee_key = penis.get_icon_cache_key()
	tail.Remove(human)
	TEST_ASSERT(!accessory.is_visible(penis, null, human), "Removing the Bee tail must hide its accessory.")
	TEST_ASSERT_NOTEQUAL(bee_key, penis.get_icon_cache_key(), "Tail removal must invalidate the genital rendering cache.")

/datum/unit_test/insect_tail_genitals/Run()
	var/datum/preferences/oviduct_preview_unit_test/prefs = new
	var/datum/customizer_entry/organ/tail/tail_entry = new
	tail_entry.customizer_type = /datum/customizer/organ/tail/anthro
	prefs.customizer_entries = list(tail_entry)
	var/datum/customizer_entry/organ/penis/penis_entry = new
	var/datum/customizer/organ/penis/customizer = CUSTOMIZER(/datum/customizer/organ/penis/anthro)
	for(var/tail_type in list(/datum/sprite_accessory/tail/bee, /datum/sprite_accessory/tail/insect))
		tail_entry.accessory_type = tail_type
		TEST_ASSERT(/datum/customizer_choice/organ/penis/bee_tail in customizer.get_available_choices(prefs, penis_entry), "Both Bee and Insect tails must offer their shared genital artwork.")
	tail_entry.disabled = TRUE
	TEST_ASSERT(!(/datum/customizer_choice/organ/penis/bee_tail in customizer.get_available_choices(prefs, penis_entry)), "A disabled tail must not enable tail genital choices.")
	tail_entry.disabled = FALSE
	prefs.taur_type = /obj/item/bodypart/taur/ant
	TEST_ASSERT(!prefs.has_selected_insect_tail(), "Regular insect-tail genital artwork must remain outside taur mode.")
	qdel(penis_entry)
	qdel(tail_entry)
	qdel(prefs)

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/tail/tail = allocate(/obj/item/organ/tail/cat)
	tail.set_accessory_type(/datum/sprite_accessory/tail/insect)
	tail.Insert(human)
	var/obj/item/organ/penis/penis = allocate(/obj/item/organ/penis/bee_tail)
	penis.Insert(human)
	var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(penis.accessory_type)
	for(var/size in SMALL_PENIS_SIZE to MAX_PENIS_SIZE)
		penis.penis_size = size
		for(var/erection in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD))
			penis.erect_state = erection
			TEST_ASSERT_EQUAL(length(accessory.get_appearance(penis, null, "#FFFFFF")), erection == ERECT_STATE_NONE ? 0 : 2, "Insect tails must show both genital layers only during partial/full arousal at every supported size.")
	var/obj/item/organ/vagina/vagina = allocate(/obj/item/organ/vagina)
	vagina.Insert(human)
	var/datum/sprite_accessory/vagina/vagina_accessory = SPRITE_ACCESSORY(vagina.accessory_type)
	for(var/manual_arousal in list(SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_FULL))
		human.sexcon.manual_arousal = manual_arousal
		var/list/appearances = vagina_accessory.get_appearance(vagina, null, "#FFFFFF")
		TEST_ASSERT_EQUAL(length(appearances), 1, "Insect tails must not add an oviduct to a regular vagina selection.")
		var/mutable_appearance/opening = appearances[1]
		TEST_ASSERT_EQUAL(opening.icon_state, "[vagina_accessory.icon_state]_FRONT", "Regular vagina artwork must remain selected at every arousal state.")
	human.obscured_flags = HIDETAIL
	TEST_ASSERT_NULL(accessory.get_appearance(penis, null, "#FFFFFF"), "Hiding the Insect tail must hide its penis artwork.")
	TEST_ASSERT_EQUAL(length(vagina_accessory.get_appearance(vagina, null, "#FFFFFF")), 1, "Hiding the Insect tail must leave only the regular vagina.")
	human.obscured_flags = HIDECROTCH
	TEST_ASSERT_NULL(vagina_accessory.get_appearance(vagina, null, "#FFFFFF"), "Crotch coverage must hide the Insect-tail opening and regular vagina.")
	human.obscured_flags = NONE
	vagina.set_accessory_type(/datum/sprite_accessory/vagina/bee_tail)
	vagina_accessory = SPRITE_ACCESSORY(vagina.accessory_type)
	TEST_ASSERT_EQUAL(length(vagina_accessory.get_appearance(vagina, null, "#FFFFFF")), 2, "Selecting Oviduct must render only its two directional layers.")
	tail.Remove(human)
	TEST_ASSERT_NULL(accessory.get_appearance(penis, null, "#FFFFFF"), "Removing the Insect tail must hide its penis artwork.")

/datum/unit_test/ovipositor_ant/Run()
	var/datum/customizer_choice/organ/penis/choice = CUSTOMIZER_CHOICE(/datum/customizer_choice/organ/penis/ovipositor_ant)
	var/datum/customizer_entry/organ/penis/entry = new
	entry.customizer_choice_type = choice.type
	entry.accessory_type = /datum/sprite_accessory/penis/ovipositor_ant
	entry.accessory_colors = "#FFFFFF"
	entry.penis_size = MAX_PENIS_SIZE
	entry.sheath_type = SHEATH_TYPE_SLIT
	entry.penis_taur_mode = TRUE
	choice.validate_entry(null, entry)
	TEST_ASSERT_EQUAL(entry.penis_size, MAX_PENIS_SIZE, "Large ovipositors must retain their selected size.")
	TEST_ASSERT_EQUAL(entry.sheath_type, SHEATH_TYPE_NONE, "The uncovered ovipositor must not substitute generic covering artwork.")
	entry.penis_size = SMALL_PENIS_SIZE
	choice.validate_entry(null, entry)
	TEST_ASSERT_EQUAL(entry.penis_size, SMALL_PENIS_SIZE, "Existing Small ovipositors must retain their size.")
	qdel(entry)

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	human.Taurize(/obj/item/bodypart/taur/ant)
	var/obj/item/organ/penis/penis = allocate(/obj/item/organ/penis/ovipositor_ant)
	penis.Insert(human)
	var/datum/sprite_accessory/penis/accessory = SPRITE_ACCESSORY(penis.accessory_type)
	TEST_ASSERT(accessory.has_taur_artwork(), "The shared sheet must contain all ovipositor sizes and layers.")
	for(var/erection in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD))
		penis.erect_state = erection
		TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "taur_ovipositor_ant_small_base", "All erection states must reuse the supplied small pose.")
		TEST_ASSERT_EQUAL(accessory.is_visible(penis, null, human), erection != ERECT_STATE_NONE, "Taur ovipositor visibility must follow arousal.")
		if(erection == ERECT_STATE_NONE)
			TEST_ASSERT_NULL(accessory.get_appearance(penis, null, "#FFFFFF"), "Relaxed must hide both taur ovipositor layers.")
	var/small_key = penis.get_icon_cache_key()
	penis.penis_size = DEFAULT_PENIS_SIZE
	TEST_ASSERT_NOTEQUAL(small_key, penis.get_icon_cache_key(), "Selecting Average must invalidate the Small rendering cache.")
	for(var/erection in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD))
		penis.erect_state = erection
		TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "taur_ovipositor_ant_average_base", "All erection states must reuse the supplied Average pose.")
	var/datum/sprite_accessory/penis/ovipositor_ant/ovipositor_accessory = accessory
	TEST_ASSERT_EQUAL(ovipositor_accessory.get_ovipositor_top_icon_state(penis.penis_size), "taur_ovipositor_ant_average_up", "Select the matching size and layer state.")
	var/average_key = penis.get_icon_cache_key()
	penis.penis_size = MAX_PENIS_SIZE
	TEST_ASSERT_NOTEQUAL(average_key, penis.get_icon_cache_key(), "Large must not reuse Average's cached appearance.")
	TEST_ASSERT_EQUAL(ovipositor_accessory.get_ovipositor_base_icon_state(penis.penis_size), "taur_ovipositor_ant_large_base", "Select the matching size and layer state.")
	TEST_ASSERT_EQUAL(ovipositor_accessory.get_ovipositor_top_icon_state(penis.penis_size), "taur_ovipositor_ant_large_up", "Select the matching size and layer state.")
	for(var/erection in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD))
		penis.erect_state = erection
		TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), "taur_ovipositor_ant_large_base", "All erection states must reuse the supplied Large pose.")
	var/list/appearances = accessory.get_appearance(penis, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "The ovipositor must render a base and a top layer.")
	var/mutable_appearance/appearance = appearances[1]
	var/mutable_appearance/top_appearance = appearances[2]
	TEST_ASSERT(top_appearance.layer > -BODY_ADJ_LAYER, "The top ovipositor layer must draw above the ant abdomen and markings.")
	TEST_ASSERT_EQUAL(appearance.layer, -BODY_BEHIND_LAYER, "Other ovipositor directions must retain their original behind-body layer.")
	var/icon/rendered = icon(appearance.icon)
	TEST_ASSERT_EQUAL(rendered.Width(), 64, "The ovipositor must retain its 64px canvas.")
	TEST_ASSERT_EQUAL(rendered.Height(), 32, "The ovipositor must retain its 32px canvas height.")
	penis.penis_size = SMALL_PENIS_SIZE
	TEST_ASSERT_EQUAL(ovipositor_accessory.get_ovipositor_top_icon_state(penis.penis_size), "taur_ovipositor_ant_small_up", "Small must use its named UP state.")
	appearances = accessory.get_appearance(penis, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "Small must render both supplied layers.")
	penis.penis_taur_mode = FALSE
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "The ovipositor must require taur mode.")
	penis.penis_taur_mode = TRUE
	for(var/taur_type in list(/obj/item/bodypart/taur/ant, /obj/item/bodypart/taur/wasp, /obj/item/bodypart/taur/insect, /obj/item/bodypart/taur/spider, /obj/item/bodypart/taur/centipede))
		human.Taurize(taur_type)
		var/obj/item/bodypart/taur/taur = human.get_taur_tail()
		var/body_style = taur_type == /obj/item/bodypart/taur/wasp ? "wasp" : (taur_type == /obj/item/bodypart/taur/spider ? "spider" : "ant")
		TEST_ASSERT_EQUAL(taur.ovipositor_sprite, body_style, "Wasp and Spider must select their own artwork; other bodies retain the Ant fallback.")
		for(var/size in SMALL_PENIS_SIZE to MAX_PENIS_SIZE)
			penis.penis_size = size
			var/expected_state = ovipositor_accessory.get_ovipositor_base_icon_state(size, body_style)
			TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(penis), expected_state, "Each body and size must resolve its own base artwork.")
			appearances = accessory.get_appearance(penis, null, "#FFFFFF")
			TEST_ASSERT_EQUAL(length(appearances), 2, "Every body and size must render both layers while aroused.")
			TEST_ASSERT(ovipositor_accessory.get_ovipositor_top_icon_state(size, body_style) in icon_states(accessory.icon), "Every body and size must have matching UP artwork.")
	human.Taurize(/obj/item/bodypart/taur/canine)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(penis), "Insect ovipositors must not appear on unrelated bodies.")

/datum/unit_test/testicles_taur_mode/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/penis/penis = allocate(/obj/item/organ/penis)
	penis.Insert(human)
	var/obj/item/organ/testicles/testes = allocate(/obj/item/organ/testicles)
	testes.Insert(human)
	var/datum/sprite_accessory/testicles/accessory = SPRITE_ACCESSORY(testes.accessory_type)
	human.Taurize(/obj/item/bodypart/taur/horse)
	var/obj/item/bodypart/taur/taur = human.get_taur_tail()
	TEST_ASSERT_EQUAL(taur.owner, human, "The test taur body must be attached to its owner.")

	TEST_ASSERT_NULL(accessory.get_taur_icon_state(testes), "Testicles must use normal sprites when Penis Taur Mode is disabled.")
	var/normal_key = testes.get_icon_cache_key()
	penis.penis_taur_mode = TRUE
	TEST_ASSERT_NOTEQUAL(normal_key, testes.get_icon_cache_key(), "The shared taur toggle must invalidate the testicle cache.")
	for(var/size in MIN_TESTICLES_SIZE to MAX_TESTICLES_SIZE)
		testes.ball_size = size
		TEST_ASSERT_EQUAL(accessory.get_taur_icon_state(testes), "m_testicles_pair_[size]_FRONT", "Each selectable size must have taur artwork.")
	var/large_key = testes.get_icon_cache_key()
	testes.ball_size = MIN_TESTICLES_SIZE
	TEST_ASSERT_NOTEQUAL(large_key, testes.get_icon_cache_key(), "Changing size must invalidate the testicle cache.")

	var/list/appearances = accessory.get_appearance(testes, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 1, "Taur testicles should produce one front-body overlay.")
	var/mutable_appearance/appearance = appearances[1]
	var/icon/rendered = icon(appearance.icon)
	TEST_ASSERT_EQUAL(rendered.Width(), 64, "Taur testicles must preserve the wide canvas.")
	TEST_ASSERT_EQUAL(rendered.Height(), 32, "Taur testicles must preserve the normal canvas height.")
	TEST_ASSERT_EQUAL(appearance.layer, -BODY_FRONT_LAYER, "Taur testicles must use the source artwork's front layer.")

	penis.sheath_type = SHEATH_TYPE_SLIT
	TEST_ASSERT_NULL(accessory.get_appearance(testes, null, "#FFFFFF"), "A slit must continue to hide external testicles.")
	penis.sheath_type = SHEATH_TYPE_NONE
	var/taur_key = testes.get_icon_cache_key()
	taur.drop_limb(TRUE)
	qdel(taur)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(testes), "Non-taur bodies must use normal testicle sprites.")
	TEST_ASSERT_NOTEQUAL(taur_key, testes.get_icon_cache_key(), "Removing the taur body must invalidate the testicle cache.")
	human.Taurize(/obj/item/bodypart/taur/lamia)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(testes), "Serpentine bodies must use normal testicle sprites.")
	human.Taurize(/obj/item/bodypart/taur/horse)
	penis.Remove(human)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(testes), "Removing the organ carrying the taur toggle must restore normal sprites.")
	testes.Remove(human)
	TEST_ASSERT_NULL(accessory.get_taur_icon_state(testes), "Detached testicles must use normal sprites.")

/datum/unit_test/bee_tail_oviduct/Run()
	for(var/customizer_type in list(/datum/customizer/organ/vagina/human, /datum/customizer/organ/vagina/human_anthro, /datum/customizer/organ/vagina/animal, /datum/customizer/organ/vagina/anthro))
		var/datum/customizer/customizer = CUSTOMIZER(customizer_type)
		var/datum/customizer_choice/choice = CUSTOMIZER_CHOICE(customizer.default_choice)
		TEST_ASSERT(/datum/sprite_accessory/vagina/bee_tail in choice.sprite_accessories, "Oviduct must be added to the existing appearance picker.")
		var/datum/customizer_entry/organ/vagina/entry = new
		entry.customizer_choice_type = /datum/customizer_choice/organ/vagina/bee_tail
		entry.accessory_type = /datum/sprite_accessory/vagina/bee_tail
		entry.accessory_colors = "#123456"
		entry.fertility = FALSE
		customizer.sanitize_choice(null, entry)
		choice.validate_entry(null, entry)
		TEST_ASSERT_EQUAL(entry.customizer_choice_type, customizer.default_choice, "Saved Oviduct choices must return to the original picker.")
		TEST_ASSERT_EQUAL(entry.accessory_type, /datum/sprite_accessory/vagina/bee_tail, "Migration must preserve selected Oviduct artwork.")
		TEST_ASSERT_EQUAL(entry.accessory_colors, "#123456", "Migration must preserve the saved tint.")
		TEST_ASSERT(!entry.fertility, "Migration must preserve organ settings.")
		qdel(entry)
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/vagina/oviduct = allocate(/obj/item/organ/vagina)
	oviduct.set_accessory_type(/datum/sprite_accessory/vagina/bee_tail)
	oviduct.Insert(human)
	var/datum/sprite_accessory/vagina/bee_tail/accessory = SPRITE_ACCESSORY(oviduct.accessory_type)
	TEST_ASSERT(accessory.is_visible(oviduct, null, human), "Oviduct must be visible without a Bee tail.")
	human.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_DEFAULT
	human.sexcon.set_arousal(0)
	TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), "bee_tail_oviduct_normal", "Relaxed must select normal artwork.")
	var/normal_key = oviduct.get_icon_cache_key()
	var/list/normal_appearances = accessory.get_appearance(oviduct, null, "#FFFFFF")
	var/mutable_appearance/normal_appearance = normal_appearances[2]
	var/icon/normal_south = icon(normal_appearance.icon, normal_appearance.icon_state, SOUTH)
	TEST_ASSERT_NOTNULL(normal_south.GetPixel(16, 3), "Normal South artwork must stay visible at its original opening.")
	human.sexcon.set_arousal(20)
	TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), "bee_tail_oviduct_normal", "Partial arousal must use normal artwork.")
	human.sexcon.set_arousal(21)
	TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), "bee_tail_oviduct_hard", "Full arousal must use hard artwork on a standard vagina organ.")
	TEST_ASSERT_NOTEQUAL(normal_key, oviduct.get_icon_cache_key(), "Arousal must invalidate the organ rendering cache.")
	var/list/appearances = accessory.get_appearance(oviduct, null, "#FFFFFF")
	TEST_ASSERT_EQUAL(length(appearances), 2, "Oviduct must separate South-behind artwork from its other directions.")
	var/mutable_appearance/appearance = appearances[1]
	TEST_ASSERT(appearance.layer > -BODY_FRONT_LAYER, "Non-South oviduct artwork must retain its front layer.")
	var/mutable_appearance/behind_appearance = appearances[2]
	TEST_ASSERT_EQUAL(behind_appearance.layer, -BODY_BEHIND_LAYER, "South oviduct artwork must draw behind the body.")
	for(var/direction in list(SOUTH, NORTH, EAST, WEST))
		var/icon/front_icon = icon(appearance.icon, appearance.icon_state, direction)
		var/icon/behind_icon = icon(behind_appearance.icon, behind_appearance.icon_state, direction)
		for(var/x in 1 to 32)
			for(var/y in 1 to 32)
				if(direction == SOUTH)
					TEST_ASSERT_NULL(front_icon.GetPixel(x, y), "South must not also draw on the front layer.")
				else
					TEST_ASSERT_NULL(behind_icon.GetPixel(x, y), "The behind layer must contain only South artwork.")
	var/icon/hard_south = icon(behind_appearance.icon, behind_appearance.icon_state, SOUTH)
	TEST_ASSERT_NOTNULL(hard_south.GetPixel(16, 3), "Hard South artwork must retain the supplied file position.")
	TEST_ASSERT_NOTNULL(hard_south.GetPixel(17, 3), "Hard South artwork must retain the corrected supplied position.")
	TEST_ASSERT_NULL(normal_south.GetPixel(15, 3), "Normal and hard must have distinct artwork.")
	human.sexcon.adjust_arousal_manual(SEX_MANUAL_AROUSAL_UNAROUSED - SEX_MANUAL_AROUSAL_DEFAULT)
	TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), "bee_tail_oviduct_normal", "Manual Unaroused must override high automatic arousal.")
	human.sexcon.set_arousal(0)
	human.sexcon.adjust_arousal_manual(SEX_MANUAL_AROUSAL_FULL - SEX_MANUAL_AROUSAL_UNAROUSED)
	TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), "bee_tail_oviduct_hard", "Manual Full must override low automatic arousal.")
	human.Taurize(/obj/item/bodypart/taur/ant)
	TEST_ASSERT(accessory.is_visible(oviduct, null, human), "Oviduct must also support taur bodies.")
	appearances = accessory.get_appearance(oviduct, null, "#FFFFFF")
	appearance = appearances[2]
	hard_south = icon(appearance.icon, appearance.icon_state, SOUTH)
	TEST_ASSERT_NOTNULL(hard_south.GetPixel(16, 3), "Taur rendering must preserve supplied directions without swapping North and South.")

	var/obj/item/organ/penis/preview_penis = human.getorganslot(ORGAN_SLOT_PENIS)
	if(preview_penis)
		preview_penis.Remove(human)
	var/datum/preferences/oviduct_preview_unit_test/prefs = new
	for(var/preview_state in list(ERECT_STATE_NONE, ERECT_STATE_PARTIAL, ERECT_STATE_HARD, ERECT_STATE_NONE))
		prefs.preview_erect_state = preview_state
		prefs.apply_preview_erect_state_to_mannequin(human)
		var/expected_state = preview_state == ERECT_STATE_HARD ? "bee_tail_oviduct_hard" : "bee_tail_oviduct_normal"
		TEST_ASSERT_EQUAL(accessory.get_icon_state(oviduct, null, human), expected_state, "Arousal Preview must switch the oviduct without a penis, and reset when leaving Hard.")
	qdel(prefs)

	// Both poses obey clothing coverage unless deliberately exposed.
	var/original_obscured_flags = human.obscured_flags
	var/obj/item/undies/undies = allocate(/obj/item/undies)
	for(var/manual_state in list(SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_FULL))
		human.sexcon.manual_arousal = manual_state
		human.sexcon.bottom_exposed = FALSE
		for(var/coverage in list(HIDEJUMPSUIT, HIDECROTCH))
			human.obscured_flags = coverage
			TEST_ASSERT_NULL(accessory.get_appearance(oviduct, null, "#FFFFFF"), "Crotch-covering clothing must hide both oviduct poses.")
		human.obscured_flags = NONE
		human.underwear = undies
		TEST_ASSERT_NULL(accessory.get_appearance(oviduct, null, "#FFFFFF"), "Underwear must hide both oviduct poses.")
		human.sexcon.bottom_exposed = TRUE
		TEST_ASSERT(accessory.is_visible(oviduct, null, human), "Explicit crotch exposure must override underwear for both oviduct poses.")
		human.underwear = null
		human.sexcon.bottom_exposed = FALSE
		TEST_ASSERT(accessory.is_visible(oviduct, null, human), "Removing coverage must restore oviduct visibility.")
	human.obscured_flags = original_obscured_flags

// Only the preview setting is needed; avoid loading account preferences for this test.
/datum/preferences/oviduct_preview_unit_test/New()
	return

/datum/unit_test/insect_tail_vagina_choices/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
	var/obj/item/organ/tail/tail = allocate(/obj/item/organ/tail/cat)
	tail.Insert(human)
	var/obj/item/organ/vagina/vagina = allocate(/obj/item/organ/vagina)
	vagina.Insert(human)
	for(var/tail_type in list(/datum/sprite_accessory/tail/bee, /datum/sprite_accessory/tail/insect))
		tail.set_accessory_type(tail_type)
		for(var/style in list(/datum/sprite_accessory/vagina/human, /datum/sprite_accessory/vagina/gaping, /datum/sprite_accessory/vagina/hairy, /datum/sprite_accessory/vagina/trimmed, /datum/sprite_accessory/vagina/spade, /datum/sprite_accessory/vagina/furred, /datum/sprite_accessory/vagina/cloaca))
			vagina.set_accessory_type(style)
			var/datum/sprite_accessory/vagina/accessory = SPRITE_ACCESSORY(style)
			human.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_UNAROUSED
			var/normal_key = vagina.get_icon_cache_key()
			for(var/manual_arousal in list(SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_FULL))
				human.sexcon.manual_arousal = manual_arousal
				var/list/appearances = accessory.get_appearance(vagina, null, "#FFFFFF")
				TEST_ASSERT_EQUAL(length(appearances), 1, "Regular vagina choices must render only their selected artwork on Bee and Insect tails.")
				var/mutable_appearance/appearance = appearances[1]
				TEST_ASSERT_EQUAL(appearance.icon_state, "[accessory.icon_state]_FRONT", "Arousal must not add or substitute Oviduct artwork for a regular vagina.")
				TEST_ASSERT_EQUAL(normal_key, vagina.get_icon_cache_key(), "Regular vagina caches must not depend on oviduct arousal states.")
			human.obscured_flags = HIDECROTCH
			TEST_ASSERT_NULL(accessory.get_appearance(vagina, null, "#FFFFFF"), "Crotch coverage must still hide regular vagina artwork.")
			human.obscured_flags = NONE
		vagina.set_accessory_type(/datum/sprite_accessory/vagina/bee_tail)
		var/datum/sprite_accessory/vagina/oviduct = SPRITE_ACCESSORY(vagina.accessory_type)
		human.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_UNAROUSED
		var/normal_key = vagina.get_icon_cache_key()
		for(var/manual_arousal in list(SEX_MANUAL_AROUSAL_UNAROUSED, SEX_MANUAL_AROUSAL_FULL))
			human.sexcon.manual_arousal = manual_arousal
			var/list/appearances = oviduct.get_appearance(vagina, null, "#FFFFFF")
			TEST_ASSERT_EQUAL(length(appearances), 2, "Explicit Oviduct selections must render their two directional layers without regular vagina artwork.")
			var/mutable_appearance/appearance = appearances[1]
			TEST_ASSERT_EQUAL(appearance.icon_state, manual_arousal == SEX_MANUAL_AROUSAL_FULL ? "bee_tail_oviduct_hard" : "bee_tail_oviduct_normal", "Explicit Oviduct selections must retain their arousal poses.")
		TEST_ASSERT_NOTEQUAL(normal_key, vagina.get_icon_cache_key(), "Explicit Oviduct selections must still invalidate their cache on arousal changes.")
