#define PHOENIX_GUARD_COOLDOWN 60 SECONDS
#define FROSTVEIL_COOLDOWN 20 SECONDS
#define LIGHTNING_COOLDOWN 40 SECONDS
#define LIFESTEAL_COOLDOWN 10 SECONDS
#define VOIDTOUCHED_COOLDOWN 10 SECONDS
///T3 Enchantmentsdatum
/datum/magic_item/greater/lifesteal
	confirmed_hits_only = TRUE
	offensive_cooldown = LIFESTEAL_COOLDOWN
	name = "life steal"
	description = "It seems bloodthirsty."
	var/flat_heal = 25
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)
	var/warned = FALSE

/datum/magic_item/greater/lifesteal/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	return trigger_offensive_effect(fired_from, firer, target)

/datum/magic_item/greater/lightning
	confirmed_hits_only = TRUE
	offensive_cooldown = LIGHTNING_COOLDOWN
	name = "lightning"
	description = "It has small arcs of electricity dance across it"

/datum/magic_item/greater/frostveil
	confirmed_hits_only = TRUE
	offensive_cooldown = FROSTVEIL_COOLDOWN
	name = "frostveil"
	description = "It feels rather cold."

/datum/magic_item/greater/frostveil/on_hit_response(obj/item/I, mob/living/carbon/human/owner, mob/living/carbon/human/attacker)
	if(!try_start_cooldown(owner, FROSTVEIL_COOLDOWN))
		return
	if(isliving(attacker) && attacker != owner)
		attacker.apply_status_effect(/datum/status_effect/debuff/cold)
		attacker.visible_message(span_danger("[I] chills [attacker]!"))

/datum/magic_item/greater/phoenixguard
	name = "phoenixguard"
	description = "It gives off radiant heat."
	var/last_used

/datum/magic_item/greater/phoenixguard/on_hit_response(obj/item/I, mob/living/carbon/human/owner, mob/living/carbon/human/attacker)
	if(!try_start_cooldown(owner, PHOENIX_GUARD_COOLDOWN))
		return
	if(isliving(attacker) && attacker != owner)
		attacker.adjust_fire_stacks(5)
		attacker.ignite_mob()
		attacker.visible_message(span_danger("[I] sets [attacker] on fire!"))

/datum/magic_item/greater/woundclosing
	name = "wound closing"
	description = "It pulses with healing magick."
	var/active_item = FALSE

/datum/magic_item/greater/woundclosing/on_equip(obj/item/i, mob/living/user, slot)
	if(slot == ITEM_SLOT_HANDS)
		return
	if(active_item)
		return
	else
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/wound_closure)
		to_chat(user, span_notice("[i] feels warm against fingers."))
		active_item = TRUE

/datum/magic_item/greater/woundclosing/on_drop(obj/item/i, mob/living/user)
	if(active_item)
		active_item = FALSE
		user.mind.RemoveSpell(/obj/effect/proc_holder/spell/invoked/wound_closure)
		to_chat(user, span_notice("The warmth of [i] fades away."))

/datum/magic_item/greater/returningweapon
	name = "returning weapon"
	description = "It glows with arcane sigils."
	var/active_item = FALSE

/datum/magic_item/greater/returningweapon/on_equip(obj/item/i, mob/living/user, slot)
	if(slot == ITEM_SLOT_HANDS)
		return
	if(active_item)
		return
	else
		active_item = TRUE
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/summonweapon)
		to_chat(user, span_notice("I feel the magick within [i] resonate with my own."))

/datum/magic_item/greater/returningweapon/on_drop(obj/item/i, mob/living/user)
	if(active_item)
		user.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/summonweapon)
		to_chat(user, span_notice("the warmth of [i] fades away."))
		active_item = FALSE

/datum/magic_item/greater/sharpshooter
	name = "sharpshooting"
	description = "It has the imprint of a bowstring."
	var/active_item = FALSE
	var/masterbow = FALSE
	var/legendbow = FALSE
	var/mastercrossbow = FALSE
	var/legendcrossbow = FALSE
	var/mastersling = FALSE
	var/legendsling = FALSE

