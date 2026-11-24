/obj/item/dogclicker
	name = "dog clicker"
	desc = "A helpful tool for training pets."
	icon = 'modular_drakian/icons/obj/dogclicker.dmi'
	icon_state = "clicker"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	dropshrink = 0.6
	drop_sound = 'sound/foley/dropsound/wooden_drop.ogg'
	sellprice = 10
	static_price = TRUE
	simpleton_price = TRUE
	resistance_flags = FIRE_PROOF
	var/click_cd = 0

/obj/item/dogclicker/attack_self(mob/living/user)
	if(world.time < click_cd + 30)
		return
	click_cd = world.time
	playsound(user, 'modular_drakian/sound/dog-clicker.ogg', 100, FALSE, 1, FALSE)
	user.visible_message(span_info("[user] snaps the dog clicker!"))

/datum/loadout_item/dogclicker
	name = "Dog Clicker"
	path = /obj/item/dogclicker
