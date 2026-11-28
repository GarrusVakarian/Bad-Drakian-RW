/obj/item/clothing/shoes/roguetown/heels
	name = "black heels"
	desc = "High heels that lift the wearer above the filth. Don't trip."
	icon = 'modular_rmh/icons/clothing/vladegeg/heels.dmi'
	mob_overlay_icon = 'modular_rmh/icons/clothing/vladegeg/onmob/heels.dmi'
	icon_state = "heels"
	item_state = "heels"
	heel_footsteps = TRUE

/obj/item/clothing/shoes/roguetown/heels/color
	name = "heels"
	icon_state = "heels_color"
	item_state = "heels_color"

//CRAFTING

/datum/crafting_recipe/roguetown/leather/footwear/boots/heels
	name = "black heels"
	result = /obj/item/clothing/shoes/roguetown/heels
	reqs = list(/obj/item/natural/hide/cured = 1)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/footwear/boots/heels_color
	name = "colorable heels"
	result = /obj/item/clothing/shoes/roguetown/heels/color
	reqs = list(/obj/item/natural/hide/cured = 1)
	craftdiff = 2

//LOADOUT

/datum/loadout_item/heels
	name = "black heels"
	path = /obj/item/clothing/shoes/roguetown/heels

/datum/loadout_item/heels_color
	name = "colorable heels"
	path = /obj/item/clothing/shoes/roguetown/heels/color

/datum/loadout_item/heelkit
	name = "heel-morphing elixir"
	path = /obj/item/heelkit
	triumph_cost = 2
