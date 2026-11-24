/datum/advclass/wretch/wildwitch
	townie_contract_gate_exempt = TRUE
	name = "Wild Witch"
	tutorial = "You are a witch of the wilds, seen as wisefolk to some and a demon to many. Ostracized and sequestered for wrongthinks or outright heresy, your potions are what the commonfolk turn to when all else fails, but your extreme ways have caused them to toss you out of town. Take care not to end 'pon a pyre, for the church condemns your left handed arts, perhaps the wretches will be more favorable to you."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/wretch/wildwitch
	class_select_category = CLASS_CAT_MAGE
	category_tags = list(CTAG_WRETCH)
	traits_applied = list(TRAIT_DEATHSIGHT, TRAIT_WITCH, TRAIT_ARCYNE_T1, TRAIT_ALCHEMY_EXPERT, TRAIT_MEDICINE_EXPERT, TRAIT_HOMESTEAD_EXPERT)
	maximum_possible_slots = 2 // really I want to say 3 but 5 is PRETTY roomy
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_SPD = 2,
		STATKEY_LCK = 1
	)

	subclass_skills = list(
		/datum/skill/combat/polearms = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/labor/farming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/cooking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/wretch/wildwitch/pre_equip(mob/living/carbon/human/H)
	..()
	mask = /obj/item/clothing/head/roguetown/roguehood/black
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/phys
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	gloves = /obj/item/clothing/gloves/roguetown/angle
	belt = /obj/item/storage/belt/rogue/leather/black
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/storage/magebag/witch
	pants = /obj/item/clothing/under/roguetown/trou
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
						/obj/item/reagent_containers/glass/mortar = 1,
						/obj/item/pestle = 1,
						/obj/item/candle/yellow = 2,
						/obj/item/recipe_book/alchemy = 1,
						/obj/item/recipe_book/magic = 1,
						/obj/item/chalk = 1
						)
	if(H.age == AGE_MIDDLEAGED)
		H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, 5, TRUE)
	if(H.age == AGE_OLD)
		H.adjust_skillrank_up_to(/datum/skill/craft/alchemy, 6, TRUE)
	if(H.mind)
		wretch_select_bounty(H)

	var/hats = list(
		"Witch Hat" 		= /obj/item/clothing/head/roguetown/witchhat,
		"Witch Hat (Old)"	= /obj/item/clothing/head/roguetown/witchhat/old,
		"None"
	)
	var/hatchoice = input(H, "Choose your hat.", "WITCH ATTIRE") as anything in hats
	if(hatchoice != "None")
		head = hats[hatchoice]

	var/classes = list("Occultist", "Spirit Caller", "Fae Touched")
	var/classchoice = input("How do your powers manifest?", "THE OLD WAYS") as anything in classes

	var/shapeshifts = list("Zad", "Cat", "Cat (Black)", "Bat", "Cabbit", "Small Rous", "Lesser Venard", "Lesser Volf", "Frog")
	var/shapeshiftchoice = input("What form does your second skin take?", "THE OLD WAYS") as anything in shapeshifts

	switch (classchoice)
		if("Occultist")
			if(H.age == AGE_OLD)
				ADD_TRAIT(H, TRAIT_ARCYNE_T3, TRAIT_GENERIC)
				H.adjust_skillrank(/datum/skill/magic/arcane, 4, TRUE)
			if(H.age == AGE_MIDDLEAGED)
				ADD_TRAIT(H, TRAIT_ARCYNE_T3, TRAIT_GENERIC)
				H.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
			else
				ADD_TRAIT(H, TRAIT_ARCYNE_T2, TRAIT_GENERIC)
				H.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
			H.mind?.adjust_spellpoints(9) // twelve if you pick arcyne potential
			if(H.age == AGE_MIDDLEAGED)
				H.mind?.adjust_spellpoints(6) // old spellcasters get more
			if(H.age == AGE_OLD)
				H.mind?.adjust_spellpoints(12) // old spellcasters get more
			neck = null
		if("Spirit Caller")
			var/datum/devotion/D = new /datum/devotion/(H, H.patron)
			if(H.age == AGE_OLD)
				H.adjust_skillrank(/datum/skill/magic/holy, 4, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T4, passive_gain = CLERIC_REGEN_WITCH, devotion_limit = CLERIC_REQ_4)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			if(H.age == AGE_MIDDLEAGED)
				H.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_WITCH, devotion_limit = CLERIC_REQ_3)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			else
				H.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_WITCH, devotion_limit = CLERIC_REQ_2)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			D.max_devotion *= 0.75
			switch(H.patron?.type)
				if(/datum/patron/divine/astrata)
					neck = /obj/item/clothing/neck/roguetown/psicross/astrata
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/noc)
					neck = /obj/item/clothing/neck/roguetown/psicross/noc
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/abyssor)
					neck = /obj/item/clothing/neck/roguetown/psicross/abyssor
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/dendor)
					neck = /obj/item/clothing/neck/roguetown/psicross/dendor
					r_hand = /obj/item/ritechalk
					if(H.age == AGE_OLD)
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 5, TRUE)
					if(H.age == AGE_MIDDLEAGED)
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 4, TRUE)
					else
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 3, TRUE)
				if(/datum/patron/divine/necra)
					neck = /obj/item/clothing/neck/roguetown/psicross/necra
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/pestra)
					neck = /obj/item/clothing/neck/roguetown/psicross/pestra
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/ravox)
					neck = /obj/item/clothing/neck/roguetown/psicross/ravox
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/malum)
					neck = /obj/item/clothing/neck/roguetown/psicross/malum
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/eora)
					neck = /obj/item/clothing/neck/roguetown/psicross/eora
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/xylix)
					neck = /obj/item/clothing/neck/roguetown/psicross/xylix
					r_hand = /obj/item/ritechalk
				else
					neck = /obj/item/clothing/neck/roguetown/psicross/wood
					r_hand = /obj/item/ritechalk
		if("Fae Touched")
			// hybrid arcane/holy witch with t1 arcane and t1 miracles, but less spellpoints, lower max devotion and less regen (0.5). Still can't pray.
			var/datum/devotion/D = new /datum/devotion/(H, H.patron)
			if(H.age == AGE_OLD)
				H.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
				H.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T3, passive_gain = CLERIC_REGEN_WITCH, devotion_limit = CLERIC_REQ_3)
				D.max_devotion *= 0.75
				ADD_TRAIT(H, TRAIT_ARCYNE_T3, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			if(H.age == AGE_MIDDLEAGED)
				H.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
				H.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T2, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_2)
				D.max_devotion *= 0.75
				ADD_TRAIT(H, TRAIT_ARCYNE_T3, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			else
				H.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
				H.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
				D.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_1)
				D.max_devotion *= 0.75
				ADD_TRAIT(H, TRAIT_ARCYNE_T3, TRAIT_GENERIC)
				ADD_TRAIT(H, TRAIT_RITUALIST, TRAIT_GENERIC)
			H.mind?.adjust_spellpoints(6) // twelve if you pick arcyne potential
			if(H.age == AGE_MIDDLEAGED)
				H.mind?.adjust_spellpoints(3) // old spellcasters get more
			if(H.age == AGE_OLD)
				H.mind?.adjust_spellpoints(6) // old spellcasters get more
			switch(H.patron?.type)
				if(/datum/patron/divine/astrata)
					neck = /obj/item/clothing/neck/roguetown/psicross/astrata
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/noc)
					neck = /obj/item/clothing/neck/roguetown/psicross/noc
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/abyssor)
					neck = /obj/item/clothing/neck/roguetown/psicross/abyssor
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/dendor)
					neck = /obj/item/clothing/neck/roguetown/psicross/dendor
					r_hand = /obj/item/ritechalk
					if(H.age == AGE_OLD)
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 3, TRUE)
					if(H.age == AGE_MIDDLEAGED)
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 2, TRUE)
					else
						H.adjust_skillrank_up_to(/datum/skill/magic/druidic, 1, TRUE)
				if(/datum/patron/divine/necra)
					neck = /obj/item/clothing/neck/roguetown/psicross/necra
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/pestra)
					neck = /obj/item/clothing/neck/roguetown/psicross/pestra
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/ravox)
					neck = /obj/item/clothing/neck/roguetown/psicross/ravox
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/malum)
					neck = /obj/item/clothing/neck/roguetown/psicross/malum
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/eora)
					neck = /obj/item/clothing/neck/roguetown/psicross/eora
					r_hand = /obj/item/ritechalk
				if(/datum/patron/divine/xylix)
					neck = /obj/item/clothing/neck/roguetown/psicross/xylix
					r_hand = /obj/item/ritechalk
				else
					neck = /obj/item/clothing/neck/roguetown/psicross/wood
					r_hand = /obj/item/ritechalk

	if(H.mind)
		switch (shapeshiftchoice)
			if("Zad")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/crow)
			if("Cat")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/cat)
			if("Cat (Black)")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/cat/black)
			if("Bat")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/bat)
			if("Lesser Volf")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/lesser_wolf)
			if("Lesser Venard")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/lesser_vernard)
			if("Small Rous")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/rous)
			if("Cabbit")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/cabbit)
			if("Frog")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/witch/frog)

		switch (classchoice)
			if("Occultist")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/guidance)
				if(H.age == AGE_MIDDLEAGED)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/arcynebolt)
				if(H.age == AGE_OLD)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/arcynebolt)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/forcewall/arcyne_prison)
			if("Fae Touched")
				if(H.age == AGE_MIDDLEAGED)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/guidance)
				if(H.age == AGE_OLD)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/guidance)
					H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/arcynebolt)

	if(H.gender == FEMALE)
		armor = /obj/item/clothing/suit/roguetown/armor/corset
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
		pants = /obj/item/clothing/under/roguetown/skirt/red

	if(H.age == AGE_OLD)
		H.change_stat(STATKEY_SPD, -2)
		H.change_stat(STATKEY_INT, 2)
		H.change_stat(STATKEY_LCK, 2)

	if(H.age == AGE_MIDDLEAGED)
		H.change_stat(STATKEY_INT, 2)

	switch(H.patron?.type)
		if(/datum/patron/inhumen/zizo)
			H.cmode_music = 'sound/music/combat_heretic.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
		if(/datum/patron/inhumen/matthios)
			H.cmode_music = 'sound/music/combat_matthios.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
		if(/datum/patron/inhumen/graggar)
			H.cmode_music = 'sound/music/combat_graggar.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
		if(/datum/patron/inhumen/baotha)
			H.cmode_music = 'sound/music/combat_baotha.ogg'
			ADD_TRAIT(H, TRAIT_HERESIARCH, TRAIT_GENERIC)
