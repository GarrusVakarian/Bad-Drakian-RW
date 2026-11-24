/// Shared setup and read-only instructions for corpse revival rites.
/obj/effect/proc_holder/spell/invoked/revival_rite
	base_action = /datum/action/spell_action/spell/revival_rite
	var/required_structure = /obj/structure/fluff/psycross
	var/ritual_site_name = "a placed cross"
	var/structure_range = 2
	var/ritual_site_near_caster = FALSE
	var/list/required_items
	var/list/alt_required_items
	var/item_radius = 1
	var/ritual_offering_note

/datum/action/spell_action/spell/revival_rite/Trigger()
	var/obj/effect/proc_holder/spell/invoked/revival_rite/rite = target
	if(owner && istype(rite) && !QDELETED(rite) && !IsAvailable())
		rite.show_rite_instructions(owner)
		return TRUE
	return ..()

/obj/effect/proc_holder/spell/invoked/revival_rite/InterceptClickOn(mob/living/caller, params, atom/target)
	if(target == caller && caller.ranged_ability == src && ranged_ability_user == caller)
		var/list/modifiers = params2list(params)
		if(modifiers["middle"])
			show_rite_instructions(caller)
			return TRUE
	return ..()

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/get_current_required_items()
	if(length(alt_required_items) && SSchimeric_tech.has_revival_cost_reduction())
		return alt_required_items
	return required_items

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/format_rite_offerings(list/recipe)
	var/list/lines = list()
	for(var/item_type in recipe)
		var/count = recipe[item_type]
		if(count > 0)
			var/obj/item/offering = item_type
			lines += "[count] × [initial(offering.name)]"
	return lines.Join(", ")

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/show_rite_instructions(mob/user)
	to_chat(user, span_notice(get_rite_instructions()))

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/get_rite_instructions()
	var/list/lines = list("<b>[name] — Rite instructions</b>")
	lines += length(req_items) ? "Carry a psycross and stand beside the corpse." : "Stand beside the corpse. No carried psycross is required."
	if(ritual_site_near_caster)
		lines += "Stand within [structure_range] tiles of [ritual_site_name], in line of sight."
	else
		lines += "Bring the corpse within [structure_range] tiles of [ritual_site_name], in line of sight."
	var/list/recipe = get_current_required_items()
	if(length(recipe))
		lines += "<b>Offerings:</b> [format_rite_offerings(recipe)]."
		if(ritual_offering_note)
			lines += ritual_offering_note
		lines += "Place the offerings on the floor on or next to the corpse. The rite consumes them on a successful revival."
		if(recipe == alt_required_items)
			lines += "<i>Enhance divine resurrection is active.</i>"
	else
		lines += "No offerings are required."
	return lines.Join("<br>")

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/find_ritual_site(atom/center)
	var/turf/origin = get_turf(center)
	if(!origin)
		return FALSE
	// Center the visibility check on the corpse's tile, not its facing or vision.
	for(var/atom/site in view(structure_range, origin))
		if(istype(site, required_structure) && !QDELETED(site) && (isturf(site) || isturf(site.loc)))
			return TRUE
	return FALSE

/obj/effect/proc_holder/spell/invoked/revival_rite/proc/matches_required_item(obj/item/offering, item_type)
	return offering.type == item_type

/// Select exact offerings from visible floor tiles. The caller consumes them only after revival.
/obj/effect/proc_holder/spell/invoked/revival_rite/proc/check_rite_setup(mob/living/patient, mob/living/caster, list/offerings)
	var/turf/origin = get_turf(patient)
	if(!origin || !find_ritual_site(patient))
		to_chat(caster, span_warning("I need [ritual_site_name] within [structure_range] tiles of [patient], in line of sight."))
		return FALSE
	var/list/recipe = get_current_required_items()
	if(!length(recipe))
		return TRUE
	var/list/missing = recipe.Copy()
	var/remaining = 0
	for(var/item_type in missing)
		remaining += missing[item_type]
	for(var/obj/item/offering in view(item_radius, origin))
		if(QDELETED(offering) || !isturf(offering.loc))
			continue
		for(var/item_type in missing)
			if(missing[item_type] <= 0 || !matches_required_item(offering, item_type))
				continue
			offerings += offering
			missing[item_type]--
			remaining--
			if(!remaining)
				return TRUE
			break
	to_chat(caster, span_warning("Missing offerings: [format_rite_offerings(missing)]. Place them on the floor on or next to [patient], in line of sight."))
	return FALSE

