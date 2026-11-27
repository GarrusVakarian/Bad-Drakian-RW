/obj/structure/handcart
	name = "cart"
	desc = "A wooden cart that will help you carry many things."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "cart-empty"
	density = TRUE
	max_integrity = 600
	anchored = FALSE
	climbable = TRUE
	facepull = FALSE
	throw_range = 1
	var/list/contained_items = list()
	var/list/contained_weights = list()
	var/current_capacity = 0
	var/maximum_capacity = 60
	var/arbitrary_living_creature_weight = 10
	var/upgrade_level = 0
	/// The first upgrade locks this cart to either "gears" or "wheelbraces".
	var/upgrade_family
	var/installed_upgrade_name
	var/list/cartloadable_structures = list(/obj/structure/fermentation_keg)
	var/structure_weight = 20
	var/bulk_moving = FALSE

/obj/structure/handcart/Initialize(mapload)
	. = ..()
	// Preserve pre-upgraded mapped carts, including the gold caravan's cart.
	if(!upgrade_family && (upgrade_level || maximum_capacity > 60))
		upgrade_family = "gears"
	recalculate_capacity()
	if(mapload)
		addtimer(CALLBACK(src, PROC_REF(take_contents)), 0)
	update_icon()

/obj/structure/handcart/examine(mob/user)
	. = ..()
	recalculate_capacity()
	if(Adjacent(user))
		. += span_notice("Capacity: [current_capacity]/[maximum_capacity].")
		. += span_notice("Contents: [counting_english_list(contained_items, output_icons = FALSE)].")
	if(installed_upgrade_name)
		. += span_notice("Installed upgrade: [html_encode(installed_upgrade_name)].")
	if(upgrade_family)
		. += span_notice("This cart uses [upgrade_family]; upgrades from the other family cannot be installed.")

/obj/structure/handcart/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Left-click selects one item, keg or passenger to unload.")
	. += span_info("Right-click dumps all cargo onto the cart's tile.")
	. += span_info("Click with a held item to load it. Middle-click loads eligible items and kegs from the cart's tile.")
	. += span_info("Drag a ground item or keg onto the cart to load eligible cargo from that object's tile.")
	. += span_info("Drag another creature onto the cart to load it after a short delay.")
	. += span_info("To climb inside, lie down and drag yourself onto the cart. Resist to climb back out.")
	. += span_info("Nearby crafting can use materials inside the cart.")
	. += span_info("Can be upgraded with handcrafted woodcutters wheelbraces, or wooden cogs made on an artificer's table.")

/obj/structure/handcart/proc/can_use_cart(mob/user)
	return isliving(user) && !QDELETED(user) && !user.incapacitated() && isturf(user.loc) && isturf(loc) && Adjacent(user)

/obj/structure/handcart/should_click_on_mouse_up(atom/original_object)
	return original_object == src

/obj/structure/handcart/MiddleClick(mob/user, params)
	if(!can_use_cart(user) || user.cmode)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(scoop_from_turf(get_turf(src)))
		playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)

/obj/structure/handcart/proc/scoop_from_turf(turf/T)
	if(!isturf(T))
		return FALSE
	recalculate_capacity()
	var/inserted_anything = FALSE
	bulk_moving = TRUE
	for(var/atom/movable/AM in T.contents.Copy())
		if(!isitem(AM) && !is_cartloadable_structure(AM))
			continue
		if(put_in(AM))
			inserted_anything = TRUE
	bulk_moving = FALSE
	update_icon()
	return inserted_anything

/obj/structure/handcart/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || !isturf(O.loc) || !can_use_cart(user) || !user.Adjacent(O))
		return FALSE
	if(user == O)
		if(user.mobility_flags & MOBILITY_STAND)
			return ..()
		return load_passenger(user, user)
	if(user.used_intent.type != INTENT_HELP && user.used_intent.type != /datum/intent/grab/move)
		return FALSE
	user.changeNext_move(CLICK_CD_MELEE)
	if(isliving(O))
		return load_passenger(O, user)
	if(!isitem(O) && !is_cartloadable_structure(O))
		return FALSE
	if(scoop_from_turf(get_turf(O)))
		playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
		return TRUE
	return FALSE

/obj/structure/handcart/proc/load_passenger(mob/living/passenger, mob/living/user)
	recalculate_capacity()
	if(!can_use_cart(user) || !istype(passenger) || !user.Adjacent(passenger) || !insertion_allowed(passenger) || !fits_in_cart(passenger))
		return FALSE
	var/atom/old_cart_location = loc
	var/atom/old_passenger_location = passenger.loc
	var/atom/old_user_location = user.loc
	if(!do_after(user, 2 SECONDS, target = src))
		return FALSE
	if(QDELETED(src) || QDELETED(passenger) || !can_use_cart(user))
		return FALSE
	if(loc != old_cart_location || passenger.loc != old_passenger_location || user.loc != old_user_location || !user.Adjacent(passenger))
		return FALSE
	if(passenger == user && (user.mobility_flags & MOBILITY_STAND))
		return FALSE
	recalculate_capacity()
	if(!put_in(passenger))
		return FALSE
	playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
	return TRUE

