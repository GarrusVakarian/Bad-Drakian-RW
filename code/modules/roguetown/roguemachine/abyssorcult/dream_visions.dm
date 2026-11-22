/datum/vision_quest
	/// Name of the quest
	var/name = "Vision Quest"
	/// Description shown to player
	var/description = ""
	/// Parchment tier required (1-3)
	var/required_tier = 1
	/// The phrase the player must say near target
	var/required_phrase = ""
	/// Reward type (singular, player chooses from this pool)
	var/list/possible_rewards = list()
	/// Bonus reward type (random)
	var/list/possible_bonus_rewards = list()
	/// Type of target description
	var/target_description = "a heretic"
	/// Short summary shown in menu
	var/summary = "A vision of judgment..."
	/// Long vision text printed to chat
	var/vision_text = "You see a vision of..."
	/// List of possible phrases to generate
	var/list/possible_phrases = list()
	/// Optional list of job/role strings that are valid targets for this quest
	// These are generic by default. Antags typically excluded to avoid meta reveals.
	var/list/valid_roles = list(
		"Orthodoxist",
		"Absolver",
		"Templar",
		"Sergeant",
		"Man at Arms",
		"Knight",
		"Squire",
		"Mercenary",
		"Warden",
		"Adventurer",
		"Towner",
		"Acolyte",
		"Keeper",
		"Bishop",
		"Sexton",
		"Martyr",
		"Druid",
		"Cook",
		"Servant",
		"Shophand",
		"Soilson",
		"Tapster",
		"Councillor",
		"Archivist",
		"Clerk",
		"Hand",
		"Jester",
		"Court Magician",
		"Seneschal",
		"Steward",
		"Suitor",
		"Apothecary",
		"Town Crier",
		"Guildmaster",
		"Guildsman",
		"Innkeeper",
		"Magicians Associate",
		"Merchant",
		"Head Physician",
		"Tailor"
	)

/datum/vision_quest/proc/is_valid_target(mob/living/carbon/human/target, mob/living/carbon/human/seeker)
	if(QDELETED(target) || target == seeker)
		return FALSE
	if(target.stat == DEAD)
		return FALSE
	if(!target.mind)
		return FALSE
	// I'm- not sure how else to prevent abyssorites from seeing emotional roleplay too often.
	// So we'll assume anyone wearing three items or less is doing emotional roleplay.
	if(target.contents && target.contents.len < 4)
		return FALSE
	if(istype(get_area(target), /area/rogue/indoors/town/bath))
		return FALSE // no more bathhouse jumpscares, even if they're not naked that's awkward as hell
	if(istype(target.dna?.species, /datum/species/werewolf)) // ww bodies are temporary and get QDEL'd upon detransform; we do NOT want to give vision quests to them
		return FALSE
	if(length(valid_roles))
		if(target.mind.assigned_role in valid_roles)
			return TRUE
		return FALSE
	return TRUE

/datum/vision_quest/proc/on_complete(datum/component/vision_quest_tracker/VCT)
	return // executed on completion of a specific quest. for adding additional effects.

/datum/component/vision_quest_tracker
	var/datum/vision_quest/quest
	var/datum/weakref/target_ref
	var/mob/living/carbon/human/seeker
	var/datum/weakref/reward_rune_ref
	var/chosen_reward_path = null
	var/bonus_reward_path = null
	/// World time when the vision quest was initialized
	var/creation_time = 0
	/// Number of times sleeping has triggered a scry vision
	var/sleep_scry_count = 0
	/// World time when sleep scry was last triggered
	var/last_sleep_scry_time = 0

/datum/component/vision_quest_tracker/Initialize(datum/vision_quest/quest_datum, mob/target_mob, obj/structure/roguemachine/ritual_rune/rune, chosen_reward, bonus_reward)
	if(!istype(quest_datum, /datum/vision_quest) || !istype(target_mob) || !istype(rune))
		return COMPONENT_INCOMPATIBLE

	var/datum/vision_quest/quest_instance = new quest_datum.type()
	quest_instance.name = quest_datum.name
	quest_instance.description = quest_datum.description
	quest_instance.required_tier = quest_datum.required_tier
	quest_instance.required_phrase = pick(quest_datum.possible_phrases)
	quest_instance.target_description = quest_datum.target_description
	quest_instance.summary = quest_datum.summary
	quest_instance.vision_text = quest_datum.vision_text

	quest = quest_instance
	target_ref = WEAKREF(target_mob)
	reward_rune_ref = WEAKREF(rune)
	seeker = parent
	chosen_reward_path = chosen_reward
	bonus_reward_path = bonus_reward
	creation_time = world.time

	if(ishuman(seeker))
		var/mob/living/carbon/human/H = seeker
		H.verbs += /mob/living/carbon/human/proc/recall_vision_quest

	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(on_say))
	RegisterSignal(parent, COMSIG_MOB_SLEEP, PROC_REF(on_mob_sleep))
	to_chat(seeker, span_purple("Vision granted: [quest.name]"))
	to_chat(seeker, span_notice("[quest.description]"))
	to_chat(seeker, span_purple("The vision unfolds before you:"))
	to_chat(seeker, span_notice("[quest.vision_text]"))
	var/mob/target = target_ref?.resolve()
	if(target)
		to_chat(seeker, span_boldnotice("You must say \"[quest.required_phrase]\" within two tiles of [target.real_name]."))
		to_chat(seeker, span_danger("Do not cause harm to [target.real_name], the waves demand you deliver the message, interfering with prophecy can be dangerous."))
		temporary_target_scry()
	else
		to_chat(seeker, span_warning("The vision's target has faded from this world..."))
		qdel(src)

