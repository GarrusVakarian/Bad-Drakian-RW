// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/rogue/antiquarian
	name = "Antiquarian"
	tutorial = "Your scholarship and connections allow you to find wealth where others do not care to look. You're unpracticed in direct combat, but knowledge and preparation leaves a few tricks up your sleeve."
	outfit = /datum/outfit/job/roguetown/adventurer/antiquarian
	cmode_music = 'sound/music/cmode/adventurer/combat_outlander3.ogg'
	traits_applied = list(TRAIT_SEEPRICES, TRAIT_GRAVEROBBER, TRAIT_INTELLECTUAL, TRAIT_ALCHEMY_EXPERT)
	category_tags = list(CTAG_ADVENTURER, CTAG_COURTAGENT)
	subclass_stats = list(
		STATKEY_STR = -1,
		STATKEY_INT = 2,
		STATKEY_PER = 2,
		STATKEY_WIL = 1,
		STATKEY_SPD = 2,
	)
	subclass_skills = list(
		/datum/skill/misc/tracking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_NOVICE,
		/datum/skill/combat/knives = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/engineering = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/alchemy = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_APPRENTICE,
	)

/datum/outfit/job/roguetown/adventurer/antiquarian/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("Your scholarship and connections allow you to find wealth where others do not care to look. You're unpracticed in direct combat, but knowledge and preparation leave a few tricks up your sleeve"))
	pants = /obj/item/clothing/under/roguetown/trou/leather
	backl = /obj/item/storage/backpack/rogue/backpack
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/flashlight/flare/torch/lantern
	cloak = /obj/item/clothing/cloak/thief_cloak
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/light
	shoes = /obj/item/clothing/shoes/roguetown/boots
	head = /obj/item/clothing/head/roguetown/roguehood
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	neck = /obj/item/clothing/neck/roguetown/leather
	backpack_contents = list(
		/obj/item/lockpick = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/skillbook/unfinished = 1,
		/obj/item/rogueweapon/huntingknife = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

	if(H.mind)
		var/weapons = list("Parrying Dagger","Whip", "Short Spear")
		var/weapon_choice = H.client ? input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons : null
		if(!weapon_choice)
			weapon_choice = (weapons)[1]
		H.set_blindness(0)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/ap_spell/matthios/barter_secular, H)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/fortifyingvapors)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/ap_flashpowder, H)
		switch(weapon_choice)
			if("Parrying Dagger")
				H.adjust_skillrank_up_to(/datum/skill/combat/knives, SKILL_LEVEL_APPRENTICE, TRUE)
				r_hand = /obj/item/rogueweapon/huntingknife/idagger/virtue
				backr = /obj/item/rogueweapon/scabbard/sheath
			if("Whip")
				H.adjust_skillrank_up_to(/datum/skill/combat/whipsflails, SKILL_LEVEL_APPRENTICE, TRUE)
				r_hand = /obj/item/rogueweapon/whip
			if("Short Spear")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_APPRENTICE, TRUE)
				r_hand = /obj/item/rogueweapon/spear
				backr = /obj/item/rogueweapon/scabbard/gwstrap

		var/utility = list("Enchanted Ring","Sling","Arcyne Affinity")
		var/utility_choice = H.client ? input(H, "Choose your utility.", "A RARE GIFT") as anything in utility : null
		if(!utility_choice)
			utility_choice = (utility)[1]
		H.set_blindness(0)
		switch(utility_choice)
			if("Enchanted Ring")
				var/rings = list("Swiftness","Vitality","Wisdom") //no courage because it gives unbound strength
				var/ring_choice = H.client ? input(H, "What enchantment?", "A RARE GIFT") as anything in rings : null
				if(!ring_choice)
					ring_choice = (rings)[1]
				H.set_blindness(0)
				switch(ring_choice)
					if("Swiftness")
						id = /obj/item/clothing/ring/statgemerald/antiquarian
					if("Vitality")
						switch(H.patron?.type)
							if(/datum/patron/inhumen/baotha)
								var/baotharing = list("Ring of Vitality","Rosa Ring")
								var/baotharing_choice = H.client ? input(H, "A discrete ring, or one of your faith?", "A RARE GIFT") as anything in baotharing : null
								if(!baotharing_choice)
									baotharing_choice = (baotharing)[1]
								H.set_blindness(0)
								switch(baotharing_choice)
									if("Ring of Vitality")
										id = /obj/item/clothing/ring/statonyx/antiquarian
									if("Rosa Ring")
										id = /obj/item/clothing/ring/griefflower
							else
								id = /obj/item/clothing/ring/statonyx/antiquarian
					if("Wisdom")
						id = /obj/item/clothing/ring/statamythortz/antiquarian //same effect but nearly worthless instead of 222 mammons
			if("Sling")
				H.adjust_skillrank_up_to(/datum/skill/combat/slings, SKILL_LEVEL_JOURNEYMAN, TRUE)
				l_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/sling
				beltl = /obj/item/quiver/sling/iron
			if("Arcyne Affinity")
				ADD_TRAIT(H, TRAIT_ARCYNE_T1, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/magic/arcane, SKILL_LEVEL_NOVICE, TRUE)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/prestidigitation, H)
				H.mind.adjust_spellpoints(5)
				H.mind.check_learnspell()
