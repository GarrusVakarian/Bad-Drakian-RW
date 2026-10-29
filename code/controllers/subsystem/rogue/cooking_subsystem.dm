SUBSYSTEM_DEF(cooking)
	name = "Cooking Controller"
	flags = SS_NO_FIRE
	var/list/recipe_index = list() // Key: base_item path | Value: list of recipe datums
	/// Assembly recipes take priority over generated preparation pages; information only.
	var/list/result_index = list()
	/// Display-only preparation pages, deliberately excluded from recipe_index/get_recipe.
	var/list/preparation_recipes = list()

/datum/controller/subsystem/cooking/Initialize()
	init_recipes()
	init_preparation_recipes()
	return ..()

/datum/controller/subsystem/cooking/proc/init_recipes()
	for(var/R in typesof(/datum/food_recipe) - /datum/food_recipe)
		var/datum/food_recipe/recipe = new R()
		if(!recipe.base_item) 
			continue
		if(!recipe_index[recipe.base_item])
			recipe_index[recipe.base_item] = list()
		recipe_index[recipe.base_item] += recipe
		if(recipe.result_type && !result_index[recipe.result_type])
			result_index[recipe.result_type] = recipe

/datum/controller/subsystem/cooking/proc/get_recipe(obj/item/base, obj/item/ingredient)
	if(!recipe_index[base.type])
		return null

	for(var/datum/food_recipe/R in recipe_index[base.type])
		var/first_req = R.ingredients[1]
		if(ispath(first_req, /datum/reagent))
			var/amt = R.ingredients[first_req]
			if(ingredient.reagents && ingredient.reagents.has_reagent(first_req, amt))
				return R
		else if(istype(ingredient, first_req))
			return R

	return null

/// Describe existing item transformations without adding any executable cooking recipes.
/datum/controller/subsystem/cooking/proc/init_preparation_recipes()
	for(var/obj/item/reagent_containers/food/snacks/source as anything in subtypesof(/obj/item/reagent_containers/food/snacks))
		if(is_abstract(source))
			continue
		var/baked = initial(source.cooked_type)
		var/fried = initial(source.fried_type)
		if(baked && baked == fried)
			add_preparation_recipe(source, baked, "Cook it in an oven or in a pan over a hearth.")
		else
			add_preparation_recipe(source, baked, "Bake it in an oven.")
			add_preparation_recipe(source, fried, "Fry it in a pan over a hearth.")
		add_preparation_recipe(source, initial(source.deep_fried_type), "Deep fry it in a pot of tallow over a hearth.")
		if(initial(source.slices_num) > 0)
			var/intent = initial(source.slice_bclass) == BCLASS_CHOP ? "CHOP" : "CUT"
			add_preparation_recipe(source, initial(source.slice_path), "Slice it on a table with a short blade using [intent] intent.", initial(source.slices_num))
		add_preparation_recipe(source, initial(source.dried_type), "Dry it on a drying rack.")

/datum/controller/subsystem/cooking/proc/add_preparation_recipe(source, result, instruction, amount = 1)
	if(!ispath(result, /obj/item/reagent_containers/food/snacks) || source == result || result_index[result])
		return
	var/datum/food_recipe/preparation/recipe = new
	var/atom/product = result
	recipe.name = initial(product.name)
	recipe.base_item = source
	recipe.result_type = result
	recipe.instruction = instruction
	recipe.result_amount = amount
	preparation_recipes += recipe
	result_index[result] = recipe
