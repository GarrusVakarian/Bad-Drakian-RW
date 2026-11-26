#define PEDDLER_MAX_PRICE 9999

/obj/structure/roguemachine/vendor
	name = "PEDDLER"
	desc = "The stomach of this thing can been stuffed with fun things for you to buy."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "streetvendor1"
	density = TRUE
	blade_dulling = DULLING_BASH
	integrity_failure = 0.1
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/list/held_items = list()
	locked = TRUE
	var/wgain = 0
	var/keycontrol = "merchant"
	var/next_hawk = 0
	var/will_hawk = TRUE
	var/max_items = 30
	var/budget = 0
	var/generating_icons = FALSE
	
/// Items of the same type sold under the same name are one product group
/obj/structure/roguemachine/vendor/proc/make_group_key(item_type, item_name)
	return "[item_type]_[item_name]"

/obj/structure/roguemachine/vendor/proc/group_key(obj/item/I)
	return make_group_key(I.type, held_items[I]["NAME"] || I.name)

/// Returns the held_items keys (actual obj/item refs) belonging to the given group key
/obj/structure/roguemachine/vendor/proc/get_group_items(key)
	var/list/matches = list()
	for(var/obj/item/O in held_items)
		if(group_key(O) == key)
			matches += O
	return matches

/obj/structure/roguemachine/vendor/proc/is_full()
	return length(held_items) >= max_items

/// Records an item already inside the machine. Mapped stock may supply its own price.
/obj/structure/roguemachine/vendor/proc/store_item(obj/item/P, price)
	if(QDELETED(P) || P.loc != src || held_items[P])
		return FALSE
	var/key = make_group_key(P.type, P.name)
	var/list/representative
	for(var/obj/item/current in held_items)
		if(group_key(current) == key)
			representative = held_items[current]
			break
	if(isnull(price))
		price = representative ? representative["PRICE"] : 0
	held_items[P] = list("NAME" = P.name, "PRICE" = price, "ICON" = representative ? representative["ICON"] : null)
	return TRUE

/// Flattens one group icon per tick while somebody is viewing this machine.
/obj/structure/roguemachine/vendor/proc/generate_icons()
	var/list/stock = held_items.Copy()
	for(var/obj/item/I as anything in stock)
		if(QDELETED(src) || !length(open_uis) || obj_broken)
			break
		if(QDELETED(I) || !held_items[I] || !isnull(held_items[I]["ICON"]))
			continue
		var/icon_data = icon2base64(getFlatIcon(I, no_anim = TRUE)) || ""
		for(var/obj/item/O as anything in get_group_items(group_key(I)))
			if(isnull(held_items[O]["ICON"]))
				held_items[O]["ICON"] = icon_data
		sleep(world.tick_lag)
	if(QDELETED(src))
		return
	generating_icons = FALSE
	SStgui.update_uis(src)

/obj/structure/roguemachine/vendor/Exited(atom/movable/gone, atom/newLoc)
	. = ..()
	if(held_items[gone])
		held_items -= gone
		update_icon()
		SStgui.update_uis(src)

/obj/structure/roguemachine/vendor/proc/insert(obj/item/P, mob/living/user)
	if(!is_loadable(P))
		return FALSE
	if(is_full())
		to_chat(user, span_warning("Full."))
		return FALSE
	if(!user.transferItemToLoc(P, src))
		to_chat(user, span_warning("[P] is stuck to your hand!"))
		return FALSE
	if(!store_item(P))
		return FALSE
	playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
	update_icon()
	SStgui.update_uis(src)
	return TRUE

