/datum/advclass/wretch/buccaneer
	name = "Buccaneer"
	tutorial = "You are a swashbuckling pirate, once the dreaded scourge of the seas. Now that your crew has disbanded, you find yourself a lawless man adrift on an ocean of land. Pillage and plunder whatever spoils you see fit. Yo ho ho, booty awaits!"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/buccaneer
	cmode_music = 'sound/music/cmode/antag/combat_cutpurse.ogg'
	class_select_category = CLASS_CAT_ROGUE
	category_tags = list(CTAG_WRETCH)
	subclass_languages = list(/datum/language/abyssal)
	traits_applied = list(TRAIT_DODGEEXPERT)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_SPD = 1,
		STATKEY_PER = 3
	)
	subclass_skills = list(
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN, // Treasure maps, ahoy!
		/datum/skill/combat/firearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/swimming = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN, // Drunken brawling.
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT, // Climb up to the crow's nest.
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
	)

/datum/outfit/job/roguetown/wretch/buccaneer/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("You are a swashbuckling pirate, once the dreaded scourge of the seas. Now that your crew has disbanded, you find yourself a lawless man adrift on an ocean of land. Pillage and plunder whatever spoils you see fit. Yo ho ho, booty awaits!"))
	head = /obj/item/clothing/head/roguetown/helmet/tricorn/lucky
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy
	cloak = /obj/item/clothing/cloak/cape/blkknight
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	backr = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	neck = /obj/item/clothing/neck/roguetown/gorget
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	beltl = /obj/item/gun/ballistic/firearm/arquebus_pistol
	beltr = /obj/item/rogueweapon/sword/cutlass

	backpack_contents = list(
		/obj/item/quiver/bullet/lead,
		/obj/item/powderflask,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch/lantern/prelit = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot = 1,
	)

	if(H.mind)
		H.set_blindness(0)
		wretch_select_bounty(H)

