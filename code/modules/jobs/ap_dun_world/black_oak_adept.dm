// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/mercenary/blackoak_adept
	name = "Black Oaken Adept"
	tutorial = "A spellblade of the Black Oaks. Half mercenary band, half irregular militia fighting for control of their ancestral elven homeland of the Peaks. You have honed the ancient Azurean art of spellbladery - an art that is yours and your people's alone. Thankfully, you are not here today to shed the blood of the Duke's men - unless someone pays you to..."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(/datum/species/human/halfelf, /datum/species/elf/wood, /datum/species/elf/dark)
	outfit = /datum/outfit/job/roguetown/mercenary/blackoak_adept
	class_select_category = CLASS_CAT_RACIAL
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/combat_blackoak.ogg'
	subclass_languages = list(/datum/language/elvish)
	class_select_category = CLASS_CAT_RACIAL
	traits_applied = list(TRAIT_AZURENATIVE, TRAIT_OUTDOORSMAN, TRAIT_BLACKOAK, TRAIT_ARCYNE_T2, TRAIT_MEDIUMARMOR)
	subclass_stats = list(
		STATKEY_INT = 1,
		STATKEY_PER = 1,
		STATKEY_SPD = 2,
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
	)
	subclass_spellpoints = 5
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/mercenary/blackoak_adept

/datum/outfit/job/roguetown/mercenary/blackoak_adept/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	head = /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm
	armor = /obj/item/clothing/suit/roguetown/armor/plate/elven_plate
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots
	cloak = /obj/item/clothing/cloak/forrestercloak
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves
	belt = /obj/item/storage/belt/rogue/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel/black
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/hatanga
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	beltl = /obj/item/rogueweapon/huntingknife/idagger/steel/special
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/spellbook_unfinished/pre_arcyne = 1,
		/obj/item/roguegem/amethyst = 1,
		/obj/item/chalk = 1,
		)


	var/spellblade_chant_selected = ap_spellblade_training(H)

	var/obj/item/rogueweapon/granted_weapon = null
	switch(spellblade_chant_selected)
		if("blade")
			var/weapons = list("Elvish Longsword", "Elvish Sabre", "Elvish Curveblade", "Elvish Dirk")
			var/weapon_choice = H.client ? input(H, "Choose your WEAPON.", "FOR THE OAKS AND THE PEAKS.") as anything in weapons : null
			if(!weapon_choice)
				weapon_choice = (weapons)[1]
			switch(weapon_choice)
				if("Elvish Longsword")
					r_hand = granted_weapon = /obj/item/rogueweapon/sword/long/elvish
					beltr = /obj/item/rogueweapon/scabbard/sword
					backr = /obj/item/rogueweapon/shield/wood
				if("Elvish Sabre")
					r_hand = granted_weapon = /obj/item/rogueweapon/sword/sabre/elf
					beltr = /obj/item/rogueweapon/scabbard/sword
					backr = /obj/item/rogueweapon/shield/wood
				if("Elvish Curveblade")
					r_hand = granted_weapon = /obj/item/rogueweapon/greatsword
					backr = /obj/item/rogueweapon/scabbard/gwstrap
				if("Elvish Dirk")
					r_hand = granted_weapon = /obj/item/rogueweapon/huntingknife/idagger/steel/elvish
					backr = /obj/item/rogueweapon/shield/wood
		if("phalangite")
			r_hand = granted_weapon = /obj/item/rogueweapon/halberd/bardiche/elvish
			backr = /obj/item/rogueweapon/scabbard/gwstrap
		if("macebearer")
			backr = /obj/item/rogueweapon/shield/wood
			var/mace_weapons = list("Steel Mace", "Steel Warhammer", "Grand Mace", "Battle Axe", "Steel Greataxe")
			var/mace_choice = H.client ? input(H, "Choose your WEAPON.", "FOR THE OAKS AND THE PEAKS.") as anything in mace_weapons : null
			if(!mace_choice)
				mace_choice = (mace_weapons)[1]
			switch(mace_choice)
				if("Steel Mace")
					r_hand = granted_weapon = /obj/item/rogueweapon/mace/steel
				if("Steel Warhammer")
					r_hand = granted_weapon = /obj/item/rogueweapon/mace/warhammer/steel
				if("Grand Mace")
					r_hand = granted_weapon = /obj/item/rogueweapon/mace/goden/steel
					backr = /obj/item/rogueweapon/scabbard/gwstrap
				if("Battle Axe")
					r_hand = granted_weapon = /obj/item/rogueweapon/stoneaxe/battle
				if("Steel Greataxe")
					r_hand = granted_weapon = /obj/item/rogueweapon/greataxe/steel
					backr = /obj/item/rogueweapon/scabbard/gwstrap
	if(granted_weapon)
		H.adjust_skillrank_up_to(granted_weapon::associated_skill, SKILL_LEVEL_EXPERT, TRUE)
	H.merctype = 2
