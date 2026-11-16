// Pinned Azure Peak art, scoped to new port types so native atlases stay intact.

/atom/movable/screen/alert/hagscry
	icon = 'icons/ap_dun_world/mob/screen_alert.dmi'

/obj/effect/proc_holder/spell/self/axedance
	action_icon = 'icons/ap_dun_world/mob/actions/roguespells.dmi'

/obj/effect/temp_visual/telegraph/pillar/fadein
	icon_state = "warning"

/obj/item/clothing/cloak/forrestercloak/autumn
	icon = 'icons/ap_dun_world/roguetown/clothing/cloaks.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/onmob/cloaks.dmi'
	sleeved = 'icons/ap_dun_world/roguetown/clothing/onmob/cloaks.dmi'

/obj/item/clothing/gloves/roguetown/elven_gloves/autumn
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'

/obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/autumn
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'

/obj/item/clothing/head/roguetown/helmet/heavy/elven_helm/autumn/light
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'

/obj/item/clothing/shoes/roguetown/boots/elven_boots/autumn
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'

/obj/item/clothing/suit/roguetown/armor/plate/elven_plate/autumn
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'
	sleeved = 'icons/ap_dun_world/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/clothing/suit/roguetown/armor/plate/elven_plate/autumn/light
	icon = 'icons/ap_dun_world/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/special/onmob/race_armor.dmi'
	sleeved = 'icons/ap_dun_world/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/autumn
	icon = 'icons/ap_dun_world/roguetown/weapons/ranged32.dmi'

/obj/item/roguekey/hag
	icon_state = "greenkey"

/obj/item/rogueweapon/greataxe/steel/hag
	icon = 'icons/ap_dun_world/roguetown/weapons/axes64.dmi'

/obj/item/rogueweapon/hag_claw
	icon_state = null

/obj/item/rogueweapon/halberd/bardiche/elvish/autumn
	icon = 'icons/ap_dun_world/roguetown/weapons/polearms64.dmi'

/obj/item/rogueweapon/halberd/hag
	icon = 'icons/ap_dun_world/roguetown/weapons/polearms64.dmi'

/obj/item/rogueweapon/huntingknife/idagger/elvish/autumn
	icon = 'icons/ap_dun_world/roguetown/weapons/daggers32.dmi'

/obj/item/rogueweapon/stoneaxe/battle/slayer
	icon = 'icons/ap_dun_world/roguetown/weapons/axes64.dmi'

/obj/item/rogueweapon/stoneaxe/woodcut/steel/slayer
	icon = 'icons/ap_dun_world/roguetown/weapons/axes32.dmi'

/obj/item/rogueweapon/sword/long/elvish/autumn
	icon = 'icons/ap_dun_world/roguetown/weapons/swords64.dmi'

/obj/item/rogueweapon/sword/long/hag
	icon = 'icons/ap_dun_world/roguetown/weapons/swords64.dmi'

/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter
	icon = 'icons/ap_dun_world/roguetown/weapons/polearms64.dmi'

/obj/item/rogueweapon/woodstaff/quarterstaff/lamplighter/warden
	icon = 'icons/ap_dun_world/roguetown/weapons/polearms64.dmi'

/obj/item/storage/belt/rogue/leather/slayer
	icon = 'icons/ap_dun_world/roguetown/clothing/belts.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/onmob/belts.dmi'

/obj/structure/roguemachine/hag_cauldron
	icon = 'icons/ap_dun_world/roguetown/misc/alchemy.dmi'

/obj/item/clothing/suit/roguetown/shirt/robe/hag
	icon = 'icons/ap_dun_world/roguetown/clothing/armor.dmi'
	mob_overlay_icon = 'icons/ap_dun_world/roguetown/clothing/onmob/armor.dmi'
	sleeved = null

// The donor has no worn wyrd_cross state; reuse the native amulet silhouette.
/proc/ap_hag_neck_overlay()
	var/static/icon/wyrd_neck_overlay
	if(!wyrd_neck_overlay)
		wyrd_neck_overlay = new /icon()
		wyrd_neck_overlay.Insert(icon('icons/roguetown/clothing/onmob/neck.dmi', "psycross_n"), "wyrd_cross")
	return wyrd_neck_overlay
