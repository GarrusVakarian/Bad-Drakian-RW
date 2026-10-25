// Eggs implanted into a host by an ovipositor. They incubate for a while, after which the host
// can lay them with the Lay Eggs verb. Left too long, the host's body pushes them out on its own.

/datum/component/implanted_eggs
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Each entry is an appearance list from get_oviposition_egg_appearance() plus "ripe_at".
	var/list/eggs = list()
	/// Whether the host has been told their eggs are ready.
	var/announced_ripe = FALSE

/datum/component/implanted_eggs/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/carbon/human/host = parent
	host.grant_egg_verbs()

/datum/component/implanted_eggs/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_LIFE, PROC_REF(handle_life))

/datum/component/implanted_eggs/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_LIFE)

/datum/component/implanted_eggs/proc/add_egg(list/appearance)
	appearance["ripe_at"] = world.time + OVI_INCUBATION_TIME
	eggs += list(appearance)
	announced_ripe = FALSE

/datum/component/implanted_eggs/proc/get_ripe_eggs()
	. = list()
	for(var/list/egg as anything in eggs)
		if(world.time >= egg["ripe_at"])
			. += list(egg)

/datum/component/implanted_eggs/proc/handle_life(datum/source, seconds, times_fired)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/host = parent
	if(host.stat == DEAD)
		return
	var/list/ripe = get_ripe_eggs()
	if(!length(ripe))
		return
	if(!announced_ripe)
		announced_ripe = TRUE
		to_chat(host, span_love("The eggs inside me shift and settle low. They're ready to be laid."))
		return
	for(var/list/egg as anything in ripe)
		if(world.time >= egg["ripe_at"] + OVI_OVERDUE_TIME)
			var/laid = lay_ripe_eggs()
			var/egg_text = laid == 1 ? "an egg" : "[laid] eggs"
			host.visible_message(span_love("[host] shudders as [egg_text] slip out of [host.p_them()]!"), span_love("My body can't hold them any longer - I lay [egg_text]!"))
			return

/// Drops every ripe egg onto the host's turf. Deletes the component once empty. Returns how many were laid.
/datum/component/implanted_eggs/proc/lay_ripe_eggs()
	var/list/ripe = get_ripe_eggs()
	if(!length(ripe))
		return 0
	eggs -= ripe
	. = spawn_oviposition_eggs(parent, ripe)
	if(!length(eggs))
		qdel(src)

/mob/living/carbon/human/proc/grant_egg_verbs()
	if(/mob/living/carbon/human/proc/lay_eggs in verbs)
		return
	verbs += /mob/living/carbon/human/proc/lay_eggs
	verbs += /mob/living/carbon/human/proc/check_eggs

/mob/living/carbon/human/proc/lay_eggs()
	set name = "Lay Eggs"
	set category = "IC"

	if(stat || incapacitated())
		return
	var/datum/component/implanted_eggs/carried = GetComponent(/datum/component/implanted_eggs)
	var/list/egg_organs = list()
	for(var/slot in list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/egg_organ = getorganslot(slot)
		if(egg_organ?.egg_settings && egg_organ.eggs_stored > 0)
			egg_organs += egg_organ
	if(!length(egg_organs) && !length(carried?.get_ripe_eggs()))
		to_chat(src, span_warning("I have no eggs ready to lay."))
		return
	visible_message(span_love("[src] squats down and begins to strain."), span_love("I squat down and begin to push."))
	if(!do_after(src, OVI_LAY_TIME, needhand = FALSE, target = src))
		return
	var/laid = 0
	for(var/obj/item/organ/egg_organ as anything in egg_organs)
		laid += egg_organ.lay_stored_eggs()
	carried = GetComponent(/datum/component/implanted_eggs)
	if(carried)
		laid += carried.lay_ripe_eggs()
	if(!laid)
		return
	var/egg_text = laid == 1 ? "an egg" : "[laid] eggs"
	visible_message(span_love("[src] lays [egg_text]!"), span_love("I lay [egg_text]!"))
	playsound(src, 'sound/misc/mat/endout.ogg', 30, TRUE, ignore_walls = FALSE)

/mob/living/carbon/human/proc/check_eggs()
	set name = "Check Eggs"
	set category = "IC"

	var/list/report = list()
	for(var/slot in list(ORGAN_SLOT_PENIS, ORGAN_SLOT_VAGINA))
		var/obj/item/organ/egg_organ = getorganslot(slot)
		if(!egg_organ?.egg_settings)
			continue
		var/clutch = egg_organ.egg_settings["clutch"]
		var/line = "My [egg_organ.get_oviposition_location_name()] holds [egg_organ.eggs_stored] of [clutch] eggs."
		if(egg_organ.eggs_stored < clutch)
			if(nutrition < NUTRITION_LEVEL_STARVING + OVI_EGG_NUTRITION_COST)
				line += " I'm too hungry to form more."
			else
				line += " Another is forming."
		report += line
	var/datum/component/implanted_eggs/carried = GetComponent(/datum/component/implanted_eggs)
	if(carried)
		var/ripe_count = length(carried.get_ripe_eggs())
		report += "I'm carrying [length(carried.eggs)] implanted egg\s, [ripe_count] ready to lay."
	if(!length(report))
		report += "I'm not carrying any eggs."
	to_chat(src, span_notice(report.Join("<br>")))
