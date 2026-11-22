// Adapted from Azure Peak's Rage. Injury bonuses belong to the full ability,
// rather than a permanent trait, so base Rage cannot inherit them accidentally.
/obj/effect/proc_holder/spell/self/rage
	name = "Rage"
	desc = "Enter a furious rage, gaining +2 Strength for 45 seconds."
	action_icon_state = "bcry"
	range = 0
	recharge_time = 1 MINUTES
	associated_skill = null
	human_req = TRUE
	antimagic_allowed = TRUE
	ignore_cockblock = TRUE
	is_cdr_exempt = TRUE
	var/full_rage = FALSE

/obj/effect/proc_holder/spell/self/rage/full
	desc = "Gain +2 Strength for 45 seconds. As combined brute and burn damage rises above 10, gain Adrenaline Rush. Above 75, recover 2% of maximum energy per second for 10 seconds. Above 160, gain dismemberment resistance and heal 2.5 brute and burn damage per second for 10 seconds. Each bonus triggers once. Recovery ends when Rage ends, and healing does not lower your Rage tier."
	full_rage = TRUE

// This is a physical ability. Keep ownership, consciousness and cooldown checks,
// without requiring magicka, speech, free hands or a stationary mount.
/obj/effect/proc_holder/spell/self/rage/proc/can_rage(mob/user)
	if(!ishuman(user) || QDELETED(user) || user.stat || HAS_TRAIT(user, TRAIT_PARALYSIS))
		return FALSE
	if(istype(user.loc, /obj/effect/dummy))
		return FALSE
	if(!(src in user.mind?.spell_list) && !(src in user.mob_spell_list))
		return FALSE
	var/mob/living/carbon/human/H = user
	return !H.has_status_effect(/datum/status_effect/buff/rage)

/obj/effect/proc_holder/spell/self/rage/can_cast(mob/user = usr)
	return can_rage(user) && charge_check(user, TRUE)

/obj/effect/proc_holder/spell/self/rage/cast_check(skipcharge, mob/user = usr)
	if(!can_rage(user))
		to_chat(user, span_warning("I cannot enter a rage right now!"))
		return FALSE
	if(!charge_check(user))
		return FALSE
	if(!skipcharge)
		charge_counter = 0
		last_process_time = world.time
	if(action)
		action.UpdateButtonIcon()
	return TRUE

// The shared recharge method also applies Leyline Haste. Rage always takes a minute.
/obj/effect/proc_holder/spell/self/rage/start_recharge()
	recharge_time = initial(recharge_time)
	last_process_time = world.time
	START_PROCESSING(SSfastprocess, src)

// Shared by the cast and the active status. Only full Rage calls this while active.
/proc/get_rage_damage_tier(mob/living/user)
	var/damage = user.getBruteLoss() + user.getFireLoss()
	if(damage > 160)
		return 3
	if(damage > 75)
		return 2
	if(damage > 10)
		return 1
	return 0

/obj/effect/proc_holder/spell/self/rage/proc/get_rage_tier(mob/living/user)
	return full_rage ? get_rage_damage_tier(user) : 0

/obj/effect/proc_holder/spell/self/rage/cast(list/targets, mob/living/user)
	if(!can_rage(user))
		return FALSE
	var/tier = get_rage_tier(user)
	if(!user.apply_status_effect(/datum/status_effect/buff/rage, tier, full_rage))
		return FALSE
	return ..()

/atom/movable/screen/alert/status_effect/buff/rage
	name = "Rage"
	desc = "Fury lends me strength."
	icon_state = "buff"

/datum/status_effect/buff/rage
	id = "class_rage"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/buff/rage
	examine_text = "SUBJECTPRONOUN is frothing at the mouth!"
	duration = 45 SECONDS
	on_remove_on_mob_delete = TRUE
	var/rage_tier = 0
	var/starting_tier = 0
	var/allow_upgrades = FALSE
	var/rage_ends_at = 0
	var/energy_until = 0
	var/energy_last_tick = 0
	var/healing_until = 0
	var/healing_last_tick = 0

