// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/mage/spellfist
	name = "Spellfist"
	tutorial = "You are a Spellfist, an unarmed warrior who combines martial prowess with arcyne magyck. Your art descends from the Pontifexes of Naledi, warrior-monks who first learned to channel arcyne power through their fists, though the technique has since spread across the world — especially to Lingyuese Psydonites in the east. You eschew most weapons in favor of using magyck to accelerate and strengthen your own body, striking enemies with blows from afar and storms of fists up close."
	outfit = /datum/outfit/job/roguetown/adventurer/spellfist
	traits_applied = list(TRAIT_CIVILIZEDBARBARIAN, TRAIT_ARCYNE_T2)
	subclass_stats = list(
		STATKEY_STR = 2,
		STATKEY_WIL = 1,
		STATKEY_CON = 2
	)
	subclass_spellpoints = 5
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_JOURNEYMAN, // Bare-handed abilities no weapon and read AA. Match unarmed.
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/adventurer/spellfist/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/headband/monk
	shoes = /obj/item/clothing/shoes/roguetown/boots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt =	/obj/item/clothing/suit/roguetown/armor/gambeson
	armor =	/obj/item/clothing/suit/roguetown/armor/leather/heavy
	gloves = /obj/item/clothing/gloves/roguetown/angle
	neck = /obj/item/clothing/neck/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/cloth/monk
	belt = /obj/item/storage/belt/rogue/leather/rope
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltr = /obj/item/rogueweapon/huntingknife
	var/naledi_book = pick(/obj/item/book/rogue/naledi1, /obj/item/book/rogue/naledi2, /obj/item/book/rogue/naledi3, /obj/item/book/rogue/naledi4)
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		(naledi_book) = 1,
		/obj/item/spellbook_unfinished/pre_arcyne = 1,
		/obj/item/chalk = 1,
		/obj/item/roguegem/amethyst = 1,
	)

	var/origin = H.client ? input(H, "Did you study under the Naledi Yogis?", "Origin") as null|anything in list("Yes", "No") : "No"
	if(origin == "Yes")
		head = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab/black
		armor = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
	var/sidearm = H.client ? input(H, "Choose your sidearm.", "Spellfist") as null|anything in list("Katar", "Knuckledusters") : "Katar"
	r_hand = sidearm == "Knuckledusters" ? /obj/item/rogueweapon/knuckles/bronzeknuckles : /obj/item/rogueweapon/katar/bronze
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/ap_spell/fist_of_psydon, H)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/ap_spell/grasp_of_psydon, H)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/ap_spell/storm_of_psydon, H)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/shadowstep)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/mending)
		H.apply_status_effect(/datum/status_effect/buff/ap_arcyne_momentum)
		to_chat(H, span_notice("Land punches or strikes with an unarmed weapon to build momentum. Fist and Grasp consume three stacks for stronger effects. Storm requires seven stacks, and unleashes its full flurry at ten. Stuns and knockdowns break your concentration."))
