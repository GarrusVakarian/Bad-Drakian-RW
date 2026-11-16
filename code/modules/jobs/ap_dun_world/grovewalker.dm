// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/advclass/foreigner/lesserblackoak
	name = "Azurian Grovewalker"
	tutorial = "Autumn's grace trails you as a guardian-errant of the Black Oaks; an irregular militia that \
	fights for the ancestral elven homelands of Azuria. Nature's call manifests along your blossoming bark, \
	and you shall answer. Whether through blade or bow, you shall ensure that those who dare to disrespect \
	Azuria's supple forests will learn to regret it."
	extra_context = "This class is restricted to the Elf, Half-Elf, and Dark Elf species."
	class_select_category = CLASS_CAT_RACIAL
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(/datum/species/human/halfelf, /datum/species/elf/wood, /datum/species/elf/dark)
	traits_applied = list(TRAIT_OUTDOORSMAN, TRAIT_BLACKOAK, TRAIT_DODGEEXPERT, TRAIT_WOODWALKER)
	outfit = /datum/outfit/job/roguetown/adventurer/lesserblackoak
	subclass_languages = list(/datum/language/elvish)
	cmode_music = 'sound/music/combat_blackoak.ogg'
	maximum_possible_slots = 3 //A little stronger than a traditional Nomad or Adventurer. The slot limit is more-so intended to keep them a limited presence within Azuria, and to account for their potentially antagonistic nature.
	subclass_stats = list(
		STATKEY_PER = 2,
		STATKEY_SPD = 2,
		STATKEY_WIL = 1, //Seven-pointed statblock. Glass cannon-coded, with an emphasis on naturally-high ranged damage and melee accuracy.
	)
	subclass_skills = list(
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/wrestling = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/unarmed = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/tracking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/tanning = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/carpentry = SKILL_LEVEL_NOVICE,
		/datum/skill/labor/farming = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/adventurer/lesserblackoak/pre_equip(mob/living/carbon/human/H)
	..()
	to_chat(H, span_warning("Whether through merit or heritage, you've earned the right of tutelage under the Black Oaks; an irregular militia that fights for the ancestral elven homelands of Azuria. Jaunt through the underbrush and oppress the oppressors with both blade-and-bow."))
	H.set_blindness(0)
	if(H.mind)
		var/weapons = list("Autumned Longsword","Autumned Glaive","Autumned Bow")
		var/weapon_choice = H.client ? input(H, "Choose your WEAPON.", "WARD NATURE FROM THOSE WHO SEEK TO DEFILE IT.") as anything in weapons : null
		if(!weapon_choice)
			weapon_choice = (weapons)[1]
		switch(weapon_choice)
			if("Autumned Longsword")
				H.adjust_skillrank_up_to(/datum/skill/combat/swords, SKILL_LEVEL_JOURNEYMAN, TRUE)
				l_hand = /obj/item/rogueweapon/sword/long/elvish/autumn
				beltr = /obj/item/rogueweapon/scabbard/sword
			if("Autumned Glaive")
				H.adjust_skillrank_up_to(/datum/skill/combat/polearms, SKILL_LEVEL_JOURNEYMAN, TRUE)
				l_hand = /obj/item/rogueweapon/halberd/bardiche/elvish/autumn
				backr = /obj/item/rogueweapon/scabbard/gwstrap
			if("Autumned Bow")
				H.adjust_skillrank_up_to(/datum/skill/combat/bows, SKILL_LEVEL_JOURNEYMAN, TRUE)
				l_hand = /obj/item/gun/ballistic/revolver/grenadelauncher/bow/autumn
				beltr = /obj/item/quiver/arrows
	head = /obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/autumn/light
	armor = /obj/item/clothing/suit/roguetown/armor/plate/elven_plate/autumn/light
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/boots/elven_boots/autumn
	cloak = /obj/item/clothing/cloak/forrestercloak/autumn
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	gloves = /obj/item/clothing/gloves/roguetown/elven_gloves/autumn
	belt = /obj/item/storage/belt/rogue/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	pants = /obj/item/clothing/under/roguetown/trou/leather
	backpack_contents = list(
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
		/obj/item/rogueweapon/huntingknife/idagger/elvish/autumn = 1,
		/obj/item/rogueweapon/scabbard/sheath = 1,
		)

/obj/item/rogueweapon/sword/long/elvish/autumn
	name = "autumned elvish longsword"
	desc = "A curved longsword, hewn from a melody of faeiron and the living bark of an Azurian \
	elk tree. Unlike traditional alloys, faeiron is refined purely through the mystical arcyne \
	techniques of the Black Oaks; nature's stones, hewn to catch and cleave like steel."
	icon = 'icons/roguetown/weapons/swords64.dmi'
	icon_state = "aelflongsword"
	sellprice = 20
	sheathe_icon = "aelfsword"
	smeltresult = /obj/item/ingot/iron
	max_blade_int = 230 //Equivalent to an Iron Broadsword.
	max_integrity = 180 //Ditto.

/obj/item/rogueweapon/halberd/bardiche/elvish/autumn
	possible_item_intents = list(/datum/intent/spear/thrust/oneh, SPEAR_BASH)
	gripped_intents = list(/datum/intent/spear/thrust, /datum/intent/spear/cut, /datum/intent/spear/cut/bardiche/cleave, /datum/intent/spear/cut/glaive/sweep)
	name = "autumned elvish bardiche"
	desc = "A cleaving polearm, hewn from the branch of an Azurian elk tree and tipped with a wide blade of faeiron. The \
	tapered edge can thrust through an oppressor's armor at the right range, while its wide sweeps can dispel even the \
	rowdiest of lumberfoots."
	icon_state = "aebardiche"
	max_blade_int = 200
	wdefense = 5
	smeltresult = /obj/item/ingot/iron

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/autumn
	name = "autumnwoad bow"
	desc = "A medium length bow hewn from an Azurian elk tree branch, it still feels as if it is one with nature; unsullied by the cruder butcherments of Man. \
	</br>'The summer sun is fading \
	as the year grows old, and darker days are drawing near..'"
	icon_state = "bow_blackoak"

/obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/autumn/light
	name = "autumnwoad elven barbute"
	desc = "A helmet of woven trunk, kept alive by ancient song and bristled with leaves \
	of perpetual autumnage. Unblossomed woadmaille can be splintered far easier than their \
	springlyfed counterparts, but - consequently - becomes far lighter to maneuver with. </br>'..the \
	winter winds will be much colder, now you're not here..'"
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfheadalt"
	item_state = "awelfheadalt"
	bloody_icon = 'icons/effects/blood64.dmi'
	armor_class = ARMOR_CLASS_LIGHT //Very good protection against stabbing and crushing, but completely unprotected to cutting and chopping. Unique to this specific class, and appropriately weakened to compensate.
	max_integrity = ARMOR_INT_HELMET_LEATHER //-33% durability hit, with 200HP instead of 300HP.
	body_parts_covered = HEAD|HAIR|NOSE|EARS

/obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/autumn
	name = "autumnwoad elven helm"
	desc = "A helmet of thickly woven trunk, kept alive by ancient song and bristled with leaves \
	of perpetual autumnage. Unblossomed woadmaille can be splintered far easier than their \
	springlyfed counterparts, but - consequently - becomes far lighter to maneuver with. </br>'..the \
	winter winds will be much colder, now you're not here..'"
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfhead"
	item_state = "awelfhead"
	bloody_icon = 'icons/effects/blood64.dmi'
	armor_class = ARMOR_CLASS_LIGHT //Very good protection against stabbing and crushing, but completely unprotected to cutting and chopping. Unique to this specific class, and appropriately weakened to compensate.
	max_integrity = ARMOR_INT_HELMET_HARDLEATHER //-15% durability hit, with 250HP instead of 300HP.

/obj/item/clothing/suit/roguetown/armor/plate/elven_plate/autumn/light
	name = "autumwoad elven maille"
	desc = "An assembly of woven trunk, kept alive by ancient song and bristled with leaves \
	of perpetual autumnage. As the mythos goes, the tone of woaden armor can sway with the \
	emotions of its wearer - for even the eldest of the Black Oaks can see their bark shifting \
	back to that familiar crimson hue, whenever they're stricken with the yearning of \
	tymes past. </br>'Like the sun through the trees you came to love me.. and like a leaf on a breeze, you blew away..'"
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfchestalt"
	item_state = "awelfchestalt"
	max_integrity = ARMOR_INT_CHEST_LIGHT_MASTER //-33% durability hit, with 300 instead of 500HP.
	body_parts_covered = CHEST | VITALS | LEGS

/obj/item/clothing/suit/roguetown/armor/plate/elven_plate/autumn
	name = "autumwoad elven plate"
	desc = "An assembly of thickly woven trunk, kept alive by ancient song and bristled with leaves \
	of perpetual autumnage. As the mythos goes, the tone of woaden armor can sway with the \
	emotions of its wearer - for even the eldest of the Black Oaks can see their bark shifting \
	back to that familiar crimson hue, whenever they're stricken with the yearning of \
	tymes past. </br>'Like the sun through the trees you came to love me.. and like a leaf on a breeze, you blew away..'"
		//Uniquely wearable among all races, as it's 'unblossomed' and appropriately malleable enough to fit on smaller bodies.
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfchest"
	item_state = "awelfchest"
	armor_class = ARMOR_CLASS_LIGHT //Ditto.
	max_integrity = ARMOR_INT_CHEST_PLATE_BRIGANDINE + 25 //-25ish% durability hit, with 375 instead of 500HP.

/obj/item/clothing/shoes/roguetown/boots/elven_boots/autumn
	name = "autumnwoad elven boots"
	desc = "A pair of mossboots that ache with the sounds of living nature, and teem with the colors \
	of perpetual autumnage. It is said that a Black Oak's armor will only fully blossom once they've \
	earned the mantle of guardianship; to forsake one's oath to nature is to dispel the ancient songs, \
	and to let the bark wither away. </br>'..those fallen leaves lie undisturbed now, 'cause you're not here!'"

	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfshoes"
	item_state = "awelfshoes"
	max_integrity = ARMOR_INT_SIDE_LEATHER - 25 // -20% durability hit, with 175HP instead of 225HP.

//

/obj/item/clothing/cloak/forrestercloak/autumn
	name = "autumneer cloak"
	desc = "'A gentle rain falls softly on my weary eyes, as if to hide a lonely tear.. my life will be forever autumn..'"
	icon_state = "aforestcloak"
	alternate_worn_layer = CLOAK_BEHIND_LAYER
	slot_flags = ITEM_SLOT_BACK_R|ITEM_SLOT_CLOAK
	sleeved = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	sleevetype = "shirt"
	nodismemsleeves = TRUE
	inhand_mod = TRUE

/obj/item/clothing/gloves/roguetown/elven_gloves/autumn
	name = "autumnwoad elven gloves"
	desc = "Barkgloves that've been freshly weened off the trunk of a sturdy Azurian elk tree, and \
	mystically preserved in a state of perpetual autumnage. Crimson vines and leaves poke out from \
	its living joints, wicking away sweat like a sponge to water. </br>'Through autumn's golden gown \
	we used to kick our way, you always loved this time of year..'"

	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "awelfhand"
	item_state = "awelfhand"
	max_integrity = ARMOR_INT_SIDE_LEATHER - 25 // -20% durability hit, with 175HP instead of 225HP.

/obj/item/rogueweapon/huntingknife/idagger/elvish/autumn
	name = "autumned elvish dagger"
	desc = "A wave-bladed dagger of faeiron, fitted from the branch of an Azurian elk \
	tree. Just like its elegant creators, so too does it glide through the gaps in maille \
	like an elf effortlessly bounding across the Groves."
	icon_state = "aelfdagger"
	sheathe_icon = "aelfdagger"
	force = 15 //Equivalent to an Iron Dagger, with +33% integrity.
	max_integrity = 150
	smeltresult = /obj/item/ingot/iron
	smelt_bar_num = 1
