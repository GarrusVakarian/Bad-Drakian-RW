// Eggs laid by ovipositors, egg-laying wombs and implanted hosts.
// Built on the chicken egg so they can be eaten, fried and cracked like any other.

/obj/item/reagent_containers/food/snacks/egg/laid
	name = "soft egg"
	desc = "A warm, smooth egg with a faintly yielding shell."
	/// Real name of whoever formed this egg.
	var/mother_name

/obj/item/reagent_containers/food/snacks/egg/laid/examine(mob/user)
	. = ..()
	if(mother_name)
		. += span_notice("It was laid by [mother_name].")

/// Applies an appearance list from get_oviposition_egg_appearance().
/obj/item/reagent_containers/food/snacks/egg/laid/proc/apply_egg_appearance(list/appearance)
	name = appearance["name"]
	desc = appearance["desc"]
	color = appearance["color"]
	mother_name = appearance["mother"]

/// Species decide what an egg looks like unless the player set their own name, desc or color.
/proc/get_oviposition_egg_appearance(list/settings, mob/living/mother)
	var/egg_name = "soft egg"
	var/egg_desc = "A warm, smooth egg with a faintly yielding shell."
	var/egg_color = null
	var/species_id
	if(ishuman(mother))
		var/mob/living/carbon/human/human_mother = mother
		species_id = human_mother.dna?.species?.id
	switch(species_id)
		if("harpy")
			egg_name = "harpy egg"
			egg_desc = "A smooth, birdlike egg with a sturdy shell and a gentle, nest-warm weight."
			egg_color = "#eee3c7"
		if("lizardfolk", "kobold", "dracon", "lamia")
			egg_name = "leathery egg"
			egg_desc = "A warm, leathery egg whose shell gives slightly under the fingers."
			egg_color = "#d8cfa8"
		if("arachnid")
			egg_name = "silk-wrapped egg"
			egg_desc = "A pale egg bound in a thin layer of sticky silk."
			egg_color = "#c9ccd4"
	if(islist(settings))
		if(settings["name"])
			egg_name = settings["name"]
		if(settings["desc"])
			egg_desc = settings["desc"]
		if(settings["color"])
			egg_color = settings["color"]
	return list(
		"name" = egg_name,
		"desc" = egg_desc,
		"color" = egg_color,
		"mother" = mother?.real_name,
	)

/// Creates laid eggs on a turf from a list of appearance lists. Returns how many were made.
/proc/spawn_oviposition_eggs(atom/drop_location, list/appearances)
	var/turf/T = get_turf(drop_location)
	if(!T)
		return 0
	for(var/list/appearance as anything in appearances)
		var/obj/item/reagent_containers/food/snacks/egg/laid/egg = new(T)
		egg.apply_egg_appearance(appearance)
		egg.pixel_x = rand(-6, 6)
		egg.pixel_y = rand(-6, 6)
	return length(appearances)
