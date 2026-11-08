/// Shared helper procs for the recipe book and OOC wiki systems.

/proc/get_recipe_category(path)
	if(!ispath(path))
		return null
	var/datum/temp_recipe
	var/category

	if(ispath(path, /datum/crafting_recipe))
		temp_recipe = new path()
		var/datum/crafting_recipe/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/anvil_recipe))
		temp_recipe = new path()
		var/datum/anvil_recipe/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/book_entry))
		temp_recipe = new path()
		var/datum/book_entry/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/alch_grind_recipe))
		temp_recipe = new path()
		var/datum/alch_grind_recipe/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/alch_cauldron_recipe))
		temp_recipe = new path()
		var/datum/alch_cauldron_recipe/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/brewing_recipe))
		temp_recipe = new path()
		var/datum/brewing_recipe/r = temp_recipe
		category = r.category
	else if(ispath(path, /datum/food_recipe))
		category = initial(path:book_category)
	else if(ispath(path, /datum/stew_recipe))
		category = "Soups and Stews"
	else if(ispath(path, /datum/runeritual))
		temp_recipe = new path()
		var/datum/runeritual/r = temp_recipe
		category = r.category
	else if(ispath(path, /obj/effect/proc_holder/spell))
		var/tier = initial(path:spell_tier)
		category = "Tier [tier]"
		return category

	if(temp_recipe)
		qdel(temp_recipe)
	return category

/proc/should_hide_recipe(path)
	if(ispath(path, /datum/crafting_recipe))
		var/datum/crafting_recipe/recipe = path
		if(initial(recipe.hides_from_books) || (ispath(path, /datum/crafting_recipe/roguetown/cooking) && ispath(initial(recipe.result), /obj/item/clothing)))
			return TRUE
	if(ispath(path, /datum/anvil_recipe))
		var/datum/anvil_recipe/recipe = path
		if(initial(recipe.hides_from_books))
			return TRUE
	if(ispath(path, /datum/runeritual))
		var/datum/runeritual/ritual = path
		if(initial(ritual.blacklisted))
			return TRUE
	return FALSE

/proc/gather_recipe_categories(list/types)
	var/list/categories = list("All")
	for(var/atom/path as anything in types)
		if(is_abstract(path))
			for(var/atom/sub_path as anything in subtypesof(path))
				if(is_abstract(sub_path))
					continue
				var/category = get_recipe_category(sub_path)
				if(category && !(category in categories))
					categories += category
		else
			var/category = get_recipe_category(path)
			if(category && !(category in categories))
				categories += category
	categories = sortTim(categories, GLOBAL_PROC_REF(cmp_text_asc))
	if("All" in categories)
		categories -= "All"
		categories.Insert(1, "All")
	return categories

/proc/generate_recipe_detail_html(path, mob/user)
	if(!ispath(path))
		return "<div class='recipe-content'><p>Invalid recipe selected.</p></div>"

	var/html = "<div class='recipe-content'>"
	var/recipe_name = "Unknown Recipe"
	var/recipe_html = ""

	var/datum/temp_recipe
	if(ispath(path, /datum/crafting_recipe))
		temp_recipe = new path()
		var/datum/crafting_recipe/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_html(user)
	else if(ispath(path, /datum/anvil_recipe))
		temp_recipe = new path()
		var/datum/anvil_recipe/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_wiki_html(user)
	else if(ispath(path, /datum/book_entry))
		temp_recipe = new path()
		var/datum/book_entry/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = "<h2>[html_encode(recipe_name)]</h2>[r.inner_book_html(user)]"
	else if(ispath(path, /datum/alch_grind_recipe))
		temp_recipe = new path()
		var/datum/alch_grind_recipe/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_html(user)
	else if(ispath(path, /datum/alch_cauldron_recipe))
		temp_recipe = new path()
		var/datum/alch_cauldron_recipe/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_html(user)
	else if(ispath(path, /datum/brewing_recipe))
		temp_recipe = new path()
		var/datum/brewing_recipe/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_html(user)
	else if(ispath(path, /datum/runeritual))
		temp_recipe = new path()
		var/datum/runeritual/r = temp_recipe
		recipe_name = initial(r.name)
		recipe_html = r.generate_html(user)
	else if(ispath(path, /datum/stew_recipe))
		temp_recipe = new path()
		var/datum/stew_recipe/r = temp_recipe
		var/datum/reagent/output = r.output
		recipe_name = r.name
		recipe_html = "<h2>[html_encode(r.name)]</h2><p>Boil water in a hot pot, then add any of these ingredients:</p><ul>"
		for(var/atom/ingredient as anything in r.inputs)
			recipe_html += "<li>[food_recipe_icon(ingredient, user)] [html_encode(initial(ingredient.name))]</li>"
		recipe_html += "</ul><p>Produces [html_encode(initial(output.name))]. Simmer for [r.cooktime / 10] seconds per ingredient; consumes 30dr of water.</p>"
	else if(ispath(path, /obj/effect/proc_holder/spell))
		var/obj/effect/proc_holder/spell/temp_spell = new path()
		recipe_name = temp_spell.name
		recipe_html = temp_spell.generate_wiki_html(user)
		qdel(temp_spell)

	if(temp_recipe)
		qdel(temp_recipe)

	if(recipe_html && recipe_html != "")
		html += recipe_html
	else
		html += "<h2 class='recipe-title'>[recipe_name]</h2>"
		html += "<p>No detailed information available.</p>"

	html += "</div>"
	return html