/// Stocks as many loose items or top-level bag contents as fit.
/obj/structure/roguemachine/vendor/proc/load_items(list/items, mob/living/user, datum/component/storage/concrete/from_storage)
	if(locked || obj_broken)
		return
	var/stored = 0
	var/bag_changed = FALSE
	var/full = FALSE
	for(var/obj/item/I in items)
		if(!is_loadable(I))
			continue
		if(is_full())
			full = TRUE
			break
		if(from_storage)
			if(QDELETED(from_storage) || from_storage.locked)
				break
			if(I.loc != from_storage.real_location() || !from_storage.remove_from_storage(I, src, refresh_storage = FALSE))
				continue
			bag_changed = TRUE
		else if(!I.forceMove(src))
			continue
		if(store_item(I))
			stored++

	if(stored)
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		to_chat(user, span_notice("\The [src] swallows [stored] item\s."))
		update_icon()
		SStgui.update_uis(src)
	if(bag_changed && !QDELETED(from_storage))
		from_storage.update_icon()
		from_storage.refresh_mob_views()
	if(full)
		to_chat(user, span_warning("\The [src] is full."))
	else if(!stored)
		to_chat(user, span_warning("There is nothing \the [src] can take."))

/obj/structure/roguemachine/vendor/proc/is_loadable(obj/item/I)
	return !QDELETED(I) && !I.anchored && !(I.item_flags & ABSTRACT) && I.w_class <= WEIGHT_CLASS_BULKY && !istype(I, /obj/item/roguecoin)

/obj/structure/roguemachine/vendor/attack_right(mob/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE) || obj_broken)
		return
	if(locked)
		return attack_hand(user)
	user.changeNext_move(CLICK_CD_INTENTCAP)
	var/obj/item/held = user.get_active_held_item()
	if(!held)
		var/turf/front = get_step(src, get_dir(src, user))
		if(front)
			load_items(front.contents.Copy(), user)
		return
	if(!istype(held, /obj/item/storage/keyring))
		var/datum/component/storage/bag = held.GetComponent(/datum/component/storage)
		var/datum/component/storage/concrete/storage = bag?.master()
		if(storage)
			if(!bag.locked && !storage.locked)
				load_items(storage.contents(), user, storage)
			return
	return attackby(held, user, null)

/obj/structure/roguemachine/vendor/attackby(obj/item/P, mob/user, params)
	if(obj_broken)
		return ..()
	if(istype(P, /obj/item/roguecoin/gilbranze) || istype(P, /obj/item/roguecoin/inqcoin))
		return
	if(istype(P, /obj/item/roguecoin))
		budget += P.get_real_price()
		qdel(P)
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)
		SStgui.update_uis(src)
		return
	if(istype(P, /obj/item/roguekey) || istype(P, /obj/item/storage/keyring))
		if(key_fits(P))
			toggle_lock()
			return
		if(locked)
			to_chat(user, span_warning("Wrong key."))
			return
	if(!locked && insert(P, user))
		return
	return ..()

/obj/structure/roguemachine/vendor/proc/key_fits(obj/item/key_or_ring)
	if(istype(key_or_ring, /obj/item/roguekey))
		var/obj/item/roguekey/key = key_or_ring
		return key.lockid == keycontrol
	for(var/obj/item/roguekey/key in key_or_ring)
		if(key.lockid == keycontrol)
			return TRUE
	return FALSE

/obj/structure/roguemachine/vendor/proc/toggle_lock()
	locked = !locked
	playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
	update_icon()
	SStgui.update_uis(src)

/obj/structure/roguemachine/vendor/attack_hand(mob/living/user)
	. = ..()
	if(. || !ishuman(user) || obj_broken)
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	ui_interact(user)

/obj/structure/roguemachine/vendor/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/structure/roguemachine/vendor/ui_status(mob/user, datum/ui_state/state)
	if(obj_broken || !isliving(user) || user.stat == DEAD)
		return UI_CLOSE
	return ..()

