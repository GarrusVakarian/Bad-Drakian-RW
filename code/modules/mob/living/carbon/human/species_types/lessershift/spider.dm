/mob/living/carbon/human/species/lessershift/spider //The bog glass cannon
	name = "Lesser Spider"
	race = /datum/species/shapelspider
	footstep_type = FOOTSTEP_MOB_CLAW
	ambushable = FALSE
	skin_armor = new /obj/item/clothing/suit/roguetown/armor/skin_armor/spider_chitin
	lessershift_icon = 'icons/roguetown/mob/monster/spider.dmi'
	lessershift_icon_state = "honeys"
	// Someone else balance this, I am here for code, not numbers

/mob/living/carbon/human/species/lessershift/spider/gain_inherent_skills()
	. = ..()
	if(src.mind)
		src.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
		src.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
		src.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE) //For the bog mainly
		src.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		src.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		src.adjust_skillrank(/datum/skill/misc/climbing, 5, TRUE)

		src.STASTR = 2
		src.STACON = 3
		src.STAWIL = 8
		src.STAPER = 10
		src.STASPD = 12

		AddSpell(new /obj/effect/proc_holder/spell/self/spiderfangs)
		AddSpell(new /obj/effect/proc_holder/spell/self/createhoney)
		AddSpell(new /obj/effect/proc_holder/spell/self/weaveweb)
		faction += "spiders" // It IS a spider
		if (src.client.prefs?.wildshape_name)
			real_name = "beespider ([stored_mob.real_name])"
		else
			real_name = "beespider"

// CAT SPECIES DATUM //
/datum/species/shapelspider
	name = "lesser spider"
	id = "shapelspider"
	species_traits = list(NO_UNDERWEAR, NO_ORGAN_FEATURES, NO_BODYPART_FEATURES)
	inherent_traits = list(
		TRAIT_KNEESTINGER_IMMUNITY, //All of these are dendorite transformations, they are ALL blessed by dendor
		TRAIT_NOFALLDAMAGE1,
		TRAIT_WILD_EATER,
		TRAIT_HARDDISMEMBER, //Decapping wildshapes causes them to bug out, badly, and need admin intervention to fix. Bandaid fix.
		TRAIT_LEAPER,
		TRAIT_WEBWALK, //This IS a spider
		TRAIT_ORGAN_EATER,
		TRAIT_PIERCEIMMUNE, //Prevents weapon dusting and caltrop effects when killed/stepping on shards, also 8 legs.
		TRAIT_LONGSTRIDER,
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

/datum/species/shapelspider/send_voice(mob/living/carbon/human/H)
	playsound(get_turf(H), pick('sound/vo/mobs/spider/speak (1).ogg','sound/vo/mobs/spider/speak (2).ogg','sound/vo/mobs/spider/speak (3).ogg','sound/vo/mobs/spider/speak (4).ogg'), 80, TRUE, -1)

/datum/species/shapelspider/regenerate_icons(mob/living/carbon/human/H)
	H.icon = 'icons/roguetown/mob/monster/spider.dmi'
	H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB)
	H.icon_state = "honeys"
	H.update_damage_overlays()
	return TRUE

/datum/species/shapelspider/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	RegisterSignal(C, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/species/shapelspider/update_damage_overlays(mob/living/carbon/human/H)
	H.remove_overlay(DAMAGE_LAYER)
	return TRUE
