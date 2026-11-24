/datum/antagonist/dreamwalker
	name = "Dreamwalker"
	roundend_category = "Dreamwalker"
	antagpanel_category = "Dreamwalker"
	job_rank = ROLE_DREAMWALKER
	confess_lines = list(
		"MY VISION ABOVE ALL!",
		"I'LL TAKE YOU TO MY REALM!",
		"HIS FORM IS MAGNICIFENT!",
	)
	rogue_enabled = TRUE

	var/traits_dreamwalker = list(
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_NOPAIN,
		TRAIT_TOXIMMUNE,
		TRAIT_STEELHEARTED,
		TRAIT_NOSLEEP,
		TRAIT_NOMOOD,
		TRAIT_NOLIMBDISABLE,
		TRAIT_SHOCKIMMUNE,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_HEAVYARMOR,
		TRAIT_COUNTERCOUNTERSPELL,
		TRAIT_RITUALIST,
		TRAIT_STRENGTH_UNCAPPED,
		TRAIT_DREAMWALKER,
		TRAIT_CURSE_RESIST,
		TRAIT_HERESIARCH
		)

	var/STASTR = 15
	var/STASPD = 12
	var/STAINT = 12
	var/STAWIL = 12
	var/STACON = 12
	var/STAPER = 12
	var/STALUC = 10

	var/mob/living/carbon/human/dream_body
	var/list/original_spells = list()
	var/list/dream_spells = list()
	var/list/removed_arcyne_traits = list()
	var/list/dreamcraft_experience = list()
	var/list/forged_weapons = list()
	var/datum/devotion/original_devotion
	var/devotion_was_processing = FALSE
	var/original_ambushable
	var/had_dream_faction = FALSE
	var/forged_empowered_weapon = FALSE
	var/has_awakened = FALSE
	var/static/list/arcyne_traits = list(TRAIT_ARCYNE_T1, TRAIT_ARCYNE_T2, TRAIT_ARCYNE_T3, TRAIT_ARCYNE_T4)
	var/static/list/dream_stat_keys = list(STATKEY_STR, STATKEY_PER, STATKEY_INT, STATKEY_CON, STATKEY_WIL, STATKEY_SPD, STATKEY_LCK)

/datum/antagonist/dreamwalker/can_be_owned(datum/mind/new_owner)
	var/datum/mind/candidate = new_owner || owner
	return !QDELETED(candidate?.current) && !isseelie(candidate.current) && ..()

/datum/antagonist/dreamwalker/on_gain()
	SSmapping.retainer.dreamwalkers |= owner
	. = ..()
	reset_stats()
	// We'll set the special role later to avoid revealing dreamwalkers early!
	//owner.special_role = name
	greet()
	return ..()

/datum/antagonist/dreamwalker/greet()
	to_chat(owner.current, "<span style='color:#C8A4E0'>I feel a rare ability awaken within me. I am someone coveted as a champion by most gods. A dreamwalker. Not merely touched by Abyssor's dream, but able to pull materia and power from his realm effortlessly. I shall bring glory to my patron. My mind frays under the influence of dream entities, but surely my resolve is stronger than theirs.</span>")
	to_chat(owner.current, span_notice("I manifest a piece of ritual chalk. I can draw a Rune of Stirring for armor and a basic dream weapon. My goal is to forge an empowered dream weapon."))
	to_chat(owner.current, span_notice("Mark Target seeks a dead player of any job first. Stand next to a dead mark and cast Track Marked Target to revive them and gain Sylveric. If no dead players are eligible, Mark Target chooses a living mark. Stand next to the living mark and cast Track Marked Target while they are downed. They must survive the extraction."))
	to_chat(owner.current, span_notice("Gather two Sylveric ingots. Hold both and use one on the other, then choose a weapon to forge. The ingots are consumed and the finished weapon is placed in your hands."))
	to_chat(owner.current, span_notice("After forging your first empowered weapon, you can cast Wake from the Dream to return to your old life and keep the weapon as a trophy. You can also choose to remain a Dreamwalker. If you yield or fall into life-threatening critical condition, you wake automatically even if you have not forged a weapon."))
	owner.announce_objectives()
	..()

