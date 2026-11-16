/// CAUTERIZE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/cauterize
	name = "Cauterize"
	desc = "Use the heat of your staff to cauterize someone's wounds."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "cauterize"
	sound = 'sound/surgery/cautery1.ogg'

	range = SPELL_RANGE_ADJACENT
	self_cast_possible = TRUE
	releasedrain = SPELLCOST_MIRACLE_LEGENDARY
	invocation_type = INVOCATION_NONE

	chargetime = 1 SECONDS
	chargedrain = 0

	recharge_time = 1 MINUTES

	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)
	associated_skill = /datum/skill/combat/polearms


/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/cauterize/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/carbon/human/HU = owner
	if(!istype(HU))
		return FALSE

	var/mob/living/spelltarget = cast_on

	if(ishuman(spelltarget))

		var/mob/living/carbon/human/target = spelltarget
		var/def_zone = check_zone(owner.zone_selected)
		var/obj/item/bodypart/affecting = target.get_bodypart(def_zone)

		if(!affecting)
			return FALSE
		if(length(affecting.embedded_objects))
			var/no_embeds = TRUE
			for(var/object in affecting.embedded_objects)
				if(!istype(object, /obj/item/natural/worms/leech))	//Leeches and surgical cheeles are made an exception.
					no_embeds = FALSE
			if(!no_embeds)
				to_chat(owner, span_warning("We cannot cauterize wounds with objects inside this limb!"))
				return FALSE
		var/foundwound = FALSE
		if(length(affecting.wounds))
			for(var/datum/wound/wound in affecting.wounds.Copy())
				if(!QDELETED(wound) && wound.can_cauterize)
					var/wound_name = wound.name
					wound.heal_wound(wound.whp)
					foundwound = TRUE
					owner.visible_message(("<font color = '#FF4500'>[capitalize(wound_name)] cauterizes from the heat of the lamp!</font>"))
					affecting.add_wound(/datum/wound/lampcautery)
					target.adjustFireLoss(10)
			if(foundwound)
				playsound(target, 'sound/surgery/cautery1.ogg', 100, TRUE)
			return TRUE
		else
			to_chat(owner, span_warning("The limb is free of wounds."))
			return FALSE
	return FALSE

/// INFLAMED STRIKE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike
	name = "Inflamed Strike"
	desc = "Twirl your staff infront of you, dealing damage and applying an oil stack. Can be alt cast with the Toggle Oil Ignition ability to activate stacks instead of applying them"
	overlay_state = "flamestrike"
	invocations = list("Burn!", "Ignite!", "Scorch!")
	blade_class = BCLASS_BLUNT
	windup_time = TELEGRAPH_DODGEABLE
	sweep_step = 0
	damage = 20
	parent_type = /obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike

	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	sound = 'sound/misc/fire_place.ogg'
	strike_sound = 'sound/misc/smelter_sound2.ogg'
	glow_intensity = GLOW_INTENSITY_HIGH

	releasedrain = 5
	recharge_time = 10 SECONDS

	telegraph_type = /obj/effect/temp_visual/special_intent/warning
	swipe_state = "flame"
	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)


	var/ignite = FALSE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/get_sweep_bands()
	return list(
		list(list(1, 1)),
		list(list(0, 1)),
		list(list(-1, 1)),
	)

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/get_pattern_offsets()
	var/list/flat = list()
	for(var/list/band in get_sweep_bands())
		flat += band
	return flat

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
	apply_scorch_stack(L, 1)
	var/datum/status_effect/debuff/oil_stack/o = L.has_status_effect(/datum/status_effect/debuff/oil_stack)
	if(ignite && L.has_status_effect(/datum/status_effect/debuff/oil_stack))
		o.activate()
		L.adjustFireLoss(15)
		return
	if(L.has_status_effect(/datum/status_effect/debuff/oil_stack))
		o.add_stacks(1)
		L.adjustFireLoss(15)
	else
		L.adjustFireLoss(15)
		L.apply_status_effect(/datum/status_effect/debuff/oil_stack)
		return

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/proc/toggle_alt_mode(mob/user)
	ignite = !ignite
	if(ignite)
		to_chat(user, span_notice("Inflamed Strike will now activate oil stacks on hit."))
	else
		to_chat(user, span_notice("Inflamed strike will no longer activate oil stacks on hit."))
	update_ignite_maptext()
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firestrike/proc/update_ignite_maptext()
	if(action)
		action.name = "[initial(name)][ignite ? " (Ignite)" : ""]"
		action.button.name = action.name