/obj/structure/roguemachine/vendor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
		ui = new(user, src, "Peddler", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/structure/roguemachine/vendor/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked ? TRUE : FALSE,
		"can_read" = user.can_read(src, TRUE) ? TRUE : FALSE,
		"budget" = budget,
		"profits" = wgain,
	)
	data["stored"] = length(held_items)
	data["capacity"] = max_items

	var/list/groups = list()
	var/list/group_order = list()
	for(var/obj/item/I in held_items)
		var/key = group_key(I)
		if(!groups[key])
			groups[key] = list(
				"key" = key,
				// names are stored html-encoded for hawking; tgui escapes text itself
				"name" = html_decode(held_items[I]["NAME"] || "thing"),
				"price" = held_items[I]["PRICE"] || 0,
				"count" = 0,
				"desc" = I.desc,
				// null until generate_icons gets to it
				"icon" = null,
			)
			group_order += key
		groups[key]["count"] += 1
		// a merged group can have members with and without an icon yet
		if(isnull(groups[key]["icon"]))
			groups[key]["icon"] = held_items[I]["ICON"]

	var/list/group_data = list()
	var/needs_icons = FALSE
	for(var/key in group_order)
		group_data += list(groups[key])
		if(isnull(groups[key]["icon"]))
			needs_icons = TRUE
	if(needs_icons && !generating_icons && !obj_broken)
		generating_icons = TRUE
		addtimer(CALLBACK(src, PROC_REF(generate_icons)), 1)
	data["groups"] = group_data
	return data

/// Hands the first item to the user and drops the rest at their feet
/obj/structure/roguemachine/vendor/proc/dispense(list/items, mob/living/user)
	var/turf/T = get_turf(user)
	var/first = TRUE
	for(var/obj/item/O as anything in items)
		held_items -= O
		if(!first || !user.put_in_hands(O))
			O.forceMove(T)
		first = FALSE
	update_icon()

/obj/structure/roguemachine/vendor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/H = ui.user
	if(!istype(H) || H != usr || obj_broken || !H.canUseTopic(src, BE_CLOSE))
		return
	return shop_action(H, action, params)

/obj/structure/roguemachine/vendor/proc/shop_action(mob/living/carbon/human/user, action, list/params)
	switch(action)
		if("change")
			if(!locked || budget <= 0)
				return FALSE
			budget2change(budget, user)
			budget = 0
			return TRUE

		if("withdraw_profits")
			if(locked || wgain <= 0)
				return FALSE
			budget2change(wgain, user)
			wgain = 0
			return TRUE
		if("buy")
			if(!locked)
				return
			var/list/matches = get_group_items(params["key"])
			if(!length(matches))
				return
			var/amount = text2num("[params["amount"]]")
			if(!(amount >= 1) || amount != round(amount) || amount > length(matches))
				return FALSE
			var/price = held_items[matches[1]]["PRICE"] || 0
			if(text2num("[params["price"]]") != price)
				return FALSE
			var/total = price * amount
			if(total > budget)
				say("NO MONEY NO HONEY!")
				return FALSE
			budget -= total
			wgain += total
			record_round_statistic(STATS_PEDDLER_REVENUE, total)
			dispense(matches.Copy(1, amount + 1), user)
			return TRUE

		if("take")
			if(locked)
				return
			var/list/matches = get_group_items(params["key"])
			if(!length(matches))
				return
			var/amount = params["all"] ? length(matches) : 1
			dispense(matches.Copy(1, amount + 1), user)
			return TRUE

		if("set_name")
			if(locked || !user.can_read(src, TRUE))
				return
			var/list/matches = get_group_items(params["key"])
			var/newname = sanitize(copytext(trim("[params["name"]]"), 1, MAX_NAME_LEN + 1))
			if(!length(matches) || !length(newname))
				return
			// renaming into an existing group merges with it, so take that group's price
			var/obj/item/first = matches[1]
			var/price = held_items[first]["PRICE"]
			var/list/joining = get_group_items(make_group_key(first.type, newname)) - matches
			if(length(joining))
				price = held_items[joining[1]]["PRICE"]
			for(var/obj/item/I in matches)
				held_items[I]["NAME"] = newname
				held_items[I]["PRICE"] = price
			return TRUE

		if("set_price")
			if(locked)
				return
			var/list/matches = get_group_items(params["key"])
			var/newprice = text2num("[params["price"]]")
			// no negative prices, no decimals
			if(!length(matches) || !(newprice >= 0) || newprice != round(newprice))
				return
			newprice = min(newprice, PEDDLER_MAX_PRICE)
			for(var/obj/item/I in matches)
				held_items[I]["PRICE"] = newprice
			return TRUE

