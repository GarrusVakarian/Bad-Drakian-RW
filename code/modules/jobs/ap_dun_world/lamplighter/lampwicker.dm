// Scare Beast

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/scare_beast
	name = "Scare Beast"
	desc = "Wave your staff towards a beast, sending fear into its heart with biting flames! This will only work against the Mindless."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "scarebeast"
	sound = 'sound/misc/smelter_sound3.ogg'

	self_cast_possible = TRUE

	releasedrain = SPELLCOST_CONJURE
	invocations = list("Flee!")
	invocation_type = INVOCATION_SHOUT

	recharge_time = 10 SECONDS
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/scare_beast/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/spelltarget = cast_on
	if(!isliving(cast_on))
		to_chat(owner, span_warning("That won't work."))
		return FALSE
	if(!spelltarget.mind && spelltarget.ai_controller)
		spelltarget.ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEE_TARGET, owner)
		spelltarget.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, owner)
		spelltarget.ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, TRUE)
		spelltarget.ai_controller.CancelActions()
		addtimer(CALLBACK(src, PROC_REF(end_fear), spelltarget), 10 SECONDS)
		return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/scare_beast/proc/end_fear(mob/living/target)
	if(QDELETED(target) || !target.ai_controller)
		return
	target.ai_controller.CancelActions()
	target.ai_controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, FALSE)
	return

// Soothe the Soul

#define SOOTHE_FILTER "soothe_glow"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/sooth_the_soul
	name = "Soothe the Soul"
	desc = "Surround yourself or your target with soothing warmth, restoring their energy for thirty seconds."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "soothe"
	sound = 'sound/misc/smelter_sound3.ogg'

	self_cast_possible = TRUE

	releasedrain = SPELLCOST_CONJURE
	invocations = list()
	invocation_type = INVOCATION_NONE

	recharge_time = 2 MINUTES
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/sooth_the_soul/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/spelltarget = cast_on
	spelltarget.apply_status_effect(/datum/status_effect/buff/sooth_the_soul)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/sooth_the_soul
	name = "Soothe the Soul"
	desc = "Comforting warmth restores my energy."
	icon_state = "buff"

/datum/status_effect/buff/sooth_the_soul
	id = "soothe the soul"
	alert_type = /atom/movable/screen/alert/status_effect/buff/sooth_the_soul
	duration = 40 SECONDS
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/buff/sooth_the_soul/on_apply()
	. = ..()
	owner.add_filter(SOOTHE_FILTER, 2, list("type" = "outline", "color" = "#ff7300", "alpha" = 60, "size" = 1))

/datum/status_effect/buff/sooth_the_soul/on_remove()
	owner.remove_filter(SOOTHE_FILTER)
	. = ..()

/datum/status_effect/buff/sooth_the_soul/tick()
	owner.energy_add(5)

#undef SOOTHE_FILTER

// Bulwark of Oil

#define BULWARK_FILTER "bulwark_glow"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/bulwark_of_oil
	name = "Bulwark of Oil"
	desc = "Surround yourself or your target with a wreath of burning oil, intercepting three attacks and applying an oil stack and ten burn damage to the attacker."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "oilshield"
	sound = 'sound/misc/smelter_sound2.ogg'

	self_cast_possible = TRUE

	releasedrain = SPELLCOST_UTILITY_BUFF
	invocations = list()
	invocation_type = INVOCATION_NONE

	recharge_time = 90 SECONDS
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/bulwark_of_oil/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	if(!isliving(cast_on))
		return FALSE
	var/mob/living/spelltarget = cast_on
	spelltarget.apply_status_effect(/datum/status_effect/buff/bulwark_of_oil)
	return TRUE

// Bulwark of Oil - Buff

/atom/movable/screen/alert/status_effect/buff/bulwark_of_oil
	name = "Bulwark of Oil"
	desc = "I will be shielded from three melee attacks, each doing ten burn damage and applying an oil stack to the attacker."
	icon_state = "buff"

/datum/status_effect/buff/bulwark_of_oil
	id = "bulwark of oil"
	alert_type = /atom/movable/screen/alert/status_effect/buff/bulwark_of_oil
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_UNIQUE
	var/defend = 3

/datum/status_effect/buff/bulwark_of_oil/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_ITEM_BEING_ATTACKED, PROC_REF(weapon_defend))
	RegisterSignal(owner, COMSIG_MOB_ATTACKED_BY_HAND, PROC_REF(unarmed_defend))
	owner.add_filter(BULWARK_FILTER, 2, list("type" = "outline", "color" = "#ff7300", "alpha" = 100, "size" = 2))
	owner.balloon_alert_to_viewers("<font color='#FF4500'>oil bulwark!</font>")

