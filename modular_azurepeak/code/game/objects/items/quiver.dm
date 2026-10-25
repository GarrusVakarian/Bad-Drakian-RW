
/obj/item/quiver
	name = "quiver"
	desc = ""
	icon_state = "quiver0"
	item_state = "quiver"
	icon = 'icons/roguetown/weapons/ammo.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK
	resistance_flags = FIRE_PROOF
	max_integrity = 0
	equip_sound = 'sound/blank.ogg'
	bloody_icon_state = "bodyblood"
	alternate_worn_layer = UNDER_CLOAK_LAYER
	strip_delay = 20
	var/max_storage = 20
	var/list/arrows = list()
	sewrepair = TRUE
	dropshrink = 0.9

/obj/item/quiver/quickdraw_interact(mob/living/user, obj/item/held_item)
	if(!istype(held_item, /obj/item/gun/ballistic/revolver/grenadelauncher/bow) && !istype(held_item, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow) && !istype(held_item, /obj/item/gun/ballistic/revolver/grenadelauncher/sling))
		return FALSE
	var/obj/item/gun/ballistic/revolver/grenadelauncher/launcher = held_item
	if(launcher.chambered)
		to_chat(user, span_notice("[launcher] is already loaded."))
		return TRUE
	if(!istype(launcher, /obj/item/gun/ballistic/revolver/grenadelauncher/sling))
		if(user.get_num_arms(FALSE) < 2 || user.get_inactive_held_item())
			to_chat(user, span_warning("I need a free hand to load [launcher]!"))
			return TRUE
	if(istype(launcher, /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow/crossbow = launcher
		if(!crossbow.cocked)
			to_chat(user, span_warning("I need to cock [launcher] first."))
			return TRUE
	if(!length(arrows))
		to_chat(user, span_warning("[src] is empty!"))
		return TRUE
	for(var/obj/item/ammo_casing/caseless/rogue/ammo in arrows)
		if(!launcher.magazine || ammo.caliber != launcher.magazine.caliber)
			continue
		launcher.quiver_loading = TRUE
		launcher.attackby(ammo, user)
		launcher.quiver_loading = FALSE
		// Only remove ammunition that the weapon actually accepted.
		if(ammo.loc != src)
			arrows -= ammo
			update_icon()
			if(HAS_TRAIT(user, TRAIT_COMBAT_AWARE))
				user.balloon_alert(user, "[length(arrows)] left...")
		return TRUE
	to_chat(user, span_warning("Nothing in [src] fits [launcher]."))
	return TRUE

/obj/item/quiver/attack_turf(turf/T, mob/living/user)
	if(arrows.len >= max_storage)
		to_chat(user, span_warning("My [src.name] is full!"))
		return
	to_chat(user, span_notice("I begin to gather the ammunition..."))
	for(var/obj/item/ammo_casing/caseless/rogue/arrow in T.contents)
		if(do_after(user, 5))
			if(!eatarrow(arrow))
				break

/obj/item/quiver/proc/eatarrow(obj/A)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue))
		if(arrows.len < max_storage)
			A.forceMove(src)
			arrows += A
			update_icon()
			return TRUE
		else
			return FALSE

/obj/item/quiver/attack_self(mob/living/user)
	..()

	if (!arrows.len)
		return
	to_chat(user, span_warning("I begin to take out the arrows from [src], one by one..."))
	for(var/obj/item/ammo_casing/caseless/rogue/arrow in arrows)
		if(!do_after(user, 0.5 SECONDS))
			return
		arrow.forceMove(user.loc)
		arrows -= arrow

	update_icon()