/obj/structure/roguemachine/vendor/proc/drop_stock()
	var/list/stock = held_items.Copy()
	held_items.Cut()
	var/atom/destination = drop_location()
	if(destination)
		for(var/obj/item/I in stock)
			if(!QDELETED(I) && I.loc == src)
				I.forceMove(destination)
	// Broken carts cannot open their shop window to pay out either balance.
	var/payout = budget + wgain
	budget = 0
	wgain = 0
	if(payout > 0)
		budget2change(payout)

/obj/structure/roguemachine/vendor/obj_break(damage_flag)
	. = ..()
	drop_stock()
	SStgui.close_uis(src)
	update_icon()

/obj/structure/roguemachine/vendor/Initialize(mapload)
	. = ..()
	update_icon()
	START_PROCESSING(SSroguemachine, src)

/obj/structure/roguemachine/vendor/update_icon()
	cut_overlays()
	var/open = !locked || obj_broken
	icon_state = open ? "streetvendor0" : "streetvendor1"
	if(!open && length(held_items))
		set_light(1, 1, 1, l_color = "#1b7bf1")
		add_overlay(mutable_appearance(icon, "vendor-gen"))
	else
		set_light(0)

/obj/structure/roguemachine/vendor/Destroy()
	STOP_PROCESSING(SSroguemachine, src)
	SStgui.close_uis(src)
	drop_stock()
	set_light(0)
	return ..()

/obj/structure/roguemachine/vendor/process()
	if(obj_broken)
		return
	if(!will_hawk)
		return
	if(world.time > next_hawk)
		next_hawk = world.time + rand(1 MINUTES, 2 MINUTES)
		if(length(held_items))
			var/obj/item/I = pick(held_items)
			var/namer = held_items[I]["NAME"]
			namer = capitalize(namer)

			if(!findtext(namer, "s", -1)) // doesn't already end with "s"
				for(var/obj/item/O in held_items)
					if(O == I)
						continue
					if(O.type == I.type && (held_items[O]["NAME"]) == held_items[I]["NAME"])
						namer += "s" //add a plural s!
						break

			say("[namer] for sale! [held_items[I]["PRICE"]] mammons!")

/obj/structure/roguemachine/vendor/centcom
	name = "LANDLORD"
	desc = "Give this thing money, and you will immediately buy a neat property in the capital."
	max_integrity = 0
	icon_state = "streetvendor1"
	keycontrol = "dhjlashfdg"
	var/list/cachey = list()

/obj/structure/roguemachine/vendor/centcom/attack_hand(mob/living/user)
	return

/obj/structure/roguemachine/vendor/centcom/attack_right(mob/user)
	return

/obj/structure/roguemachine/vendor/centcom/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguecoin))
		if(!cachey[user])
			cachey[user] = list()
		cachey[user]["moneydonate"] += P.get_real_price()
		qdel(P)
		update_icon()
		playsound(loc, 'sound/misc/machinevomit.ogg', 100, TRUE, -1)

		if(cachey[user]["moneydonate"] > 99)
			if(!cachey[user]["trisawarded"])
				cachey[user]["trisawarded"] = 1
				user.adjust_triumphs(1)
				say("[user] has purchased a prole dwelling.")
				playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)
		if(cachey[user]["moneydonate"] > 499)
			if(cachey[user]["trisawarded"] < 2)
				cachey[user]["trisawarded"] = 2
				user.adjust_triumphs(1)
				say("[user] has been upgraded to a space in a serf apartment.")
				playsound(src, pick('sound/misc/machinetalk.ogg'), 100, FALSE, -1)
		if(cachey[user]["moneydonate"] > 999)
			if(cachey[user]["trisawarded"] < 3)
				cachey[user]["trisawarded"] = 3
				user.adjust_triumphs(1)
				say("[user] HAS BEEN UPGRADED TO A NOBLE BEDCHAMBER!")
				playsound(src, 'sound/misc/machinelong.ogg', 100, FALSE, -1)

