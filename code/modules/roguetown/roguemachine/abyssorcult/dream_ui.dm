/datum/tgui_module/vision_quest_selection
	var/datum/vision_quest_selection/selection_data
	var/name

/datum/tgui_module/vision_quest_selection/New(datum/vision_quest_selection/data)
	. = ..()
	selection_data = data
	src.name = "VisionQuestSelection"

/datum/tgui_module/vision_quest_selection/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VisionQuestSelection")
		ui.open()

/datum/tgui_module/vision_quest_selection/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/vision_quest_selection/ui_data(mob/user)
	. = ..()
	.["choices"] = selection_data.choices
	return .

/datum/tgui_module/vision_quest_selection/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("confirm_quest")
			var/quest_id = params["quest_id"]
			var/reward_path = text2path(params["reward_path"])
			var/datum/vision_quest_selection/selection = selection_data
			var/mob/living/carbon/human/seeker = selection.user
			var/obj/structure/roguemachine/ritual_rune/rune = selection.source_rune
			var/obj/item/parchment = selection.parchment_used
			if(ui.user != seeker || QDELETED(rune) || QDELETED(parchment) || !seeker.is_holding(parchment) || !rune.can_use_rune(seeker))
				ui.close()
				return TRUE

			for(var/entry in selection.available_choices)
				var/datum/vision_quest/quest = entry["quest"]
				if("[quest.type]" != quest_id)
					continue
				var/mob/living/carbon/human/target = entry["target"]
				if(!(reward_path in quest.possible_rewards) || !quest.is_valid_target(target, seeker))
					to_chat(seeker, span_warning("The vision has faded. Try the rune again."))
					break

				var/bonus_path = entry["bonus"]
				qdel(parchment)
				var/datum/component/vision_quest_tracker/existing = seeker.GetComponent(/datum/component/vision_quest_tracker)
				if(existing)
					rune.reclaim_quest_parchment(seeker, existing)
				rune.cached_choices -= "[selection.selected_tier]"
				ui.close()
				seeker.Sleeping(10 SECONDS)
				seeker.AddComponent(/datum/component/vision_quest_tracker, quest, target, rune, reward_path, bonus_path)
				return TRUE

			ui.close()
			return TRUE

/datum/vision_quest_selection
	var/list/choices
	var/list/available_choices
	var/mob/living/carbon/human/user
	var/obj/structure/roguemachine/ritual_rune/source_rune
	var/obj/item/parchment_used
	var/selected_quest_id
	var/selected_reward_path
	var/selected_bonus_path
	var/selected_tier

/datum/tgui_module/vortex_ritual_selection
	var/obj/structure/roguemachine/dream_pool/pool
	var/mob/living/carbon/human/user
	var/name

/datum/tgui_module/vortex_ritual_selection/New(obj/structure/roguemachine/dream_pool/pool, mob/living/carbon/human/user)
	. = ..()
	src.pool = pool
	src.user = user
	src.name = "VortexRitualSelection"

/datum/tgui_module/vortex_ritual_selection/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VortexRitualSelection")
		ui.open()

/datum/tgui_module/vortex_ritual_selection/ui_state(mob/user)
	return GLOB.tgui_always_state

/datum/tgui_module/vortex_ritual_selection/ui_data(mob/user)
	. = list()
	var/list/ritual_choices = list()

	for(var/ritual_name in GLOB.abyssal_rituals)
		var/datum/abyssal_ritual/R = GLOB.abyssal_rituals[ritual_name]

		// Compile ingredient breakdown for React transparency
		var/list/ingredients_data = list()
		for(var/ing_type in R.required_ingredients)
			var/qty_needed = R.required_ingredients[ing_type]
			var/obj/item/dummy_item = ing_type
			ingredients_data += list(list(
				"name" = initial(dummy_item.name),
				"required" = qty_needed
			))

		ritual_choices += list(list(
			"id" = R.name,
			"name" = R.name,
			"desc" = R.desc || "A mysterious chant querying the void.",
			"channel_time" = R.base_channel_time / 10, // convert deciseconds to seconds
			"has_materials" = R.check_ingredients(pool),
			"ingredients" = ingredients_data
		))

	.["rituals"] = ritual_choices
	return .

/datum/tgui_module/vortex_ritual_selection/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("execute_ritual")
			var/ritual_id = params["ritual_id"]
			var/datum/abyssal_ritual/chosen_ritual = GLOB.abyssal_rituals[ritual_id]

			if(!pool || QDELETED(pool) || pool.ritual_active)
				return TRUE
			if(ui.user != user || !pool.linked_door || pool.linked_door.gate_closed || !pool.channel_check(user, pool.get_outer_rim_turfs()))
				return TRUE

			if(!chosen_ritual)
				to_chat(user, span_warning("The chosen ritual configuration has dissolved back into the tide."))
				return TRUE

			if(user.get_skill_level(/datum/skill/magic/holy) < 1)
				to_chat(user, span_warning("You lack the holy proficiency required to initiate an abyssal ritual."))
				return TRUE
			if(!istype(user.patron, /datum/patron/divine/abyssor))
				to_chat(user, span_warning("Only a true follower of Abyssor can initiate this ritual."))
				return TRUE
			if(!chosen_ritual.check_ingredients(pool))
				to_chat(user, span_warning("The materials on the rim shifted! You no longer have the correct alignment for [chosen_ritual.name]."))
				return TRUE
			if(!chosen_ritual.can_commence_ritual(pool, user))
				return TRUE

			// Success, close interface and kick off loop
			INVOKE_ASYNC(pool, TYPE_PROC_REF(/obj/structure/roguemachine/dream_pool, coordinate_channeling_loop), user, chosen_ritual)
			ui.close()
			return TRUE

/datum/tgui_module/vision_quest_selection/ui_close(mob/user)
	qdel(src)

/datum/tgui_module/vision_quest_selection/Destroy()
	QDEL_NULL(selection_data)
	return ..()

/datum/tgui_module/vortex_ritual_selection/ui_close(mob/user)
	qdel(src)