/obj/effect/proc_holder/spell/invoked/resurrect
	parent_type = /obj/effect/proc_holder/spell/invoked/revival_rite
	name = "Anastasis"
	overlay_state = "revive"
	releasedrain = 90
	chargedrain = 0
	chargetime = 50
	range = 1
	warnie = "sydwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokeholy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	sound = 'sound/magic/revive.ogg'
	associated_skill = /datum/skill/magic/holy
	antimagic_allowed = TRUE
	recharge_time = 10 MINUTES
	miracle = TRUE
	devotion_cost = 250
	var/revive_pq = PQ_GAIN_REVIVE
	required_items = list(/obj/item/clothing/neck/roguetown/psicross = 1)
	alt_required_items = list(/obj/item/clothing/neck/roguetown/psicross = 1)
	var/debuff_type = /datum/status_effect/debuff/revived
	var/harms_undead = TRUE
	priest_excluded = TRUE
	var/pestrian_freaks = FALSE

/obj/effect/proc_holder/spell/invoked/resurrect/start_recharge()
	var/old_recharge = recharge_time
	recharge_time = initial(recharge_time) * SSchimeric_tech.get_resurrection_multiplier()
	// If the spell was fully charged, keep it fully charged after adjusting recharge_time
	if(charge_counter >= old_recharge && old_recharge > 0)
		charge_counter = recharge_time
	. = ..()

/obj/effect/proc_holder/spell/invoked/resurrect/cast(list/targets, mob/living/user)
	. = ..()
	if(isliving(targets[1]))
		var/list/offerings = list()
		if(check_rite_setup(targets[1], user, offerings) && perform_revival(targets, user, offerings))
			return TRUE
	revert_cast(user)
	return FALSE

/// Apply the miracle after the caller has resolved its casting costs and ritual setup.
/obj/effect/proc_holder/spell/invoked/resurrect/proc/perform_revival(list/targets, mob/living/user, list/offerings)
	var/mob/living/target = targets[1]
	var/obj/shapeshift_holder/ooze_death/ooze = target.get_ooze_revival_holder()
	if(!ooze)
		var/mob/living/carbon/spirit/underworld_spirit = target.get_spirit()
		if(underworld_spirit?.client)
			var/mob/dead/observer/ghost = underworld_spirit.ghostize()
			if(ghost?.mind)
				qdel(underworld_spirit)
				ghost.mind.transfer_to(target, TRUE)
		target.grab_ghost(force = TRUE)
	var/precheck_error = get_revival_precheck_error(target, user)
	if(precheck_error)
		to_chat(user, span_warning(precheck_error))
		return FALSE
	if(!ooze && !target.check_revive(user, bypass_foreign_brain_check = pestrian_freaks))
		return FALSE
	if(!ooze && (target.mob_biotypes & MOB_UNDEAD) && harms_undead) //positive energy harms the undead
		target.visible_message(
			span_danger("[target] is unmade by divine magic!"),
			span_userdanger("I'm unmade by divine magic!")
		)
		target.gib()
		return TRUE
	if(ooze)
		target = ooze.revive_patient(targets)
		if(!target)
			return FALSE
	else
		target.adjustOxyLoss(-target.getOxyLoss()) //Ye Olde CPR
		if(!target.revive(full_heal = FALSE, bypass_foreign_brain_check = pestrian_freaks)) // Pestrians get to revive people with foreign brains, flesh abominations are their thing
			to_chat(user, span_warning(get_revival_failure_message(target)))
			return FALSE
	target.emote("breathgasp")
	target.Jitter(100)
	target.update_body()
	target.visible_message(span_notice("[target] is revived by divine magic!"), span_green("I awake from the void."))
	if(revive_pq && !HAS_TRAIT(target, TRAIT_IWASREVIVED) && user?.ckey)
		adjust_playerquality(revive_pq, user.ckey)
		ADD_TRAIT(target, TRAIT_IWASREVIVED, "[type]")
	target.mind?.remove_antag_datum(/datum/antagonist/zombie)
	target.remove_status_effect(/datum/status_effect/debuff/rotted_zombie)	//Removes the rotted-zombie debuff if they have it - Failsafe for it.
	QDEL_LIST(offerings)
	apply_revival_aftereffect(target)
	// Due to the increased cost and cooldown, these revival types heal quite a bit.
	target.apply_status_effect(/datum/status_effect/buff/healing, 14)
	return TRUE

