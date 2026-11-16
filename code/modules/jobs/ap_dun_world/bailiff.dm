// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/manorguard/bailiff
	name = "Bailiff"
	tutorial = "Once, you held the tasking of an executioner; yet the dungeons have grown quiet, and the nooses limply sway in the breeze. Now, you serve a lesser office in the Lord's name - as a master of the fist-and-flail."
	outfit = /datum/outfit/job/roguetown/manorguard/bailiff
	maximum_possible_slots = 1 //Had one dungeoneer before, this is how many we get to keep still.

	category_tags = list(CTAG_MENATARMS)
	traits_applied = list(TRAIT_CIVILIZEDBARBARIAN, TRAIT_BLOOD_RESISTANCE, TRAIT_NOPAINSTUN)//This is surely going to be funny
	subclass_stats = list(
		STATKEY_STR = 3,
		STATKEY_CON = 2,
		STATKEY_WIL = 2,
		STATKEY_INT = -1//Old dungeoneer statspread more or less
	)
	subclass_skills = list(
		/datum/skill/combat/whipsflails = SKILL_LEVEL_EXPERT,//Primary way they are meant to dispose of ppl
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT, //hilarious
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/slings = SKILL_LEVEL_JOURNEYMAN,//Funny
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,//Enough for majority of surgeries without grinding.
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,//Since they are MAA now I guess
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE
	)

/datum/outfit/job/roguetown/manorguard/bailiff/pre_equip(mob/living/carbon/human/H)
	..()

	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored/iron
	neck = /obj/item/clothing/neck/roguetown/bevor/iron
	mask = /obj/item/clothing/mask/rogue/ragmask/black
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/light/retinue
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	gloves = /obj/item/clothing/gloves/roguetown/bandages/weighted
	pants = /obj/item/clothing/under/roguetown/chainlegs
	beltl = /obj/item/rogueweapon/flail
	beltr = /obj/item/rogueweapon/whip/antique
	backl = /obj/item/rogueweapon/shield/iron

	H.adjust_blindness(-3)
	if(H.mind)
		H.set_blindness(0)
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rope/chain = 1,
		/obj/item/storage/keyring/guardcastle = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1
		)
	H.verbs |= /mob/proc/haltyell

	if(H.mind)
		SStreasury.grant_savings(rand(40, 80), H)

// Carries the ducal standard.
// When carrying it, they're granted a few unique traits;
// +fortune, +perception, mood spell