/datum/antagonist/dreamwalker/proc/reset_stats()
	var/mob/living/carbon/human/body = owner.current
	if(!istype(body) || dream_body || has_awakened)
		return
	dream_body = body
	RegisterSignal(body, COMSIG_LIVING_YIELDED, PROC_REF(on_dreamwalker_yielded))
	RegisterSignal(body, list(COMSIG_LIVING_CONSCIOUSNESS_CHANGED, COMSIG_LIVING_HEALTH_UPDATE), PROC_REF(on_dreamwalker_critical))
	var/list/dream_stats = list(STATKEY_STR = STASTR, STATKEY_PER = STAPER, STATKEY_INT = STAINT, STATKEY_CON = STACON, STATKEY_WIL = STAWIL, STATKEY_SPD = STASPD, STATKEY_LCK = STALUC)
	for(var/stat in dream_stats)
		body.change_stat(stat, dream_stats[stat] - body.get_stat(stat), "[REF(src)]_[stat]")

	had_dream_faction = ("dream" in body.faction)
	body.faction |= "dream"
	for(var/trait in traits_dreamwalker)
		ADD_TRAIT(body, trait, "[type]")

	original_spells = owner.spell_list.Copy()
	for(var/obj/effect/proc_holder/spell/spell as anything in original_spells)
		spell.remove_ranged_ability()
		spell.action?.Grant(null)
	owner.spell_list.Cut()
	grant_dream_spell(/obj/effect/proc_holder/spell/invoked/blink)
	grant_dream_spell(/obj/effect/proc_holder/spell/invoked/mark_target)
	grant_dream_spell(/obj/effect/proc_holder/spell/invoked/jaunt)
	grant_dream_spell(/obj/effect/proc_holder/spell/invoked/dream_bind)
	grant_dream_spell(/obj/effect/proc_holder/spell/invoked/dream_trance)

	original_ambushable = body.ambushable
	body.ambushable = FALSE
	body.AddComponent(/datum/component/dreamwalker_repair)
	body.AddComponent(/datum/component/dreamwalker_mark)
	body.put_in_hands(new /obj/item/ritechalk())
	to_chat(body, span_danger("I feel my connection to the arcyne and divine weaken as dream energies assert themselves..."))
	for(var/trait in arcyne_traits)
		if(HAS_TRAIT_FROM(body, trait, TRAIT_GENERIC))
			removed_arcyne_traits += trait
			REMOVE_TRAIT(body, trait, TRAIT_GENERIC)

	original_devotion = body.devotion
	if(original_devotion)
		devotion_was_processing = original_devotion.datum_flags & SSobj.processing_flag
		STOP_PROCESSING(SSobj, original_devotion)
		body.devotion = null
		body.hud_used?.shutdown_bloodpool()

/datum/antagonist/dreamwalker/proc/grant_dream_spell(spell_type)
	var/obj/effect/proc_holder/spell/spell = new spell_type
	dream_spells += spell
	owner.AddSpell(spell)

/datum/antagonist/dreamwalker/proc/record_forged_weapon(mob/living/user, obj/item/weapon)
	if(user != dream_body || has_awakened)
		return
	forged_weapons += weapon
	if(forged_empowered_weapon)
		return
	forged_empowered_weapon = TRUE
	grant_dream_spell(/obj/effect/proc_holder/spell/self/wake_from_dream)
	to_chat(user, span_notice("You can now Wake from the Dream and return to your old life. Your weapon will be yours to keep as a trophy."))

/datum/antagonist/dreamwalker/proc/grant_dreamcraft_skill(mob/living/user, skill, rank)
	var/datum/skill_holder/skills = user.ensure_skills()
	var/datum/skill/skill_ref = GetSkillRef(skill)
	var/previous_experience = skills.skill_experience[skill_ref] || 0
	user.adjust_skillrank_up_to(skill, rank)
	dreamcraft_experience[skill] += (skills.skill_experience[skill_ref] || 0) - previous_experience

/datum/antagonist/dreamwalker/proc/on_dreamwalker_yielded(mob/living/carbon/human/body)
	SIGNAL_HANDLER
	wake_from_dream(body, forced = TRUE)

/datum/antagonist/dreamwalker/proc/on_dreamwalker_critical(mob/living/carbon/human/body)
	SIGNAL_HANDLER
	if(body.stat != UNCONSCIOUS)
		return
	if(body.InFullCritical() || body.getOxyLoss() > 75 || (body.blood_volume <= BLOOD_VOLUME_SURVIVE && !HAS_TRAIT(body, TRAIT_BLOODLOSS_IMMUNE)))
		// Let the current health or consciousness update finish before restoring the character.
		addtimer(CALLBACK(src, PROC_REF(wake_from_dream), body, TRUE), 0, TIMER_UNIQUE)

