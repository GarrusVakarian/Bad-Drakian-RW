/datum/advclass/vagabond_wanted
	name = "Wanted"
	examine_name = "Beggar"
	tutorial = "The long arm of the law reaches out for you - are you slippery enough to evade its grip this time, or is your head destined to end up in an Excidium's maw?"
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/vagabond/wanted
	category_tags = list(CTAG_VAGABOND)
	subclass_stats = list(
		STATKEY_PER = 2,
		STATKEY_SPD = 2,
		STATKEY_INT = -1
	)
	subclass_skills = list(
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
	)
	extra_context = "This class starts with a bounty."

/datum/outfit/job/roguetown/vagabond/wanted/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
	else if(should_wear_masc_clothes(H))
		pants = /obj/item/clothing/under/roguetown/tights/vagrant
		if(prob(50))
			pants = /obj/item/clothing/under/roguetown/tights/vagrant/l
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
		if(prob(50))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l

	if(prob(33))
		cloak = /obj/item/clothing/cloak/half/brown
		gloves = /obj/item/clothing/gloves/roguetown/fingerless

	if (H.mind)
		H.change_stat(STATKEY_LCK, rand(-2, 2))
		if(!H.client)
			return
		var/list/preset = H.bounty_presets?["Wanted vagabond"]
		var/my_crime = preset ? preset["crime"] : input(H, "What is your crime?", "Crime") as text|null
		if(QDELETED(H) || !H.client)
			return
		if(!my_crime)
			my_crime = "crimes against the Crown"
		var/bounty_amount = preset ? preset["tier"] : choose_character_bounty_tier(H, "Wanted vagabond")
		var/bounty_total = roll_character_bounty_reward("Wanted vagabond", bounty_amount)
		if(!bounty_total || QDELETED(H) || !H.client)
			return
		add_character_bounty(H, bounty_total, FALSE, my_crime, character_bounty_issuer("justiciary"), bounty_amount == "Massive" ? BOUNTY_DESCRIPTION_FULL : BOUNTY_DESCRIPTION_BUILD, bounty_amount == "Meager" ? BOUNTY_RECOGNITION_NONE : BOUNTY_RECOGNITION_FACE)
		to_chat(H, span_notice("I'm on the run from the law, and there's a [LOWER_TEXT(bounty_amount)] sum of mammons out on my head... better lay low."))