/obj/structure/roguemachine/vendor/inn
	keycontrol = "tavern"
	will_hawk = FALSE

/obj/structure/roguemachine/vendor/inn/Initialize(mapload)
	. = ..()

	// Add room keys with a price of 20
	for (var/X in list(/obj/item/roguekey/roomi, /obj/item/roguekey/roomii, /obj/item/roguekey/roomiii, /obj/item/roguekey/roomiv, /obj/item/roguekey/roomv, /obj/item/roguekey/roomvi, /obj/item/roguekey/roomvii, /obj/item/roguekey/roomviii))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 20

	// Add fancy keys with a price of 100
	for (var/Y in list(/obj/item/storage/keyring/innfancyi, /obj/item/roguekey/fancyroomii, /obj/item/storage/keyring/innfancyiii, /obj/item/storage/keyring/innfancyiv, /obj/item/storage/keyring/innfancyv))
		var/obj/Q = new Y(src)
		held_items[Q] = list()
		held_items[Q]["NAME"] = Q.name
		held_items[Q]["PRICE"] = 100

	update_icon()

/obj/structure/roguemachine/vendor/innrockhill
	keycontrol = "tavern"
	will_hawk = FALSE

/obj/structure/roguemachine/vendor/innrockhill/Initialize(mapload)
	. = ..()

	// Add room keys with a price of 20
	for (var/X in list(/obj/item/roguekey/roomi, /obj/item/roguekey/roomii, /obj/item/roguekey/roomiii, /obj/item/roguekey/roomiv, /obj/item/roguekey/roomv, /obj/item/roguekey/roomvi, /obj/item/roguekey/roomvii, /obj/item/roguekey/roomviii, /obj/item/roguekey/roomix, /obj/item/roguekey/roomx))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 20

	// Add fancy keys with a price of 100
	for (var/Y in list(/obj/item/storage/keyring/innfancyi, /obj/item/storage/keyring/innfancyii, /obj/item/storage/keyring/innfancyiii))
		var/obj/Q = new Y(src)
		held_items[Q] = list()
		held_items[Q]["NAME"] = Q.name
		held_items[Q]["PRICE"] = 100

	update_icon()


/obj/structure/roguemachine/vendor/bathhouse
	keycontrol = "nightmaiden"//used to be nightman but it's nice for them to be able to stock the shelves too when the master isn't around

/obj/structure/roguemachine/vendor/bathhouse/locker
	will_hawk = FALSE

/obj/structure/roguemachine/vendor/bathhouse/locker/Initialize(mapload)
	. = ..()

	// Add locker keys with a price of 10
	for (var/X in list(/obj/item/roguekey/bathlocker1, /obj/item/roguekey/bathlocker2, /obj/item/roguekey/bathlocker3, /obj/item/roguekey/bathlocker4, /obj/item/roguekey/bathlocker5, /obj/item/roguekey/bathlocker6))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 5

	update_icon()


/obj/structure/roguemachine/vendor/merchant
	keycontrol = "merchant"

/obj/structure/roguemachine/vendor/merchant/Initialize(mapload)
	. = ..()
	for(var/X in list(/obj/item/roguekey/apartments/stall1,/obj/item/roguekey/apartments/stall2,/obj/item/roguekey/apartments/stall3))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 10
	update_icon()

/obj/structure/roguemachine/vendor/stablemaster
	keycontrol = "stablemaster"