/datum/antagonist/dreamwalker/proc/wake_from_dream(mob/living/carbon/human/body, forced = FALSE)
	if(QDELETED(body) || body != dream_body || owner?.current != body || has_awakened || body.stat == DEAD || (!forced && !forged_empowered_weapon))
		return
	has_awakened = TRUE
	antag_flags |= FLAG_ANTAG_CAP_IGNORE
	SSmapping.retainer.dreamwalkers -= owner
	restore_character(body)
	to_chat(body, span_notice("The dream releases you. You return to your old self."))

/datum/antagonist/dreamwalker/on_removal()
	if(dream_body)
		SSmapping.retainer.dreamwalkers -= owner
		restore_character(dream_body)
	return ..()

/datum/antagonist/dreamwalker/proc/restore_character(mob/living/carbon/human/body)
	dream_body = null
	if(!QDELETED(body))
		UnregisterSignal(body, list(COMSIG_LIVING_YIELDED, COMSIG_LIVING_CONSCIOUSNESS_CHANGED, COMSIG_LIVING_HEALTH_UPDATE))
		var/datum/component/dreamwalker_mark/mark = body.GetComponent(/datum/component/dreamwalker_mark)
		if(mark)
			mark.set_marked_target(null)
			dream_spells |= mark.summon_spell
			qdel(mark)
		qdel(body.GetComponent(/datum/component/dreamwalker_repair))

	for(var/obj/effect/proc_holder/spell/spell as anything in dream_spells)
		if(QDELETED(spell))
			continue
		if(istype(spell, /obj/effect/proc_holder/spell/invoked/mark_target))
			var/obj/effect/proc_holder/spell/invoked/mark_target/mark_spell = spell
			mark_spell.remove_mark(owner)
		owner.spell_list -= spell
		qdel(spell)
	dream_spells.Cut()

	if(cmptext(owner.special_role, ROLE_DREAMWALKER))
		owner.special_role = null
	for(var/obj/effect/proc_holder/spell/spell as anything in original_spells)
		if(!QDELETED(spell) && !(spell in owner.spell_list))
			owner.AddSpell(spell)
	original_spells.Cut()
	if(QDELETED(body))
		return

	for(var/stat in dream_stat_keys)
		body.change_stat(stat, 0, "[REF(src)]_[stat]")
	for(var/trait in traits_dreamwalker)
		REMOVE_TRAIT(body, trait, "[type]")
	for(var/trait in removed_arcyne_traits)
		ADD_TRAIT(body, trait, TRAIT_GENERIC)
	removed_arcyne_traits.Cut()
	for(var/skill in dreamcraft_experience)
		body.ensure_skills().adjust_experience(skill, -dreamcraft_experience[skill], silent = TRUE)
	dreamcraft_experience.Cut()
	if(!had_dream_faction)
		body.faction -= "dream"
	body.ambushable = original_ambushable

	if(!QDELETED(original_devotion) && !body.devotion)
		body.devotion = original_devotion
		original_devotion.patron = body.patron
		if(body.hud_used && !body.hud_used.bloodpool)
			body.hud_used.initialize_bloodpool()
			body.hud_used.bloodpool.set_fill_color("#3C41A4")
		if(body.hud_used?.bloodpool)
			original_devotion.update_devotion(0, 0, silent = TRUE)
		if(devotion_was_processing)
			START_PROCESSING(SSobj, original_devotion)
	original_devotion = null

	var/turf/drop_turf = get_turf(body)
	for(var/obj/item/weapon as anything in forged_weapons)
		if(QDELETED(weapon) || get_atom_on_turf(weapon, /mob/living) != body)
			continue
		var/atom/old_location = weapon.loc
		var/was_held = (weapon in body.held_items)
		var/obj/item/dream_weapon_trophy/trophy = new(drop_turf, weapon)
		qdel(weapon)
		if(was_held)
			body.put_in_hands(trophy)
		else if(old_location != body)
			trophy.forceMove(old_location)
	forged_weapons.Cut()
	for(var/obj/item/item in body.get_equipped_items(TRUE) | body.held_items)
		if(item.item_flags & DREAM_ITEM)
			body.dropItemToGround(item, TRUE)

/datum/outfit/job/roguetown/dreamwalker/pre_equip(mob/living/carbon/human/H) //Equipment is located below
	..()

	H.adjust_skillrank(/datum/skill/magic/arcane, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	// We lose our statpack & racial, so bonuses are significant.
	H.change_stat(STATKEY_STR, 5)
	H.change_stat(STATKEY_INT, 2)
	H.change_stat(STATKEY_CON, 2)
	H.change_stat(STATKEY_PER, 2)
	H.change_stat(STATKEY_SPD, 2)
	H.change_stat(STATKEY_WIL, 2)

	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/blink)
	H.ambushable = FALSE

