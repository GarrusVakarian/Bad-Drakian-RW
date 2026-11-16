// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/councillor/herald
	name = "Herald"
	tutorial = "While lacking in some faculties, such as wealth and courtly advice, you have the uncanny ability to spread the word of the court, and rally people to your liege's cause. The crown saw it fit to employ you as a messenger, but may still lend an ear if you speak your mind. You may be the lowest rung of the ladder, but that rung still towers over everyone else in town."
	outfit = /datum/outfit/job/roguetown/councillor/herald
	category_tags = list(CTAG_COUNCILLOR)
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_INT = 1,
		STATKEY_PER = 1,
		STATKEY_WIL = 1,
		STATKEY_STR = -1
	)

	// better movement skills
	subclass_skills = list(
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
	)
	subclass_virtues = list(
		/datum/virtue/utility/riding
	)

/datum/advclass/councillor/cofferer
	name = "Cofferer"
	tutorial = "Whether born into wealth, or earned through working up from the bottom, you have quite the reserve of mammon at your disposal. Use your silver-tongue to acquire more, or buy more favour with the court. You may be the lowest rung of the ladder, but that rung still towers over everyone else in town."
	outfit = /datum/outfit/job/roguetown/councillor/cofferer
	category_tags = list(CTAG_COUNCILLOR)
	subclass_stats = list(
		STATKEY_WIL = 2,
		STATKEY_INT = 2,
		STATKEY_PER = 2,
		STATKEY_STR = -1
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
	)

/datum/advclass/councillor/castellan
	name = "Castellan"
	tutorial = "Whilst not enjoying a position of leadership over the troops, you are in charge of overseeing the keep's defenses. You even know a thing or two about constructing siege weaponry, and defending against such devices."
	outfit = /datum/outfit/job/roguetown/councillor/castellan
	category_tags = list(CTAG_COUNCILLOR)
	// Mini Artificer
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
		STATKEY_PER = 1
	)
	subclass_skills = list(
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/councillor/herald
	parent_type = /datum/outfit/job/roguetown/councillor/basic

/datum/outfit/job/roguetown/councillor/herald/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		pants = /obj/item/clothing/under/roguetown/trou/beltpants
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltl = /obj/item/rogueweapon/scabbard/sheath/noble
	id = /obj/item/clothing/ring/silver
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/storage/keyring/councillor = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
	)
	if(H.mind)
		SStreasury.grant_savings(rand(80, 100), H) // bumped from lower-middle so the lowest councillor rung still feels like nobility
	// give them the shitty see prices trait
	ADD_TRAIT(H, TRAIT_SEEPRICES_SHITTY, JOB_TRAIT)

/datum/outfit/job/roguetown/councillor/cofferer
	parent_type = /datum/outfit/job/roguetown/councillor/basic

/datum/outfit/job/roguetown/councillor/cofferer/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
		pants = /obj/item/clothing/under/roguetown/trou/beltpants
	if(should_wear_femme_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/formal
		//no trousers because it breaks on fem-sprite
	mask = /obj/item/clothing/mask/rogue/spectacles
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	backl = /obj/item/storage/backpack/rogue/satchel/black
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	beltl = /obj/item/rogueweapon/scabbard/sheath/royal
	neck = /obj/item/clothing/neck/roguetown/ornateamulet/noble
	id = /obj/item/clothing/ring/gold
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/storage/keyring/steward = 1,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 1, //high starting funds
	)
	if(H.mind)
		SStreasury.grant_savings(rand(120, 140), H) // wealth beyond measure
	// give them the good see prices trait
	ADD_TRAIT(H, TRAIT_SEEPRICES, JOB_TRAIT)

/datum/outfit/job/roguetown/councillor/castellan
	parent_type = /datum/outfit/job/roguetown/councillor/basic

/datum/outfit/job/roguetown/councillor/castellan/pre_equip(mob/living/carbon/human/H)
	..()
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/councillor // Technically an important figure
	pants = /obj/item/clothing/under/roguetown/trou/beltpants
	backl = /obj/item/storage/backpack/rogue/satchel/black
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	beltl = /obj/item/rogueweapon/scabbard/sheath/noble
	id = /obj/item/clothing/ring/silver
	backpack_contents = list(
		/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1,
		/obj/item/storage/keyring/councillor = 1,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1, // a mediocre pouch of coins
	)
	if(H.mind)
		SStreasury.grant_savings(rand(80, 100), H) // bumped from lower-middle to match councillor floor
	// give them the good see prices trait
	ADD_TRAIT(H, TRAIT_SEEPRICES, JOB_TRAIT)
	// Level past Jman if they want to
	ADD_TRAIT(H, TRAIT_SMITHING_EXPERT, JOB_TRAIT)