/datum/status_effect/buff/bulwark_of_oil/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_ITEM_BEING_ATTACKED)
	UnregisterSignal(owner, COMSIG_MOB_ATTACKED_BY_HAND)
	owner.remove_filter(BULWARK_FILTER)
	. = ..()

/datum/status_effect/buff/bulwark_of_oil/proc/weapon_defend(mob/living/source, mob/living/target, mob/living/user, obj/item/weapon)
	SIGNAL_HANDLER
	if(block_attack(user, TRUE))
		return COMPONENT_ITEM_NO_ATTACK

/datum/status_effect/buff/bulwark_of_oil/proc/unarmed_defend(mob/living/source, mob/living/attacker, mob/living/defender)
	SIGNAL_HANDLER
	if(block_attack(attacker))
		return COMPONENT_HAND_NO_ATTACK

/datum/status_effect/buff/bulwark_of_oil/proc/block_attack(mob/living/attacker, scorch = FALSE)
	if(!isliving(attacker) || attacker == owner || defend <= 0)
		return FALSE
	attacker.adjustFireLoss(10)
	if(scorch)
		apply_scorch_stack(attacker, 1)
	var/datum/status_effect/debuff/oil_stack/oil = attacker.has_status_effect(/datum/status_effect/debuff/oil_stack)
	if(oil)
		oil.add_stacks(1)
	else
		attacker.apply_status_effect(/datum/status_effect/debuff/oil_stack)
	defend--
	owner.balloon_alert_to_viewers("Blocked! [defend]/3")
	playsound(owner, 'sound/combat/clash_struck.ogg', 40, TRUE)
	if(defend <= 0)
		qdel(src)
	return TRUE

#undef BULWARK_FILTER

// Smoke Food

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/smoke_food
	name = "Smoke Food"
	desc = "Smoke food with your lamptern, increasing its lifespan."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "smokefood"
	sound = 'sound/misc/smelter_sound2.ogg'

	self_cast_possible = TRUE

	releasedrain = SPELLCOST_UTILITY_BUFF
	invocations = list()
	invocation_type = INVOCATION_NONE

	recharge_time = 90 SECONDS
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/smoke_food/cast(list/targets, mob/living/user)
	owner = user
	var/atom/cast_on = targets[1]
	. = ..()
	if(!istype(cast_on, /obj/item/reagent_containers/food/snacks))
		to_chat(owner, span_warning("That is not food."))
		return FALSE

	var/obj/item/reagent_containers/food/snacks/food = cast_on

	if(!food.rotprocess)
		to_chat(owner, span_warning("[food] does not spoil."))
		return FALSE

	// Same as chill food, but we use fire. Waow.
	food.warming += 15 MINUTES
	food.add_filter("smokefood_glow", 2, list("type" = "outline", "color" = "#5c362f", "alpha" = 150, "size" = 1))
	new /obj/effect/temp_visual/small_smoke(get_turf(food))
	owner.visible_message(span_notice("[owner] holds their lamptern to [food]. The heat and smoke from the lamptern preserving the food."), span_notice("I smoke [food] with my lamptern."))
	return TRUE

// Anoint Foe

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe
	name = "Anoint Foe"
	desc = "Swing your staff forward, splashing oil in an arc and applying 2 oil stacks. Can be alt cast to open the lamptern instead and activate the oil stacks of those it hits. Any amount of stacks will apply a stack of scorched, but at five stacks you will apply two stacks of scorched and vulnerable, and at twenty you will apply three stacks and expose the target."
	overlay_state = "oilsplash"
	invocations = list("Splash!")
	blade_class = BCLASS_BURN
	windup_time = TELEGRAPH_DODGEABLE
	sweep_step = 0
	damage = 15
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

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/get_sweep_bands()
	return list(
		list(list(0, 1), list(0, 2)),
	)

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/get_pattern_offsets()
	var/list/flat = list()
	for(var/list/band in get_sweep_bands())
		flat += band
	return flat

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/on_hit_target(mob/living/carbon/human/H, mob/living/L, facing)
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

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/proc/toggle_alt_mode(mob/user)
	ignite = !ignite
	if(ignite)
		to_chat(user, span_notice("Anoint foe will now activate oil stacks on hit."))
	else
		to_chat(user, span_notice("Anoint foe will no longer activate oil stacks on hit."))
	update_ignite_maptext()
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/anoint_foe/proc/update_ignite_maptext()
	if(action)
		action.name = "[initial(name)][ignite ? " (Ignite)" : ""]"
		action.button.name = action.name


