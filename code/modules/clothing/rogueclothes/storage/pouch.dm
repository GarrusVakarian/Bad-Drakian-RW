/obj/item/storage/belt/rogue/pouch
	name = "pouch"
	desc = "A small sack with a drawstring, worn around the neck, on the back or wrist, or at the hips with a belt."
	icon = 'icons/roguetown/clothing/storage.dmi'
	mob_overlay_icon = null
	icon_state = "pouch"
	item_state = "pouch"
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_NECK|ITEM_SLOT_CLOAK|ITEM_SLOT_BACK|ITEM_SLOT_WRISTS
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("whips", "lashes")
	max_integrity = 300
	equip_sound = 'sound/blank.ogg'
	content_overlays = FALSE
	bloody_icon_state = "bodyblood"
	sewrepair = TRUE
	resistance_flags = FIRE_PROOF
	grid_height = 64
	grid_width = 32
	component_type = /datum/component/storage/concrete/roguetown/coin_pouch
	salvage_amount = 1
	salvage_result = /obj/item/natural/fibers

/obj/item/storage/belt/rogue/pouch/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/belt/rogue/pouch/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(icon_state == "pouch_e")
		update_icon()

/obj/item/storage/belt/rogue/pouch/Exited(atom/movable/gone, direction)
	. = ..()
	if(!length(contents) && icon_state != "pouch_e")
		update_icon()

/obj/item/storage/belt/rogue/pouch/update_icon_state()
	. = ..()
	icon_state = length(contents) ? "pouch" : "pouch_e"

/obj/item/storage/belt/rogue/pouch/build_worn_icon(default_layer = 0, default_icon_file = null, isinhands = FALSE, femaleuniform = NO_FEMALE_UNIFORM, override_state = null, female = FALSE, customi = null, sleeveindex, boobed_overlay = FALSE, icon/clip_mask = null)
	// The empty sprite only exists in the inventory and ground icon sheet.
	return ..(default_layer, default_icon_file, isinhands, femaleuniform, override_state || (female && !isinhands ? "pouch_f" : "pouch"), female, customi, sleeveindex, boobed_overlay, clip_mask)

/obj/item/storage/belt/rogue/pouch/coins/poor/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/copper/pile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)
	if(prob(50))
		H = new(loc)
		if(istype(H))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
				qdel(H)

/obj/item/storage/belt/rogue/pouch/coins/mid/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/silver/pile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)
	var/obj/item/roguecoin/copper/pile/C = new(loc)
	if(istype(C))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, C, null, TRUE, TRUE))
			qdel(C)

/obj/item/storage/belt/rogue/pouch/coins/rich/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/silver/pile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)
	if(prob(50))
		H = new(loc)
		if(istype(H))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
				qdel(H)
	var/obj/item/roguecoin/gold/pile/G = new(loc)
	if(istype(G))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, G, null, TRUE, TRUE))
			qdel(G)
	if(prob(50))
		G = new(loc)
		if(istype(G))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, G, null, TRUE, TRUE))
				qdel(G)

/obj/item/storage/belt/rogue/pouch/coins/veryrich/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/gold/pile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)
	H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)
	if(prob(50))
		H = new(loc)
		if(istype(H))
			if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
				qdel(H)

/obj/item/storage/belt/rogue/pouch/coins/virtuepouch/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/gold/virtuepile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)

/obj/item/storage/belt/rogue/pouch/coins/readyuppouch/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/silver/pile/readyuppile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)

/obj/item/storage/belt/rogue/pouch/coins/gilbranze/Initialize(mapload)
	. = ..()
	var/obj/item/roguecoin/gilbranze/pile/H = new(loc)
	if(istype(H))
		if(!SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, H, null, TRUE, TRUE))
			qdel(H)

/obj/item/storage/belt/rogue/pouch/food/PopulateContents()
	new /obj/effect/spawner/lootdrop/roguetown/dungeon/food(src)

/obj/item/storage/belt/rogue/pouch/treasure/PopulateContents()
	new /obj/effect/spawner/lootdrop/mobtreasure(src)
	new /obj/item/reagent_containers/food/snacks/rogue/crackerscooked(src)

/obj/item/storage/belt/rogue/pouch/healing

/obj/item/storage/belt/rogue/pouch/healing/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/alchemical/healthpot(src)
	new /obj/item/reagent_containers/glass/bottle/alchemical/healthpot(src)
	new /obj/item/needle(src)

/obj/item/storage/belt/rogue/pouch/alchemy

/obj/item/storage/belt/rogue/pouch/alchemy/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/alchemical(src)
	new /obj/item/reagent_containers/glass/bottle/alchemical(src)
	new /obj/item/reagent_containers/glass/bottle/alchemical(src)
	new /obj/item/needle(src)

/obj/item/storage/belt/rogue/pouch/zigarrete
	name = "zig box"
	desc = "Used to hold someone's zigs and flints."
	icon_state = "smokebox"
	item_state = "smokebox"
	component_type = /datum/component/storage/concrete/grid/zigbox

/obj/item/storage/belt/rogue/pouch/zigarrete/nicotine/PopulateContents()
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)
	new /obj/item/clothing/mask/cigarette/rollie/nicotine(src)

/obj/item/storage/belt/rogue/pouch/zigarrete/trippy/PopulateContents()
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)
	new /obj/item/clothing/mask/cigarette/rollie/trippy(src)

/obj/item/storage/belt/rogue/pouch/treasure/lucky/PopulateContents()
	new /obj/effect/spawner/lootdrop/mobtreasure/lucky(src)
