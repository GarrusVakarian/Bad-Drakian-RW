// lirvan tithebound - decided to make this as modular as possible for a few reasons. should work fine.

/datum/job/roguetown/mercenary/New()
	. = ..()
	job_subclasses += /datum/advclass/mercenary/lirvanmerc

/datum/advclass/mercenary/lirvanmerc
	name = "Gilded Tithebound"
	tutorial = "Contrary to the name, you're not indebted. Far from it. You hail from a secretive order of ritualists that wield the fact that WEALTH and AUTHORITY are the keys to POWER in its truest form as a weapon. Whether you stand by Astrata's order or Matthios' exchange, with tough scales hardened by your rituals and gilded armor to inspire the jealousy of all who'd stand against you, prove your might to the world, one Mammon at a time."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(
		/datum/species/dracon,
		/datum/species/lizardfolk,
		/datum/species/kobold,
	)
	outfit = /datum/outfit/job/roguetown/mercenary/lirvanmerc
	class_select_category = CLASS_CAT_RACIAL
	category_tags = list(CTAG_MERCENARY)
	traits_applied = list(TRAIT_SEEPRICES, TRAIT_MEDIUMARMOR)
	cmode_music = 'sound/music/combat_matthios.ogg'
	maximum_possible_slots = 2

	subclass_stats = list(
		STATKEY_STR = 2, //stats roughly equiv to adv, give or take one. when buff is active, they will have more than merc; when inactive, less
		STATKEY_CON = 1,
		STATKEY_WIL = 1,
		STATKEY_PER = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/maces = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_NOVICE, //pity. your staff is incredibly fragile
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/polearms = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
	)
	extra_context = "This subclass is race-limited to: Drakian, Sissean, and Kobold. This subclass locks you to Matthios or Astrata-worship."

/datum/outfit/job/roguetown/mercenary/lirvanmerc
	allowed_patrons = list(/datum/patron/divine/astrata, /datum/patron/inhumen/matthios)

/datum/outfit/job/roguetown/mercenary/lirvanmerc/pre_equip(mob/living/carbon/human/H)
	..()

	cloak = /obj/item/clothing/cloak/ordinatorcape/lirvas
	wrists = /obj/item/clothing/wrists/roguetown/bracers/lirvas
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	beltr = /obj/item/rogueweapon/sword/long/dec
	beltl = /obj/item/rogueweapon/scabbard/sword/noble
	neck = /obj/item/clothing/neck/roguetown/gorget/steel/gold
	armor = /obj/item/clothing/suit/roguetown/armor/regenerating/skin/lirvas
	pants = /obj/item/clothing/under/roguetown/chainlegs/kilt/gold
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	backr = /obj/item/storage/backpack/rogue/satchel/black
	r_hand = /obj/item/storage/belt/rogue/pouch/coins/mid
	backpack_contents = list(
		/obj/item/roguekey/mercenary = 1,
		/obj/item/flashlight/flare/torch = 1,
		)

	if(!H.mind)
		return

	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/lirvan_tithe)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/lirvan_raze)

	var/list/weapon_choices = list("Staff", "Unarmed")
	var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapon_choices
	switch(weapon_choice)
		if("Staff")
			gloves = /obj/item/clothing/gloves/roguetown/angle
			shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/gold
			l_hand = /obj/item/rogueweapon/woodstaff/quarterstaff/gold
			H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_EXPERT, TRUE)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/saxtonhale)
		if("Unarmed")
			if(H.gender == FEMALE)
				shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
			gloves = /obj/item/clothing/gloves/roguetown/bandages/pugilist
			ADD_TRAIT(H, TRAIT_CIVILIZEDBARBARIAN, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_GENERIC)
			H.adjust_skillrank_up_to(/datum/skill/combat/unarmed, SKILL_LEVEL_EXPERT, TRUE)
			H.adjust_skillrank_up_to(/datum/skill/combat/wrestling, SKILL_LEVEL_JOURNEYMAN, TRUE)
			H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/lirvan_talon)

	var/list/patron_choices = list("The ORDER and MONARCHY of Astrata", "The WEALTH and POWER of Matthios")
	var/patron_choice = input(H, "What do you worship?", "Choose a Patron", "The WEALTH and POWER of Matthios") as anything in patron_choices
	switch(patron_choice)
		if("The ORDER and MONARCHY of Astrata")
			H.set_patron(/datum/patron/divine/astrata)
			H.adjust_skillrank_up_to(/datum/skill/misc/reading, SKILL_LEVEL_EXPERT, TRUE) //idfk what astratans do man
		if("The WEALTH and POWER of Matthios")
			H.set_patron(/datum/patron/inhumen/matthios)
			H.adjust_skillrank_up_to(/datum/skill/misc/athletics, SKILL_LEVEL_JOURNEYMAN, TRUE)