/datum/magic_item/greater/sharpshooter/on_equip(obj/item/i, mob/living/user, slot)
	if(slot == ITEM_SLOT_HANDS)
		return
	if(active_item)
		return
	else
		//stat boost
		user.change_stat(STATKEY_PER, 2)

		//Bow boost
		if (user.get_skill_level(/datum/skill/combat/bows) == 6)
			legendbow = TRUE
			masterbow = FALSE
		else
			if (user.get_skill_level(/datum/skill/combat/bows) == 5)
				user.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
				masterbow = TRUE
			else
				user.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)

		//crossbow boost
		if (user.get_skill_level(/datum/skill/combat/crossbows) == 6)
			legendcrossbow = TRUE
			mastercrossbow = FALSE
		else
			if (user.get_skill_level(/datum/skill/combat/crossbows) == 5)
				user.adjust_skillrank(/datum/skill/combat/crossbows, 1, TRUE)
				mastercrossbow = TRUE
			else
				user.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)

		//sling boost
		if (user.get_skill_level(/datum/skill/combat/slings) == 6)
			legendsling = TRUE
			mastersling = FALSE
		else
			if (user.get_skill_level(/datum/skill/combat/slings) == 5)
				user.adjust_skillrank(/datum/skill/combat/slings, 1, TRUE)
				mastersling = TRUE
			else
				user.adjust_skillrank(/datum/skill/combat/slings, 2, TRUE)

		to_chat(user, span_notice("I feel more dexterious!"))
		active_item = TRUE

/datum/magic_item/greater/sharpshooter/on_drop(obj/item/i, mob/living/user)
	if(active_item)
		active_item = FALSE
		user.change_stat(STATKEY_PER, -2)
		//correct bows
		if (!legendbow)
			if (masterbow)
				user.adjust_skillrank(/datum/skill/combat/bows -1, TRUE)
			else
				user.adjust_skillrank(/datum/skill/combat/bows, -2, TRUE)

		//correct crossbows
		if (!legendcrossbow)
			if (mastercrossbow)
				user.adjust_skillrank(/datum/skill/combat/crossbows -1, TRUE)
			else
				user.adjust_skillrank(/datum/skill/combat/crossbows, -2, TRUE)

		//correct slings
		if (!legendsling)
			if (mastersling)
				user.adjust_skillrank(/datum/skill/combat/slings -1, TRUE)
			else
				user.adjust_skillrank(/datum/skill/combat/slings, -2, TRUE)

		to_chat(user, span_notice("I feel mundane once more"))

/datum/magic_item/greater/void
	confirmed_hits_only = TRUE
	offensive_cooldown = VOIDTOUCHED_COOLDOWN
	name = "void touched"
	description = "It seems to absorb light around it, existing partially outside reality."
	var/list/last_used = list()

/datum/magic_item/greater/lifesteal/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	var/damage_before = user.getBruteLoss() + user.getFireLoss() + user.getOxyLoss()
	user.heal_ordered_damage(flat_heal, damage_heal_order)
	if(user.getBruteLoss() + user.getFireLoss() + user.getOxyLoss() >= damage_before)
		return FALSE
	user.visible_message(span_danger("[source] drains life from [target]!"))
	return TRUE

/datum/magic_item/greater/lightning/proc/shock_target(mob/living/target)
	var/health_before = target.health
	if(!target.electrocute_act(1, src, 1, SHOCK_NOSTUN) || target.health >= health_before)
		return FALSE
	target.Immobilize(0.5 SECONDS)
	target.apply_status_effect(/datum/status_effect/debuff/clickcd, 6 SECONDS)
	target.apply_status_effect(/datum/status_effect/buff/lightningstruck, 6 SECONDS)
	return TRUE

/datum/magic_item/greater/lightning/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	if(!shock_target(target))
		return FALSE
	for(var/mob/living/nearby in range(2, target))
		if(nearby == target || nearby == user || nearby.stat == DEAD)
			continue
		if(prob(30) && shock_target(nearby))
			new /obj/effect/temp_visual/lightning(get_turf(target), get_turf(nearby))
	return TRUE

/datum/magic_item/greater/frostveil/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	var/datum/status_effect/debuff/cold/applied = target.apply_status_effect(/datum/status_effect/debuff/cold)
	if(!istype(applied) || QDELETED(applied))
		return FALSE
	target.visible_message(span_danger("[source] chills [target]!"))
	return TRUE

/datum/magic_item/greater/void/apply_offensive_effect(obj/item/source, mob/living/user, mob/living/target)
	var/turf/origin = get_turf(target)
	if(!origin)
		return FALSE
	var/list/possible_turfs = list()
	for(var/turf/T in range(3, origin))
		if(T.density || T == origin)
			continue
		possible_turfs += T
	if(!length(possible_turfs))
		return FALSE
	target.forceMove(pick(possible_turfs))
	if(get_turf(target) == origin)
		return FALSE
	to_chat(target, span_warning("You feel reality warp around you!"))
	return TRUE

#undef PHOENIX_GUARD_COOLDOWN
#undef FROSTVEIL_COOLDOWN
#undef LIGHTNING_COOLDOWN
#undef LIFESTEAL_COOLDOWN
#undef VOIDTOUCHED_COOLDOWN
