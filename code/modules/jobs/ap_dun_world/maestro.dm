// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/wretch/maestro
	name = "Maestro"
	tutorial = "You were renowned all over Psydonia for your song and merriment until you seduced the wrong dragon or made too many jokes at a noble's expense. Whatever happened, you now play melancholic or manic songs for the dregs of society. Lyve your best lyfe and lyve to tell the tale."
	allowed_sexes = list(MALE, FEMALE)

	outfit				= /datum/outfit/job/roguetown/wretch/maestro

	cmode_music			= 'sound/music/cmode/antag/combat_cutpurse.ogg'
	class_select_category = CLASS_CAT_ROGUE
	category_tags		= list(CTAG_WRETCH)
	traits_applied		= list(TRAIT_DODGEEXPERT, TRAIT_GOODLOVER)
	extra_context		= "All paths gain Allegro: every 5th landed rhythm restores energy.<br>\
							Busker gains Empath, Deceiving Meekness, and Light Step, with Expert Sneaking, Lockpicking, Climbing, and Knives (Parrying Knife).<br>\
							Cacophonist gains a bonus rhythm pick (3 total) and song slot (5 total), with Expert Swords and Whips & Flails (Alloy-tipped whip & Arming Sword).<br>\
							Boomwhacker gains Expert Pugilist and +1 Strength, with Expert Unarmed and Wrestling (Knuckle dusters & Katar).<br>\
							Chanter gains T1 miracles (slow Devotion regen), with Journeyman Holy skill.<br>\
							Cipher gains eight spellpoints, Prestidigitation, and Fetch."
	subclass_stats = list(
		STATKEY_INT = 1,
		STATKEY_WIL = 2,
		STATKEY_SPD = 2,
	)
	subclass_skills = list(
		/datum/skill/misc/music		= SKILL_LEVEL_MASTER,
		/datum/skill/misc/sneaking	= SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics	= SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing	= SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading		= SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives	= SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming	= SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/engineering		= SKILL_LEVEL_APPRENTICE,
	)
	subclass_stashed_items = list(
		"Sewing Kit" = /obj/item/repair_kit,
		"Stashed Funds" = /obj/item/roguecoin/silver/pile/wretchpile,
	)

/datum/outfit/job/roguetown/wretch/maestro/pre_equip(mob/living/carbon/human/H)
	..()

	head	= /obj/item/clothing/head/roguetown/bardhat
	armor	= /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak	= /obj/item/clothing/cloak/thief_cloak/yoruku
	shirt	= /obj/item/clothing/suit/roguetown/armor/gambeson
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather/heavy
	pants	= /obj/item/clothing/under/roguetown/heavy_leather_pants
	shoes	= /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	belt	= /obj/item/storage/belt/rogue/leather/knifebelt/black/iron
	beltr	= /obj/item/rogueweapon/huntingknife/idagger/steel
	backl	= /obj/item/storage/backpack/rogue/satchel
	mask	= /obj/item/clothing/mask/rogue/duelmask
	neck	= /obj/item/clothing/neck/roguetown/coif/heavypadding
	backpack_contents = list(
		/obj/item/flashlight/flare/torch/lantern/prelit					= 1,
		/obj/item/rogueweapon/scabbard/sheath							= 1,
		/obj/item/reagent_containers/glass/bottle/alchemical/healthpot	= 1,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot			= 1,
	)

	var/datum/inspiration/I = new /datum/inspiration(H)
	I.grant_inspiration(H, bard_tier = BARD_T2)
	I.ap_allegro = TRUE // Allegro — every 5th landed rhythm restores energy

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mockery/ap_maestro, H)

		var/instruments = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Psyaltery","Flute","Drums")
		var/instrument_choice = H.client ? input(H, "Choose your instrument.", "Choose your instrument.") as anything in instruments : null
		if(!instrument_choice)
			instrument_choice = (instruments)[1]
		H.set_blindness(0)
		switch(instrument_choice)
			if("Harp")
				backr = /obj/item/rogue/instrument/harp
			if("Lute")
				backr = /obj/item/rogue/instrument/lute
			if("Accordion")
				backr = /obj/item/rogue/instrument/accord
			if("Guitar")
				backr = /obj/item/rogue/instrument/guitar
			if("Hurdy-Gurdy")
				backr = /obj/item/rogue/instrument/hurdygurdy
			if("Viola")
				backr = /obj/item/rogue/instrument/viola
			if("Vocal Talisman")
				backr = /obj/item/rogue/instrument/vocals
			if("Psyaltery")
				backr = /obj/item/rogue/instrument/psyaltery
			if("Flute")
				backr = /obj/item/rogue/instrument/flute
			if("Drums")
				backr = /obj/item/rogue/instrument/drum

		var/paths = list("Busker", "Cacophonist", "Boomwhacker", "Chanter", "Cipher")
		var/path_choice = H.client ? input(H, "Choose your genre.", "Choose your genre") as anything in paths : null
		if(!path_choice)
			path_choice = (paths)[1]
		switch(path_choice)
			if("Busker")
				ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)

				ADD_TRAIT(H, TRAIT_DECEIVING_MEEKNESS, TRAIT_VIRTUE)
				H.verbs |= /mob/living/carbon/human/proc/emote_ffsalute

				ADD_TRAIT(H, TRAIT_LIGHT_STEP, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/misc/sneaking,	SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/misc/lockpicking, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/misc/climbing,	SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/knives,	SKILL_LEVEL_EXPERT, TRUE)
				beltr	= /obj/item/rogueweapon/huntingknife/idagger/steel/parrying
			if("Cacophonist")
				H.inspiration.maxrhythms++ // 3 rhythm picks instead of T2 default 2
				H.inspiration.maxsongs++				// 5 song slots instead of T2 default 4
				H.adjust_skillrank_up_to(/datum/skill/combat/swords,		SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_EXPERT, TRUE)
				r_hand = /obj/item/rogueweapon/whip
				l_hand = /obj/item/rogueweapon/sword
				beltl	= /obj/item/rogueweapon/scabbard/sword
			if("Boomwhacker")
				ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/combat/unarmed,	SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/wrestling,	SKILL_LEVEL_EXPERT, TRUE)
				H.change_stat(STATKEY_STR, 1)
				backpack_contents[/obj/item/rogueweapon/knuckles] = 1
				beltl	= /obj/item/rogueweapon/katar
			if("Chanter")
				H.adjust_skillrank_up_to(/datum/skill/magic/holy, SKILL_LEVEL_JOURNEYMAN, TRUE)
				var/datum/devotion/D = new /datum/devotion(H, H.patron)
				D.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_WEAK, devotion_limit = CLERIC_REQ_1)
			if("Cipher")
				ADD_TRAIT(H, TRAIT_ARCYNE_T2, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_JOURNEYMAN, TRUE)
				H.mind.adjust_spellpoints(8)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation)
				H.mind.check_learnspell()
				r_hand = /obj/item/spellbook_unfinished/pre_arcyne
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fetch)

		if(H.client)
			wretch_select_bounty(H)

/datum/advclass/wretch/maestro/post_equip(mob/living/carbon/human/H)
	..()
	if(H.age == AGE_OLD)
		H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_MASTER, TRUE)
		H.adjust_skillrank_up_to(/datum/skill/misc/music, SKILL_LEVEL_LEGENDARY, TRUE)
		H.change_stat(STATKEY_LCK, 1)
		H.change_stat(STATKEY_WIL, 1)
