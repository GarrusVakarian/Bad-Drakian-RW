/datum/magic_item
	var/name = "Name of Magical Item Effect"
	var/description = "A MAGICAL ITEM, WOW!"
	var/confirmed_hits_only = FALSE
	var/offensive_cooldown = 0
	var/offensive_trigger_running = FALSE

/datum/magic_item/proc/do_literally_anything_thanks()
	return

/datum/magic_item/proc/try_start_cooldown(mob/living/gate_holder, cooldown_time)
	var/status_id = "[type]"
	if(gate_holder.has_status_effect(/datum/status_effect/debuff/enchantmenttriggered, status_id))
		return FALSE
	gate_holder.apply_status_effect(/datum/status_effect/debuff/enchantmenttriggered, cooldown_time, status_id)
	return TRUE

/datum/magic_item/proc/on_apply(obj/item/i)
	if(confirmed_hits_only)
		RegisterSignal(i, COMSIG_PROJECTILE_ENCHANTMENT_HIT, PROC_REF(projectile_hit))
		RegisterSignal(i, COMSIG_ITEM_ENCHANTMENT_HIT, PROC_REF(on_confirmed_hit))
	else
		RegisterSignal(i, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))
		RegisterSignal(i, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_hit))
	RegisterSignal(i, COMSIG_ITEM_ATTACK_OBJ, PROC_REF(on_hit_structure))
	RegisterSignal(i, COMSIG_ITEM_ATTACK_TURF, PROC_REF(on_hit_turf))
	RegisterSignal(i, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(i, COMSIG_ITEM_PICKUP, PROC_REF(on_pickup))
	RegisterSignal(i, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(i, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_use))
	RegisterSignal(i, COMSIG_ITEM_HIT_RESPONSE, PROC_REF(on_hit_response))
	// If the item is already on a mob, fire on_equip immediately so stat effects apply without re-equip
	if(isliving(i.loc))
		var/mob/living/user = i.loc
		if(user.is_holding(i))
			on_equip(i, user, ITEM_SLOT_HANDS)
		else
			for(var/slot_id in ALL_ITEM_SLOTS)
				if(user.get_item_by_slot(slot_id) == i)
					on_equip(i, user, slot_id)
					break


/datum/magic_item/proc/on_hit(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)	//when enchanted item hits a mob/living, do effect.

/datum/magic_item/proc/on_confirmed_hit(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!valid_offensive_target(user, target))
		return
	trigger_offensive_effect(source, user, target)

/datum/magic_item/proc/valid_offensive_target(mob/living/user, mob/living/target)
	return isliving(user) && isliving(target) && !QDELETED(user) && !QDELETED(target) && user != target && user.stat != DEAD && target.stat != DEAD

// Effect implementations are synchronous. Do not charge failed/immune/no-op applications.
/datum/magic_item/proc/trigger_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	if(!valid_offensive_target(user, target) || offensive_trigger_running || user.has_status_effect(/datum/status_effect/debuff/enchantmenttriggered, "[type]"))
		return FALSE
	offensive_trigger_running = TRUE
	var/applied = apply_offensive_effect(source, user, target)
	offensive_trigger_running = FALSE
	if(!applied || QDELETED(user))
		return FALSE
	try_start_cooldown(user, offensive_cooldown)
	return TRUE

/datum/magic_item/proc/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	return FALSE

/datum/magic_item/proc/apply_offensive_fire(mob/living/target, stacks)
	if("lava" in target.weather_immunities)
		return FALSE
	var/old_stacks = target.fire_stacks
	target.adjust_fire_stacks(stacks)
	target.ignite_mob()
	var/datum/status_effect/fire_handler/fire_stacks/fire = target.has_status_effect(/datum/status_effect/fire_handler/fire_stacks)
	if(istype(fire) && !QDELETED(fire) && fire.on_fire && target.fire_stacks > old_stacks)
		return TRUE
	// Failed ignition must not leave the enchantment's extra fuel behind.
	target.set_fire_stacks(old_stacks)
	return FALSE

/datum/magic_item/proc/on_hit_turf(turf/target, obj/item/I, mob/living/user)		//when enchated item hits a turf, do effect

/datum/magic_item/proc/on_hit_structure(obj/target, obj/item/I, mob/living/user)	//when enchanted item hits structure, do effect

/datum/magic_item/proc/on_equip(obj/item/i, mob/living/user, slot)	//when enchanted item is placed into an equipment slot, do effect

/datum/magic_item/proc/on_pickup(obj/item/i, mob/living/user)		//when enchanted item is picked up, do effect

/datum/magic_item/proc/on_use(obj/item/i, mob/living/user)		//when enchanted item is used in hand, do effect

/datum/magic_item/proc/on_drop(obj/item/i, mob/living/user)		//when enchanted item is dropped, do effect
	addtimer(CALLBACK(src, PROC_REF(drop_effects), i, user), 1)

/datum/magic_item/proc/drop_effects(obj/item/i, mob/living/user)

/datum/magic_item/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)	//effects when shooting a protectile from an enchanted item

/datum/magic_item/proc/on_hit_response(obj/item/I, mob/living/carbon/human/owner, mob/living/carbon/human/attacker)//use for worn items such as armor to have effects on hit.