/datum/status_effect/buff/rage/on_creation(mob/living/new_owner, tier = 0, upgrade_with_damage = FALSE)
	starting_tier = clamp(tier, 0, 3)
	allow_upgrades = upgrade_with_damage
	if(!new_owner)
		return ..()
	// The status framework caps and modifies this list, so give every cast its own.
	effectedstats = list(STATKEY_STR = max(0, min(2, 20 - new_owner.get_stat(STATKEY_STR))))
	return ..()

/datum/status_effect/buff/rage/on_apply()
	. = ..()
	if(!.)
		return
	rage_ends_at = world.time + initial(duration)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(end_rage))
	upgrade_tier(starting_tier)
	owner.add_filter("class_rage", 2, list("type" = "outline", "color" = "#ca0000", "alpha" = 120, "size" = 1))
	owner.emote("rage")
	to_chat(owner, span_notice("Fury surges through me. My body is ready to fight!"))
	playsound(owner, 'sound/combat/hits/burn (2).ogg', 100, TRUE)

// Never replace/refresh the status to upgrade it: that would restart Rage,
// repeat recovery and risk reapplying the Strength modifier.
/datum/status_effect/buff/rage/proc/upgrade_tier(new_tier)
	new_tier = clamp(new_tier, 0, 3)
	if(new_tier <= rage_tier)
		return
	var/previous_tier = rage_tier
	rage_tier = new_tier
	if(previous_tier < 1 && rage_tier >= 1)
		owner.apply_status_effect(/datum/status_effect/buff/adrenaline_rush)
	if(previous_tier < 2 && rage_tier >= 2)
		energy_last_tick = world.time
		energy_until = min(world.time + 10 SECONDS, rage_ends_at)
	if(previous_tier < 3 && rage_tier >= 3)
		healing_last_tick = world.time
		healing_until = min(world.time + 10 SECONDS, rage_ends_at)
		ADD_TRAIT(owner, TRAIT_HARDDISMEMBER, REF(src))

/datum/status_effect/buff/rage/tick()
	// The shared processor ticks before checking expiry. Do not grant upgrades or
	// recovery to expired Rage, a dead owner, or an owner being deleted.
	if(QDELETED(owner) || owner.stat == DEAD || world.time >= duration)
		return
	if(allow_upgrades && rage_tier < 3)
		var/new_tier = get_rage_damage_tier(owner)
		if(new_tier > rage_tier)
			upgrade_tier(new_tier)
			to_chat(owner, span_notice("Pain feeds my fury. My rage grows stronger!"))
	// Account for elapsed time so subsystem timing does not lose the last tick
	// or extend either ten-second window. Both stop with their owning Rage.
	var/energy_time = min(world.time, energy_until)
	if(energy_time > energy_last_tick)
		var/seconds = (energy_time - energy_last_tick) / (1 SECONDS)
		energy_last_tick = energy_time
		owner.energy_add(max(0, owner.max_energy) * 0.02 * seconds)
	var/healing_time = min(world.time, healing_until)
	if(healing_time > healing_last_tick)
		var/healing_seconds = (healing_time - healing_last_tick) / (1 SECONDS)
		healing_last_tick = healing_time
		if(owner.getBruteLoss() > 0 || owner.getFireLoss() > 0)
			// Physical damage only. This does not invoke miracle wound, blood,
			// organ, oxygen or toxin treatment, or its shared healing status.
			owner.heal_overall_damage(2.5 * healing_seconds, 2.5 * healing_seconds, 0, BODYPART_ORGANIC)

/datum/status_effect/buff/rage/proc/end_rage()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/buff/rage/proc/clear_rage()
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	REMOVE_TRAIT(owner, TRAIT_HARDDISMEMBER, REF(src))
	owner.remove_filter("class_rage")
	if(!QDELETED(owner))
		to_chat(owner, span_notice("My rage subsides."))

/datum/status_effect/buff/rage/on_remove()
	clear_rage()
	return ..()

/datum/status_effect/buff/rage/be_replaced()
	clear_rage()
	return ..()
