// Spellfist strikes use Drakian's armor, shields, damage and wound rules.
/proc/ap_arcyne_strike(mob/living/user, mob/living/target, obj/item/weapon, damage, zone, blade_class, spell_name)
	if(QDELETED(user) || QDELETED(target) || target.anti_magic_check())
		return AP_STRIKE_BLOCKED
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.check_shields(weapon, damage, spell_name, MELEE_ATTACK))
			return AP_STRIKE_BLOCKED
	zone = check_zone(zone)
	var/blocked = target.run_armor_check(zone, "blunt", damage = damage, blade_dulling = BCLASS_BLUNT)
	var/dealt = target.apply_damage(damage, BRUTE, zone, blocked)
	if(dealt && iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/limb = C.get_bodypart(zone)
		limb?.bodypart_attacked_by(BCLASS_BLUNT, damage * ((100 - blocked) / 100), user, zone, crit_message = TRUE)
	user.do_attack_animation(target)
	log_combat(user, target, "spell-struck with [spell_name]", zone = zone)
	return dealt

/atom/movable/screen/alert/status_effect/buff/ap_arcyne_momentum
	name = "Arcyne Momentum"
	desc = "Landed unarmed strikes build momentum. Stuns and knockdowns break concentration. Unspent power decays."
	icon_state = "buff"

/datum/status_effect/buff/ap_arcyne_momentum
	id = "ap_arcyne_momentum"
	alert_type = /atom/movable/screen/alert/status_effect/buff/ap_arcyne_momentum
	duration = -1
	tick_interval = 2 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	var/stacks = 0
	var/last_melee_gain = -2 SECONDS
	var/last_stack_time = 0
	var/last_decay_time = 0

/datum/status_effect/buff/ap_arcyne_momentum/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_AP_MOB_MELEE_HIT, PROC_REF(on_hit))
	RegisterSignal(owner, list(COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN), PROC_REF(break_concentration))

/datum/status_effect/buff/ap_arcyne_momentum/on_remove()
	UnregisterSignal(owner, list(COMSIG_AP_MOB_MELEE_HIT, COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN))
	owner.remove_filter("ap_momentum")
	return ..()

/datum/status_effect/buff/ap_arcyne_momentum/proc/on_hit(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	if(QDELETED(target) || target == owner || target.stat == DEAD || world.time < last_melee_gain + 2 SECONDS)
		return
	if(weapon)
		if(weapon.associated_skill != /datum/skill/combat/unarmed)
			return
	else if(!istype(user.used_intent, /datum/intent/unarmed/punch))
		return
	last_melee_gain = world.time
	add_stacks(1)

/datum/status_effect/buff/ap_arcyne_momentum/proc/break_concentration()
	SIGNAL_HANDLER
	stacks = 0
	update_alert()

/datum/status_effect/buff/ap_arcyne_momentum/proc/add_stacks(amount)
	stacks = clamp(stacks + amount, 0, 10)
	last_stack_time = world.time
	update_alert()

/datum/status_effect/buff/ap_arcyne_momentum/proc/consume_stacks(amount)
	var/consumed = min(stacks, amount)
	stacks -= consumed
	update_alert()
	return consumed

/datum/status_effect/buff/ap_arcyne_momentum/proc/consume_all_stacks()
	return consume_stacks(stacks)

/datum/status_effect/buff/ap_arcyne_momentum/proc/update_alert()
	if(linked_alert)
		linked_alert.name = "Arcyne Momentum ([stacks]/10)"
	owner.remove_filter("ap_momentum")
	if(stacks >= 3)
		owner.add_filter("ap_momentum", 2, list("type" = "outline", "color" = stacks >= 7 ? "#7b5ea7" : "#4a90d9", "alpha" = 150, "size" = 1))
	owner.balloon_alert(owner, "Momentum: [stacks]/10")

/datum/status_effect/buff/ap_arcyne_momentum/tick()
	if(stacks <= 0 || world.time < last_stack_time + 8 SECONDS || world.time < last_decay_time + 6 SECONDS)
		return
	last_decay_time = world.time
	if(stacks >= 7)
		stacks = 0
		owner.apply_status_effect(/datum/status_effect/debuff/vulnerable, 5 SECONDS)
		to_chat(owner, span_warning("The unspent power lashes back through my body!"))
	else
		stacks--
	update_alert()

/obj/effect/temp_visual/telegraph/air_strike
	parent_type = /obj/effect/temp_visual/special_intent/warning

/obj/effect/proc_holder/spell/invoked/ap_spell/storm_of_psydon
	name = "Storm of Psydon"
	desc = "Close on a foe and unleash three punches and a kick. Requires seven momentum; at ten, unleash nine punches. Targets can block with shields or escape between blows."
	action_icon = 'icons/mob/actions/classuniquespells/spellfist.dmi'
	overlay_state = "storm_of_psydon"
	range = 7
	releasedrain = 50
	chargetime = 1 SECONDS
	recharge_time = 60 SECONDS
	invocation_type = "none"
	associated_skill = /datum/skill/magic/arcane
	var/combining = FALSE

/obj/effect/proc_holder/spell/invoked/ap_spell/storm_of_psydon/can_cast_spell(feedback = TRUE)
	if(!..() || combining)
		return FALSE
	var/datum/status_effect/buff/ap_arcyne_momentum/momentum = owner.has_status_effect(/datum/status_effect/buff/ap_arcyne_momentum)
	if(!momentum || momentum.stacks < 7)
		if(feedback)
			to_chat(owner, span_warning("I need at least seven momentum."))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/storm_of_psydon/cast(list/targets, mob/living/user)
	owner = user
	var/mob/living/target = targets[1]
	var/datum/status_effect/buff/ap_arcyne_momentum/momentum = user.has_status_effect(/datum/status_effect/buff/ap_arcyne_momentum)
	if(!isliving(target) || target == user || !momentum || momentum.stacks < 7 || combining)
		return FALSE
	var/punches = momentum.stacks >= 10 ? 9 : 3
	combining = TRUE
	var/turf/origin = get_turf(user)
	for(var/i in 1 to range)
		if(!combo_valid(user, target, origin.z))
			break
		if(get_dist(user, target) <= 1)
			break
		if(!step_towards(user, target))
			break
		sleep(1)
	if(!combo_valid(user, target, origin.z) || get_dist(user, target) > 1 || target.anti_magic_check())
		combining = FALSE
		return TRUE
	momentum.consume_all_stacks()
	user.visible_message(span_danger("[user] unleashes a storm of blows at [target]!"))
	for(var/i in 1 to punches + 1)
		if(!combo_valid(user, target, origin.z) || get_dist(user, target) > 1)
			break
		if(ap_arcyne_strike(user, target, null, 20, user.zone_selected, BCLASS_BLUNT, "Storm of Psydon") == AP_STRIKE_BLOCKED)
			break
		playsound(target, 'sound/combat/hits/blunt/genblunt (1).ogg', 60, TRUE)
		if(i <= punches)
			sleep(3)
	combining = FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/storm_of_psydon/proc/combo_valid(mob/living/user, mob/living/target, origin_z)
	return !QDELETED(target) && target.stat != DEAD && can_continue(user) && user.z == origin_z && target.z == origin_z && get_dist(user, target) <= range && (target in view(range, user))