/obj/item/quiver/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue))
		if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue/javelin))
			to_chat(loc, span_warning("Javelins are too big to fit in a quiver, silly!"))
			return FALSE
		else if(arrows.len < max_storage)
			if(ismob(loc))
				var/mob/M = loc
				M.doUnEquip(A, TRUE, src, TRUE, silent = TRUE)
			else
				A.forceMove(src)
			arrows += A
			update_icon()
		else
			to_chat(loc, span_warning("Full!"))
		return
	if(istype(A, /obj/item/gun/ballistic/revolver/grenadelauncher/bow))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/B = A
		if(arrows.len && !B.chambered)
			for(var/AR in arrows)
				if(istype(AR, /obj/item/ammo_casing/caseless/rogue/arrow))
					arrows -= AR
					B.attackby(AR, loc, params)
					if(ismob(loc))
						var/mob/M = loc
						if(HAS_TRAIT(M, TRAIT_COMBAT_AWARE))
							M.balloon_alert(M, "[length(arrows)] left...")
					break
		return
	..()

/obj/item/quiver/attack_right(mob/user)
	if(arrows.len)
		var/obj/O = arrows[arrows.len]
		arrows -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/examine(mob/user)
	. = ..()
	if(arrows.len)
		. += span_notice("[arrows.len] inside.")
	. += span_notice("Click on the ground to pick up ammos on the floor.")

/obj/item/quiver/update_icon()
	if(arrows.len)
		icon_state = "quiver1"
	else
		icon_state = "quiver0"

/obj/item/quiver/arrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/iron/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bluntarrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/blunt/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bolts/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bolt/bronze/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/bronze/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bluntbolts/Initialize(mapload)
	. = ..()
	for(var/i in  1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/blunt/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/heavybluntbolts/Initialize(mapload)
	. = ..()
	for(var/i in  1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/heavyblunt/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/holybolts/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/holy/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/heavybolts/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/heavy_bolt/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/Wbolts/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/water/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/pyrobolts/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/pyro/A = new()
		arrows += A
	update_icon()


/obj/item/quiver/poisonarrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/poison/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/pyroarrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/pyro/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/Parrows/Initialize(mapload)
	. = ..()

/obj/item/quiver/boltsancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/bolt/ancient/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/Warrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/water/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bodkin/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/steel/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/steel/ancient/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/bronzearrows/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/arrow/bronze/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/javelin
	name = "javelinbag"
	desc = ""
	icon_state = "javelinbag0"
	item_state = "javelinbag"
	max_storage = 4
	dropshrink = 0.85

/obj/item/quiver/javelin/attack_turf(turf/T, mob/living/user)
	if(arrows.len >= max_storage)
		to_chat(user, span_warning("My [src.name] is full!"))
		return
	to_chat(user, span_notice("I begin to gather the ammunition..."))
	for(var/obj/item/ammo_casing/caseless/rogue/javelin in T.contents)
		if(do_after(user, 5))
			if(!eatarrow(javelin))
				break

/obj/item/quiver/javelin/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue/javelin))
		if(arrows.len < max_storage)
			if(ismob(loc))
				var/mob/M = loc
				M.doUnEquip(A, TRUE, src, TRUE, silent = TRUE)
			else
				A.forceMove(src)
			arrows += A
			update_icon()
		else
			to_chat(loc, span_warning("Full!"))
		return
	..()

/obj/item/quiver/javelin/attack_right(mob/user)
	if(arrows.len)
		var/obj/O = arrows[arrows.len]
		arrows -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/javelin/examine(mob/user)
	. = ..()
	if(arrows.len)
		. += span_notice("[arrows.len] inside.")

/obj/item/quiver/javelin/update_icon()
	if(arrows.len)
		icon_state = "javelinbag1"
	else
		icon_state = "javelinbag0"

