#define PILLORY_HEAD_OFFSET      2 // How much we need to move the player to center their head

/obj/structure/pillory
	name = "pillory"
	desc = "To keep the criminals locked!"
	icon_state = "pillory_single"
	icon = 'modular/icons/obj/pillory.dmi'
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	buckle_blocks_spells = TRUE
	anchored = TRUE
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER
	var/latched = FALSE
	locked = FALSE
	var/base_icon = "pillory_single"
	lockid = list()

/obj/structure/pillory/double
	icon_state = "pillory_double"
	base_icon = "pillory_double"

/obj/structure/pillory/reinforced
	icon_state = "pillory_reinforced"
	base_icon = "pillory_reinforced"


/obj/structure/pillory/Initialize(mapload)
	LAZYINITLIST(buckled_mobs)
	. = ..()

/obj/structure/pillory/examine(mob/user)
	. = ..()

	var/msg = "It is [latched ? "latched" : "unlatched"] and [locked ? "locked." : "unlocked."]<br/>"
	. += msg
	. += span_info("Click with a held liquid container outside combat mode to set it at the base.")

/obj/structure/pillory/attack_right(mob/living/user)
	. = ..()
	if(!buckled_mobs.len)
		to_chat(user, span_warning("What's the point of latching it with nobody inside?"))
		return
	if(user in buckled_mobs)
		to_chat(user, span_warning("I can't reach the latch!"))
		return
	if(locked)
		to_chat(usr, span_warning("Unlock it first!"))
		return
	togglelatch(user)

/obj/structure/pillory/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/reagent_containers/glass) && isliving(user) && !user.cmode)
		place_liquid_container(P, user)
		// Consume failed placements too: do not follow up by pouring or attacking.
		return TRUE
	if(user in buckled_mobs)
		to_chat(user, span_warning("I can't reach the lock!"))
		return
	if(!latched)
		to_chat(user, span_warning("It's not latched shut!"))
		return
	if(istype(P, /obj/item/roguekey))
		var/obj/item/roguekey/K = P
		if(K.lockid in lockid)
			togglelock(user)
			return
		else
			to_chat(user, span_warning("Wrong key."))
			playsound(src, 'sound/foley/doors/lockrattle.ogg', 100)
			return
	if(istype(P, /obj/item/storage/keyring))
		var/obj/item/storage/keyring/K = P
		for(var/obj/item/roguekey/KE in K.keys)
			if(KE.lockid in lockid)
				togglelock(user)
				return

/obj/structure/pillory/proc/place_liquid_container(obj/item/reagent_containers/glass/container, mob/user)
	if(!isliving(user) || QDELETED(user) || !istype(container) || QDELETED(container) || user.get_active_held_item() != container || !Adjacent(user))
		return FALSE
	var/turf/placement_turf = loc
	if(!istype(placement_turf))
		return FALSE
	if(!user.transferItemToLoc(container, placement_turf, silent = FALSE))
		return FALSE
	// Dropping can trigger deletion or relocation through inventory/turf callbacks.
	if(QDELETED(container) || QDELETED(src) || container.loc != placement_turf || loc != placement_turf)
		return FALSE
	container.AddComponent(/datum/component/pillory_container_placement, src)
	return TRUE

/// Temporary floor positioning; no processing or timer is needed.
/datum/component/pillory_container_placement
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/obj/structure/pillory/pillory
	var/original_plane
	var/original_layer

/datum/component/pillory_container_placement/Initialize(obj/structure/pillory/support)
	if(!istype(parent, /obj/item/reagent_containers/glass) || !istype(support) || QDELETED(support) || !isturf(support.loc))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/container = parent
	if(container.loc != support.loc)
		return COMPONENT_INCOMPATIBLE
	pillory = support
	original_plane = container.plane
	original_layer = container.layer

/datum/component/pillory_container_placement/RegisterWithParent()
	var/obj/item/container = parent
	RegisterSignal(container, list(COMSIG_MOVABLE_MOVED, COMSIG_ITEM_PICKUP), PROC_REF(clear_placement))
	RegisterSignal(pillory, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(clear_placement))
	// Cancel the ordinary drop bounce before applying a fixed position.
	animate(container)
	container.pixel_x = initial(container.pixel_x)
	container.pixel_y = initial(container.pixel_y) - world.icon_size / 2
	container.plane = pillory.plane
	container.layer = pillory.layer + 0.1

/datum/component/pillory_container_placement/proc/clear_placement()
	SIGNAL_HANDLER
	qdel(src)

