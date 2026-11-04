/obj/item/reagent_containers/food/snacks
	/// Shared lifetime allowance for manually poured liquids and sprinkled powders.
	var/food_additions_used = 0

/// Read-only checks: leave recognized preparation to the normal attackby chain.
/obj/item/reagent_containers/food/snacks/proc/has_preparation_interaction(obj/item/ingredient)
	return FALSE

/obj/item/reagent_containers/food/snacks/rogue/has_preparation_interaction(obj/item/ingredient)
	if(!active_recipe)
		return !!SScooking.get_recipe(src, ingredient)
	if(current_step < 1 || current_step > length(active_recipe.ingredients))
		return FALSE
	var/requirement = active_recipe.ingredients[current_step]
	if(ispath(requirement, /datum/reagent))
		return ingredient.reagents && ingredient.reagents.has_reagent(requirement, active_recipe.ingredients[requirement])
	return istype(ingredient, requirement)

/obj/item/reagent_containers/food/snacks/grown/rice/has_preparation_interaction(obj/item/ingredient)
	return !water_added

/// Capture preparation changes on an item that survives another player's recipe step.
/obj/item/reagent_containers/food/snacks/proc/get_food_preparation_state()
	return list(cooked_type, fried_type)

/obj/item/reagent_containers/food/snacks/rogue/get_food_preparation_state()
	. = ..()
	. += list(active_recipe, prepped_recipe, current_step, process_step)

/obj/item/reagent_containers/food/snacks/grown/rice/get_food_preparation_state()
	. = ..()
	. += list(water_added)

/datum/intent/sprinkle
	name = "sprinkle"
	icon_state = "infeed"
	chargetime = 0
	noaa = TRUE
	dodgeable_intent = FALSE
	misscost = 0

/obj/item/reagent_containers/proc/can_season_food(mob/living/user, obj/item/reagent_containers/food/snacks/food)
	if(!istype(user) || QDELETED(user) || !istype(food) || QDELETED(food) || food == src)
		return FALSE
	if(QDELETED(src) || loc != user || user.get_active_held_item() != src || !user.Adjacent(food))
		return FALSE
	if(!reagents?.total_volume || !food.reagents || food.in_container)
		return FALSE
	if(istype(src, /obj/item/reagent_containers/glass))
		var/obj/item/reagent_containers/glass/vessel = src
		return !vessel.closed && vessel.spillable && vessel.is_drainable() && user.used_intent?.type == INTENT_POUR
	return (istype(src, /obj/item/reagent_containers/powder) || istype(src, /obj/item/reagent_containers/food/snacks/allspice)) && user.used_intent?.type == /datum/intent/sprinkle

// Recognized preparation takes priority; otherwise Pour and Sprinkle add reagents.
/obj/item/reagent_containers/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	if(!istype(user) || !istype(target, /obj/item/reagent_containers/food/snacks))
		return FALSE
	var/is_powder = istype(src, /obj/item/reagent_containers/powder) || istype(src, /obj/item/reagent_containers/food/snacks/allspice)
	if(!(is_powder && user.used_intent?.type == /datum/intent/sprinkle) && !(istype(src, /obj/item/reagent_containers/glass) && user.used_intent?.type == INTENT_POUR))
		return FALSE
	var/obj/item/reagent_containers/food/snacks/food = target
	if(!can_season_food(user, food))
		to_chat(user, span_warning("I can't add anything to [food] from [src] right now."))
		return TRUE
	if(food.has_preparation_interaction(src))
		return FALSE
	if(food.food_additions_used >= 5)
		to_chat(user, span_warning("[food] can't absorb any more."))
		return TRUE
	var/atom/food_location = food.loc
	var/list/preparation_state = food.get_food_preparation_state()
	to_chat(user, span_notice("I start [is_powder ? "sprinkling" : "pouring"] [src] onto [food]..."))
	if(!do_after(user, 2 SECONDS, target = food))
		return TRUE
	if(!can_season_food(user, food) || food.loc != food_location)
		return TRUE
	if(food.has_preparation_interaction(src) || !compare_list(preparation_state, food.get_food_preparation_state()))
		to_chat(user, span_warning("[food]'s preparation changed. I stop adding to it."))
		return TRUE
	// Recheck after waiting: another application may have used the allowance.
	var/portion = is_powder ? 5 : (user.m_intent == MOVE_INTENT_SNEAK ? 1 : amount_per_transfer_from_this)
	var/amount = min(portion, reagents.total_volume, 5 - food.food_additions_used)
	if(amount <= 0)
		return TRUE
	// Make room without deleting any of the food's existing contents.
	food.reagents.maximum_volume = max(food.reagents.maximum_volume, food.reagents.total_volume + amount)
	// Reserve the allowance before transfer reactions can run another action.
	food.food_additions_used += amount
	var/transferred = reagents.trans_to(food, amount, transfered_by = user)
	if(!QDELETED(food))
		food.food_additions_used -= amount - transferred
	if(transferred && !QDELETED(user) && !QDELETED(src) && !QDELETED(food))
		user.visible_message(span_notice("[user] [is_powder ? "sprinkles" : "pours"] [src] onto [food]."), span_notice("I [is_powder ? "sprinkle" : "pour"] [src] onto [food]."))
	if(is_powder && !QDELETED(src) && reagents && !reagents.total_volume)
		qdel(src)
	return TRUE

/obj/item/reagent_containers/powder/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Use Sprinkle intent on solid food to add powder. Food can absorb up to five drams of liquid and powder combined.")

/obj/item/reagent_containers/food/snacks/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pour liquid or sprinkle powder onto this food to add up to five drams in total.")
	. += span_info("Matching recipes take priority and consume their required ingredients; other reagents in the mixture are not automatically added to the result. Apply additions to finished food to avoid losing them during preparation. Slicing shares additives between slices.")
