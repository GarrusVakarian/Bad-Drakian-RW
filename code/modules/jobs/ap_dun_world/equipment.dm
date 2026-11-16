/obj/item/contraption/linker/ap_precharged/Initialize(mapload)
	. = ..()
	current_charge = max_stored_charge

/obj/item/roguecoin/silver/pile/wretchpile/Initialize(mapload)
	. = ..()
	set_quantity(10)

/obj/item/roguecoin/silver/pile/munitioneerpile/Initialize(mapload)
	. = ..()
	set_quantity(16)

/obj/item/natural/bundle/stick/full
	amount = 10
