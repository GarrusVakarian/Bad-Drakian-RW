/mob/living/carbon/human/species/lessershift/fox //The baseline and tracker of the wildshapes 
	name = "Lesser Vernard"
	race = /datum/species/shapelfox
	footstep_type = FOOTSTEP_MOB_CLAW
	ambushable = FALSE
	skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/wolf_skin
	lessershift_icon = 'icons/roguetown/mob/monster/fox.dmi'
	lessershift_icon_state = "fox"
	//This is basically just Wolf & Cat form combined, think rogue form

/mob/living/carbon/human/species/lessershift/fox/gain_inherent_skills()
	. = ..()
	if(src.mind)
		src.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		src.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		src.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		src.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE) //Stalking

		src.STASTR = 2
		src.STACON = 4
		src.STAPER = 10
		src.STASPD = 14

		AddSpell(new /obj/effect/proc_holder/spell/self/foxclaws)
		faction += "wolfs" // Foxes have the same faction code-wise so leaving it for now
		if (src.client.prefs?.wildshape_name)
			real_name = "vernard ([stored_mob.real_name])"
		else
			real_name = "vernard"

// FOX SPECIES DATUM //
/datum/species/shapelfox
	name = "lesser vernard"
	id = "shapelfox"
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES)
	inherent_traits = list(
		TRAIT_KNEESTINGER_IMMUNITY, //All of these are dendorite transformations, they are ALL blessed by dendor
		TRAIT_STEELHEARTED,
		TRAIT_ORGAN_EATER,
		TRAIT_WILD_EATER,
		TRAIT_HARDDISMEMBER, //Decapping might cause them to bug out, badly, and need admin intervention to fix. Bandaid fix.
		TRAIT_PIERCEIMMUNE, //Prevents weapon dusting and caltrop effects due to them transforming when killed/stepping on shards.
		TRAIT_LONGSTRIDER
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

/datum/species/shapelfox/send_voice(mob/living/carbon/human/H)
	playsound(get_turf(H), pick('sound/vo/mobs/vw/idle (1).ogg','sound/vo/mobs/vw/idle (2).ogg','sound/vo/mobs/vw/bark (1).ogg','sound/vo/mobs/vw/bark (2).ogg','sound/vo/mobs/vw/idle (3).ogg'), 80, TRUE, -1)

/datum/species/shapelfox/regenerate_icons(mob/living/carbon/human/H)
	H.icon = 'icons/roguetown/mob/monster/fox.dmi'
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	H.icon_state = "fox"
	H.update_damage_overlays()
	return TRUE

/datum/species/shapelfox/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/shapelfox/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	return TRUE
