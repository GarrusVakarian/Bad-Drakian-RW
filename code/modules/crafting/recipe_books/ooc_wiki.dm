// Adapted from Azure-Peak/Azure-Peak for Bad Drakian on 2026-10-30.
// Distributed under AGPLv3; see LICENSE.
GLOBAL_DATUM(recipe_wiki, /datum/recipe_wiki)

/datum/recipe_wiki
	/// Cached book metadata: list of assoc lists with "name", "types", "path" keys
	var/list/book_entries = list()
	/// Persistent cooking preparation pages, indexed separately from type paths.
	var/list/dynamic_recipes = list()
	/// Per-user viewing state, keyed by ckey
	var/list/user_states = list()
	/// Cached per-book recipe lists for TGUI static data, keyed by book path string
	var/list/cached_book_recipes = list()

/datum/recipe_wiki/New()
	. = ..()
	for(var/book_type in subtypesof(/obj/item/recipe_book))
		var/obj/item/recipe_book/book = new book_type()
		if(!length(book.types))
			qdel(book)
			continue
		if(book.can_spawn || book.wiki_only)
			book_entries += list(list(
				"name" = book.name,
				"wiki_name" = book.wiki_name || book.name,
				"types" = book.types.Copy(),
				"path" = book_type,
				"wiki_section" = book.wiki_section
			))
		cached_book_recipes["[book_type]"] = build_recipe_list(book.types)
		qdel(book)
	book_entries = sortTim(book_entries, GLOBAL_PROC_REF(cmp_book_entries))

/proc/cmp_book_entries(list/a, list/b)
	return sorttext(b["wiki_name"], a["wiki_name"])

/proc/get_recipe_wiki()
	if(!GLOB.recipe_wiki)
		GLOB.recipe_wiki = new /datum/recipe_wiki()
	return GLOB.recipe_wiki

/// Open the recipe viewer for a specific book's types. Used by physical recipe book items.
/datum/recipe_wiki/proc/show_to_user(mob/user, list/type_filter, title = "Recipe Book", book_type_path)
	if(!user?.client)
		return
	var/ckey = user.client.ckey
	if(!user_states[ckey])
		user_states[ckey] = list()
	var/list/state = user_states[ckey]
	state["recipe"] = null
	state["category"] = "All"
	state["filter"] = type_filter
	state["title"] = title
	state["page"] = "book"
	state["book_path"] = book_type_path ? "[book_type_path]" : null
	ui_interact(user)

/// Open the OOC wiki library landing page.
/datum/recipe_wiki/proc/show_library(mob/user)
	if(!user?.client)
		return
	var/ckey = user.client.ckey
	if(!user_states[ckey])
		user_states[ckey] = list()
	var/list/state = user_states[ckey]
	state["recipe"] = null
	state["filter"] = null
	state["title"] = null
	state["page"] = "library"
	state["book_path"] = null
	state["category"] = "All"
	ui_interact(user)

/datum/recipe_wiki/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RecipeBook", "Encyclopedia")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/recipe_wiki/ui_state(mob/user)
	return GLOB.always_state

/datum/recipe_wiki/ui_static_data(mob/user)
	var/list/data = list()

	var/list/books = list()
	for(var/list/entry in book_entries)
		var/entry_path = "[entry["path"]]"
		books += list(list(
			"wiki_name" = entry["wiki_name"],
			"path" = entry_path,
			"section" = entry["wiki_section"]
		))
	data["books"] = books

	var/list/book_recipes = list()
	for(var/list/entry in book_entries)
		var/epath = entry["path"]
		var/book_key = "[epath]"
		if(!cached_book_recipes[book_key])
			cached_book_recipes[book_key] = build_recipe_list(entry["types"])
		book_recipes[book_key] = cached_book_recipes[book_key]
	data["book_recipes"] = book_recipes

	return data

/datum/recipe_wiki/ui_data(mob/user)
	var/list/data = list()
	var/ckey = user?.client?.ckey
	if(!ckey || !user_states[ckey])
		data["page"] = "library"
		data["current_book"] = null
		data["current_book_title"] = ""
		data["current_recipe"] = null
		data["recipe_detail_html"] = ""
		return data

	var/list/state = user_states[ckey]
	data["page"] = state["page"] || "library"
	data["current_book"] = state["book_path"]
	data["current_book_title"] = state["title"] || "Guidebook"
	var/cur_recipe = state["recipe"]
	data["current_recipe"] = cur_recipe ? "[cur_recipe]" : null

	if(state["recipe"])
		data["recipe_detail_html"] = get_cached_detail(state["recipe"], user)
	else
		data["recipe_detail_html"] = ""

	return data