/obj/structure/handcart/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!can_use_cart(user) || user.cmode || !user.client)
		return
	recalculate_capacity()
	if(!length(contained_items))
		to_chat(user, span_warning("The cart is empty."))
		return
	var/list/targets = list()
	var/index = 0
	for(var/atom/movable/AM as anything in contained_items)
		index++
		targets["[index]. [AM.name]"] = AM
	var/selected = tgui_input_list(user, "Which item would you like to take out of the cart?", name, targets)
	if(!selected || QDELETED(src) || !can_use_cart(user) || user.cmode || !user.client)
		return
	return unload_item(targets[selected], user)

/obj/structure/handcart/proc/unload_item(atom/movable/AM, mob/living/user)
	if(!can_use_cart(user) || user.cmode || !istype(AM) || QDELETED(AM) || !(AM in contained_items) || AM.loc != src)
		return FALSE
	if(isitem(AM))
		// put_in_hands may merge a stack or drop it at the user's feet when full.
		user.put_in_hands(AM)
	else
		AM.forceMove(user.drop_location())
	return QDELETED(AM) || AM.loc != src

/obj/structure/handcart/attack_right(mob/user)
	. = ..()
	if(.)
		return
	if(!can_use_cart(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(length(contained_items))
		dump_contents()
		visible_message(span_info("[user] dumps out \the [src]!"))
		playsound(loc, 'sound/foley/cartdump.ogg', 100, FALSE, -1)

/obj/structure/handcart/attackby(obj/item/I, mob/user, params)
	if(!can_use_cart(user))
		return
	if(istype(I, /obj/item/roguegear/wood) || istype(I, /obj/item/cart_upgrade))
		install_upgrade(I, user)
		return
	if(!user.cmode)
		if(put_in(I, user))
			playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
		return
	return ..()

/obj/structure/handcart/proc/install_upgrade(obj/item/I, mob/user)
	if(!can_use_cart(user) || !user.is_holding(I))
		return FALSE
	var/family
	var/new_capacity
	var/new_level
	if(istype(I, /obj/item/cart_upgrade))
		var/obj/item/cart_upgrade/brace = I
		family = "wheelbraces"
		new_level = brace.ulevel
		new_capacity = (new_level == 1) ? 90 : 120
	else if(istype(I, /obj/item/roguegear/wood))
		var/obj/item/roguegear/wood/gear = I
		family = "gears"
		new_capacity = gear.cart_capacity
		new_level = gear.ulevel
	else
		return FALSE
	if(upgrade_family && upgrade_family != family)
		to_chat(user, span_warning("This cart already uses [upgrade_family]; I cannot fit [family] to it."))
		return FALSE
	if(family == "wheelbraces" && (new_level < 1 || new_level > 2 || new_level != upgrade_level + 1))
		to_chat(user, span_warning("Install the normal wheelbrace first, and use each wheelbrace only once."))
		return FALSE
	if(new_capacity <= maximum_capacity)
		to_chat(user, span_warning("This upgrade would not improve the cart's capacity."))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(I))
		return FALSE
	upgrade_family = family
	upgrade_level = new_level
	maximum_capacity = new_capacity
	installed_upgrade_name = I.name
	to_chat(user, span_notice("I install [I] into the cart."))
	qdel(I)
	update_icon()
	playsound(loc, 'sound/foley/cartadd.ogg', 100, FALSE, -1)
	return TRUE

/obj/structure/handcart/proc/fits_in_cart(atom/movable/O)
	return istype(O) && !QDELETED(O) && current_capacity + get_atom_weight(O) <= maximum_capacity

/obj/structure/handcart/proc/put_in(atom/movable/O, mob/user)
	if(!istype(O) || QDELETED(O) || O == src || O.loc == src || !insertion_allowed(O))
		return FALSE
	if(!bulk_moving)
		recalculate_capacity()
	if(!fits_in_cart(O))
		if(user)
			to_chat(user, span_warning("The cart cannot hold any more weight!"))
		return FALSE
	if(user)
		if(!isitem(O) || !user.is_holding(O) || !user.transferItemToLoc(O, src))
			return FALSE
	else
		if(isliving(O))
			var/mob/living/passenger = O
			passenger.stop_pulling()
		O.forceMove(src)
	return !QDELETED(O) && O.loc == src

/obj/structure/handcart/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	track_cargo(AM)

/obj/structure/handcart/proc/track_cargo(atom/movable/AM)
	if(AM in contained_items)
		return
	if(!isitem(AM) && !isliving(AM) && !is_cartloadable_structure(AM))
		return
	contained_items += AM
	contained_weights[AM] = get_atom_weight(AM)
	current_capacity += contained_weights[AM]
	RegisterSignal(AM, COMSIG_QDELETING, PROC_REF(remove_from_signal))
	if(!bulk_moving)
		update_icon()

/obj/structure/handcart/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	remove_from(AM)

/obj/structure/handcart/proc/remove_from_signal(atom/movable/AM)
	SIGNAL_HANDLER
	remove_from(AM)

/obj/structure/handcart/proc/remove_from(atom/movable/AM)
	if(!(AM in contained_items))
		return FALSE
	UnregisterSignal(AM, COMSIG_QDELETING)
	current_capacity = max(current_capacity - contained_weights[AM], 0)
	contained_weights -= AM
	contained_items -= AM
	if(!bulk_moving)
		update_icon()
	return TRUE

/obj/structure/handcart/proc/recalculate_capacity()
	var/was_bulk_moving = bulk_moving
	bulk_moving = TRUE
	// Items can also be constructed directly inside mapped or merchant carts.
	for(var/atom/movable/AM in src)
		track_cargo(AM)
	var/total = 0
	for(var/atom/movable/AM in contained_items.Copy())
		if(QDELETED(AM) || AM.loc != src)
			remove_from(AM)
			continue
		contained_weights[AM] = get_atom_weight(AM)
		total += contained_weights[AM]
	current_capacity = total
	bulk_moving = was_bulk_moving
	if(!bulk_moving)
		update_icon()

/obj/structure/handcart/proc/get_atom_weight(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		return I.w_class
	if(isliving(AM))
		var/mob/living/L = AM
		return arbitrary_living_creature_weight * max(L.mob_size, 1)
	if(is_cartloadable_structure(AM))
		return structure_weight
	return 0

/obj/structure/handcart/proc/is_cartloadable_structure(atom/movable/AM)
	for(var/path in cartloadable_structures)
		if(istype(AM, path))
			return TRUE
	return FALSE

/obj/structure/handcart/proc/insertion_allowed(atom/movable/AM)
	if(!istype(AM) || QDELETED(AM) || AM == src || AM.anchored || AM.has_buckled_mobs())
		return FALSE
	if(isliving(AM))
		var/mob/living/L = AM
		return !L.buckled && !L.incorporeal_move && (L.mob_size <= MOB_SIZE_TINY || !L.cmode || L.stat == DEAD)
	if(is_cartloadable_structure(AM))
		return TRUE
	if(isitem(AM))
		var/obj/item/I = AM
		return !I.density && !HAS_TRAIT(I, TRAIT_NODROP) && !(I.item_flags & ABSTRACT)
	return FALSE

/obj/structure/handcart/container_resist(mob/living/user)
	if(user.loc == src && !user.incapacitated())
		user.forceMove(drop_location())

/obj/structure/handcart/dump_contents()
	bulk_moving = TRUE
	var/atom/destination = drop_location()
	for(var/atom/movable/AM in contents.Copy())
		if(destination)
			AM.forceMove(destination)
		else
			AM.moveToNullspace()
	bulk_moving = FALSE
	recalculate_capacity()
	update_icon()

/obj/structure/handcart/proc/take_contents()
	scoop_from_turf(get_turf(src))

/obj/structure/handcart/Destroy()
	dump_contents()
	return ..()

/obj/structure/handcart/update_icon()
	. = ..()
	cut_overlays()
	if(upgrade_level == 1)
		add_overlay("ov_upgrade")
	else if(upgrade_level == 2)
		add_overlay("ov_upgrade2")
	icon_state = length(contained_items) ? "cart-full" : "cart-empty"

/obj/structure/handcart/Move(atom/newloc, direct, glide_size_override)
	. = ..()
	if(. && pulledby && dir != pulledby.dir)
		setDir(pulledby.dir)

/obj/structure/handcart/get_crafting_contents()
	recalculate_capacity()
	return contained_items.Copy()

/obj/item/cart_upgrade
	name = "woodcutters wheelbrace"
	desc = "A wooden cart upgrade. It cannot be combined with artificer gears."
	icon_state = "upgrade"
	icon = 'icons/roguetown/misc/structure.dmi'
	var/ulevel = 0
	grid_width = 64
	grid_height = 32

/obj/item/cart_upgrade/level_1
	desc = "A wheelbrace, skillfully cut by a woodworker, that increases a cart's capacity to 90. It cannot be combined with artificer gears."
	ulevel = 1

/obj/item/cart_upgrade/level_2
	name = "reinforced woodcutters wheelbrace"
	desc = "An expertly crafted wheelbrace that increases a cart's capacity to 120. A normal wheelbrace must be installed first. It cannot be combined with artificer gears."
	icon_state = "upgrade2"
	ulevel = 2
