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
	var/list/listeners = playsound(user, 'modular_drakian/sound/dog-clicker.ogg', 100, FALSE, 1, FALSE)
	user.visible_message(span_info("[user] snaps the dog clicker!"))
	react_to_listeners(user, listeners)

/obj/item/dogclicker/proc/react_to_listeners(mob/living/user, list/listeners)
	if(!isturf(user.loc))
		return
	var/list/nearby_listeners
	for(var/mob/living/carbon/human/listener in listeners)
		if(listener == user || !HAS_TRAIT(listener, TRAIT_CLICKER_TRAINED) || !listener.can_react_to_dog_clicker())
			continue
		// Match the clicker's local emote range. The sound itself can carry farther.
		if(isnull(nearby_listeners))
			nearby_listeners = view(DEFAULT_MESSAGE_RANGE, user)
		if(!(listener in nearby_listeners))
			continue
		listener.set_resting(TRUE)
		if(!listener.resting)
			continue
		COOLDOWN_START(listener, dog_clicker_reaction, 10 SECONDS)
		playsound(listener, 'sound/foley/toggledown.ogg', 30, FALSE, ignore_walls = FALSE)
		listener.audible_message(span_notice("[listener] drops flat with a soft thump."), self_message = span_notice("I drop flat with a soft thump."))

/mob/living/carbon/human
	COOLDOWN_DECLARE(dog_clicker_reaction)

/mob/living/carbon/human/proc/can_react_to_dog_clicker()
	return COOLDOWN_FINISHED(src, dog_clicker_reaction) && isturf(loc) && !cmode && !resting && (mobility_flags & MOBILITY_STAND) && !(movement_type & FLYING) && !buckled && !buckling && !pulledby && !incapacitated() && can_hear()

/datum/loadout_item/dogclicker
	name = "Dog Clicker"
	path = /obj/item/dogclicker

/datum/quirk/clicker_trained
	name = "Clicker-Trained"
	desc = "I drop flat when someone snaps a dog clicker nearby."
	point_cost = 0
	custom_text = "Drops you prone when you hear another character's dog clicker in clear line of sight. Works outside combat, at most once every 10 seconds."
	added_traits = list(TRAIT_CLICKER_TRAINED)
