// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/templar/noc_spellblade
	name = "Noccite Azurcaephan"
	tutorial = "You are a Noccite Azurcaephan - A devotee of the Azurean Church\
	Other templars clad themselves in heavy armor and relies on their miracles and their cone\
	But you know Noc's true teaching - he granted knowledge so we, humen, may seize upon it and uses magyck\
	to seize our own destiny. With steel in one hand, sorcery in the other, and Noc's blessing in your heart\
	None can stand against you. Protect the Church, its myriad acolytes, and further the pursuit of enlightenment, knowledge and mastery."
	outfit = /datum/outfit/job/roguetown/templar/noc_spellblade
	category_tags = list(CTAG_TEMPLAR)
	allowed_patrons = list(/datum/patron/divine/noc)
	maximum_possible_slots = 2 // The Special Snowflake And Their Friend
	subclass_languages = list(/datum/language/grenzelhoftian)
	traits_applied = list(TRAIT_MEDIUMARMOR, TRAIT_ARCYNE_T2)
	subclass_stats = list(
		STATKEY_STR = 1,
		STATKEY_INT = 1, // Weighted 7 but a nice statblock
		STATKEY_PER = 1,
		STATKEY_CON = 1,
		STATKEY_WIL = 2,
	)
	subclass_spellpoints = 5
	subclass_skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/shields = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/magic/holy = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/templar/noc_spellblade
	has_loadout = TRUE
	var/ap_training = "blade"

/datum/outfit/job/roguetown/templar/noc_spellblade/pre_equip(mob/living/carbon/human/H)
	..()

	// Equipment — medium armor templar with Noc theming
	cloak = /obj/item/clothing/cloak/tabard
	armor = /obj/item/clothing/suit/roguetown/armor/plate/cuirass/fluted
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	wrists = /obj/item/clothing/wrists/roguetown/bracers/jackchain
	gloves = /obj/item/clothing/gloves/roguetown/chain
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	pants = /obj/item/clothing/under/roguetown/chainlegs
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather/reinforced
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/rogueweapon/shield/heater
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/clothing/neck/roguetown/psicross/noc
	id = /obj/item/clothing/ring/silver
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 1,
		/obj/item/ritechalk = 1,
		/obj/item/rope/chain = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		/obj/item/storage/keyring/churchie = 1,
		/obj/item/spellbook_unfinished/pre_arcyne = 1,
		/obj/item/roguegem/amethyst = 1,
	)

	backpack_contents[/obj/item/rogueweapon/huntingknife/idagger/steel] = 1

	H.cmode_music = 'sound/music/cmode/church/combat_reckoning.ogg'


	ap_training = ap_spellblade_training(H)
	if(H.mind)
		SStreasury.grant_savings(rand(40, 80), H)

	var/helmets = list(
		"Greatplumed Owl Armet" = /obj/item/clothing/head/roguetown/helmet/heavy/nochelm,
		"Noc Helmet"			= /obj/item/clothing/head/roguetown/helmet/heavy/nochelm,
		"Snouted Noc Helmet"			= /obj/item/clothing/head/roguetown/helmet/heavy/nochelm/snouted
	)
	var/helmchoice = H.client ? input(H, "Choose your Helm.", "REFLECTION OF PALE LIGHT") as anything in helmets : null
	if(!helmchoice)
		helmchoice = (helmets)[1]
	head = helmets[helmchoice]
	if(H.mind)
		var/datum/devotion/C = new /datum/devotion(H, H.patron)
		C.grant_miracles(H, cleric_tier = CLERIC_T1, passive_gain = CLERIC_REGEN_MINOR, devotion_limit = CLERIC_REQ_1, start_maxed = TRUE)

/datum/outfit/job/roguetown/templar/noc_spellblade/choose_loadout(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	if(!H.client)
		return ..()
	. = ..()
	var/spellblade_chant_selected = ap_training

	var/obj/item/rogueweapon/granted_weapon = null
	switch(spellblade_chant_selected)
		if("blade")
			var/list/weapons = list("Moonlight Khopesh", "Moonlight Kriegmesser", "Longsword", "Rapier", "Sabre", "Steel Arming Sword", "Steel Greatsword", "Steel Dagger", "Twilight Fang")
			var/weapon_choice = H.client ? input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons : null
			if(!weapon_choice)
				weapon_choice = (weapons)[1]
			switch(weapon_choice)
				if("Moonlight Khopesh")
					granted_weapon = new /obj/item/rogueweapon/sword/sabre/nockhopesh(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Moonlight Kriegmesser")
					granted_weapon = new /obj/item/rogueweapon/sword/long/kriegmesser(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Longsword")
					granted_weapon = new /obj/item/rogueweapon/sword/long/church(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Rapier")
					granted_weapon = new /obj/item/rogueweapon/sword/rapier(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Sabre")
					granted_weapon = new /obj/item/rogueweapon/sword/sabre(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Steel Arming Sword")
					granted_weapon = new /obj/item/rogueweapon/sword(H)
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/sword(H), SLOT_BELT_R, TRUE)
				if("Steel Greatsword")
					granted_weapon = new /obj/item/rogueweapon/greatsword(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
				if("Steel Dagger")
					granted_weapon = new /obj/item/rogueweapon/huntingknife/idagger/steel(H)
				if("Twilight Fang")
					granted_weapon = new /obj/item/rogueweapon/huntingknife/idagger/steel(H)
		if("phalangite")
			var/polearm_weapons = list("Halberd", "Bardiche", "Moonlight Spear", "Dory", "Naginata")
			var/polearm_choice = H.client ? input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in polearm_weapons : null
			if(!polearm_choice)
				polearm_choice = (polearm_weapons)[1]
			switch(polearm_choice)
				if("Halberd")
					granted_weapon = new /obj/item/rogueweapon/halberd(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
				if("Bardiche")
					granted_weapon = new /obj/item/rogueweapon/halberd/bardiche(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
				if("Moonlight Spear")
					granted_weapon = new /obj/item/rogueweapon/spear/boar(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
				if("Dory")
					granted_weapon = new /obj/item/rogueweapon/spear(H)
				if("Naginata")
					granted_weapon = new /obj/item/rogueweapon/spear/naginata(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
		if("macebearer")
			var/mace_weapons = list("Steel Mace", "Steel Warhammer", "Grand Mace", "Battle Axe", "Steel Greataxe")
			var/mace_choice = H.client ? input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in mace_weapons : null
			if(!mace_choice)
				mace_choice = (mace_weapons)[1]
			switch(mace_choice)
				if("Steel Mace")
					granted_weapon = new /obj/item/rogueweapon/mace/steel(H)
				if("Steel Warhammer")
					granted_weapon = new /obj/item/rogueweapon/mace/warhammer/steel(H)
				if("Grand Mace")
					granted_weapon = new /obj/item/rogueweapon/mace/goden/steel(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
				if("Battle Axe")
					granted_weapon = new /obj/item/rogueweapon/stoneaxe/battle(H)
				if("Steel Greataxe")
					granted_weapon = new /obj/item/rogueweapon/greataxe/steel(H)
					qdel(H.get_item_by_slot(SLOT_BACK_R))
					H.equip_to_slot_or_del(new /obj/item/rogueweapon/scabbard/gwstrap(H), SLOT_BACK_R, TRUE)
	if(granted_weapon)
		H.put_in_hands(granted_weapon)
		H.adjust_skillrank_up_to(granted_weapon.associated_skill, SKILL_LEVEL_EXPERT, TRUE)
