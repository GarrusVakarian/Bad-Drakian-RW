// No DE/CR or armour trait. Unless dropping the pistol.
// Your entire thing is guns. You ARE the gun man. A pistoleer. A rifleman. Whatever.
// You get middling of a few things to start, but your mount and selection of weapon adjusts the statspread.
/datum/advclass/manorguard/dragoon
	name = "Dragoon"
	tutorial = "You are a Dragoon of the throne's service. A man or woman trained with an exceptionally rare smokepowder weapon. \
	Whether that be the exceedingly costly sidearm, or a fusil of distinguished make? \
	It matters not, for it had been commissioned for your use by the throne all the same."
	outfit = /datum/outfit/job/roguetown/manorguard/dragoon
	maximum_possible_slots = 2//A single blunderbuss is now a pasting weapon. This also lets us maintain 'these are rare', ish. Somewhat.

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
		/datum/skill/combat/unarmed = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/swords = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,//Like cavalry proper, if you go Pistoleer.
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,//Remain atop your mount, in an ideal world.
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_NOVICE,
	)

	extra_context = "This subclass has two paths of gameplay. It is restricted from the Equestrian virtue. \
	Pistoleers maintain the mount gameplay of cavalry, padded by a sidearm, with EXPT riding and the Equestrian trait. \
	Other choices provide an additional +1 INT/PER, medium armour training and the respective weapon. \
	Fusiliers additionally receive legendary firearms skill."

	virtue_restrictions = list(
		/datum/virtue/utility/riding
	)

	subclass_stashed_items = list("Caparison (Saiga)" = /obj/item/caparison, "Caparison (Fogbeast)" = /obj/item/caparison/fogbeast)

/datum/outfit/job/roguetown/manorguard/dragoon/pre_equip(mob/living/carbon/human/H)
	..()

	pants = /obj/item/clothing/under/roguetown/splintlegs
	wrists = /obj/item/clothing/wrists/roguetown/splintarms
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fencer
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	head = /obj/item/clothing/head/roguetown/chaperon/greyscale/dragoon
	backl = /obj/item/storage/backpack/rogue/backpack
	beltr = /obj/item/flashlight/flare/torch/lantern/prelit
	beltl = /obj/item/rogueweapon/sword

	H.adjust_blindness(-3)
	if(H.mind)
		var/weapons = list("Pistoleer","Fusilier", "Picket (Blunderbuss)")
		var/weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as anything in weapons
		H.set_blindness(0)
		switch(weapon_choice)
			if("Pistoleer")//Arquebus pistol and messer. This thing is CRACKED.
				l_hand = /obj/item/gun/ballistic/firearm/arquebus_pistol
				neck = /obj/item/quiver/bullet/lead
				ADD_TRAIT(H, TRAIT_EQUESTRIAN, TRAIT_GENERIC)
				H.adjust_skillrank_up_to(/datum/skill/misc/riding, SKILL_LEVEL_EXPERT, TRUE)
			if("Fusilier")//Fusil, same as in use on other maps. Not nearly as good.
				l_hand = /obj/item/gun/ballistic/firearm/flintgonne/fusil
				neck = /obj/item/quiver/bullet/lead
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_PER, 1)
				//So we give additional goodies. In the form of instant aiming. Because of a firing delay, unlike sidearms.
				//God help the duchy if they get a better firearm. Good lord. Also MA.
				H.adjust_skillrank_up_to(/datum/skill/combat/firearms, SKILL_LEVEL_LEGENDARY, TRUE)
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)//Go upgrade if you're a dripless knave.
			if("Picket (Blunderbuss)")//Bruise-ville is now available to you, m'lord. This is now stupid good.
				l_hand = /obj/item/gun/ballistic/firearm/blunderbuss
				neck = /obj/item/quiver/bullet/grapeshot
				H.change_stat(STATKEY_INT, 1)
				H.change_stat(STATKEY_PER, 1)
				//As with fusiliers, we give them a treat. Not legendary though, just MA.
				ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)//Again, m'lord. You need to rock the light armour look. Alas...

		belt_contents = list(/obj/item/storage/keyring/guardcastle = 1)
		backpack_contents = list(
			/obj/item/rogueweapon/huntingknife/combat/messer = 1,
			/obj/item/rogueweapon/scabbard/sheath = 1,
			/obj/item/rope/chain = 1,
			/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 1,
			/obj/item/powderflask = 1,
			)
		H.verbs |= /mob/proc/haltyell

//They get a mount, regardless of loadout.
	if (H.mind)
		H.AddSpell(new /obj/effect/proc_holder/spell/self/choose_riding_virtue_mount)
