// REGENERATING ARMOUR

#define COMBAT_TAG_DURATION 30 SECONDS

/obj/item/clothing/suit/roguetown/armor/regenerating
	name = "regenerating armour"
	desc = "Abstract parent. Contact developer if you see this."
	icon_state = null
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR

	/// Feedback messages
	var/repairmsg_begin = "My armour begins to slowly mend its abuse.."
	var/repairmsg_continue = "My armour mends some of its abuse.."
	var/repairmsg_stop = "My armour stops mending from the onslaught!"
	var/repairmsg_end = "My armour has become taut with newfound vigor!"

	/// Combat timer that prevents you from healing while taking damage
	var/combat_timer
	/// Recursive timer that slowly regenerates the armor
	var/reptimer
	/// Time taken for regeneration
	var/repair_time = 10 SECONDS
	/// If the armor regen is stopped by a combat tag
	var/combat_taggable = FALSE

/obj/item/clothing/suit/roguetown/armor/regenerating/equipped(mob/user, slot)
	. = ..()
	UnregisterSignal(user, list(COMSIG_SPECIES_ATTACKED_BY, COMSIG_LIVING_ARMOR_CHECKED, COMSIG_MOB_APPLY_DAMGE))
	if(slot == SLOT_SHIRT || slot == SLOT_ARMOR)
		RegisterSignal(user, list(COMSIG_SPECIES_ATTACKED_BY, COMSIG_LIVING_ARMOR_CHECKED, COMSIG_MOB_APPLY_DAMGE), PROC_REF(on_attacked_by))

/// Combat tag system, makes your skin stop regenning if you are attacked by anything
/obj/item/clothing/suit/roguetown/armor/regenerating/proc/on_attacked_by(datum/source)
	SIGNAL_HANDLER
	if(!combat_taggable) // This means constant in-combat regen
		if(!reptimer && obj_integrity < max_integrity)
			reptimer = addtimer(CALLBACK(src, PROC_REF(begin_repair)), repair_time, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_STOPPABLE)
		return

	combat_timer = addtimer(CALLBACK(src, PROC_REF(begin_repair)), COMBAT_TAG_DURATION, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(timeleft(reptimer))
		to_chat(loc, span_notice(repairmsg_stop))
	deltimer(reptimer)
	reptimer = null
	return

/// Start repairing the armor
/obj/item/clothing/suit/roguetown/armor/regenerating/proc/begin_repair()
	to_chat(loc, span_notice(repairmsg_begin))
	armour_regen(skip_message = TRUE)

/// Recursive loop that fixes the armor
/obj/item/clothing/suit/roguetown/armor/regenerating/proc/armour_regen(repair_percent = 0.2 * max_integrity, skip_message = FALSE)
	obj_integrity = min(obj_integrity + repair_percent, max_integrity)
	if(obj_broken)
		obj_fix(full_repair = FALSE)

	if(obj_integrity >= max_integrity)
		to_chat(loc, span_notice(repairmsg_end))
		deltimer(reptimer)
		reptimer = null
		return

	if(!skip_message)
		to_chat(loc, span_notice(repairmsg_continue))

	reptimer = addtimer(CALLBACK(src, PROC_REF(armour_regen)), repair_time, TIMER_OVERRIDE|TIMER_UNIQUE|TIMER_STOPPABLE)

// SKIN ARMOUR

/obj/item/clothing/suit/roguetown/armor/regenerating/skin
	name = "regenerating skin"
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'

	resistance_flags = FIRE_PROOF
	body_parts_covered = COVERAGE_FULL
	body_parts_inherent = COVERAGE_FULL
	flags_inv = null //Exposes the chest and-or breasts.
	surgery_cover = FALSE //Should permit surgery and other invasive processes.
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor_class = ARMOR_CLASS_LIGHT
	blocksound = SOFTUNDERHIT
	blade_dulling = DULLING_BASHCHOP
	armor = ARMOR_PADDED
	nudist_approved = TRUE

	repairmsg_begin = "My skin begins to slowly mend its abuse.."
	repairmsg_continue = "My skin mends some of its abuse.."
	repairmsg_stop = "My skin stops mending from the onslaught!"
	repairmsg_end = "My skin has become taut with newfound vigor!"

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/dropped(mob/living/carbon/human/user)
	..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/disciple
	name = "disciple's skin"
	desc = "It's far more than just an oath. </br>'AEON, PSYDON, ADONAI - ENTROPY, HUMENITY, DIVINITY. A TRINITY THAT IS ONE, \
	YET THREE; KNOWN BY ALL, YET FORGOTTEN TO TYME.' </br>'A CORPSE. \
	I AM LIVING ON A FUCKING CORPSE. HE IS THE WORLD, AND THE WORLD IS ROTTING AWAY. \
	HEAVEN CLOSED ITS GATES TO US, LONG AGO.' </br>'YET, HIS CHILDREN PERSIST; AND AS LONG AS THEY DO, SO MUST I. \
	HAPPINESS MUST BE FOUGHT FOR.'"
	armor = ARMOR_LEATHER_STUDDED
	prevent_crits = list(BCLASS_CUT, BCLASS_BLUNT)
	repair_time = 20 SECONDS
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER + 50//350

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak
	name = "tough skin"
	desc = "My skin has always been tough enough to stop most cuts and bruises, with time it will mend."
	armor = list("blunt" = 30, "slash" = 50, "stab" = 50, "piercing" = 20, "fire" = 0, "acid" = 0)
	max_integrity = 300
	body_parts_covered = FULL_BODY
	body_parts_inherent = FULL_BODY
	combat_taggable = TRUE

// Inherent armor uses the virtue's stats and regeneration without occupying clothing slots.
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial
	slot_flags = null
	attachment_component = null

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/Initialize(mapload)
	. = ..()
	if(ishuman(loc))
		RegisterSignal(loc, list(COMSIG_SPECIES_ATTACKED_BY, COMSIG_LIVING_ARMOR_CHECKED, COMSIG_MOB_APPLY_DAMGE), PROC_REF(on_attacked_by))

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/Destroy()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.skin_armor == src)
			H.skin_armor = null
	deltimer(reptimer)
	return ..()

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/lamia
	name = "foot scales"
	desc = "Tough scales protect the feet and mend over time."
	body_parts_covered = FEET
	body_parts_inherent = FEET

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/harpy
	name = "talon scales"
	desc = "Tough scales protect the feet and mend over time."
	body_parts_covered = FEET
	body_parts_inherent = FEET
	attachment_component = /datum/component/storage/concrete/roguetown/talon_decoration

