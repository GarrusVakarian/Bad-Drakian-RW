/obj/item/reagent_containers/food/snacks
	/// Shared lifetime allowance for manually poured liquids and sprinkled powders.
	var/food_additions_used = 0

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

// Explicit intents intercept before recipe attackby handlers. Other intents
// retain their existing crafting, feeding, filling and splashing behavior.
/obj/item/reagent_containers/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	if(!istype(user))
		return FALSE
	var/is_powder = istype(src, /obj/item/reagent_containers/powder) || istype(src, /obj/item/reagent_containers/food/snacks/allspice)
	if(is_powder && user.used_intent?.type == /datum/intent/sprinkle && istype(target, /obj/item/reagent_containers/glass))
		return sprinkle_into_drink(target, user)
	if(!istype(target, /obj/item/reagent_containers/food/snacks))
		return FALSE
	if(!(is_powder && user.used_intent?.type == /datum/intent/sprinkle) && !(istype(src, /obj/item/reagent_containers/glass) && user.used_intent?.type == INTENT_POUR))
		return FALSE
	var/obj/item/reagent_containers/food/snacks/food = target
	if(!can_season_food(user, food))
		to_chat(user, span_warning("I can't add anything to [food] from [src] right now."))
		return TRUE
	if(food.food_additions_used >= 5)
		to_chat(user, span_warning("[food] can't absorb any more."))
		return TRUE
	var/atom/food_location = food.loc
	to_chat(user, span_notice("I start [is_powder ? "sprinkling" : "pouring"] [src] onto [food]..."))
	if(!do_after(user, 2 SECONDS, target = food))
		return TRUE
	if(!can_season_food(user, food) || food.loc != food_location)
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
	. += span_info("Use Sprinkle intent on solid food or an open drink container to add powder. Food can absorb five drams in total; drink containers accept up to five drams per application, space permitting.")

/obj/item/reagent_containers/food/snacks/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Pour liquid or sprinkle powder onto this food to add up to five drams in total.")

/obj/item/reagent_containers/proc/can_sprinkle_into_drink(mob/living/user, obj/item/reagent_containers/glass/vessel)
	if(!istype(user) || QDELETED(user) || !istype(vessel) || QDELETED(vessel) || vessel == src || QDELETED(src))
		return FALSE
	if(loc != user || user.get_active_held_item() != src || !user.Adjacent(vessel))
		return FALSE
	if(!reagents?.total_volume || vessel.closed || !vessel.is_open_container())
		return FALSE
	return (istype(src, /obj/item/reagent_containers/powder) || istype(src, /obj/item/reagent_containers/food/snacks/allspice)) && user.used_intent?.type == /datum/intent/sprinkle

/obj/item/reagent_containers/proc/sprinkle_into_drink(obj/item/reagent_containers/glass/vessel, mob/living/user)
	if(!can_sprinkle_into_drink(user, vessel))
		if(istype(user) && !QDELETED(user))
			to_chat(user, span_warning("I need powder in hand and an open vessel within reach."))
		return TRUE
	if(vessel.reagents.total_volume >= vessel.reagents.maximum_volume)
		to_chat(user, span_warning("[vessel] is full."))
		return TRUE
	var/atom/vessel_location = vessel.loc
	to_chat(user, span_notice("I start sprinkling [src] into [vessel]..."))
	if(!do_after(user, 2 SECONDS, target = vessel))
		return TRUE
	if(!can_sprinkle_into_drink(user, vessel) || vessel.loc != vessel_location)
		return TRUE
	var/amount = min(5, reagents.total_volume, vessel.reagents.maximum_volume - vessel.reagents.total_volume)
	if(amount <= 0)
		return TRUE
	var/transferred = reagents.trans_to(vessel, amount, transfered_by = user)
	if(transferred && !QDELETED(user) && !QDELETED(src) && !QDELETED(vessel))
		user.visible_message(span_notice("[user] sprinkles [src] into [vessel]."), span_notice("I sprinkle [src] into [vessel]."))
	if(!QDELETED(src) && reagents && !reagents.total_volume)
		qdel(src)
	return TRUE

/obj/item/reagent_containers/glass/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Powders and allspice can be sprinkled into this vessel while it is open. Each application adds up to five drams, space permitting.")