// Same smithing information as the physical book, without spawning example items.
/datum/anvil_recipe/proc/generate_wiki_html(mob/user)
	var/client/client = user
	if(!istype(client))
		client = user.client
	user << browse_rsc('html/book.png')
	var/html = {"
		<!DOCTYPE html>
		<html lang="en">
		<meta charset='UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1'/>
		<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'/>
		<body>
		  <div>
		    <h1>[icon2html(created_item, user)][name]</h1>
			<h4>DESCRIPTION: [initial(created_item.desc)]</h4>
			<div>
		"}
	var/obj/item/clothing/suit/roguetown/armor/bookarmor = initial(created_item)
	var/obj/item/rogueweapon/bookweapon = initial(created_item)

	if(!(bookarmor.armor == "")&&!isnull(bookarmor.armor) )
		var/obj/item/clothing/C = initial(created_item)
		if(C.body_parts_covered)
			html += "\n<b>COVERAGE: </b>"
			html += " | "
			if(C.body_parts_covered == C.body_parts_covered_dynamic)
				for(var/zone in body_parts_covered2organ_names(C.body_parts_covered))
					html += "<b>[capitalize(zone)]</b> | "
			else
				var/list/zones = list()
				//We have some part peeled, so we turn the printout into precise mode and highlight the missing coverage.
				for(var/zoneorg in body_parts_covered2organ_names(C.body_parts_covered, precise = TRUE))
					zones += zoneorg
				for(var/zonedyn in body_parts_covered2organ_names(C.body_parts_covered_dynamic, precise = TRUE))
					html += "<b>[capitalize(zonedyn)]</b> | "
					if(zonedyn in zones)
						zones.Remove(zonedyn)
				for(var/zone in zones)
					html += "<b><font color = '#470000'>[capitalize(zone)]</font></b> | "
			html += "<br>"
		if(C.body_parts_inherent)
			html += "<b>CANNOT BE PEELED: </b>"
			var/list/inherentList = body_parts_covered2organ_names(C.body_parts_inherent)
			if(length(inherentList) == 1)
				html += "<b><font color = '#000833'>[capitalize(inherentList[1])]</font></b><br>"
			else
				html += "| "
				for(var/zone in inherentList)
					html += "<b><font color = '#000833'>[capitalize(zone)]</b></font> | "
			html += "<br>"
		if(C.prevent_crits)
			if(length(C.prevent_crits))
				html += "\n<b>PREVENTS CRITS:</b>"
				for(var/X in C.prevent_crits)
					if(X == BCLASS_PICK)	//BCLASS_PICK is named "stab", and "stabbing" is its own damage class. Prevents confusion.
						X = "pick"
					html += ("\n<b>[capitalize(X)]</b><br>")
		html += "INTEGRITY: [bookarmor.max_integrity]<br>"
		if(bookarmor.armor_class == ARMOR_CLASS_HEAVY)
			html += "<b>AC: </b>HEAVY<br>"
		if(bookarmor.armor_class == ARMOR_CLASS_MEDIUM)
			html += "<b>AC: </b>MEDIUM<br>"
		if(bookarmor.armor_class == ARMOR_CLASS_LIGHT)
			html += "<b>AC: </b> LIGHT<br>"
	else if (!isnull(bookweapon) && bookweapon.force>1)
		html += "Combat Properties<br>"
		if(bookweapon.minstr)
			html += "\n<b>MIN.STR:</b> [bookweapon.minstr]<br>"

		if(bookweapon.force)
			html += "\n<b>FORCE:</b> [bookweapon.force]<br>"
		if(bookweapon.gripped_intents && !bookweapon.wielded)
			if(bookweapon.force_wielded)
				html += "\n<b>WIELDED FORCE:</b> [bookweapon.force_wielded]<br>"

		if(bookweapon.wbalance)
			html += "\n<b>BALANCE: </b>"
			if(bookweapon.wbalance == WBALANCE_HEAVY)
				html += "Heavy<br>"
			if(bookweapon.wbalance == WBALANCE_SWIFT)
				html += "Swift<br>"


		if(bookweapon.wlength != WLENGTH_NORMAL)
			html += "\n<b>LENGTH:</b> "
			switch(bookweapon.wlength)
				if(WLENGTH_SHORT)
					html += "Short<br>"
				if(WLENGTH_LONG)
					html += "Long<br>"
				if(WLENGTH_GREAT)
					html += "Great<br>"

		if(bookweapon.alt_intents)
			html += "\n<b>GRIP: ALT-GRIP (right click while in hand)</b><br>"
		if(bookweapon.gripped_intents)
			html += "\n<b>TWO-HANDED: Yes</b><br>"

		var/shafttext = get_blade_dulling_text(bookweapon, verbose = TRUE)
		if(shafttext)
			html += "\n<b>SHAFT:</b> [shafttext] <br>"

		if(bookweapon.twohands_required)
			html += "\n<b>BULKY</b><br>"
		if(bookweapon.can_parry)
			html += "\n<b>DEFENSE:</b> [bookweapon.wdefense]<br>"
		if(bookweapon.associated_skill && bookweapon.associated_skill.name)
			html += "\n<b>SKILL:</b> [bookweapon.associated_skill.name]<br>"

		if(bookweapon.intdamage_factor != 1 && bookweapon.force >= 5)
			html += "\n<b>INTEGRITY DAMAGE:</b> [bookweapon.intdamage_factor * 100]%<br>"


	if(craftdiff > 0)
		html += "<h1></h1>For those of [SSskills.level_names_plain[craftdiff]] skills<br>"
	else
		html += "<h1></h1>Suitable for all skills<br>"

	if(appro_skill == /datum/skill/craft/engineering) // SNOWFLAKE!!!
		html += "in Engineering<br>"

	html += {"<div>
		      <strong>Requirements</strong>
			  <br>"}

	html += "[icon2html(req_bar, user)] Start with [initial(req_bar.name)] on an anvil.<br>"
	html += "Hammer the material.<br>"
	for(var/atom/path as anything in additional_items)
		html += "[icon2html(path, user)] then add [initial(path.name)]<br>"
		html += "Hammer the material.<br>"

	html += {"
		</div>
		<div>
		"}

	if(createditem_num > 1)
		html += "<strong class=class='scroll'>and then you get</strong> <br> [createditem_num] [icon2html(created_item, user)]  [initial(created_item.name)]<br>"
	else
		html += "<strong class=class='scroll'>and then you get</strong> <br> [icon2html(created_item, user)]   [initial(created_item.name)]<br>"

	if(created_item.sellprice)
		html += "<strong class=class='scroll'>You can sell this for [created_item.sellprice] mammons at a normal quality</strong> <br>"
	else
		html += "<strong class=class='scroll'>This is worthless for export</strong> <br>"

	html += {"
		</div>
		</div>
	</body>
	</html>
	"}
	return html
