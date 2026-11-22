/obj/effect/proc_holder/spell/self/ink_presence
	name = "Depth Stride"
	desc = "Start leaving paint trails as you move. You and those with paint affinity are sped up and regain a smidge of nutrition for touching trails, everyone else touching the trail is slowed."
	action_icon = 'icons/mob/actions/painter_miracles.dmi'
	overlay_icon = 'icons/mob/actions/painter_miracles.dmi'
	miracle = TRUE
	antimagic_allowed = TRUE
	releasedrain = 25
	overlay_state = "paint"
	sound = 'sound/magic/abyssor_splash.ogg'


	invocations = list(
		"Shogg sp'gai! Swift steps from beyond!",
		"N'gai, n'gha'ghaa, fhtagn!",
		"Y'gathil mor, speed my step!",
		"K'rnul, the painter bleeds!"
	)
	invocation_type = "shout"
	chargetime = 0.1 SECONDS
	recharge_time = 22 SECONDS
	devotion_cost = 25
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/self/ink_presence/cast(list/targets, mob/living/user)
	. = ..()
	if(!user)
		return FALSE

	user.apply_status_effect(/datum/status_effect/buff/ink_presence)
	return TRUE

/obj/effect/proc_holder/spell/invoked/paint_blessing
	name = "Paint Attunement"
	desc = "Conduct a lengthy attunement miracle to bind an ally to your paint trails. Targets cannot move during the ritual. Casting without a direct target allows you to manage or revoke existing blessings."
	action_icon = 'icons/mob/actions/painter_miracles.dmi'
	overlay_icon = 'icons/mob/actions/painter_miracles.dmi'
	miracle = TRUE
	antimagic_allowed = TRUE
	releasedrain = 25
	overlay_state = "paint_bless"
	sound = 'sound/magic/abyssor_splash.ogg'


	invocations = list(
		"Tha'lass-vax, maro det'us!",
		"Vrek'hen-dyll, khoro!",
		"zul-morn, dra'yne the light!"
	)
	invocation_type = "shout"
	chargetime = 1.5 SECONDS
	recharge_time = 1 SECONDS
	devotion_cost = 30
	associated_skill = /datum/skill/magic/holy

	// Soft references (weakrefs) mapping [Target Ref String] -> [Weakref to Target]
	var/list/beneficiaries = list()

/obj/effect/proc_holder/spell/invoked/paint_blessing/cast(list/targets, mob/living/user)
	. = ..()
	if(!user)
		return FALSE

	for(var/ref_str in beneficiaries)
		var/datum/weakref/W = beneficiaries[ref_str]
		var/mob/living/L = W?.resolve()
		if(!L || QDELETED(L) || L.stat == DEAD)
			beneficiaries -= ref_str

	var/mob/living/target = targets[1]
	if(!istype(target) || target == user)
		if(!length(beneficiaries))
			to_chat(user, span_warning("You are not currently sustaining any paint affinity blessings."))
			return FALSE

		var/list/revoke_options = list()
		for(var/ref_str in beneficiaries)
			var/datum/weakref/W = beneficiaries[ref_str]
			var/mob/living/L = W.resolve()
			if(L && !(L.patron?.type == /datum/patron/divine/abyssor))
				revoke_options[L.name] = ref_str
			else if(L)
				revoke_options[L.real_name] = ref_str

		var/chosen_name = tgui_input_list(user, "Select a blessing to revoke:", "Manage Paint Blessings", revoke_options)
		if(!chosen_name || !user || QDELETED(src))
			return FALSE

		var/target_ref_str = revoke_options[chosen_name]
		var/datum/weakref/target_W = beneficiaries[target_ref_str]
		var/mob/living/revoked_mob = target_W?.resolve()

		beneficiaries -= target_ref_str
		if(revoked_mob)
			REMOVE_TRAIT(revoked_mob, TRAIT_INK_AFFINITY, TRAIT_MIRACLE)
			to_chat(revoked_mob, span_userdanger("Your paint affinity has been dissolved by your patron!"))
		user.visible_message(span_warning("[user] severs the canvas binding [chosen_name]!"))
		return TRUE

	if(target.stat == DEAD)
		to_chat(user, span_warning("The dead cannot hold the pigment of Abyssor."))
		return FALSE
	if(HAS_TRAIT(target, TRAIT_INK_AFFINITY))
		to_chat(user, span_warning("[target] is already attuned to holy paints."))
		return FALSE

	var/max_beneficiaries = 1
	var/holy_skill = user.get_skill_level(/datum/skill/magic/holy)

	switch(holy_skill)
		if(3)
			max_beneficiaries = 2
		if(4, 5)
			max_beneficiaries = 3
		if(6)
			max_beneficiaries = 4
		else
			max_beneficiaries = 1

	if(length(beneficiaries) >= max_beneficiaries)
		to_chat(user, span_warning("Your current holy skill only allows you to sustain [max_beneficiaries] blessing\s at a time. Revoke an old one first."))
		return FALSE

	user.visible_message(span_notice("[user] begins painting beneath [target]'s feet!"))

	if(!do_after(user, 1 SECONDS, target = target))
		to_chat(user, span_warning("The attunement ritual was broken by movement!"))
		return FALSE

	if(QDELETED(target) || target.stat == DEAD || HAS_TRAIT(target, TRAIT_INK_AFFINITY))
		return FALSE

	var/display_name = target.name
	beneficiaries[REF(target)] = WEAKREF(target)
	ADD_TRAIT(target, TRAIT_INK_AFFINITY, TRAIT_MIRACLE)

	user.visible_message(span_nicegreen("[user] successfully completes the ritual! [display_name] is now attuned to holy paints."))
	to_chat(target, span_purple("<b>Your lux has been coated in sacred pigments. You can now walk safely through abyssal paints!</b>"))
	return TRUE

