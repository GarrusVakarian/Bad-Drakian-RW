/datum/food_recipe
	abstract_type = /datum/food_recipe
	var/name = "Generic Recipe"
	/// What item is used to start a recipe, e.g a piece of raw steak
	var/base_item = null
	/// Ingredients in order of completion
	var/list/ingredients = list()
	/// Resulting item
	var/result_type = null
	/// Whether or not this needs to be cooked
	var/needs_cooking = FALSE
	/// How long it takes to add items
	var/time_per_step = 2 SECONDS
	/// Experience per step per int
	var/experience_per_step = 0.5
	/// Economy bucket used by the pricing engine.
	var/display_category = ITEM_CAT_FOODSTUFF_FRESH
	/// Encyclopedia sidebar bucket. One of the FOOD_CAT_* defines.
	var/book_category = FOOD_CAT_COMBINATION

// Recipe links/step labels adapted from WeNeedMorePhoron, Azure-Peak/Azure-Peak PR #7567 (AGPL-3.0).
// https://github.com/Azure-Peak/Azure-Peak/pull/7567
/datum/food_recipe/proc/step_label(entry)
	if(ispath(entry, /datum/reagent))
		var/datum/reagent/reagent = entry
		var/amount = ingredients[entry]
		return "[amount] [UNIT_FORM_STRING(amount)] of [initial(reagent.name)]"
	var/atom/ingredient = entry
	return initial(ingredient.name)

/datum/food_recipe/proc/get_examine_link(label)
	return "<a href='byond://?src=[REF(src)];show_recipe=1'>[html_encode(label || name)]</a>"

/datum/food_recipe/Topic(href, list/href_list)
	. = ..()
	if(!href_list["show_recipe"] || !usr?.client)
		return
	// Only the persistent recipes registered by the cooking subsystem can serve pages.
	if(!(src in SScooking?.recipe_index[base_item]) && !(src in SScooking?.preparation_recipes))
		return
	var/datum/browser/popup = new(usr, "food_recipe", name, 650, 650)
	popup.set_content(generate_html(usr))
	popup.open()

/datum/food_recipe/proc/generate_html(mob/user)
	var/html = "<h2>[name]</h2>"

	var/atom/base = base_item
	if(base)
		html += "<p><b>Start with:</b> [food_recipe_icon(base, user)] [item_recipe_label(base)]</p>"

	if(length(ingredients))
		html += "<p>Prepare the ingredients on a table.</p>"
		html += "<h3>Then add, in order:</h3><ul>"
		for(var/i in 1 to length(ingredients))
			var/entry = ingredients[i]
			if(ispath(entry, /datum/reagent))
				var/amt = ingredients[entry]
				var/datum/reagent/R = entry
				html += "<li>[amt] [UNIT_FORM_STRING(amt)] of [initial(R.name)]</li>"
			else
				var/atom/A = entry
				html += "<li>[food_recipe_icon(A, user)] [item_recipe_label(A)]</li>"
		html += "</ul>"

	var/atom/result = result_type
	if(result)
		html += "<p><b>Produces:</b> [food_recipe_icon(result, user)] [initial(result.name)]</p>"
		var/result_details = describe_food_result(result)
		if(result_details)
			html += result_details

	if(needs_cooking)
		html += "<p>After assembly, this still needs to be cooked - place over a hearth in a pan, or bake in an oven.</p>"

	html += "<p>Each step takes about [time_per_step / 10] seconds before cooking skill modifiers.</p>"

	if(SScooking?.recipe_index && result_type)
		var/list/follow_ups = SScooking.recipe_index[result_type]
		if(length(follow_ups))
			html += "<h3>Can be further prepared into:</h3><ul>"
			for(var/datum/food_recipe/F in follow_ups)
				html += "<li>[F.get_examine_link()]</li>"
			html += "</ul>"

	return html

/// A prerequisite may be an assembly recipe or an existing cooking/slicing transformation.
/datum/food_recipe/proc/item_recipe_label(atom/item_type)
	var/datum/food_recipe/producer = SScooking?.result_index[item_type]
	if(producer && producer != src)
		return producer.get_examine_link(initial(item_type.name))
	return html_encode(initial(item_type.name))

/// Read-only pages generated from item variables, never used by food assembly.
/datum/food_recipe/preparation
	var/instruction
	var/result_amount = 1

/datum/food_recipe/preparation/generate_html(mob/user)
	var/atom/base = base_item
	var/atom/result = result_type
	var/html = "<h2>[html_encode(name)]</h2>"
	html += "<p><b>Start with:</b> [food_recipe_icon(base, user)] [item_recipe_label(base)]</p>"
	html += "<p>[instruction]</p>"
	html += "<p><b>Produces:</b> [result_amount] x [food_recipe_icon(result, user)] [html_encode(initial(result.name))]</p>"
	html += describe_food_result(result)
	return html