/datum/component/vision_quest_tracker/proc/on_say(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[1]
	var/clean_message = sanitize_speech_phrase(message)
	var/clean_phrase = sanitize_speech_phrase(quest.required_phrase)
	if(findtext(clean_message, clean_phrase))
		var/mob/target = target_ref?.resolve()
		if(!target)
			to_chat(seeker, span_warning("The vision's target is gone... Your quest is lost."))
			qdel(src)
			return
		var/dist = get_dist(seeker, target)
		if(seeker.z == target.z && dist <= 2 && target.stat != DEAD)
			complete_quest()
		else
			to_chat(seeker, span_warning("The vision flickers - you are not close enough to [target.real_name] or they are not present."))

/datum/component/vision_quest_tracker/proc/on_mob_sleep(datum/source)
	SIGNAL_HANDLER

	if(world.time > creation_time + 10 MINUTES)
		to_chat(seeker, span_notice("It's been too long since the initial vision.. my dreams cannot summon my vision's target again."))
		return

	if(sleep_scry_count >= 2)
		to_chat(seeker, span_notice("I've muddied the waters of the dream too much, I cannot see my vision's target in my dreams again."))
		return

	if(last_sleep_scry_time && world.time < last_sleep_scry_time + 1 MINUTES)
		return

	sleep_scry_count++
	last_sleep_scry_time = world.time

	to_chat(seeker, span_purple("Your slumber pulls you back into the vision..."))
	temporary_target_scry()

/datum/component/vision_quest_tracker/proc/sanitize_speech_phrase(phrase)
	var/cleaned = LOWER_TEXT(phrase)
	cleaned = replacetext(cleaned, "&#39;", "'")
	cleaned = replacetext(cleaned, "&apos;", "'")
	cleaned = replacetext(cleaned, "’", "'")
	cleaned = replacetext(cleaned, "‘", "'")
	cleaned = replacetext(cleaned, ",", "")
	cleaned = replacetext(cleaned, ".", "")
	return cleaned

/datum/component/vision_quest_tracker/proc/complete_quest()
	var/obj/structure/roguemachine/ritual_rune/rune = reward_rune_ref?.resolve()
	if(rune && !QDELETED(rune))
		var/turf/T = get_turf(rune)
		if(T)
			if(chosen_reward_path)
				for(var/i in 1 to 3)
					new chosen_reward_path(T)
			if(bonus_reward_path)
				for(var/i in 1 to 2)
					new bonus_reward_path(T)
			to_chat(seeker, span_green("The vision solidifies! Your rewards appear at the ritual rune."))
			quest?.on_complete(src)
		else
			to_chat(seeker, span_warning("The ritual rune is gone! Your rewards are lost."))
	else
		to_chat(seeker, span_warning("The ritual rune is gone! Your rewards are lost."))
	qdel(src)

/datum/component/vision_quest_tracker/Destroy()
	if(ishuman(seeker))
		var/mob/living/carbon/human/H = seeker
		H.verbs -= /mob/living/carbon/human/proc/recall_vision_quest
	UnregisterSignal(parent, list(COMSIG_MOB_SAY, COMSIG_MOB_SLEEP))
	QDEL_NULL(quest)
	target_ref = null
	reward_rune_ref = null
	seeker = null
	return ..()

/datum/component/vision_quest_tracker/proc/temporary_target_scry()
	var/mob/living/carbon/human/target = target_ref?.resolve()
	if(!quest?.is_valid_target(target, seeker))
		to_chat(seeker, span_warning("The vision is too faint to manifest..."))
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return FALSE

	// Trigger standard eye manifestation
	var/mob/dead/observer/screye/abyssor/eye = seeker.scry_ghost(/mob/dead/observer/screye/abyssor)
	if(!eye)
		return FALSE

	eye.forceMove(target_turf)
	eye.scry_center_turf = target_turf

	to_chat(seeker, span_purple("Your mind pierces the veil to glimpse your target... You have 6 seconds."))
	addtimer(CALLBACK(eye, TYPE_PROC_REF(/mob/dead/observer/screye/abyssor, return_from_vision)), 6 SECONDS)
	return TRUE

/mob/living/carbon/human/proc/recall_vision_quest()
	set name = "Recall Vision Quest"
	set category = "RoleUnique.Cleric"
	set desc = "Recall the required phrase, target details, and objectives for your active vision quest."

	var/datum/component/vision_quest_tracker/tracker = GetComponent(/datum/component/vision_quest_tracker)
	if(!tracker || !tracker.quest)
		to_chat(src, span_warning("You do not currently have an active vision quest."))
		return

	var/datum/vision_quest/Q = tracker.quest
	var/mob/target = tracker.target_ref?.resolve()

	to_chat(src, span_purple("--- Vision Quest: [Q.name] ---"))
	to_chat(src, span_notice("Summary: [Q.summary]"))
	if(target)
		to_chat(src, span_boldnotice("Target: [target.real_name]"))
		to_chat(src, span_boldnotice("Required Phrase: \"[Q.required_phrase]\" (Must say within 2 tiles)"))
	else
		to_chat(src, span_danger("Target: [Q.target_description] (Faded from this world)"))

/mob/dead/observer/screye/abyssor
	var/turf/scry_center_turf

/mob/dead/observer/screye/abyssor/proc/return_from_vision()
	if(reenter_corpse())
		qdel(src)

/mob/dead/observer/screye/abyssor/Move(NewLoc, direct)
	var/turf/destination = NewLoc ? get_turf(NewLoc) : get_step(src, direct)
	if(destination && scry_center_turf && destination.z == scry_center_turf.z && get_dist(destination, scry_center_turf) <= 2)
		return forceMove(destination)
	return FALSE

/mob/dead/observer/screye/abyssor/beach
	name = "Abyssal Inundation Eye"
	var/obj/structure/roguemachine/dream_pool/source_pool

/mob/dead/observer/screye/abyssor/beach/Initialize(mapload)
	. = ..()
	verbs += /mob/dead/observer/screye/abyssor/beach/proc/unleash_inundation
	addtimer(CALLBACK(src, PROC_REF(return_from_vision)), 1 MINUTES)

/mob/dead/observer/screye/abyssor/beach/Move(NewLoc, direct)
	var/turf/destination = NewLoc ? get_turf(NewLoc) : get_step(src, direct)
	if(destination && destination.z == z && istype(get_area(destination), /area/rogue/outdoors/beach))
		return forceMove(destination)
	return FALSE

/mob/dead/observer/screye/abyssor/beach/proc/unleash_inundation()
	set category = "RoleUnique.Arcane Eye"
	set name = "Unleash Inundation"
	set desc = "Select the water tile you are currently hovering over to crash a tidal wave here, washing all channelers and deep ones onto the dry ground."
	set hidden = 0

	if(!isobserver(usr))
		to_chat(usr, span_warning("You're not an Eye!"))
		return

	var/turf/target_turf = get_turf(src)

	if(!istype(target_turf, /turf/open/water/ocean))
		to_chat(src, span_warning("You must unleash the wave onto a water tile!"))
		return

	var/non_water_count = 0
	var/list/landing_spots = list()
	for(var/turf/T in range(5, target_turf))
		if(!istype(T, /turf/open/water/ocean))
			non_water_count++
			if(isopenturf(T) && !T.density && istype(get_area(T), /area/rogue/outdoors/beach))
				landing_spots += T

	if(non_water_count < 5 || !length(landing_spots))
		to_chat(src, span_warning("This location lacks enough dry shoreline (needs at least 5 non-water tiles nearby)!"))
		return

	if(QDELETED(source_pool))
		return_from_vision()
		return

	var/list/mob/living/travelers = list()
	for(var/mob/living/M in range(2, source_pool))
		if(M.stat != DEAD)
			travelers += M

	for(var/mob/living/M in travelers)
		var/turf/land_turf = pick(landing_spots)
		if(do_teleport(M, land_turf))
			M.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
			M.Knockdown(40)
			if(ishuman(M))
				M.apply_status_effect(/datum/status_effect/debuff/waterlogged)
			to_chat(M, span_purple("A terrifying, dark tidal wave pulls you into the pool vortex and forcefully slams you onto the shore!"))

	// Base 5 spawns + 0.75 per alive traveler, rounded to the nearest whole number
	var/total_spawns = 5 + round(length(travelers) * 0.75)

	addtimer(CALLBACK(source_pool, TYPE_PROC_REF(/obj/structure/roguemachine/dream_pool, spawn_deep_one_wave), total_spawns, landing_spots), 4 SECONDS)
	return_from_vision()