/obj/effect/proc_holder/spell/invoked/resurrect/cast_check(skipcharge,mob/user = usr)
	if(!..())
		to_chat(user, span_warning("The miracle fizzles."))
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/invoked/resurrect/proc/get_revival_precheck_error(mob/living/target, mob/living/user)
	return null

/obj/effect/proc_holder/spell/invoked/resurrect/proc/get_revival_failure_message(mob/living/target)
	return "The body could not sustain revival. Check its injuries and vital organs."

/obj/effect/proc_holder/spell/invoked/resurrect/proc/apply_revival_aftereffect(mob/living/target)
	if(debuff_type)
		target.apply_status_effect(debuff_type)

/obj/effect/proc_holder/spell/invoked/resurrect/abyssor
	name = "Abyssal Revival"
	desc = "Abyssor gives back what the deep has taken. Raise the dead beside ocean water with an offering from the catch. A dreamfiend will sap the one you revive until they summon and confront it.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	ritual_site_name = "ocean water"
	overlay_icon = 'icons/mob/actions/abyssormiracles.dmi'
	action_icon = 'icons/mob/actions/abyssormiracles.dmi'
	overlay_state = "resurrect"
	sound = 'sound/magic/whale.ogg'
	//A medley of common ocean fish, totalling 10
	required_items = list(
		/obj/item/reagent_containers/food/snacks/fish/sole = 3,
		/obj/item/reagent_containers/food/snacks/fish/cod = 3,
		/obj/item/reagent_containers/food/snacks/fish/bass = 2,
		/obj/item/reagent_containers/food/snacks/fish/plaice = 1,
		/obj/item/reagent_containers/food/snacks/fish/lobster = 1,
	)
	alt_required_items = list(
		/obj/item/reagent_containers/food/snacks/fish/plaice = 2,
		/obj/item/reagent_containers/food/snacks/fish/angler = 1
	)
	debuff_type = /datum/status_effect/debuff/dreamfiend_curse
	//This will be Abyssor's statue soon.
	required_structure = /turf/open/water/ocean

/datum/status_effect/debuff/dreamfiend_curse
	id = "dreamfiend_curse"
	alert_type = /atom/movable/screen/alert/status_effect/dreamfiend_curse
	/// Type of dreamfiend to summon
	var/dreamfiend_type
	var/obj/effect/proc_holder/spell/invoked/summon_dreamfiend_curse/curse_spell

/datum/status_effect/debuff/dreamfiend_curse/on_creation(mob/living/new_owner)
	// Choose dreamfiend type from weighted list
	var/list/dreamfiend_types = list(
		/mob/living/simple_animal/hostile/rogue/dreamfiend = 50,
		/mob/living/simple_animal/hostile/rogue/dreamfiend/major = 49,
		/mob/living/simple_animal/hostile/rogue/dreamfiend/ancient = 1
	)
	dreamfiend_type = pickweight(dreamfiend_types)

	effectedstats = list(
		STATKEY_STR = 1,
		STATKEY_INT = -5,
		STATKEY_SPD = -2,
		STATKEY_PER = -5
	)

	// Add summoning spell to the victim
	if(!new_owner.mind?.has_spell(/obj/effect/proc_holder/spell/invoked/abyssal_strength))
		curse_spell = new(new_owner)
		new_owner.mind?.AddSpell(curse_spell)
		curse_spell.dreamfiend_type = dreamfiend_type
		curse_spell.timed_cooldown = world.time + 5 MINUTES

	. = ..()

	switch(dreamfiend_type)
		if(/mob/living/simple_animal/hostile/rogue/dreamfiend/ancient)
			linked_alert.icon_state = "dreamfiend_ancient"
			linked_alert.name = "Grand Abyssal Curse"
			linked_alert.desc = "A terrifying presence if felt fraying the edges of my mind. This is a threat I cannot face alone."
		if(/mob/living/simple_animal/hostile/rogue/dreamfiend/major)
			linked_alert.icon_state = "dreamfiend_major"
			linked_alert.name = "Major Abyssal Curse"
			linked_alert.desc = "A great daemon is sapping my mind, a dangerous foe which I must summon to regain my faculties."
		if(/mob/living/simple_animal/hostile/rogue/dreamfiend)
			linked_alert.icon_state = "dreamfiend"

/atom/movable/screen/alert/status_effect/dreamfiend_curse
	name = "Abyssal Curse"
	desc = "A nightmare entity has revived you, but now it is draining your vitality. Summon it to confront it."