/obj/item/quiver/javelin/iron/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/javelin/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/javelin/steel/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/javelin/steel/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/javelin/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/javelin/steel/ancient/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/javelin/stone/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/javelin/stone/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/javelin/bronze/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 4)
		var/obj/item/ammo_casing/caseless/rogue/javelin/bronze/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/sling
	name = "sling bullet pouch"
	desc = "This pouch holds the ouch." //i came up with this line on an impulse
	icon = 'icons/roguetown/weapons/ammo.dmi'
	icon_state = "slingpouch"
	item_state = "slingpouch"
	// Bad Drakian adjustment: ITEM_SLOT_BACK allows either back slot; retain hip and neck slots.
	// slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_NECK
	slot_flags = ITEM_SLOT_HIP | ITEM_SLOT_NECK | ITEM_SLOT_BACK
	max_storage = 20
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 64
	grid_width = 32

/obj/item/quiver/sling/attack_turf(turf/T, mob/living/user)
	if(arrows.len >= max_storage)
		to_chat(user, span_warning("My [src.name] is full!"))
		return
	to_chat(user, span_notice("I begin to gather the ammunition..."))
	for(var/obj/item/ammo_casing/caseless/rogue/sling_bullet in T.contents)
		if(do_after(user, 5))
			if(!eatarrow(sling_bullet))
				break

/obj/item/quiver/sling/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/ammo_casing/caseless/rogue/sling_bullet))
		if(arrows.len < max_storage)
			if(ismob(loc))
				var/mob/M = loc
				M.doUnEquip(A, TRUE, src, TRUE, silent = TRUE)
			else
				A.forceMove(src)
			arrows += A
			update_icon()
		else
			to_chat(loc, span_warning("Full!"))
		return
	if(istype(A, /obj/item/gun/ballistic/revolver/grenadelauncher/sling))
		var/obj/item/gun/ballistic/revolver/grenadelauncher/sling/B = A
		if(arrows.len && !B.chambered)
			for(var/AR in arrows)
				if(istype(AR, /obj/item/ammo_casing/caseless/rogue/sling_bullet))
					arrows -= AR
					B.attackby(AR, loc, params)
					break
		return
	..()

/obj/item/quiver/sling/attack_right(mob/user)
	if(arrows.len)
		var/obj/O = arrows[arrows.len]
		arrows -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/sling/update_icon()
	return

/obj/item/quiver/sling/iron/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/sling_bullet/iron/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/sling/steel/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/sling_bullet/steel/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/sling/ancient/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/sling_bullet/ancient/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/sling/bronze/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/ammo_casing/caseless/rogue/sling_bullet/bronze/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/zigs
	name = "zig box"
	desc = "A box for all your smoking needs."
	icon = 'icons/roguetown/clothing/storage.dmi'
	icon_state = "smokebox"
	item_state = "smokebox"
	slot_flags = ITEM_SLOT_HIP
	max_storage = 10
	w_class = WEIGHT_CLASS_NORMAL
	grid_height = 64
	grid_width = 32
	dropshrink = 0.5

/obj/item/quiver/zigs/attackby(obj/A, loc, params)
	if(A.type in subtypesof(/obj/item/clothing/mask/cigarette/rollie))
		if(arrows.len < max_storage)
			if(ismob(loc))
				var/mob/M = loc
				M.doUnEquip(A, TRUE, src, TRUE, silent = TRUE)
			else
				A.forceMove(src)
			arrows += A
			update_icon()
		else

	..()

/obj/item/quiver/zigs/attack_right(mob/user)
	if(arrows.len)
		var/obj/O = arrows[arrows.len]
		arrows -= O
		O.forceMove(user.loc)
		user.put_in_hands(O)
		update_icon()
		return TRUE

/obj/item/quiver/zigs/update_icon()
	return

/obj/item/quiver/zigs/nicotine/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/clothing/mask/cigarette/rollie/nicotine/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/zigs/trippy/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/clothing/mask/cigarette/rollie/trippy/A = new()
		arrows += A
	update_icon()

/obj/item/quiver/zigs/cannabis/Initialize(mapload)
	. = ..()
	for(var/i in 1 to max_storage)
		var/obj/item/clothing/mask/cigarette/rollie/cannabis/A = new()
		arrows += A
	update_icon()