/datum/component/dreamwalker_repair
	/// List of dream items being repaired
	var/list/repairing_items = list()
	/// List of timers for broken items being fully repaired
	var/list/repair_timers = list()
	/// Processing interval
	/// Careful touching this as setting it too low makes it REALLY hard to break items.
	var/process_interval = 5 SECONDS
	/// Time of last processing
	var/last_process = 0
	var/next_armor_peel_process = 0
	var/next_armor_peel_interval = 1 MINUTES

/datum/component/dreamwalker_repair/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	to_chat(parent, span_userdanger("Your body pulses with strange dream energies."))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_item_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_item_dropped))
	// Register for processing
	START_PROCESSING(SSprocessing, src)

/datum/component/dreamwalker_repair/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	// Clean up all timers
	for(var/obj/item/I in repair_timers)
		deltimer(repair_timers[I])
	repair_timers = null
	repairing_items = null
	return ..()

/datum/component/dreamwalker_repair/process(delta_time)
	// Only process every x seconds
	if(world.time < last_process + process_interval)
		return

	last_process = world.time

	// Process all items in the repair list
	for(var/obj/item/I in repairing_items)
		if(I.obj_broken)
			continue // Broken items are handled separately
		if(I.obj_integrity < I.max_integrity)
			I.obj_integrity = min(I.obj_integrity + I.max_integrity * 0.01, I.max_integrity) // Repair 1% of max integrity
			I.update_icon()
		if(I.blade_int < I.max_blade_int)
			I.add_bintegrity(min(I.blade_int + I.max_blade_int * 0.01, I.max_blade_int), src.parent) // Sharpen 1% of max sharpness

	if(world.time >= next_armor_peel_process)
		next_armor_peel_process = world.time + next_armor_peel_interval

		for(var/obj/item/I in repairing_items)
			if(istype(I, /obj/item/clothing) && I.peel_count > 0)
				I.peel_count--
				I.visible_message(span_notice("The dream energies snap a peeled layer of [I] back in place."))
				break

/datum/component/dreamwalker_repair/proc/on_item_equipped(mob/user, obj/item/source, slot)
	SIGNAL_HANDLER
	if(source.item_flags & DREAM_ITEM)
		to_chat(parent, span_notice("[source] pulses in your hands, dream energies passively repairing it."))
		add_item(source)

/datum/component/dreamwalker_repair/proc/on_item_dropped(mob/user, obj/item/source)
	SIGNAL_HANDLER
	if(source.item_flags & DREAM_ITEM)
		to_chat(parent, span_notice("[source] stops pulsing as it leaves your person."))
		remove_item(source)

/datum/component/dreamwalker_repair/proc/add_item(obj/item/I)
	if(I in repairing_items)
		return
	repairing_items += I
	RegisterSignal(I, COMSIG_ITEM_BROKEN, PROC_REF(on_item_broken))

	// If item is already broken, start full repair process
	if(I.obj_broken)
		start_full_repair(I)

/datum/component/dreamwalker_repair/proc/remove_item(obj/item/I)
	if(I in repairing_items)
		repairing_items -= I
		UnregisterSignal(I, COMSIG_ITEM_BROKEN)
		// Cancel any ongoing full repair
		if(I in repair_timers)
			deltimer(repair_timers[I])
			repair_timers -= I

/datum/component/dreamwalker_repair/proc/on_item_broken(obj/item/source)
	SIGNAL_HANDLER
	if(source in repairing_items)
		source.visible_message(span_danger("The [source] shatters, but it seems strange energies are slowly bending the metal back into shape."))
		start_full_repair(source)

/datum/component/dreamwalker_repair/proc/start_full_repair(obj/item/I)
	// Cancel any existing timer
	if(I in repair_timers)
		deltimer(repair_timers[I])

	// Set a timer to fully repair after 1 minute
	repair_timers[I] = addtimer(CALLBACK(src, PROC_REF(finish_full_repair), I), 1 MINUTES, TIMER_STOPPABLE)

/datum/component/dreamwalker_repair/proc/finish_full_repair(obj/item/I)
	// Check if the item is still in our inventory and broken
	if(I && (I in repairing_items) && I.obj_broken)
		I.visible_message(span_danger("The [I] melds back into a useable shape."))
		I.obj_fix()
		// Restore up to 25% of durability instead of all of it. This is slightly more as I.integrity_failure for MOST things.
		I.obj_integrity *= 0.25
		I.update_icon()

	// Remove the timer reference
	repair_timers -= I

