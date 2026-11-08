/obj/item/natural/cloth/bandage
	name = "bandage"
	icon = 'icons/roguetown/items/surgery.dmi'
	icon_state = "bandageroll"
	desc = "A fabric treated and specially made to help with bleeding wounds. Better and faster at stopping bleeding than your regular piece of cloth."
	bundletype = /obj/item/natural/bundle/cloth/bandage
	bandage_effectiveness = 0.5
	bandage_health = 300 //High HP so it can last some time on more serious wounds like arteries, total of 225 blood soaked
	bandage_speed = 4 SECONDS

/obj/item/natural/cloth/bandage/attack_right(mob/user)
	return

/obj/item/natural/bundle/cloth/bandage
	name = "roll of bandages"
	icon = 'icons/roguetown/items/surgery.dmi'
	icon_state = "bandageroll1"
	desc = "A roll of joined bandages for easier carrying. A bleeding man's best friend."
	maxamount = 4 //balanced...? You'd die of bloodloss before all of them were dirty.
	stacktype = /obj/item/natural/cloth/bandage
	stackname = "bandages"
	icon1 = "bandageroll1"
	icon1step = 3
	icon2 = "bandageroll2"
	icon2step = 4

/obj/item/natural/bundle/cloth/bandage/full
	icon_state = "bandageroll2"
	amount = 4

/obj/item/natural/bundle/cloth/bandage/attack(mob/living/M, mob/user)
	if(QDELETED(src) || !user || loc != user || user.get_active_held_item() != src || amount < 1)
		return
	var/obj/item/natural/cloth/bandage/piece = new stacktype(src)
	piece.bandage(M, user, src)
	if(!QDELETED(piece) && piece.loc == src)
		qdel(piece)

/// Called after the piece has moved onto the limb, so deleting the roll cannot delete the dressing.
/obj/item/natural/bundle/cloth/bandage/proc/consume_bandage(mob/user)
	amount--
	if(amount == 1)
		var/obj/item/remaining = new stacktype(drop_location())
		qdel(src)
		user.put_in_hands(remaining)
	else if(amount <= 0)
		qdel(src)
	else
		update_bundle()