/obj/structure/roguemachine/vendor/stablemaster/Initialize(mapload)
	. = ..()
	for(var/X in list(/obj/item/roguekey/apartments/stablemaster_1,/obj/item/roguekey/apartments/stablemaster_2,/obj/item/roguekey/apartments/stablemaster_3,/obj/item/roguekey/apartments/stablemaster_4,/obj/item/roguekey/apartments/stablemaster_5))
		var/obj/P = new X(src)
		held_items[P] = list()
		held_items[P]["NAME"] = P.name
		held_items[P]["PRICE"] = 30
	update_icon()

// PEDDLER CARTS

/obj/structure/roguemachine/vendor/mobile
	name = "peddler cart"
	desc = "A smaller, wheeled PEDDLER that can be moved around."
	icon_state = "svendorcart1"
	anchored = FALSE
	max_items = 20
	max_integrity = 400
	keycontrol = "pdefault"
	var/keycontrol_initialized = FALSE
	climbable = TRUE

/obj/structure/roguemachine/vendor/mobile/Move() //Stops cart from being pushed around by explosions and such while locked.
	if(anchored)
		return FALSE
	return ..()

/obj/structure/roguemachine/vendor/mobile/can_be_pulled(mob/user) //Stops players from grabbing and pulling cart while locked.
	return !anchored

/obj/structure/roguemachine/vendor/mobile/attackby(obj/item/P, mob/user, params)
	if(obj_broken || !istype(P, /obj/item/roguekey))
		return ..()
	var/obj/item/roguekey/K = P
	if(!keycontrol_initialized) // First key used sets ownership.
		keycontrol = K.lockid
		keycontrol_initialized = TRUE
		to_chat(user, span_notice("The peddler accepts the key and binds itself to its pattern."))
	else
		if(K.lockid != keycontrol) // Normal behaviour if the peddler already has an owner.
			to_chat(user, span_warning("Wrong key."))
			return
	toggle_lock()
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the peddler."))
	return

/obj/structure/roguemachine/vendor/mobile/attack_right(mob/user)
	if(!ishuman(user) || !user.canUseTopic(src, BE_CLOSE) || obj_broken)
		return
	var/obj/item/I = user.get_active_held_item()
	if(istype(I, /obj/item/roguekey))
		var/obj/item/roguekey/K = I
		if(K.lockid != keycontrol)
			to_chat(user, span_warning("Wrong key."))
			return
		anchored = !anchored
		to_chat(user, span_notice("You [anchored ? "secure" : "unsecure"] the wheels."))
		playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
		update_icon()
		return
	return ..()

/obj/structure/roguemachine/vendor/mobile/update_icon()
	cut_overlays()
	if(obj_broken)
		icon_state = "svendorcart0"
		set_light(0)
		return
	if(!locked)
		set_light(0)
		icon_state = "svendorcart0"
		return
	else
		icon_state = "svendorcart1"
	if(held_items.len)
		set_light(1, 1, 1, l_color = "#1b7bf1")
		add_overlay(mutable_appearance(icon, "vendor-gen"))
	else
		set_light(0)

/obj/structure/roguemachine/vendor/mobile/get_mechanics_examine(mob/user)
	. = list()
	. += span_info("Left-clicking a PEDDLER CART with an open hand allows you to browse and purchase its wares. Click on the 'Stored Mammon' option to retrieve any coinage or change left behind.")
	. += span_info("The PEDDLER CART will bind to the first key inserted into its lock by left-clicking with said key.")
	. += span_info("Owners of the PEDDLER CART can UNLOCK it by left-clicking with the relevant key. They can then restock wares and vend whatever coinage might've been earned from completed sales.")
	. += span_info("While unlocked, right-click with a bag to stock it from the bag, or empty-handed to load items off the ground.")
	. += span_info("Owners of the PEDDLER CART can ANCHOR it by right-clicking with the relevant key. This locks the wheels in place.")

#undef PEDDLER_MAX_PRICE
