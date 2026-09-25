// No DE/CR or armour trait.
// Your entire thing is guns. You ARE the gun man. A pistoleer. A rifleman. Whatever.
// You get middling of a few things to start, but your mount and selection of weapon adjusts the statspread.
/datum/advclass/manorguard/dragoon
	name = "Dragoon"
	tutorial = "You are a Dragoon of the throne's service. A man or woman trained with an exceptionally rare smokepowder weapon. \
	Whether that be the exceedingly costly sidearm, or a fusil of distinguished make? \
	It matters not, for it had been commissioned for your use by the throne all the same."
	outfit = /datum/outfit/job/roguetown/manorguard/dragoon

	category_tags = list(CTAG_MENATARMS)
	traits_applied = list(TRAIT_FUSILIER)
	subclass_stats = list(//-1 Stat over Skirmisher. No STR/SPD as is.
		STATKEY_WIL = 2,
		STATKEY_INT = 2,
		STATKEY_PER = 2,
	)
	subclass_skills = list(
		/datum/skill/combat/firearms = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,//Like cavalry proper, if you go Pistoleer.
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,//Remain atop your mount, in an ideal world.
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

	extra_context = "This subclass has two paths of gameplay. It is restricted from the Equestrian virtue. \
	Pistoleers maintain the mount gameplay of cavalry, padded by a sidearm, with EXPT riding, JMAN swords and the Equestrian trait. \
	Fusilier provides an additional +1 INT/PER, legendary firearms skill and the respective weapon."

	virtue_restrictions = list(
		/datum/virtue/utility/riding
	)

	subclass_stashed_items = list("Caparison (Saiga)" = /obj/item/caparison, "Caparison (Fogbeast)" = /obj/item/caparison/fogbeast)

/datum/outfit/job/roguetown/manorguard/dragoon/pre_equip(mob/living/carbon/human/H)
	..()

	neck = /obj/item/quiver/bullet/lead//They get a spare pouch in their bag, too.
	pants = /obj/item/clothing/under/roguetown/splintlegs
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	head = /obj/item/clothing/head/roguetown/chaperon/greyscale/dragoon
	backl = /obj/item/storage/backpack/rogue/backpack

	H.adjust_blindness(-3)
	if(H.mind)
		var/weapons = list("Pistoleer","Fusilier")
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("Pistoleer")//Arquebus pistol and messer. This thing is CRACKED.
				beltl = /obj/item/gun/ballistic/firearm/arquebus_pistol
				beltr = /obj/item/rogueweapon/sword
				ADD_TRAIT(H, TRAIT_EQUESTRIAN, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/misc/riding, SKILL_LEVEL_EXPERT, TRUE)
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
			if("Fusilier")//Fusil, same as in use on other maps. Not nearly as good.
				l_hand = /obj/item/gun/ballistic/firearm/flintgonne/fusil
				beltl = /obj/item/rogueweapon/sword
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_PER, 1)
				//So we give additional goodies. In the form of instant aiming. Because of a firing delay, unlike sidearms.
				//God help the duchy if they get a better firearm. Good lord.
				H.adjust_skillrank_up_to(/datum/skill/combat/firearms, SKILL_LEVEL_LEGENDARY, TRUE)

		backpack_contents = list(
			/obj/item/rogueweapon/huntingknife/combat/messer = 1,
			/obj/item/rogueweapon/scabbard/sheath = 1,
			/obj/item/rope/chain = 1,
			/obj/item/storage/keyring/guardcastle = 1,
			/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
			/obj/item/quiver/bullet/lead = 1,
			/obj/item/powderflask = 1,
			)
		H.verbs |= /mob/proc/haltyell

//They get a mount, regardless of loadout.
	if (H.mind)
		H.AddSpell(new /obj/effect/proc_holder/spell/self/choose_riding_virtue_mount)