/obj/effect/proc_holder/spell/invoked/paint_blessing/Destroy()
	for(var/ref_str in beneficiaries)
		var/datum/weakref/W = beneficiaries[ref_str]
		var/mob/living/L = W?.resolve()
		if(L)
			REMOVE_TRAIT(L, TRAIT_INK_AFFINITY, TRAIT_MIRACLE)
	beneficiaries.Cut()
	return ..()

/obj/effect/proc_holder/spell/self/umbral_viscosity
	name = "Umbral Coating"
	desc = "Infuse your active weapon with a heavy, abyssal paint. Strikes against mindless beasts deal devastating damage. Conscious targets take minimal damage but bleed paint trails. If cast with an empty hand, shapes the paint into a short-lived bow preloaded with a single paint arrow."
	action_icon = 'icons/mob/actions/painter_miracles.dmi'
	overlay_icon = 'icons/mob/actions/painter_miracles.dmi'
	miracle = TRUE
	antimagic_allowed = TRUE
	releasedrain = 25
	overlay_state = "paint_blade"
	sound = 'sound/magic/abyssor_splash.ogg'


	invocations = list(
		"Tha'lass-vax, blacken the iron!",
		"Cri'morah, let the edges weep!",
		"kra'khen, coat this steel!"
	)
	invocation_type = "shout"
	chargetime = 0.5 SECONDS
	recharge_time = 35 SECONDS
	devotion_cost = 25
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/self/umbral_viscosity/cast(list/targets, mob/living/user)
	. = ..()
	if(!user)
		return FALSE

	var/obj/item/weapon = user.get_active_held_item()
	if(!weapon)
		var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/paint/P = new(user)
		if(user.put_in_active_hand(P))
			user.visible_message(span_purple("Shimmering, abyssal paint coalesces in [user]'s empty hand, forming a volatile bow!"))
			return TRUE
		qdel(P)
		return FALSE

	if(!isitem(weapon))
		to_chat(user, span_warning("I must hold a valid weapon to coat it!"))
		return FALSE

	if(weapon.AddComponent(/datum/component/umbral_enchant, user))
		weapon.visible_message(span_purple("[weapon]'s aura turns purple, oozing thick droplets of paint."))
		return TRUE

	return FALSE

/obj/effect/proc_holder/spell/self/umbral_viscosity/single_use
	miracle = FALSE
	devotion_cost = 0
	name = "Invoke Umbral Coating"
	desc = "Call upon your gifted umbral energy to coat your active weapon, or form a volatile bow if your hand is empty. This is a one-time use manifestation."
	recharge_time = 1 HOURS

/obj/effect/proc_holder/spell/self/umbral_viscosity/single_use/cast(list/targets, mob/living/user)
	. = ..()
	if(.)
		addtimer(CALLBACK(src, PROC_REF(self_consume), user), 1)

/obj/effect/proc_holder/spell/self/umbral_viscosity/single_use/proc/self_consume(mob/living/L)
	if(L?.mind)
		L.mind.RemoveSpell(src)