/// Recipe illustrations need no live items or their initialization side effects.
/proc/food_recipe_icon(atom/item_type, mob/user)
	return icon2html(icon(initial(item_type.icon), initial(item_type.icon_state)), user)

/proc/describe_food_result(atom/result_path)
	if(!ispath(result_path, /obj/item/reagent_containers/food/snacks))
		return ""
	var/obj/item/reagent_containers/food/snacks/proto = new result_path()
	var/list/lines = list()

	switch(proto.faretype)
		if(FARE_IMPOVERISHED)
			lines += "Quality: Impoverished (fit for the desperate)."
		if(FARE_POOR)
			lines += "Quality: Poor (fit for the poor)."
		if(FARE_NEUTRAL)
			lines += "Quality: Neutral (decent food)."
		if(FARE_FINE)
			lines += "Quality: Fine."
		if(FARE_LAVISH)
			lines += "Quality: Lavish."

	var/nutriment_total = 0
	var/list/declared_reagents = proto.list_reagents
	if(islist(declared_reagents))
		nutriment_total += declared_reagents[/datum/reagent/consumable/nutriment] || 0
	var/list/declared_bonus = proto.bonus_reagents
	if(islist(declared_bonus))
		nutriment_total += declared_bonus[/datum/reagent/consumable/nutriment] || 0
	if(nutriment_total > 0)
		lines += "Nutrition: [nutrition_unit_label(nutriment_total)] ([nutriment_total] units)."

	var/list/other_reagents = list()
	if(islist(declared_reagents))
		for(var/r_path in declared_reagents)
			if(r_path == /datum/reagent/consumable/nutriment)
				continue
			var/datum/reagent/R = r_path
			other_reagents += "[initial(R.name)] ([declared_reagents[r_path]]u)"
	if(length(other_reagents))
		lines += "Also contains: [other_reagents.Join(", ")]."

	var/buff_desc = describe_food_effect(proto.eat_effect)
	if(buff_desc)
		lines += "Effect on eating: [buff_desc]."
	var/extra_desc = describe_food_effect(proto.extra_eat_effect)
	if(extra_desc)
		lines += "Bonus effect: [extra_desc]."

	var/atom/slice_target = proto.slice_path
	if(slice_target)
		var/count = proto.slices_num || 1
		lines += "Can be cut into [count] x [initial(slice_target.name)]."

	qdel(proto)

	if(!length(lines))
		return ""
	return "<p>[lines.Join("<br>")]</p>"

/proc/describe_food_effect(effect_path)
	if(!ispath(effect_path, /datum/status_effect))
		return null
	var/datum/status_effect/S = effect_path
	var/label
	var/alert_path = initial(S.alert_type)
	if(ispath(alert_path, /atom))
		var/atom/A = alert_path
		label = initial(A.name)
	if(!label)
		label = initial(S.id) || "[effect_path]"

	var/list/parts = list("<b>[label]</b>")
	var/duration = initial(S.duration)
	if(duration && duration > 0)
		parts += "for [duration_label(duration)]"
	return parts.Join(" ")

/proc/duration_label(deciseconds)
	var/seconds = deciseconds / 10
	if(seconds >= 60)
		var/minutes = round(seconds / 60)
		return "[minutes] minute[minutes == 1 ? "" : "s"]"
	return "[seconds] seconds"

/proc/nutrition_unit_label(amount)
	if(amount >= NUTRITION_FIVE_MEALS)
		return "five meals or more"
	if(amount >= NUTRITION_THREE_AND_HALF_MEALS)
		return "three-and-a-half meals"
	if(amount >= NUTRITION_TWO_AND_HALF_MEALS)
		return "two-and-a-half meals"
	if(amount >= NUTRITION_TWO_MEALS)
		return "two meals"
	if(amount >= NUTRITION_MEAL_AND_HALF)
		return "a meal and a half"
	if(amount >= NUTRITION_MEAL_AND_QUARTER)
		return "a meal and a quarter"
	if(amount >= NUTRITION_FULL_MEAL)
		return "a full meal"
	if(amount >= NUTRITION_THREE_QUARTER_MEAL)
		return "three-quarters of a meal"
	if(amount >= NUTRITION_HALF_MEAL)
		return "half a meal"
	if(amount >= NUTRITION_QUARTER_MEAL)
		return "a quarter of a meal"
	return "a small bite"