/obj/structure/portal_jaunt
	name = "dream rift"
	desc = "A shimmering portal to another place. You hear countless whispers when you get close, seems dangerous."
	icon_state = "shitportal"
	icon = 'icons/roguetown/misc/structure.dmi'
	max_integrity = 250
	var/cooldown = 0
	var/uses = 0
	var/max_uses = 3
	var/turf/linked_turf
	var/safe_passage = FALSE

/obj/structure/portal_jaunt/Initialize(mapload)
	. = ..()
	cooldown = world.time + 4 SECONDS
	visible_message(span_warning("[src] shimmers into existence!"))
	playsound(src, 'sound/magic/charging_lightning.ogg', 50, TRUE)

/obj/structure/portal_jaunt/attack_hand(mob/user)
	if(!do_after(user, 1 SECONDS, target = src))
		to_chat(user, span_warning("I must stand still to use the portal."))
		return

	if(world.time < cooldown)
		var/time_left = (cooldown - world.time) * 0.1
		to_chat(user, span_warning("The portal is not stable yet. [time_left] seconds remaining."))
		return

	if(uses >= max_uses)
		to_chat(user, span_warning("The portal collapses as you touch it!"))
		qdel(src)
		return

	if(!linked_turf || !do_teleport(user, linked_turf))
		to_chat(user, span_warning("The portal flickers but nothing happens."))
		return

	uses++
	cooldown = world.time + 15 SECONDS
	// High likelyhood of getting a dreamfiend summon upon non dreamwalkers when used.
	if(!HAS_TRAIT(user, TRAIT_DREAMWALKER) && prob(75))
		summon_dreamfiend(
			target = user,
			user = user,
			F = /mob/living/simple_animal/hostile/rogue/dreamfiend,
			outer_tele_radius = 3,
			inner_tele_radius = 2,
			include_dense = FALSE,
			include_teleport_restricted = FALSE
		)

	visible_message(span_warning("[user] steps through [src]!"))
	playsound(src, 'sound/magic/lightning.ogg', 50, TRUE)

	if(uses >= max_uses)
		visible_message(span_danger("[src] collapses in on itself!"))
		QDEL_IN(src, 1)

// Component to track marked targets and hits
/datum/component/dreamwalker_mark
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/mob/living/marked_target = null
	var/hit_count = 0
	var/max_hits = 5
	var/mark_duration = 30 MINUTES
	var/mark_start_time = 0
	var/mark_minimum_duration = 10 MINUTES
	var/obj/effect/proc_holder/spell/invoked/summon_marked/summon_spell = null

/datum/component/dreamwalker_mark/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/dreamwalker_mark/Destroy()
	if(marked_target)
		UnregisterSignal(marked_target, COMSIG_LIVING_DEATH)
		marked_target = null

	if(summon_spell && ishuman(parent))
		var/mob/living/carbon/human/H = parent
		if(H.mind)
			H.mind.RemoveSpell(summon_spell)
		QDEL_NULL(summon_spell)
	return ..()

