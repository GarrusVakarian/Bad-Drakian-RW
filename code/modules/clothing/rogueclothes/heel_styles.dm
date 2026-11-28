/obj/item/heelkit
	name = "heel-morphing elixir"
	desc = "A small bottle of shimmering dust. Apply it to a pair of shoes or boots to give them the click of heels."
	icon = 'modular_azurepeak/icons/obj/items/donor_objects.dmi'
	icon_state = "enchanting_kit"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/heelkit/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	var/obj/item/clothing/shoes/roguetown/footwear = target
	if(!istype(footwear) || footwear.is_barefoot)
		to_chat(user, span_warning("This elixir only works on shoes and boots that cover the feet."))
		return TRUE
	if(footwear.loc != user && (!isturf(footwear.loc) || !user.Adjacent(footwear)))
		to_chat(user, span_warning("Set the footwear down or hold it before applying the elixir."))
		return TRUE
	if(footwear.heel_footsteps)
		to_chat(user, span_warning("[footwear] already has heels."))
		return TRUE

	footwear.heel_footsteps = TRUE
	footwear.name += " (heeled)"
	footwear.visible_message(span_notice("The dust sparkles over [footwear] as its heels take shape."))
	do_sparks(2, TRUE, get_turf(footwear))
	qdel(src)
	return TRUE

/obj/item/clothing/shoes/roguetown/simpleshoes/heels
	name = "high-heeled shoes"
	desc = "Elegant shoes with raised heels that click against hard floors."
	icon = 'icons/roguetown/clothing/azure_heel_styles.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/azure_heel_styles.dmi'
	icon_state = "heels"
	item_state = "heels"
	color = null
	detail_tag = "_detail"
	detail_color = "#ffffff"
	heel_footsteps = TRUE
	/// Whether the wearer has chosen the trim color.
	var/trim_selected = FALSE

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/update_overlays()
	. = ..()
	if(!get_detail_tag())
		return
	var/mutable_appearance/trim = mutable_appearance(icon, "[icon_state][get_detail_tag()]")
	trim.appearance_flags = RESET_COLOR
	trim.color = get_detail_color()
	. += trim

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/attack_right(mob/user)
	if(..() || !get_detail_tag() || loc != user || trim_selected)
		return
	var/choice = input(user, "Choose a trim color.", "High-heeled shoes") as null|anything in GLOB.colorlist
	if(!choice || QDELETED(src) || loc != user || trim_selected)
		return
	trim_selected = TRUE
	detail_color = GLOB.colorlist[choice]
	update_icon()
	user.update_inv_shoes()

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/gold
	name = "gold-laced high heels"
	icon_state = "goldheels"
	item_state = "goldheels"

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/silver
	name = "silver-laced high heels"
	icon_state = "silverheels"
	item_state = "silverheels"

/obj/item/clothing/shoes/roguetown/simpleshoes/heels/saccharine
	name = "saccharine heels"
	desc = "Violet heels in a style associated with Baotha."
	icon_state = "baothaboots"
	item_state = "baothaboots"
	detail_tag = null
	detail_color = null

/obj/item/clothing/shoes/roguetown/courtphysician
	name = "sanguine shoes"
	desc = "Leather shoes associated with court physicians."
	icon = 'icons/roguetown/clothing/azure_heel_styles.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/azure_heel_styles.dmi'
	icon_state = "docshoes"
	item_state = "docshoes"
	salvage_amount = 1
	salvage_result = /obj/item/natural/hide/cured

// These heels inherit Bad Drakian's boot sheath behavior.
/obj/item/clothing/shoes/roguetown/boots/courtphysician
	name = "sanguine heels"
	desc = "Leather heels associated with court physicians, with a sheath tucked into the boot."
	icon = 'icons/roguetown/clothing/azure_heel_styles.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/azure_heel_styles.dmi'
	icon_state = "docheels"
	item_state = "docheels"
	color = null
	detail_tag = "_detail"
	detail_color = CLOTHING_RED
	heel_footsteps = TRUE

/obj/item/clothing/shoes/roguetown/boots/courtphysician/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/shoes/roguetown/boots/courtphysician/update_overlays()
	. = ..()
	var/mutable_appearance/trim = mutable_appearance(icon, "[icon_state][get_detail_tag()]")
	trim.appearance_flags = RESET_COLOR
	trim.color = get_detail_color()
	. += trim

/obj/item/clothing/shoes/roguetown/boots/courtphysician/keeper
	name = "pestrian heels"
	desc = "Leather heels fitted for keepers of Pestra."
	detail_color = CLOTHING_GREEN

/obj/item/clothing/shoes/roguetown/boots/otavan/inqboots/heels
	name = "inquisitorial heels"
	desc = "Heeled inquisitorial boots with silver clasps and blacksteel fittings. Activate them in hand to detach the heels."
	icon = 'icons/roguetown/clothing/azure_heel_styles.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/azure_heel_styles.dmi'
	icon_state = "inqheels"
	item_state = "inqheels"
	heel_footsteps = TRUE

/obj/item/clothing/shoes/roguetown/boots/otavan/inqboots/heels/attack_self(mob/user)
	if(!user.is_holding(src))
		return
	user.visible_message(span_notice("[user] begins carefully detaching the heels from [src]."))
	if(!do_after(user, 3 SECONDS, target = src) || QDELETED(src) || !user.is_holding(src))
		return
	if(!user.dropItemToGround(src))
		return

	var/obj/item/clothing/shoes/roguetown/boots/otavan/inqboots/boots = new(get_turf(src))
	boots.obj_integrity = obj_integrity
	boots.color = color
	transfer_fingerprints_to(boots)
	if(holdingknife?.loc == src)
		boots.holdingknife = holdingknife
	if(holdinglockpick?.loc == src)
		boots.holdinglockpick = holdinglockpick
	holdingknife = null
	holdinglockpick = null
	for(var/atom/movable/stored in contents)
		stored.forceMove(boots)
	qdel(src)
	user.put_in_hands(boots)
	to_chat(user, span_notice("You detach the heels, leaving a pair of inquisitorial boots."))

/datum/crafting_recipe/roguetown/leather/footwear/boots/azure_high_heels
	name = "high-heeled shoes"
	result = /obj/item/clothing/shoes/roguetown/simpleshoes/heels
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/footwear/boots/azure_gold_heels
	name = "gold-laced high heels"
	result = /obj/item/clothing/shoes/roguetown/simpleshoes/heels/gold
	reqs = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/gold = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/footwear/boots/azure_silver_heels
	name = "silver-laced high heels"
	result = /obj/item/clothing/shoes/roguetown/simpleshoes/heels/silver
	reqs = list(/obj/item/natural/hide/cured = 2, /obj/item/ingot/silver = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/footwear/boots/saccharine_heels
	name = "saccharine heels"
	result = /obj/item/clothing/shoes/roguetown/simpleshoes/heels/saccharine
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 2

/datum/crafting_recipe/roguetown/leather/footwear/boots/sanguine_shoes
	name = "sanguine shoes"
	result = /obj/item/clothing/shoes/roguetown/courtphysician
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/footwear/boots/sanguine_heels
	name = "sanguine heels"
	result = /obj/item/clothing/shoes/roguetown/boots/courtphysician
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/leather/footwear/boots/pestrian_heels
	name = "pestrian heels"
	result = /obj/item/clothing/shoes/roguetown/boots/courtphysician/keeper
	reqs = list(/obj/item/natural/hide/cured = 2)
	craftdiff = 3
