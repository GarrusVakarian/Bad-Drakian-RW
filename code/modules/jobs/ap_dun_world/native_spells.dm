// Native spell entry points for the abilities brought over with AP's classes.
/obj/effect/proc_holder/spell/invoked/ap_spell
	var/mob/living/owner
	var/list/required_items
	var/self_cast_possible = TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/on_gain(mob/living/user)
	. = ..()
	owner = user

/obj/effect/proc_holder/spell/invoked/ap_spell/cast_check(skipcharge, mob/user = usr)
	owner = user
	if(length(required_items))
		var/found_item = FALSE
		for(var/obj/item/held in user.held_items)
			if(is_type_in_list(held, required_items))
				found_item = TRUE
				break
		if(!found_item)
			to_chat(user, span_warning("I need to hold the right implement to use [name]."))
			return FALSE
	if(!can_cast_spell())
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/invoked/ap_spell/proc/can_cast_spell(feedback = TRUE)
	return owner && !QDELETED(owner) && owner.stat == CONSCIOUS

/obj/effect/proc_holder/spell/invoked/ap_spell/proc/is_valid_target(atom/target)
	return target && owner && target.z == owner.z && get_dist(owner, target) <= range

/obj/effect/proc_holder/spell/invoked/ap_spell/proc/StartCooldown(override_time)
	charge_counter = isnull(override_time) ? 0 : max(0, recharge_time - override_time)
	start_recharge()

/obj/effect/proc_holder/spell/invoked/ap_spell/proc/can_continue(mob/living/user)
	if(QDELETED(user) || user.stat != CONSCIOUS || !isturf(user.loc))
		return FALSE
	if(!check_cast_requirements(TRUE, user, FALSE))
		return FALSE
	if(length(required_items))
		for(var/obj/item/held in user.held_items)
			if(is_type_in_list(held, required_items))
				return TRUE
		return FALSE
	return TRUE