/datum/component/pillory_container_placement/Destroy(force, silent)
	restore_placement()
	return ..()

/datum/component/pillory_container_placement/UnregisterFromParent()
	restore_placement()
	return ..()

/datum/component/pillory_container_placement/proc/restore_placement()
	if(!pillory)
		return
	var/obj/item/container = parent
	if(container)
		UnregisterSignal(container, list(COMSIG_MOVABLE_MOVED, COMSIG_ITEM_PICKUP))
		if(!QDELETED(container) && pillory)
			container.pixel_x = initial(container.pixel_x)
			container.pixel_y = initial(container.pixel_y)
			container.plane = original_plane
			container.layer = original_layer
	if(pillory)
		UnregisterSignal(pillory, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	pillory = null

/obj/structure/pillory/proc/togglelatch(mob/living/user, silent)
	user.changeNext_move(CLICK_CD_MELEE)
	if(latched)
		user.visible_message(span_warning("[user] unlatches [src]."), \
			span_notice("I unlatch [src]."))
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		latched = FALSE
	else
		user.visible_message(span_warning("[user] latches [src]."), \
			span_notice("I latch [src]."))
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		latched = TRUE

/obj/structure/pillory/proc/togglelock(mob/living/user, silent)
	user.changeNext_move(CLICK_CD_MELEE)
	if (!latched)
		to_chat(user, span_warning("\The [src] is not latched shut."))
	if(locked)
		user.visible_message(span_warning("[user] unlocks [src]."), \
			span_notice("I unlock [src]."))
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = FALSE
	else
		user.visible_message(span_warning("[user] locks [src]."), \
			span_notice("I lock [src]."))
		playsound(src, 'sound/foley/doors/lock.ogg', 100)
		locked = TRUE

/obj/structure/pillory/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if (!anchored)
		return FALSE

	if(locked)
		to_chat(usr, span_warning("Unlock it first!"))
		return FALSE

	if (!istype(M, /mob/living/carbon/human))
		to_chat(usr, span_warning("It doesn't look like [M.p_they()] can fit into this properly!"))
		return FALSE // Can't hold non-humanoids

	return ..(M, force, FALSE)

/obj/structure/pillory/post_buckle_mob(mob/living/M)
	if (!istype(M, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = M

	if (H.dna)
		if (H.dna.species)
			var/datum/species/S = H.dna.species

			if (istype(S))
				//H.cut_overlays()
				H.update_body_parts_head_only()
				switch(H.dna.species.name)
					if ("Dwarf", "Kobold", "Goblin", "Critterkin")
						H.set_mob_offsets("bed_buckle", _x = 0, _y = PILLORY_HEAD_OFFSET)
				icon_state = "[base_icon]-over"
				update_icon()
			else
				unbuckle_all_mobs()
		else
			unbuckle_all_mobs()
	else
		unbuckle_all_mobs()

	..()

/obj/structure/pillory/post_unbuckle_mob(mob/living/M)
	//M.regenerate_icons()
	M.reset_offsets("bed_buckle")
	icon_state = "[base_icon]"
	update_icon()
	..()

/obj/structure/pillory/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!latched)
		return ..()
	if(buckled_mob == user)
		if(buckled_mob.STASTR >= 18)
			if(do_after(buckled_mob, 2.5 SECONDS))
				buckled_mob.visible_message(span_warning("[buckled_mob] breaks [src] open!"))
				locked = FALSE
				latched = FALSE
				return ..()
			return null
		if(locked)	//can't be locked without also being latched anyway
			to_chat(user, span_warning("It's locked! I can't free myself!"))
			return
		else if(latched)
			buckled_mob.visible_message(span_warning("[buckled_mob] struggles in [src], trying to get the latch off!"))
			if(do_after(buckled_mob, 12 SECONDS))
				buckled_mob.visible_message(span_warning("[buckled_mob] forces [src]'s latch open!"))
				latched = FALSE
				return ..()
			else
				return null
	if(locked)	//if user isn't the one in the pillory and it's also locked
		to_chat(user, span_warning("[src] is locked! I'll need a key to unlatch it."))
		return null
	latched = FALSE //we pull them free, which implies unlatching
	return ..()

/obj/structure/pillory/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum, damage_flag)
	if(!has_buckled_mobs())
		return ..()

	var/mob/living/victim = pick(buckled_mobs)
	return AM.throw_impact(victim, throwingdatum)

#undef PILLORY_HEAD_OFFSET