/datum/component/dreamwalker_mark/proc/set_marked_target(mob/living/target)
	if(marked_target)
		UnregisterSignal(marked_target, COMSIG_LIVING_DEATH)
		if(marked_target.has_status_effect(/datum/status_effect/dream_mark))
			marked_target.remove_status_effect(/datum/status_effect/dream_mark)

	marked_target = target
	hit_count = 0
	mark_start_time = 0

	if(marked_target)
		RegisterSignal(marked_target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
		to_chat(parent, span_notice("You begin focusing your dream energy on [marked_target.real_name]."))

		// Remove any existing summon spell
		if(summon_spell && ishuman(parent))
			var/mob/living/carbon/human/H = parent
			if(H.mind)
				H.mind.RemoveSpell(summon_spell)
			QDEL_NULL(summon_spell)

/datum/component/dreamwalker_mark/proc/on_attack(mob/parent, mob/living/target, mob/user, obj/item/I)
	SIGNAL_HANDLER

	if(!marked_target || target != marked_target)
		return

	if(!(I.item_flags & DREAM_ITEM))
		return

	if(marked_target.has_status_effect(/datum/status_effect/dream_mark))
		return

	hit_count++
	to_chat(user, span_notice("Your dream weapon strikes true. [hit_count]/[max_hits] hits to establish a connection."))

	if(hit_count >= max_hits)
		// Apply the mark status effect
		marked_target.apply_status_effect(/datum/status_effect/dream_mark, mark_duration)
		mark_start_time = world.time
		to_chat(user, span_warning("You've established a strong dream connection with [marked_target]! You'll be able to summon them in 10 minutes."))
		to_chat(marked_target, span_userdanger("You feel an unnatural connection forming with [user]. Your very essence feels tethered to them."))

		create_summon_spell()

/datum/component/dreamwalker_mark/proc/create_summon_spell()
	if(!marked_target || !ishuman(parent))
		return

	// Check if mark is still active
	if(!marked_target.has_status_effect(/datum/status_effect/dream_mark))
		to_chat(parent, span_warning("Your connection with [marked_target] has faded before you could summon them!"))
		return

	// Create the summon spell
	summon_spell = new()
	var/mob/living/carbon/human/H = parent
	if(H.mind)
		H.mind.AddSpell(summon_spell)
		to_chat(H, span_warning("Your connection with [marked_target] is now strong enough to summon them!"))

/datum/component/dreamwalker_mark/proc/on_target_death()
	SIGNAL_HANDLER
	to_chat(parent, span_warning("Your connection with [marked_target] has been severed by death."))
	set_marked_target(null)

/datum/component/dreamwalker_mark/proc/can_summon()
	if(!marked_target)
		return FALSE

	if(!marked_target.has_status_effect(/datum/status_effect/dream_mark))
		return FALSE

	if(world.time < mark_start_time + mark_minimum_duration)
		var/time_left = ((mark_start_time + mark_minimum_duration) - world.time) * 0.1
		to_chat(parent, span_warning("The mark is not stable yet. [time_left] seconds remaining."))
		return FALSE

	return TRUE

// Status effect for marked targets
/datum/status_effect/dream_mark
	id = "dream_mark"
	duration = 30 MINUTES // Increased to 30 minutes
	alert_type = /atom/movable/screen/alert/status_effect/dream_mark

/datum/status_effect/dream_mark/on_apply()
	to_chat(owner, span_userdanger("You feel your essence being pulled toward another realm. You've been marked by a dreamwalker!"))
	return TRUE

/datum/status_effect/dream_mark/on_remove()
	to_chat(owner, span_notice("The connection to the dream realm fades."))

/atom/movable/screen/alert/status_effect/dream_mark
	name = "Dream Marked"
	desc = "A dreamwalker has established a connection to your essence. They may attempt to summon you once the connection stabilizes."
	icon_state = "dream_mark"

/obj/item/ingot/sylveric
	name = "Sylveric ingot"
	icon = 'icons/roguetown/items/ore.dmi'
	icon_state = "ingotsylveric"
	desc = "An impossibly light metal that seems to grow harder and heavier when pressured. Nothing seems to be able to shape this metal."

// Add extra examine text for dreamwalkers
// Handle attacking one sylveric ingot with another
/obj/item/ingot/sylveric/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/ingot/sylveric))
		if(!HAS_TRAIT(user, TRAIT_DREAMWALKER))
			return ..()

		// Check if both ingots are accessible
		if(I != user.get_active_held_item())
			return ..()

		if(!(src in user.contents) && !(isturf(src.loc) && in_range(src, user)))
			return ..()

		// Show weapon selection menu
		var/list/weapon_options = list(
			"Dreamreaver Greataxe" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamaxeactive"),
			"Harmonious Spear" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamspearactive"),
			"Oozing Sword" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamswordactive"),
			"Thunderous Trident" = image(icon = 'icons/roguetown/weapons/64.dmi', icon_state = "dreamtriactive")
		)

		var/choice = show_radial_menu(user, src, weapon_options, require_near = TRUE, tooltips = TRUE)
		if(!choice)
			return

		to_chat(user, span_notice("You begin focusing your dream energy to shape the sylveric ingots into a [choice]..."))
		if(do_after(user, 10 SECONDS, target = src) && !QDELETED(I) && !QDELETED(src) && HAS_TRAIT(user, TRAIT_DREAMWALKER))
			var/obj/item/new_weapon
			switch(choice)
				if("Dreamreaver Greataxe")
					new_weapon = new /obj/item/rogueweapon/greataxe/dreamscape/active(user.loc)
				if("Harmonious Spear")
					new_weapon = new /obj/item/rogueweapon/halberd/glaive/dreamscape/active(user.loc)
				if("Oozing Sword")
					new_weapon = new /obj/item/rogueweapon/greatsword/bsword/dreamscape/active(user.loc)
				if("Thunderous Trident")
					new_weapon = new /obj/item/rogueweapon/spear/dreamscape_trident/active(user.loc)

			if(new_weapon)
				to_chat(user, span_notice("You shape the sylveric ingots into a [choice]."))
				qdel(I)
				user.put_in_hands(new_weapon)
				var/datum/antagonist/dreamwalker/dreamwalker = user.mind?.has_antag_datum(/datum/antagonist/dreamwalker)
				if(istype(dreamwalker))
					dreamwalker.record_forged_weapon(user, new_weapon)
				qdel(src)
		return
	return ..()