/obj/effect/proc_holder/spell/self/transmute_ink
	name = "Purifying Wave"
	desc = "Purify nearby abyssal paint trails within your immediate surroundings, turning them into healing trails for the attuned. The more paint affected (up to 10), the longer the cooldown. If you pull targets, those attuned will get healed in your stead. If you use a paint brush staff, you can heal via pulling regardless."
	action_icon = 'icons/mob/actions/painter_miracles.dmi'
	overlay_icon = 'icons/mob/actions/painter_miracles.dmi'
	miracle = TRUE
	antimagic_allowed = TRUE
	releasedrain = 25
	overlay_state = "paint_heal"
	sound = 'sound/magic/abyssor_splash.ogg'


	invocations = list(
		"Prash'ik, nar'n. Heal the faithful!",
		"Ya'shna vin'thu rasa. Fruits of the sea!",
		"Hu'maw, A'ferta'nu. Rejuvinate!"
	)
	invocation_type = "shout"
	// Hefty cooldown given we can heal a lot of people.
	// Up to double the cooldown with no int modifiers if a lot of puddles are made into healing stuff.
	recharge_time = 28 SECONDS
	chargetime = 0.5 SECONDS
	associated_skill = /datum/skill/magic/holy
	var/transmute_range = 4

/obj/effect/proc_holder/spell/self/transmute_ink/cast(list/targets, mob/living/user)
	. = ..()
	if(!user)
		return FALSE

	var/turf/center = get_turf(user)
	if(!center)
		return FALSE

	var/affected_count = 0
	for(var/obj/effect/ink_trail/trail in range(transmute_range, center))
		trail.apply_custom_effect(
			new_buff = /datum/status_effect/buff/umbral_recovery,
			new_debuff = null,
			new_icon_state = "paint_gray",
			new_color = "#b6e6b6",
			consume = TRUE,
			deny = TRUE,
			new_duration = 15 SECONDS,
			to_pulled = TRUE
		)
		affected_count++

	if(affected_count > 0)
		to_chat(user, span_nicegreen("I have successfully converted [affected_count] puddles into healing paint!"))
		charge_counter -= recharge_time * min(affected_count, 10) * 0.08
		return TRUE
	else
		to_chat(user, span_warning("There were no abyssal paint puddles nearby to transmute."))
		return FALSE

/obj/effect/proc_holder/spell/invoked/recharge_pylon
	name = "Umbral Replenishment"
	desc = "Channel your devotion into a depleted pylon, restoring its current infusion reservoirs up to half capacity. Can only be performed once per unique infusion cycle."
	action_icon = 'icons/mob/actions/painter_miracles.dmi'
	overlay_icon = 'icons/mob/actions/painter_miracles.dmi'
	miracle = TRUE
	antimagic_allowed = TRUE
	releasedrain = 25
	overlay_state = "paint_infusion"
	sound = 'sound/magic/abyssor_splash.ogg'


	invocations = list(
		"O'khor, remember the well!",
		"Thal'ass, feed the paints!",
		"Dra'yne back the void, fill the core!"
	)
	invocation_type = "shout"
	chargetime = 1.5 SECONDS
	recharge_time = 45 SECONDS
	devotion_cost = 100
	associated_skill = /datum/skill/magic/holy

/obj/effect/proc_holder/spell/invoked/recharge_pylon/cast(list/targets, mob/living/user)
	. = ..()
	if(!user)
		return FALSE

	var/obj/structure/dream_pylon/target = targets[1]
	if(!istype(target))
		to_chat(user, span_warning("This miracle must target a painted pylon!"))
		return FALSE

	if(!target.can_recharge)
		to_chat(user, span_warning("[target]'s structure is saturated. It cannot accept any further replenishment until its core changes!"))
		return FALSE

	if(target.charge >= target.max_charge)
		to_chat(user, span_warning("[target] is already completely overflowing with paint energy!"))
		return FALSE

	var/replenish_amount = target.max_charge * 0.5
	replenish_amount = max(25, round(replenish_amount, 25))

	target.charge = min(target.max_charge, target.charge + replenish_amount)
	target.can_recharge = FALSE

	user.visible_message(span_purple("[user] raises their hands, coaxing streams of ink from the dream back into [target]'s core!"))
	target.update_pylon_appearance()
	return TRUE