/obj/effect/proc_holder/spell/invoked/summon_dreamfiend_curse
	name = "Confront Terror"
	desc = "Summon the dreamfiend haunting you to confront it directly"
	overlay_state = "terrors"
	chargetime = 0
	invocations = list(span_danger("begins to smell of saltwater. You can hear waves crashing nearby..."))
	invocation_type = "emote"
	sound = 'modular_azurepeak/sound/mobs/abyssal/abyssal_teleport.ogg'
	/// Type of dreamfiend to summon
	var/dreamfiend_type
	recharge_time = 600 SECONDS
	var/timed_cooldown

/obj/effect/proc_holder/spell/invoked/summon_dreamfiend_curse/cast(list/targets, mob/living/user)
	if (world.time < timed_cooldown)
		to_chat(user, span_warning("You must gather your strength before you are ready to confront your terror!"))
		to_chat(user, span_warning("Time remaining: [max(0, timed_cooldown - world.time)/10] seconds."))
		revert_cast()
		return FALSE
	// Summon the dreamfiend
	if(summon_dreamfiend(
		target = user,
		user = user,
		F = dreamfiend_type,
		outer_tele_radius = 6,
		inner_tele_radius = 5
	))
		// Remove the curse after summoning
		user.remove_status_effect(/datum/status_effect/debuff/dreamfiend_curse)
		user.mind.RemoveSpell(src)
		return TRUE

	to_chat(user, span_warning("No valid space to manifest the nightmare!"))
	return FALSE

/obj/effect/proc_holder/spell/invoked/resurrect/pestra
	name = "Putrid Revival"
	desc = "Pestra knits life back into dead flesh with an offering of heartblood. She can even bind a soul to a body with a transplanted brain.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	overlay_icon = 'icons/mob/actions/pestramiracles.dmi'
	action_icon = 'icons/mob/actions/pestramiracles.dmi'
	overlay_state = "resurrect"
	sound = 'sound/magic/slimesquish.ogg'
	required_items = list(
		/obj/item/heart_blood_canister/filled = 1,
		/obj/item/heart_blood_vial/filled = 2
	)
	alt_required_items = list(
		/obj/item/heart_blood_vial/filled = 2
	)
	pestrian_freaks = TRUE
	harms_undead = FALSE   // cough, cough, there is a reason pestrians are looked at with suspicion

/obj/effect/proc_holder/spell/invoked/resurrect/eora
	//Does heartfelt even exist?
	name = "Heartfelt Revival"
	desc = "Eora warms a stilled heart with an offering of bread. The one you bring back is frailer for a time, and their renewed body burns through food faster. Those who never hunger lose blood instead.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	overlay_icon = 'icons/mob/actions/eoramiracles.dmi'
	action_icon = 'icons/mob/actions/eoramiracles.dmi'
	overlay_state = "resurrect"
	required_items = list(
		/obj/item/reagent_containers/food/snacks/rogue/breadslice/toast = 5
	)
	alt_required_items = list(
		/obj/item/reagent_containers/food/snacks/rogue/bread = 1
	)
	debuff_type = /datum/status_effect/debuff/metabolic_acceleration
	sound = 'sound/magic/heartbeat.ogg'
	overlay_state = "eora_revive"

/atom/movable/screen/alert/status_effect/nutrition_drain
	name = "Metabolic Acceleration"
	desc = "Your body is burning energy at an accelerated rate!"
	icon_state = "nutrition_drain"

/datum/status_effect/debuff/metabolic_acceleration
	id = "metabolic_accel"
	alert_type = /atom/movable/screen/alert/status_effect/nutrition_drain
	tick_interval = 1 MINUTES
	duration = 15 MINUTES

/datum/status_effect/debuff/metabolic_acceleration/tick()
	if(!owner || owner.stat == DEAD)
		qdel(src)
		return

	if(HAS_TRAIT(owner, TRAIT_NOHUNGER))
		// For those without hunger, drain blood instead. CONSEQUENCES FOR MY TRAIT CHOICES?!
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			H.set_blood_volume(max(H.get_blood_volume() - 100, BLOOD_VOLUME_SURVIVE))
	else
		// For normal humans, drain nutrition
		owner.adjust_nutrition(-100)

/datum/status_effect/debuff/metabolic_acceleration/on_creation(mob/living/new_owner)
	effectedstats = list(
		STATKEY_CON = -5
	)

	return ..()