/obj/item/dream_weapon_trophy
	name = "dream weapon trophy"
	desc = "An otherworldly weapon, now still and powerless."

/obj/item/dream_weapon_trophy/Initialize(mapload, obj/item/weapon)
	. = ..()
	if(!weapon)
		return
	name = "[weapon.name] trophy"
	icon = weapon.icon
	icon_state = weapon.icon_state
	color = weapon.color
	w_class = weapon.w_class

// Component for dream weapon special properties
/datum/component/dream_weapon
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/effect_type = null
	var/cooldown_time
	var/next_use = 0

/datum/component/dream_weapon/Initialize(effect_type, cooldown_time)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.effect_type = effect_type
	src.cooldown_time = cooldown_time

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SUCCESS, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))


/datum/component/dream_weapon/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER
	if(!effect_type)
		return

	// Check cooldown
	if(world.time < next_use)
		return

	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target

	// Apply effect based on type
	switch(effect_type)
		if("fire")
			H.adjust_fire_stacks(4)
			addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living, ignite_mob)), 0)
			target.visible_message(span_warning("[source] ignites [target] with strange flame!"))
		if("frost")
			H.apply_status_effect(/datum/status_effect/buff/frostbite)
			target.visible_message(span_warning("[source] freezes [target] with scalding ice!"))
		if("poison")
			if(H.reagents)
				H.reagents.add_reagent(/datum/reagent/berrypoison, 2)
				target.visible_message(span_warning("[source] injects [target] with vile ooze!"))

	// Set cooldown
	next_use = world.time + cooldown_time

/datum/component/dream_weapon/proc/on_equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(HAS_TRAIT(user, TRAIT_DREAMWALKER))
		return

	// Non-dreamwalker trying to equip a dream weapon
	to_chat(user, span_userdanger("The weapon rejects your touch, burning with dream energy!"))
	user.dropItemToGround(source, TRUE)

	// Apply some damage or negative effect
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dreamscape_backfire), H), 0)

/proc/dreamscape_backfire(mob/living/carbon/human/H)
	H.apply_damage(10, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
	H.adjust_fire_stacks(2)
	H.ignite_mob()

/obj/item/rogueweapon/halberd/glaive/dreamscape
	name = "otherworldly spear"
	desc = "A strange spear, who knows where it came from. It seems like it is made out of ancient bone."
	icon_state = "dreamspear"
	anvilrepair = /datum/skill/craft/weaponsmithing
	smeltresult = null
	item_flags = DREAM_ITEM
	wbalance = WBALANCE_HEAVY
	max_blade_int = 200
	wdefense = 8

/obj/item/rogueweapon/halberd/glaive/dreamscape/active
	desc = "A strange spear, who knows where it came from. Strange harmonious sounds ring out as wind passes through the holes."
	icon_state = "dreamspearactive"
	max_blade_int = 400
	wdefense = 9
	force = 20
	force_wielded = 35

/obj/item/rogueweapon/greatsword/bsword/dreamscape
	name = "otherworldly sword"
	desc = "A strange sword made out of a strange reflective metal."
	icon_state = "dreamsword"
	force = 25
	force_wielded = 30
	max_integrity = 275
	smeltresult = null
	item_flags = DREAM_ITEM
	wbalance = WBALANCE_HEAVY
	wdefense = 4
	possible_item_intents = list(/datum/intent/sword/cut,/datum/intent/sword/chop,/datum/intent/stab, /datum/intent/sword/peel)
	gripped_intents = list(/datum/intent/sword/cut/zwei, /datum/intent/sword/chop, /datum/intent/sword/lunge, /datum/intent/sword/thrust/estoc)
	alt_intents = list(/datum/intent/effect/daze, /datum/intent/sword/strike, /datum/intent/sword/bash)

/obj/item/rogueweapon/greatsword/bsword/dreamscape/active
	name = "otherworldly sword"
	desc = "A strange sword made out of a strange reflective metal. It oozes sickening sludge."
	icon_state = "dreamswordactive"
	max_integrity = 500
	force = 30
	force_wielded = 35
	wdefense = 5

/obj/item/rogueweapon/spear/dreamscape_trident
	name = "otherworldly trident"
	desc = "A strange trident. It feels like it shouldn't be an effective weapon, but the dull metal whispers tales of its power to you."
	icon_state = "dreamtri"
	smeltresult = null
	max_blade_int = 240
	minstr = 8
	wdefense = 4
	throwforce = 40
	force = 30
	force_wielded = 20
	item_flags = DREAM_ITEM
	var/shockwave_cooldown = 0
	var/shockwave_cooldown_interval = 1 MINUTES
	var/shockwave_divisor = 3
	var/shockwave_damage = FALSE

/obj/item/rogueweapon/spear/dreamscape_trident/active
	name = "Iridescent trident"
	desc = "A strange trident glimmering with an oily hue. The air shimmers around it."
	icon_state = "dreamtriactive"
	max_integrity = 480
	throwforce = 50
	force = 35
	force_wielded = 25
	wdefense = 5
	shockwave_cooldown_interval = 30 SECONDS
	shockwave_divisor = 2
	shockwave_damage = TRUE

// Update weapon initializations with specific effects
/obj/item/rogueweapon/greataxe/dreamscape/active/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, "fire", 20 SECONDS)