/// FUEL THE BURN

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firespin
	name = "Fuel The Burn"
	desc = "Twirl your staff around you, engulfing people around you in flame."
	overlay_state = "fuel"
	invocations = list("To cinders!", "To ashes!", "To dust!")
	blade_class = BCLASS_BURN
	windup_time = TELEGRAPH_DODGEABLE
	sweep_step = 0
	damage = 15
	parent_type = /obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	sound = 'sound/misc/fire_place.ogg'
	strike_sound = 'sound/misc/smelter_sound2.ogg'
	glow_intensity = GLOW_INTENSITY_HIGH

	releasedrain = 10
	recharge_time = 15 SECONDS

	telegraph_type = /obj/effect/temp_visual/special_intent/warning
	swipe_state = "flame"
	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firespin/get_sweep_bands()
	return list(
		list(list(1, 1), list(1, 0), list(1, -1)),
		list(list(0, 1), list(0, -1)),
		list(list(-1, 1), list(-1, 0), list(-1, -1)),
	)

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firespin/get_pattern_offsets()
	var/list/flat = list()
	for(var/list/band in get_sweep_bands())
		flat += band
	return flat

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/firespin/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
	apply_scorch_stack(L, 1)
	var/datum/status_effect/debuff/oil_stack/o = L.has_status_effect(/datum/status_effect/debuff/oil_stack)
	if(L.has_status_effect(/datum/status_effect/debuff/oil_stack))
		o.add_stacks(1)
		L.adjustFireLoss(15)
	else
		L.adjustFireLoss(15)
		L.apply_status_effect(/datum/status_effect/debuff/oil_stack)
		return

/// TO BRING LIGHT

#define EMPOWER_FILTER "empower_glow"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/oil_spill
	name = "To Bring Light"
	desc = "Open up your lamptern staff, spilling oil on the next person you strike with it and applying an Oil Stack. Any amount of stacks will apply a stack of scorched, but at five stacks you will apply two stacks of scorched and vulnerable, and at twenty you will apply three stacks and expose the target."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "bringlight"
	sound = 'sound/misc/smelter_sound2.ogg'

	self_cast_possible = TRUE

	releasedrain = 10
	invocations = list()
	invocation_type = INVOCATION_NONE

	recharge_time = 20 SECONDS
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)




/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/oil_spill/cast(list/targets, mob/living/user)
	owner = user
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	if(H.has_status_effect(/datum/status_effect/buff/oil_spill))
		to_chat(H, span_warning("The lamptern is already ready to spill!"))
		return FALSE

	H.apply_status_effect(/datum/status_effect/buff/oil_spill)
	H.visible_message(
		span_danger("[H] opens up their lamptern, ready to splash oil!"),
		span_notice("I open up my lamptern, readying myself to splash oil."))

	return TRUE

// To Bring Light - Buff

/atom/movable/screen/alert/status_effect/buff/oil_spill
	name = "Lamptern Open"
	desc = "My next melee strike will apply an oil stack."
	icon_state = "buff"

/datum/status_effect/buff/oil_spill
	id = "lamptern open"
	alert_type = /atom/movable/screen/alert/status_effect/buff/oil_spill
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/buff/oil_spill/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_AP_MOB_MELEE_HIT, PROC_REF(on_attack))
	owner.add_filter(EMPOWER_FILTER, 2, list("type" = "outline", "color" = "#FF4500", "alpha" = 200, "size" = 2))
	owner.balloon_alert_to_viewers("<font color='#FF4500'>lamptern open!</font>")

/datum/status_effect/buff/oil_spill/on_remove()
	UnregisterSignal(owner, COMSIG_AP_MOB_MELEE_HIT)
	owner.remove_filter(EMPOWER_FILTER)
	. = ..()

