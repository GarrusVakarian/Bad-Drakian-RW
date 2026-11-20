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
	desc = "Gain +2 Strength for 45 seconds. When activated above 10 damage, also gain Adrenaline Rush. Above 75 damage, recover energy for 15 seconds. Above 160 damage, also gain +2 Constitution and dismemberment resistance for 45 seconds. Injury bonuses use combined brute and burn damage at activation."
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

/obj/effect/proc_holder/spell/self/rage/proc/get_rage_tier(mob/living/user)
	if(!full_rage)
		return 0
	var/damage = user.getBruteLoss() + user.getFireLoss()
	if(damage > 160)
		return 3
	if(damage > 75)
		return 2
	if(damage > 10)
		return 1
	return 0

/obj/effect/proc_holder/spell/self/rage/cast(list/targets, mob/living/user)
	if(!can_rage(user))
		return FALSE
	var/tier = get_rage_tier(user)
	if(!user.apply_status_effect(/datum/status_effect/buff/rage, tier))
		return FALSE
	if(tier >= 1)
		user.apply_status_effect(/datum/status_effect/buff/adrenaline_rush)
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
	var/energy_until = 0

/datum/status_effect/buff/rage/on_creation(mob/living/new_owner, tier = 0)
	rage_tier = clamp(tier, 0, 3)
	if(!new_owner)
		return ..()
	// The status framework caps and modifies this list, so give every cast its own.
	effectedstats = list(STATKEY_STR = max(0, min(2, 20 - new_owner.get_stat(STATKEY_STR))))
	if(rage_tier >= 3)
		effectedstats[STATKEY_CON] = max(0, min(2, 20 - new_owner.get_stat(STATKEY_CON)))
	return ..()

/datum/status_effect/buff/rage/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(end_rage))
	if(rage_tier >= 2)
		energy_until = world.time + 15 SECONDS
	if(rage_tier >= 3)
		ADD_TRAIT(owner, TRAIT_HARDDISMEMBER, REF(src))
	owner.add_filter("class_rage", 2, list("type" = "outline", "color" = "#ca0000", "alpha" = 120, "size" = 1))
	owner.emote("rage")
	to_chat(owner, span_notice("Fury surges through me. My body is ready to fight!"))
	playsound(owner, 'sound/combat/hits/burn (2).ogg', 100, TRUE)

/datum/status_effect/buff/rage/tick()
	if(world.time < energy_until && owner.stat != DEAD)
		owner.energy_add(5)

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