/obj/effect/proc_holder/spell/invoked/resurrect/xylix
	name = "Anastasis?"
	desc = "Xylix gives the dead another throw of the dice. The one you raise returns with one unpredictable aftereffect borrowed from another revival rite.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	debuff_type = null
	ritual_offering_note = "Set out a separate psycross as the offering and keep your casting focus on you."
	alt_required_items = list(/obj/item/clothing/neck/roguetown/psicross/wood = 1)

/obj/effect/proc_holder/spell/invoked/resurrect/xylix/apply_revival_aftereffect(mob/living/target)
	var/static/list/possible_debuffs = list(
		/datum/status_effect/debuff/revived,
		/datum/status_effect/debuff/dreamfiend_curse,
		/datum/status_effect/debuff/metabolic_acceleration,
		/datum/status_effect/debuff/malum_revival,
		/datum/status_effect/debuff/ravox_revival,
		/datum/status_effect/debuff/dendor_revival,
		/datum/status_effect/debuff/noc_revival,
	)
	target.apply_status_effect(pick(possible_debuffs))

//Dendor, Malum, Ravox, Noc
//Fairly generic for now, I might give these more unique effects later!
/datum/status_effect/debuff/malum_revival
	id = "malum_revival"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/malum_revival

/datum/status_effect/debuff/malum_revival/on_creation(mob/living/new_owner)
	effectedstats = list(
		STATKEY_WIL = -5,
		STATKEY_STR = -2
	)
	return ..()

/atom/movable/screen/alert/status_effect/malum_revival
	name = "Malum's Burden"
	desc = "Your body feels heavy and slow to recover."
	icon_state = "malum_burden"

/datum/status_effect/debuff/ravox_revival
	id = "ravox_revival"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/ravox_revival

/datum/status_effect/debuff/ravox_revival/on_creation(mob/living/new_owner)
	effectedstats = list(
		STATKEY_STR = -5,
		STATKEY_SPD = -2
	)
	return ..()

/atom/movable/screen/alert/status_effect/ravox_revival
	name = "Ravox's Weakness"
	desc = "Your muscles feel feeble and movements sluggish."
	icon_state = "ravox_weakness"

/datum/status_effect/debuff/dendor_revival
	id = "dendor_revival"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/dendor_revival

/datum/status_effect/debuff/dendor_revival/on_creation(mob/living/new_owner)
	effectedstats = list(
		STATKEY_SPD = -5,
		STATKEY_CON = -2
	)
	return ..()

/atom/movable/screen/alert/status_effect/dendor_revival
	name = "Dendor's Sluggishness"
	desc = "Your movements are weighted by invisible roots and your body feels fragile."
	icon_state = "dendor_sluggish"

/datum/status_effect/debuff/noc_revival
	id = "noc_revival"
	duration = 15 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/noc_revival
	tick_interval = 10 SECONDS
	var/static/list/valid_body_zones = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG
	)

/datum/status_effect/debuff/noc_revival/on_creation(mob/living/new_owner)
	effectedstats = list(STATKEY_INT = -5)
	return ..()

/datum/status_effect/debuff/noc_revival/tick()
	// Check if outside at night
	if(istype(get_area(owner), /area/rogue/outdoors) && (GLOB.tod == "night"))
		if(prob(15))
			to_chat(owner, span_danger("Moonlight sears your flesh!"))
			owner.adjustFireLoss(15)
			if(iscarbon(owner))
				var/mob/living/carbon/C = owner
				var/list/valid_parts = list()

				for(var/obj/item/bodypart/BP in C.bodyparts)
					var/BP_name = BP.name
					if(!BP_name) BP_name = "Unnamed Bodypart" // Fallback

					var/bool_can_bloody_wound = BP.can_bloody_wound()
					var/bool_in_zone = (BP.body_zone in valid_body_zones)
					var/bool_combined_condition = (bool_in_zone && bool_can_bloody_wound)

					if(bool_combined_condition) //Idk but it works like this.
						valid_parts += BP

				if(length(valid_parts))
					var/obj/item/bodypart/BP = pick(valid_parts)
					BP.add_wound(/datum/wound/nocburn, FALSE, "looks burnt.")

/datum/wound/nocburn
	name = "light burn"
	whp = 15
	sewn_whp = 5
	bleed_rate = 0
	clotting_rate = 0.02
	sewn_clotting_rate = 0.02
	clotting_threshold = 0.1
	sewn_clotting_threshold = 0.05
	sew_threshold = 25
	mob_overlay = "cut"
	can_sew = TRUE
	//It's.. a burn..
	can_cauterize = FALSE