/datum/status_effect/buff/oil_spill/proc/on_attack(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	if(!istype(weapon, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter))
		return
	if(!isliving(target) || target == owner || target.stat == DEAD)
		return
	consume_empower(target)
	return

/datum/status_effect/buff/oil_spill/proc/consume_empower(mob/living/hit_target)
	playsound(get_turf(owner), 'sound/misc/fire_place.ogg', 40, TRUE)
	owner.visible_message(
		span_danger("[owner]'s splashes oil forward with their strike!"),
		span_notice("I coat [hit_target] in oil!"))
	owner.remove_status_effect(/datum/status_effect/buff/oil_spill)
	if(!hit_target.has_status_effect(/datum/status_effect/debuff/oil_stack))
		hit_target.apply_status_effect(/datum/status_effect/debuff/oil_stack)
	else
		var/datum/status_effect/debuff/oil_stack/o = hit_target.has_status_effect(/datum/status_effect/debuff/oil_stack)
		o.add_stacks(1)

#undef EMPOWER_FILTER

/// OIL STACKS

/atom/movable/screen/alert/status_effect/debuff/oil_stack
	name = "Oil Stack (0)"
	desc = "I'm covered in oil! If ignited by a Lamplighter I will be afflicted with the first tier of SCORCH. At five stacks I will become vulnerable and afflicted with the second tier, and at twenty stacks I will become EXPOSED and inflicted with the third tier. I can clean the stacks off by washing myself."
	icon_state = "debuff"

/datum/status_effect/debuff/oil_stack
	id = "oil_stack"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/oil_stack
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	var/stacks = 1

/datum/status_effect/debuff/oil_stack/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(cleanse))
	RegisterSignal(owner, COMSIG_ATOM_FIRE_ACT, PROC_REF(activate))
	owner.balloon_alert_to_viewers("<font color='#FF4500'>oil coated!</font>")

/datum/status_effect/debuff/oil_stack/on_remove()
	UnregisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT)
	UnregisterSignal(owner, COMSIG_ATOM_FIRE_ACT)
	. = ..()

/datum/status_effect/debuff/oil_stack/proc/add_stacks(amount)
	var/old_stacks = stacks
	stacks = stacks + amount
	owner.balloon_alert_to_viewers("<font color='#FF4500'>[stacks]</font>")
	if(linked_alert)
		linked_alert.name = "Oil Stack ([stacks])"
	if(stacks == old_stacks)
		return

/datum/status_effect/debuff/oil_stack/proc/cleanse()
	to_chat(owner, span_nicegreen("I'm rid of this oil, finally!"))
	owner.balloon_alert_to_viewers("<font color='#80ff86'>stacks cleansed!</font>")
	owner.remove_status_effect(/datum/status_effect/debuff/oil_stack)

/datum/status_effect/debuff/oil_stack/proc/activate()
	owner.balloon_alert_to_viewers("<font color='#FF4500'>stacks ignited!!</font>")
	if(stacks >= 20)
		owner.apply_status_effect(/datum/status_effect/debuff/exposed)
		apply_scorch_stack(owner, 4)
		owner.remove_status_effect(/datum/status_effect/debuff/oil_stack)
		return
	if(stacks >= 5)
		owner.apply_status_effect(/datum/status_effect/debuff/vulnerable)
		apply_scorch_stack(owner, 3)
		owner.remove_status_effect(/datum/status_effect/debuff/oil_stack)
		return
	else
		apply_scorch_stack(owner, 2)
		owner.remove_status_effect(/datum/status_effect/debuff/oil_stack)
		return

/// ULT - BURN IT ALL DOWN

#define ULT_FILTER "ult_glow"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/burn_it_down
	name = "Burn It All Down"
	desc = "Instantly ignite yourself at <b>maximum fire stacks</b>. For three minutes you are immune to fire damage, then for two minutes after you take half fire damage. For five minutes after casting apply an oil stack for <b>every melee hit</b>. The fire does not end when your immunity does."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "burnall"
	sound = 'sound/misc/smelter_sound2.ogg'

	self_cast_possible = TRUE

	releasedrain = 0
	invocations = list("LETS BURN IT ALL DOWN!!")
	invocation_type = INVOCATION_SHOUT

	recharge_time = 20 MINUTES
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/burn_it_down/cast(list/targets, mob/living/user)
	owner = user
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	H.apply_status_effect(/datum/status_effect/buff/burn_it_down)
	return TRUE

