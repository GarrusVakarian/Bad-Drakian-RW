/datum/crafting_recipe/roguetown/survival/lampstaff
	always_availible = FALSE
	name = "lamplighter's staff"
	result = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter = 1)
	reqs = list(/obj/item/rogueweapon/woodstaff/quarterstaff = 1, /obj/item/flashlight/flare/torch/lantern = 1, /obj/item/reagent_containers/food/snacks/tallow = 2)
	craftdiff = 3

/datum/crafting_recipe/roguetown/survival/lampwarden
	always_availible = FALSE
	name = "lampwarden's staff"
	result = list(/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden = 1)
	reqs = list(/obj/item/rogueweapon/woodstaff/quarterstaff = 1, /obj/item/flashlight/flare/torch/lantern = 1, /obj/item/reagent_containers/food/snacks/tallow = 2, /obj/item/ingot/iron = 1)
	craftdiff = 3

/datum/crafting_recipe/roguetown/structure/lamplighter_brazier // Cheap brazier recipe for lamplighters only.
	name = "brazier (Lamplighter)"
	category = "Lighting"
	result = /obj/machinery/light/rogue/firebowl/stump
	reqs = list(/obj/item/grown/log/tree/small = 1,
				/obj/item/natural/stone = 1)
	verbage_simple = "assembles"
	verbage = "assembles"
	always_availible = FALSE

/obj/item/clothing/mask/rogue/facemask/leather/lamplighter
	name = "lamplighter's mask"
	desc = "A leather mask meant to shield your face from claw and oil."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampmask1"
	adjustable = CANT_CADJUST

/obj/item/clothing/mask/rogue/facemask/leather/lamplighter/beaked
	name = "lamplighter's beaked mask"
	desc = "A beaked leather mask meant to shield your face from claw and oil."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampmask2"
	flags_inv = HIDEFACE|HIDESNOUT|HIDEHAIR|HIDEEARS

/obj/item/clothing/neck/roguetown/chaincoif/chainmantle/lamplighter
	name = "lamplighter's collar"
	desc = "A large neck covering made to protect the neck from splashing oil and jumping flames."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampneck"

/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/lamplighter
	name = "lampwicker's overcoat"
	desc = "A Lamplighters overcoat is made to protect them both from the elements and from their own tools, treated to be resistant to flames, these hardy overcoats often still aren’t enough, evidenced by the many burns lamplighters seem to carry regardless."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	sleeved = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampcoat1"
	color = null

/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat/lamplighter/warden
	name = "lampwarden's overcoat"
	desc = "A heavier leather overcoat favored by Lampwardens, when combined with the usual collar stand covering the neck, these overcoats protect Lampwardens from the fire and oil of their own staves as they escort travellers. The burns covering their grim owners are evidence that these often still aren’t ."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	sleeved = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lampcoat2"

/obj/item/clothing/head/roguetown/inqhat/lamplighter
	name = "lampwicker's hat"
	desc = "A seared and stained tricorn hat."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lamphat1"

/obj/item/clothing/head/roguetown/inqhat/lamplighter/warden
	name = "lampwarden's hat"
	desc = "A seared and stained widebrim hat."
	icon = 'icons/roguetown/clothing/special/lamplighter.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/lamplighter.dmi'
	icon_state = "lamphat2"

/obj/item/book/rogue/lamplighter
	name = "Roadsman's Codex"
	desc = "By Lampsmith Arlniss"
	icon_state = "lawtome_0"
	base_icon_state = "lawtome"
	bookfile = "lamplighter.json"

/datum/wound/lampcautery
	name = "cauterized wound"
	whp = 240
	bleed_rate = 0
	clotting_rate = 0
	clotting_threshold = 0
	passive_healing = 1
	woundpain = 100
	healable_by_miracles = FALSE