/atom/movable/screen/alert/status_effect/noc_revival
	name = "Noc's Moonlit Curse"
	desc = "Your mind feels clouded and moonlight burns your skin."
	icon_state = "noc_curse"

/obj/effect/proc_holder/spell/invoked/resurrect/malum
	name = "Diligent Revival"
	desc = "Malum puts the dead back to work. Offer metal to kindle life anew. The one who rises will have less strength and willpower for a time.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	overlay_icon = 'icons/mob/actions/malummiracles.dmi'
	action_icon = 'icons/mob/actions/malummiracles.dmi'
	overlay_state = "resurrect"
	required_items = list(
		/obj/item/ingot/iron = 3
	)
	alt_required_items = list(
		/obj/item/ingot/copper = 1
	)
	debuff_type = /datum/status_effect/debuff/malum_revival
	sound = 'sound/magic/clang.ogg'

/obj/effect/proc_holder/spell/invoked/resurrect/ravox
	name = "Just Revival"
	desc = "Ravox grants the fallen another chance to see justice done. Raise them with an offering of bones. They return weaker and slower for a time.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	overlay_icon = 'icons/mob/actions/ravoxmiracles.dmi'
	action_icon = 'icons/mob/actions/ravoxmiracles.dmi'
	overlay_state = "resurrect"
	// The items here are somewhat hard to pick as it still has to be something a ravox acolyte would reasonably obtain.
	// Bones insinuate that mayhaps, they went out there to delete some skeletons for justice?
	required_items = list(
		/obj/item/natural/bone = 10
	)
	alt_required_items = list(
		/obj/item/natural/bone = 7
	)
	debuff_type = /datum/status_effect/debuff/ravox_revival

/obj/effect/proc_holder/spell/invoked/resurrect/dendor
	name = "Wild Revival"
	desc = "At a wise or sanctified tree, offer herbs and call the dead back to the living world. Those who rise are slower and frailer for a time. Beasts rise whole.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	ritual_site_name = "a wise tree or sanctified tree"
	//Herbs that have to do with intelligence mostly. Easier to remember.
	required_items = list(
		/obj/item/reagent_containers/food/snacks/grown/manabloom = 3,
		/obj/item/alch/mentha = 3,
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed = 3
	)
	alt_required_items = list(
		/obj/item/reagent_containers/food/snacks/grown/manabloom = 3,
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweed = 1
	)
	debuff_type = /datum/status_effect/debuff/dendor_revival
	required_structure = /obj/structure/flora/roguetree/wise
	sound = 'sound/magic/birdsong.ogg'

// Wild Revival can also revive simple animal mobs (no debuff applied, full heal).
/obj/effect/proc_holder/spell/invoked/resurrect/dendor/cast(list/targets, mob/living/user)
	var/mob/living/patient = targets[1]
	if(!isanimal(patient) || patient.get_ooze_revival_holder())
		return ..()
	var/mob/living/simple_animal/target = patient
	if(target.stat != DEAD)
		to_chat(user, span_warning("[target] is not dead."))
		revert_cast(user)
		return FALSE
	var/list/offerings = list()
	if(!check_rite_setup(target, user, offerings))
		revert_cast(user)
		return FALSE
	if(!target.revive(full_heal = TRUE))
		to_chat(user, span_warning("Nothing happens."))
		revert_cast(user)
		return FALSE
	target.visible_message(span_notice("[target] is roused by the wild magic!"))
	QDEL_LIST(offerings)
	return TRUE

/obj/effect/proc_holder/spell/invoked/resurrect/noc
	name = "Moonlit Revival"
	desc = "Noc reads a life back into the world from an offering of scrolls. The one you raise returns with a clouded mind, and for a time even moonlight burns them.<br><b>Cast on yourself to see the required offerings and where to perform the rite.</b>"
	overlay_icon = 'icons/mob/actions/nocmiracles.dmi'
	action_icon = 'icons/mob/actions/nocmiracles.dmi'
	overlay_state = "resurrect"
	required_items = list(
		/obj/item/paper/scroll = 6
	)
	alt_required_items = list(
		/obj/item/paper = 10
	)
	debuff_type = /datum/status_effect/debuff/noc_revival
	sound = 'sound/magic/owlhoot.ogg'