/datum/component/storage/concrete/roguetown/talon_decoration
	max_items = 1
	max_w_class = WEIGHT_CLASS_NORMAL
	screen_max_rows = 2
	screen_max_columns = 2
	attack_hand_interact = FALSE
	intercept_parent_attack = FALSE
	intercept_parent_mousedrop = FALSE
	insert_preposition = "onto"

/datum/component/storage/concrete/roguetown/talon_decoration/New(datum/P, ...)
	. = ..()
	set_holdable(list(
		/obj/item/clothing/shoes/roguetown/anklets,
		/obj/item/clothing/shoes/roguetown/boots/clothlinedanklets,
		/obj/item/clothing/shoes/roguetown/boots/furlinedanklets,
		/obj/item/clothing/shoes/roguetown/boots/footwraps,
	), list(/obj/item/clothing/shoes/roguetown/anklets/baotha))

/datum/component/storage/concrete/roguetown/talon_decoration/can_be_inserted(obj/item/storing, stop_messages, mob/user, worn_check = FALSE, params, storage_click = FALSE)
	var/obj/item/scales = parent
	var/mob/living/carbon/human/wearer = scales.loc
	if(!istype(wearer) || QDELETED(wearer) || wearer != user || wearer.skin_armor != scales || !wearer.get_num_legs(FALSE))
		return FALSE
	if(!istype(storing) || length(storing.contents) || storing.GetComponent(/datum/component/storage))
		return FALSE
	return ..()

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/harpy/update_icon()
	. = ..()
	var/mob/living/carbon/human/wearer = loc
	if(istype(wearer) && wearer.skin_armor == src && !QDELETED(wearer))
		wearer.update_inv_shoes()

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/harpy/Destroy()
	var/datum/component/storage/concrete/roguetown/talon_decoration/storage = GetComponent(attachment_component)
	var/turf/destination = get_turf(src)
	var/obj/item/clothing/shoes/decoration = locate() in contents
	if(storage && destination && decoration)
		storage.remove_from_storage(decoration, destination)
	return ..()

/mob/living/carbon/human/proc/get_talon_decoration()
	if(!istype(skin_armor, /obj/item/clothing/suit/roguetown/armor/regenerating/skin/weak/racial/harpy) || QDELETED(skin_armor) || get_num_legs(FALSE) < 1)
		return null
	return locate(/obj/item/clothing/shoes) in skin_armor.contents

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/chest/gladiator
	name = "pit-hardened chest"//pit? hnnnnhhhffgggg
	desc = "Are you not entertained?!"
	body_parts_covered = COVERAGE_VEST
	body_parts_inherent = COVERAGE_VEST
	blocksound = SOFTHIT
	armor = ARMOR_LEATHER
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER //defaults to a leather armor

/obj/item/clothing/suit/roguetown/armor/regenerating/skin/body/gladiator
	name = "pit-hardened skin"
	desc = "Are you not entertained?!"
	body_parts_covered = COVERAGE_FULL //everything but head and it's subzones (neck, skull, ears, eyes, nose, mouth)
	body_parts_inherent = COVERAGE_FULL
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_LIGHT_MEDIUM //defaults to a gambeson

#undef COMBAT_TAG_DURATION

