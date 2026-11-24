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

/obj/item/dogclicker/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Activate the clicker in your hand to snap it. Nearby Clicker-Trained characters who hear it may drop prone.")
	. += span_info("Click an adjacent character while holding the clicker to offer them Clicker-Trained for this round. They must be out of combat mode and accept the offer.")

/obj/item/dogclicker/pre_attack(atom/target, mob/living/user, params)
	if(..())
		return TRUE
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/trainee = target
	if(!trainee.dog_clicker_offer_pending && COOLDOWN_FINISHED(trainee, dog_clicker_offer) && can_offer_training(user, trainee))
		trainee.dog_clicker_offer_pending = TRUE
		INVOKE_ASYNC(trainee, TYPE_PROC_REF(/mob/living/carbon/human, offer_clicker_training), src, user)
	return TRUE

/obj/item/dogclicker/proc/can_offer_training(mob/living/user, mob/living/carbon/human/trainee)
	if(QDELETED(src) || QDELETED(user) || QDELETED(trainee) || user == trainee || !user.client || !trainee.client)
		return FALSE
	if(trainee.stat != CONSCIOUS || HAS_TRAIT(trainee, TRAIT_CLICKER_TRAINED) || user.incapacitated())
		return FALSE
	if(loc != user || !isturf(user.loc) || !isturf(trainee.loc))
		return FALSE
	var/hand = user.get_held_index_of_item(src)
	return hand && user.has_hand_for_held_index(hand, TRUE) && !user.check_arm_grabbed(hand) && trainee.Adjacent(user)

/mob/living/carbon/human/proc/offer_clicker_training(obj/item/dogclicker/clicker, mob/living/user)
	if(QDELETED(clicker) || !clicker.can_offer_training(user, src))
		dog_clicker_offer_pending = FALSE
		return
	var/tension_warning = span_notice("Their mind is too tense! This will only work if they relax!")
	if(cmode)
		dog_clicker_offer_pending = FALSE
		to_chat(user, tension_warning)
		return
	var/client/trainer_client = user.client
	var/client/trainee_client = client
	var/answer = tgui_alert(src, "Become clicker-trained?", "Dog Clicker", list("No", "Yes"), timeout = 20 SECONDS, autofocus = FALSE, force_tgui = TRUE)
	if(QDELETED(src))
		return
	dog_clicker_offer_pending = FALSE
	COOLDOWN_START(src, dog_clicker_offer, 5 SECONDS)
	if(QDELETED(user) || user.client != trainer_client || client != trainee_client)
		return
	if(answer == "No")
		to_chat(user, span_notice("[src] resists the clicker's magic..."))
		return
	if(answer != "Yes" || QDELETED(clicker) || !clicker.can_offer_training(user, src))
		return
	if(cmode)
		to_chat(user, tension_warning)
		return
	if(apply_quirk(src, GLOB.quirks[/datum/quirk/clicker_trained]))
		to_chat(src, span_notice("My body submits to the tyranny of the clicker..."))
		to_chat(user, span_notice("[src] is now a trained pet!"))

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
	COOLDOWN_DECLARE(dog_clicker_offer)
	var/dog_clicker_offer_pending = FALSE

/mob/living/carbon/human/proc/can_react_to_dog_clicker()
	return COOLDOWN_FINISHED(src, dog_clicker_reaction) && isturf(loc) && !cmode && !resting && (mobility_flags & MOBILITY_STAND) && !(movement_type & FLYING) && !buckled && !buckling && !pulledby && !incapacitated() && can_hear()

/datum/loadout_item/dogclicker
	name = "Dog Clicker"
	path = /obj/item/dogclicker
	sort_category = "Toys"

/datum/quirk/clicker_trained
	name = "Clicker-Trained"
	desc = "I drop flat when someone snaps a dog clicker nearby."
	point_cost = 0
	custom_text = "Drops you prone when you hear another character's dog clicker in clear line of sight. Works outside combat, at most once every 10 seconds."
	added_traits = list(TRAIT_CLICKER_TRAINED)
