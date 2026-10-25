// Egg forming organs. A penis with egg settings is an ovipositor that implants its clutch into
// a partner on climax; a vagina with egg settings is an egg-laying womb. Both slowly form eggs
// from the owner's nutrition and can lay them through the Lay Eggs verb.

/obj/item/organ
	/// Egg settings from default_oviposition_settings(), null when this organ does not form eggs.
	var/list/egg_settings
	/// Eggs formed and waiting to be laid or implanted.
	var/eggs_stored = 0
	/// world.time the next egg finishes forming.
	var/next_egg_time = 0

/obj/item/organ/proc/set_egg_settings(list/new_settings)
	egg_settings = islist(new_settings) ? sanitize_oviposition_settings(new_settings) : null
	if(!egg_settings)
		eggs_stored = 0
		return
	eggs_stored = min(eggs_stored, egg_settings["clutch"])

/obj/item/organ/proc/get_oviposition_location_name()
	return name

/obj/item/organ/proc/process_egg_production()
	if(!egg_settings || !owner || owner.stat == DEAD)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.grant_egg_verbs()
	if(!next_egg_time)
		next_egg_time = world.time + OVI_EGG_FORM_TIME
		return
	if(world.time < next_egg_time)
		return
	next_egg_time = world.time + OVI_EGG_FORM_TIME
	var/clutch = egg_settings["clutch"]
	if(eggs_stored >= clutch)
		return
	if(owner.nutrition < NUTRITION_LEVEL_STARVING + OVI_EGG_NUTRITION_COST)
		if(prob(25))
			to_chat(owner, span_warning("My [get_oviposition_location_name()] aches faintly. I need to eat before I can form more eggs."))
		return
	owner.adjust_nutrition(-OVI_EGG_NUTRITION_COST)
	eggs_stored++
	if(eggs_stored >= clutch)
		to_chat(owner, span_love("My [get_oviposition_location_name()] feels heavy and full. A clutch is ready."))

/// Lays every stored egg onto the owner's turf. Returns how many were laid.
/obj/item/organ/proc/lay_stored_eggs()
	if(!owner || eggs_stored <= 0)
		return 0
	var/list/appearances = list()
	for(var/i in 1 to eggs_stored)
		appearances += list(get_oviposition_egg_appearance(egg_settings, owner))
	eggs_stored = 0
	return spawn_oviposition_eggs(owner, appearances)

/obj/item/organ/penis/on_life()
	. = ..()
	process_egg_production()

/obj/item/organ/penis/get_oviposition_location_name()
	return "ovipositor"

/// Implants as much of the stored clutch as the host has room for. Returns how many were implanted.
/obj/item/organ/penis/proc/implant_eggs(mob/living/carbon/human/host)
	if(!egg_settings || !owner || eggs_stored <= 0 || !istype(host) || host == owner)
		return 0
	if(!host.accepts_oviposition())
		return 0
	var/datum/component/implanted_eggs/carried = host.GetComponent(/datum/component/implanted_eggs)
	if(!carried)
		carried = host.AddComponent(/datum/component/implanted_eggs)
	var/room = OVI_HOST_MAX_EGGS - length(carried.eggs)
	if(room <= 0)
		to_chat(owner, span_warning("[host] is already too full of eggs to take any more."))
		return 0
	var/count = min(eggs_stored, room)
	for(var/i in 1 to count)
		carried.add_egg(get_oviposition_egg_appearance(egg_settings, owner))
	eggs_stored -= count
	var/egg_text = count == 1 ? "an egg" : "[count] eggs"
	owner.visible_message(span_love("[owner] pumps [egg_text] deep into [host]!"), span_love("I pump [egg_text] deep into [host]!"))
	to_chat(host, span_love("I feel [egg_text] settle heavily inside me."))
	return count

/obj/item/organ/vagina/on_life()
	. = ..()
	process_egg_production()

/obj/item/organ/vagina/get_oviposition_location_name()
	return "womb"

/// Called from cum_into() once per climax. Ovipositors implant into whoever took the load.
/datum/sex_controller/proc/modular_try_oviposit(mob/living/carbon/human/receiver, oral, orifice)
	if(oral || !orifice || !istype(receiver) || receiver == user)
		return
	var/obj/item/organ/penis/ovipositor = user.getorganslot(ORGAN_SLOT_PENIS)
	if(!ovipositor?.egg_settings || ovipositor.eggs_stored <= 0)
		return
	ovipositor.implant_eggs(receiver)

/// Called from ejaculate() when climaxing without a partner. Any formed clutch drops out.
/datum/sex_controller/proc/modular_lay_eggs_on_climax()
	var/laid = 0
	for(var/slot in list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/egg_organ = user.getorganslot(slot)
		if(egg_organ?.egg_settings)
			laid += egg_organ.lay_stored_eggs()
	if(laid)
		var/egg_text = laid == 1 ? "an egg" : "[laid] eggs"
		user.visible_message(span_love("[user] lays [egg_text]!"), span_love("I lay [egg_text]!"))

/mob/living/carbon/human/proc/accepts_oviposition()
	return !!client?.prefs?.accept_oviposition
