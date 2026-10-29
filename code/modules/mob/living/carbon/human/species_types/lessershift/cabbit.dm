/mob/living/carbon/human/species/lessershift/cabbit //The baseline and tracker of the wildshapes
	name = "Lesser Cabbit"
	race = /datum/species/shapelcabbit
	footstep_type = FOOTSTEP_MOB_CLAW
	ambushable = FALSE
	skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/cabbit_skin
	lessershift_icon = 'icons/roguetown/mob/cabbit.dmi'
	lessershift_icon_state = "cabbit"
	// The form when you gotta go fast and want to be cute

/mob/living/carbon/human/species/lessershift/cabbit/gain_inherent_skills()
	. = ..()
	if(!mind)
		return

	adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE) //Run and hide if you can

	STASTR = 2
	STACON = 2
	STAWIL = 7
	STAPER = 9
	STASPD = 16 //May be overtuned with dodge expert, but this thing is so fragile
	STALUC = 15 //Xylyx's critters

	AddSpell(new /obj/effect/proc_holder/spell/self/cabbitclaws)
	faction += "cabbits"
	if(client.prefs?.wildshape_name)
		real_name = "cabbit ([stored_mob.real_name])"
	else
		real_name = "cabbit"

	// Let cabbits walk through people
	pass_flags = PASSMOB

	update_move_intent_slowdown()

/mob/living/carbon/human/species/lessershift/cabbit/CanPass(atom/movable/mover, turf/target)
	if(!ismob(mover))
		return ..()
	return TRUE // Mobs can always pass through cabbits

/mob/living/carbon/human/species/lessershift/cabbit/start_pulling(atom/movable/AM, state, force, supress_message, obj/item/item_override)
	if(ismob(AM))
		to_chat(src, span_warning("My tiny paws can't grab that!"))
		return FALSE
	return ..()

// CABBIT SPECIES DATUM //
/datum/species/shapelcabbit
	name = "lesser cabbit"
	id = "shapelcabbit"
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES)
	inherent_traits = list(
		TRAIT_KNEESTINGER_IMMUNITY, //All of these are dendorite transformations, they are ALL blessed by dendor
		TRAIT_WILD_EATER,
		TRAIT_HARDDISMEMBER, //Decapping wildshapes causes them to bug out, badly, and need admin intervention to fix. Bandaid fix.
		TRAIT_BRITTLE,
		TRAIT_LEAPER,
		TRAIT_UNCAPPED_SPEED,
	)
	inherent_biotypes = MOB_HUMANOID
	armor = 5
	no_equip = list(SLOT_SHIRT, SLOT_HEAD, SLOT_WEAR_MASK, SLOT_ARMOR, SLOT_GLOVES, SLOT_SHOES, SLOT_PANTS, SLOT_CLOAK, SLOT_BELT, SLOT_BACK_R, SLOT_BACK_L, SLOT_S_STORE)
	nojumpsuit = 1
	sexes = 1
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | SLIME_EXTRACT
	offset_features = list(OFFSET_HANDS = list(0,2), OFFSET_HANDS_F = list(0,2))
	organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain,
		ORGAN_SLOT_HEART = /obj/item/organ/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/night_vision,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/wild_tongue,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/appendix,
		ORGAN_SLOT_GUTS = /obj/item/organ/guts,
		)

	languages = list(
		/datum/language/beast,
		/datum/language/common,
	)

/datum/species/shapelcabbit/regenerate_icons(mob/living/carbon/human/H)
	H.icon = 'icons/roguetown/mob/cabbit.dmi'
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	H.icon_state = "cabbit"
	H.update_damage_overlays()
	return TRUE

/datum/species/shapelcabbit/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/shapelcabbit/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	return TRUE
