/mob/living/carbon/human/species/lessershift/cat //The sneaker of the wildshapes
	name = "Lesser Cat"
	race = /datum/species/shapelcat
	footstep_type = FOOTSTEP_MOB_CLAW
	ambushable = FALSE
	skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/cat_skin
	lessershift_icon = 'icons/mob/pets.dmi'
	lessershift_icon_state = "cat2"
	// Someone else balance this, I am here for code, not numbers

/mob/living/carbon/human/species/lessershift/cat/gain_inherent_skills()
	. = ..()
	if(src.mind)
		src.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		src.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		src.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE) //Who's a sneaky fellow?
		src.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE) //May as well be magical
		src.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
		src.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)

		src.STASTR = 1
		src.STACON = 3
		src.STAWIL = 7
		src.STAPER = 10
		src.STASPD = 14 //May be overtuned with dodge expert, but this thing is so fragile
		src.STALUC = 12 //Xylyx's critters

		AddSpell(new /obj/effect/proc_holder/spell/self/catclaws)
		AddSpell(new /obj/effect/proc_holder/spell/targeted/woundlick)
		if (src.client.prefs?.wildshape_name)
			real_name = "cat ([stored_mob.real_name])"
		else
			real_name = "cat"

// CAT SPECIES DATUM //
/datum/species/shapelcat
	name = "lesser cat"
	id = "shapelcat"
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES)
	inherent_traits = list(
		TRAIT_KNEESTINGER_IMMUNITY, //All of these are dendorite transformations, they are ALL blessed by dendor
		TRAIT_NOFALLDAMAGE2, //Cats, what else can I say?
		TRAIT_WILD_EATER,
		TRAIT_HARDDISMEMBER, //Decapping wildshapes causes them to bug out, badly, and need admin intervention to fix. Bandaid fix.
		TRAIT_BRITTLE,
		TRAIT_LEAPER,
		TRAIT_ZJUMP //its a CAT. Cats can jump so high!
	)
	inherent_biotypes = MOB_HUMANOID
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

/datum/species/shapelcat/regenerate_icons(mob/living/carbon/human/H)
	H.icon = 'icons/mob/pets.dmi'
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	H.icon_state = "cat2"
	H.update_damage_overlays()
	return TRUE

/datum/species/shapelcat/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/shapelcat/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	return TRUE