/datum/recipe_wiki/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(!user?.client)
		return
	var/ckey = user.client.ckey
	if(!user_states[ckey])
		user_states[ckey] = list()
	var/list/ustate = user_states[ckey]
	var/changed = FALSE

	switch(action)
		if("open_book")
			changed = open_book(ustate, params["path"])

		if("back_to_library")
			ustate["recipe"] = null
			ustate["filter"] = null
			ustate["title"] = null
			ustate["page"] = "library"
			ustate["book_path"] = null
			ustate["category"] = "All"
			changed = TRUE

		if("view_recipe")
			changed = select_recipe(ustate, params["path"])

		if("clear_recipe")
			ustate["recipe"] = null
			changed = TRUE

	if(changed)
		SStgui.update_user_uis(user, src)
	return FALSE

/// Build sorted recipe list data for a given set of types.
/datum/recipe_wiki/proc/build_recipe_list(list/types)
	var/list/valid_paths = list()
	for(var/atom/path as anything in types)
		if(path == /datum/food_recipe)
			continue
		if(is_abstract(path) || path == /datum/crafting_recipe/roguetown/cooking)
			for(var/atom/sub_path as anything in subtypesof(path))
				if(is_abstract(sub_path))
					continue
				if(!initial(sub_path.name))
					continue
				if(should_hide_recipe(sub_path))
					continue
				valid_paths |= sub_path
		else
			if(!initial(path.name))
				continue
			if(should_hide_recipe(path))
				continue
			valid_paths |= path
	valid_paths = sortNames(valid_paths)

	var/list/recipes = list()
	for(var/atom/entry_path as anything in valid_paths)
		var/recipe_category = get_recipe_category(entry_path) || "All"
		recipes += list(list(
			"name" = initial(entry_path.name),
			"path" = "[entry_path]",
			"category" = recipe_category
		))
	if(/datum/food_recipe in types)
		for(var/base in SScooking.recipe_index)
			for(var/datum/food_recipe/recipe as anything in SScooking.recipe_index[base])
				add_food_recipe(recipes, recipe)
		for(var/datum/food_recipe/recipe as anything in SScooking.preparation_recipes)
			add_food_recipe(recipes, recipe)
	if(/datum/stew_recipe in types)
		// Stew names are derived from their output reagent in New().
		for(var/recipe_type in subtypesof(/datum/stew_recipe))
			if(is_abstract(recipe_type))
				continue
			var/datum/stew_recipe/stew = new recipe_type()
			recipes += list(list("name" = stew.name, "path" = "[recipe_type]", "category" = "Soups and Stews"))
			qdel(stew)
	return sortTim(recipes, GLOBAL_PROC_REF(cmp_wiki_recipe_entries))

/// Render for each reader so icons are sent to that client's asset cache.
/datum/recipe_wiki/proc/get_cached_detail(path, mob/user)
	var/datum/food_recipe/food = dynamic_recipes[path]
	if(food)
		return food.generate_html(user)
	return generate_recipe_detail_html(path, user)

/datum/recipe_wiki/ui_close(mob/user)
	if(user?.client)
		user_states -= user.client.ckey

/datum/recipe_wiki/proc/open_book(list/ustate, key)
	if(!istext(key))
		return FALSE
	for(var/list/entry in book_entries)
		if("[entry["path"]]" != key)
			continue
		ustate["recipe"] = null
		ustate["category"] = "All"
		ustate["filter"] = entry["types"]
		ustate["title"] = entry["wiki_name"]
		ustate["page"] = "book"
		ustate["book_path"] = key
		return TRUE
	return FALSE

/datum/recipe_wiki/proc/select_recipe(list/ustate, key)
	if(!istext(key) || !istext(ustate["book_path"]))
		return FALSE
	var/list/entries = cached_book_recipes[ustate["book_path"]]
	for(var/list/entry in entries)
		if(entry["path"] == key)
			ustate["recipe"] = dynamic_recipes[key] ? key : text2path(key)
			return TRUE
	return FALSE

/datum/recipe_wiki/proc/add_food_recipe(list/recipes, datum/food_recipe/recipe)
	var/key = REF(recipe)
	dynamic_recipes[key] = recipe
	recipes += list(list("name" = recipe.name, "path" = key, "category" = recipe.book_category))

/proc/cmp_wiki_recipe_entries(list/a, list/b)
	return sorttext(b["name"], a["name"])

/client/verb/ooc_wiki()
	set name = "Encyclopedia"
	set category = "OOC"
	set desc = "Browse the Encyclopaedia Drakiana - all recipe books and guidebook entries."

	var/datum/recipe_wiki/wiki = get_recipe_wiki()
	wiki.show_library(mob)