// Burn It Down - Buff

/atom/movable/screen/alert/status_effect/buff/burn_it_down
	name = "BURN IT ALL DOWN!!"
	desc = "LETS DO THIS!!"
	icon_state = "buff"

/datum/status_effect/buff/burn_it_down
	var/downgrade_timer
	id = "burn it down"
	alert_type = /atom/movable/screen/alert/status_effect/buff/burn_it_down
	effectedstats = list(STATKEY_CON = 1, STATKEY_WIL = 2, STATKEY_STR = 2)
	duration = 5 MINUTES // realistically we're only getting 4ish minutes out of this before we die
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/buff/burn_it_down/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_AP_MOB_MELEE_HIT, PROC_REF(on_attack))
	RegisterSignal(owner, COMSIG_LIVING_EXTINGUISHED, PROC_REF(on_extinguish))
	owner.add_filter(ULT_FILTER, 2, list("type" = "outline", "color" = "#FF4500", "alpha" = 200, "size" = 2))
	owner.balloon_alert_to_viewers("<font color='#FF4500'>IGNITED!!</font>")
	downgrade_timer = addtimer(CALLBACK(src, PROC_REF(downgrade)), 3 MINUTES, TIMER_STOPPABLE)
	ADD_TRAIT(owner, TRAIT_AP_FIRE_IMMUNE, "burnitdown")
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "burnitdown")
	ADD_TRAIT(owner, TRAIT_AP_NO_FIRE_DECAY, "burnitdown")
	ADD_TRAIT(owner, TRAIT_NOPAINSTUN, "burnitdown")
	owner.adjust_fire_stacks(20)
	owner.ignite_mob()

/datum/status_effect/buff/burn_it_down/on_remove()
	if(downgrade_timer)
		deltimer(downgrade_timer)
	UnregisterSignal(owner, COMSIG_AP_MOB_MELEE_HIT)
	UnregisterSignal(owner, COMSIG_LIVING_EXTINGUISHED)
	owner.remove_filter(ULT_FILTER)
	REMOVE_TRAIT(owner, TRAIT_AP_FIRE_IMMUNE, "burnitdown")
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, "burnitdown")
	REMOVE_TRAIT(owner, TRAIT_NOPAINSTUN, "burnitdown")
	REMOVE_TRAIT(owner, TRAIT_AP_FIRE_RESIST, "burnitdown")
	REMOVE_TRAIT(owner, TRAIT_AP_NO_FIRE_DECAY, "burnitdown")
	owner.balloon_alert_to_viewers("<font color='#FF4500'>smoldering!</font>")
	. = ..()

/datum/status_effect/buff/burn_it_down/proc/on_extinguish()
	owner.balloon_alert_to_viewers("<font color='#47a7e7'>extinguished!</font>")
	owner.remove_status_effect(/datum/status_effect/buff/burn_it_down)
	return

/datum/status_effect/buff/burn_it_down/proc/downgrade()
	downgrade_timer = null
	if(QDELETED(owner))
		return
	owner.balloon_alert_to_viewers("<font color='#FF4500'>weakening!</font>")
	owner.visible_message(
		span_warningbig("[owner] lets out a scream as their spell weakens!"),
		span_warningbig("My spell weakens, the fires scorch me!"))
	REMOVE_TRAIT(owner, TRAIT_AP_FIRE_IMMUNE, "burnitdown")
	ADD_TRAIT(owner, TRAIT_AP_FIRE_RESIST, "burnitdown")
	return

/datum/status_effect/buff/burn_it_down/proc/on_attack(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	if(!isliving(target) || target == owner || target.stat == DEAD)
		return
	if(!target.has_status_effect(/datum/status_effect/debuff/oil_stack))
		target.apply_status_effect(/datum/status_effect/debuff/oil_stack)
	else
		var/datum/status_effect/debuff/oil_stack/o = target.has_status_effect(/datum/status_effect/debuff/oil_stack)
		o.add_stacks(1)
	return

#undef ULT_FILTER