/obj/item/rogueweapon/halberd/glaive/dreamscape/active/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, "frost", 40 SECONDS)

/obj/item/rogueweapon/greatsword/bsword/dreamscape/active/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, "poison", 20 SECONDS)

/obj/item/rogueweapon/spear/dreamscape_trident/active/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)

/datum/outfit/job/roguetown/dreamwalker_armorrite/pre_equip(mob/living/carbon/human/H)
	..()
	var/list/items = list()
	items |= H.get_equipped_items(TRUE)
	for(var/I in items)
		H.dropItemToGround(I, TRUE)
	H.drop_all_held_items()
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/dreamwalker
	pants = /obj/item/clothing/under/roguetown/platelegs/dreamwalker
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/dreamwalker
	gloves = /obj/item/clothing/gloves/roguetown/plate/dreamwalker
	head = /obj/item/clothing/head/roguetown/helmet/bascinet/dreamwalker
	neck = /obj/item/clothing/neck/roguetown/bevor

/obj/item/clothing/suit/roguetown/armor/plate/full/dreamwalker
	name = "otherworldly fullplate"
	desc = "Strange iridescent full plate. It reflects light as if covered in shiny oil."
	icon_state = "dreamplate"
	max_integrity = ARMOR_INT_CHEST_PLATE_ANTAG
	item_flags = DREAM_ITEM
	peel_threshold = 5

/obj/item/clothing/suit/roguetown/armor/plate/full/dreamwalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)

/obj/item/clothing/under/roguetown/platelegs/dreamwalker
	max_integrity = ARMOR_INT_LEG_ANTAG
	name = "otherworldly legplate"
	desc = "Strange iridescent leg plate. It reflects light as if covered in shiny oil."
	icon_state = "dreamlegs"
	armor = ARMOR_ASCENDANT
	item_flags = DREAM_ITEM
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_SMASH, BCLASS_PICK)

/obj/item/clothing/under/roguetown/platelegs/dreamwalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)

/obj/item/clothing/shoes/roguetown/boots/armor/dreamwalker
	max_integrity = ARMOR_INT_SIDE_ANTAG
	name = "otherworldly boots"
	desc = "Strange iridescent plated boots. It reflects light as if covered in shiny oil."
	icon_state = "dreamboots"
	armor = ARMOR_ASCENDANT
	item_flags = DREAM_ITEM

/obj/item/clothing/shoes/roguetown/boots/armor/dreamwalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)

/obj/item/clothing/gloves/roguetown/plate/dreamwalker
	name = "otherworldly gauntlets"
	desc = "Strange iridescent plated gauntlets. It reflects light as if covered in shiny oil."
	icon_state = "dreamgauntlets"
	max_integrity = ARMOR_INT_SIDE_ANTAG
	item_flags = DREAM_ITEM

/obj/item/clothing/gloves/roguetown/plate/dreamwalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)

/obj/item/clothing/head/roguetown/helmet/bascinet/dreamwalker
	name = "otherworldly squid helm"
	desc = "A otherworldly squid helm. It reflects light as if covered in shiny oil."
	adjustable = CAN_CADJUST
	icon_state = "dreamsquidhelm"
	max_integrity = ARMOR_INT_HELMET_ANTAG
	peel_threshold = 4
	item_flags = DREAM_ITEM
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/32x48/head.dmi'
	block2add = null
	worn_x_dimension = 32
	worn_y_dimension = 48
	body_parts_covered = FULL_HEAD
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/roguetown/helmet/bascinet/dreamwalker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dream_weapon, null, 20 SECONDS)