// Light the Wicks

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/wicklight
	name = "Light the Wicks"
	desc = "Ignite flammables within seven paces of yourself. Be careful."
	overlay_state = "wicks"
	invocations = list("Light!")
	parent_type = /obj/effect/proc_holder/spell/invoked/ap_spell/telegraphed_strike
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	sound = 'sound/misc/fire_place.ogg'
	strike_sound = 'sound/misc/smelter_sound2.ogg'
	glow_intensity = GLOW_INTENSITY_HIGH

	releasedrain = SPELLCOST_MINOR_AOE
	recharge_time = 30 SECONDS
	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/wicklight/cast(list/targets, mob/living/user)
	owner = user
	. = ..()

	if(!ishuman(owner))
		return FALSE

	for(var/obj/O in range(7, owner))
		if(istype(O, /obj/item/flashlight/flare/torch/lantern/psycenser))
			continue
		if(istype(O, /obj/structure/flora)) // lets not burn the WHOLE forest down
			continue
		O.spark_act()

	for(var/obj/structure/flora/F in range(3, owner)) // But we can burn a little forest down as a treat
		F.spark_act()

	for(var/mob/M in range(7, owner))
		for(var/obj/O in M.contents)
			if(istype(O, /obj/item/flashlight/flare/torch/lantern/psycenser))
				continue
			O.spark_act()
	owner.visible_message(span_red("[owner] releases a flickering wave of heat that ignites flammables around them!"))
	return TRUE

// ULT - Provide Beacon

#define PROVIDE_BEACON_SLOWDOWN_ID "beacon_slowdown"
#define BEACON_FILTER "beacon_filter"

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/provide_beacon
	name = "Provide Beacon"
	desc = "Raise your lamptern high, taking fire stacks every five seconds over the course of forty seconds, every five seconds anyone around you regenerates energy. You do NOT gain resistance against the fire, be ready to pat the flames out."
	action_icon = 'icons/mob/actions/classuniquespells/lamplighter.dmi'
	overlay_state = "beacon"
	sound = 'sound/misc/smelter_sound2.ogg'

	self_cast_possible = TRUE

	releasedrain = 0
	invocations = list("Come to the light!")
	invocation_type = INVOCATION_SHOUT

	recharge_time = 10 MINUTES
	spell_tier = 1

	associated_skill = /datum/skill/combat/polearms
	required_items = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden, /obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter)



	var/channel_duration = 40 SECONDS
	var/pulse_interval = 5 SECONDS
	var/channel_slowdown = 3
	var/beacon_range = 7

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/provide_beacon/cast(list/targets, mob/living/user)
	owner = user
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/end_time = world.time + channel_duration

	H.visible_message(span_danger("<b>[H] unleashes a wave of restoring warmth!</b>"))
	playsound(get_turf(H), 'sound/misc/smelter_sound3.ogg', 100, TRUE)
	H.add_movespeed_modifier(PROVIDE_BEACON_SLOWDOWN_ID, update = TRUE, priority = 100, multiplicative_slowdown = channel_slowdown, movetypes = GROUND)
	H.add_filter(BEACON_FILTER, 2, list("type" = "outline", "color" = "#ff7300", "alpha" = 100, "size" = 2))
	StartCooldown(recharge_time)

	while(world.time < end_time)
		if(!channel_valid(H))
			end_channel(H, TRUE)
			return TRUE

		fire_pulse(H)
		H.adjust_fire_stacks(5)
		H.ignite_mob()
		H.balloon_alert_to_viewers("<font color='#FF4500'>channeling!</font>")
		playsound(get_turf(H), 'sound/misc/smelter_sound3.ogg', 100, TRUE)

		sleep(pulse_interval)

	end_channel(H, FALSE)
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/provide_beacon/proc/end_channel(mob/living/carbon/human/H, interrupted)
	if(H)
		H.remove_movespeed_modifier(PROVIDE_BEACON_SLOWDOWN_ID)
		H.remove_filter(BEACON_FILTER)
	if(interrupted)
		if(H)
			to_chat(H, span_warning("My beacon falters!"))
			H.balloon_alert_to_viewers("<font color='#FF4500'>interrupted!</font>")

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/provide_beacon/proc/channel_valid(mob/living/carbon/human/H)
	if(QDELETED(H))
		return FALSE
	if(H.stat != CONSCIOUS)
		return FALSE
	if(!can_continue(H) || H.IsParalyzed() || H.IsStun() || H.IsKnockdown() || H.IsUnconscious())
		return FALSE
	if(H.pulledby)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/lamplighter/provide_beacon/proc/fire_pulse(mob/living/carbon/human/H)
	for(var/mob/living/carbon/human/human in view(7, get_turf(owner)))
		human.energy_add(100)
	return

#undef BEACON_FILTER
#undef PROVIDE_BEACON_SLOWDOWN_ID
