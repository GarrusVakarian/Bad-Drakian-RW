// Thieves' Guild Objective - No = assignments

/datum/objective/thieves_guild_objective
	name = "Thieves' Guild Objective"
	explanation_text = "Complete your Thieves' Guild task."
	var/target_item_path
	var/target_item_name
	var/is_mammon
	var/mammon_amount
	triumph_count = 5

/datum/objective/thieves_guild_objective/proc/setup_steal_objective()
	var/list/items
	items = list(
		list("Staff of the Shepherd", /obj/item/rogueweapon/woodstaff/aries),
		list("Crown of the Realm", /obj/item/clothing/head/roguetown/crown/serpcrown),
		list("Bell Ringer", /obj/item/rogueweapon/mace/church),
		list("Pepper Mill", /obj/item/reagent_containers/peppermill),
		list("Sword of the Mad Duke", /obj/item/rogueweapon/sword/rapier/lord),
		list("Judgement", /obj/item/rogueweapon/sword/long/judgement),
		list("Holy Book", /obj/item/book/rogue/bookofpriests),
		list("The Master Key", /obj/item/roguekey/lord),
		list("Book of Law", /obj/item/book/rogue/law),
		list("Garrison houndstone", /obj/item/scomstone/bad/garrison)
	)
	var/selected
	selected = pick(items)
	if(selected)
		target_item_name = selected[1]
		target_item_path = selected[2]
		is_mammon = FALSE
		return TRUE
	else
		return FALSE

/datum/objective/thieves_guild_objective/proc/setup_mammon_objective()
	is_mammon = TRUE
	mammon_amount = 1000
	return TRUE

/datum/objective/thieves_guild_objective/New(owner)
	..()
	if(owner)
		src.owner = owner
		if(prob(50) || !setup_steal_objective())
			setup_mammon_objective()
	update_explanation_text()

/datum/objective/thieves_guild_objective/update_explanation_text()
	..()
	if(is_mammon)
		explanation_text = "Have at least <b>[mammon_amount] mammon</b> on your person at the end of the round."
	else
		explanation_text = "Steal and keep <b>[target_item_name]</b> in your possession until the end of the round."

// Helper proc to get all items a mob is carrying, including inside containers
/proc/get_all_mob_items(mob/M)
	var/list/all_items = list()
	if(!M) return all_items
	for(var/obj/item/I in M.contents)
		all_items += I
		if(I.contents && I.contents.len)
			all_items += get_all_item_contents(I)
	return all_items

/proc/get_all_item_contents(obj/item/I)
	var/list/all_items = list()
	for(var/obj/item/subI in I.contents)
		all_items += subI
		if(subI.contents && subI.contents.len)
			all_items += get_all_item_contents(subI)
	return all_items

/datum/objective/thieves_guild_objective/proc/check_steal_completion()
	if(owner.current)
		for(var/obj/item/I in get_all_mob_items(owner.current))
			if(istype(I, target_item_path))
				return TRUE
	return FALSE

/datum/objective/thieves_guild_objective/check_completion()
	if(!owner)
		return FALSE
	if(!owner.current)
		return FALSE
	if(is_mammon)
		var/total_mammon = get_mammons_in_atom(owner.current)
		if(owner.current && owner.current.client)
			to_chat(owner.current, "[span_notice("Mammon objective check: you have [total_mammon] mammon counted in all containers.")]")
		return total_mammon >= mammon_amount
	return target_item_path && check_steal_completion()
