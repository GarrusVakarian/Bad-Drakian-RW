
/obj/effect/proc_holder/spell/invoked/mark_target
	name = "Mark Target"
	desc = "Marks a dead player first, regardless of job. If no dead mark is available, it chooses an eligible living player. Use Track Marked Target to recover Sylveric. Hit a living mark with a dream weapon to summon them later."
	releasedrain = 75
	chargedrain = 1
	chargetime = 1.5 SECONDS
	recharge_time = 25 MINUTES
	overlay_state = "dream_mark"
	invocations = list("Dream... manifest my vision, bend to my will.")
	invocation_type = "whisper"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	associated_skill = /datum/skill/magic/arcane

	// Define roles that are considered valid targets
	// Generally combat ready roles connected to a larger faction.
	var/static/list/valid_target_roles = list(
		"Orthodoxist",
		"Absolver",
		"Templar",
		"Dungeoneer",
		"Sergeant",
		"Man at Arms",
		"Knight",
		"Squire",
		"Mercenary",
		"Warden",
		"Adventurer",
		"Rookie",
		"Vanguard",
	)

	var/mob/living/marked_target = null
	var/obj/effect/proc_holder/spell/invoked/track_mark/tracking_spell = null
	var/living_mark_identity
	var/list/failed_corpse_marks

/obj/effect/proc_holder/spell/invoked/mark_target/Destroy()
	remove_mark(action?.owner?.mind)
	return ..()

/obj/effect/proc_holder/spell/invoked/mark_target/cast(list/targets, mob/living/user)
	if(select_mark(user))
		return TRUE
	to_chat(user, span_warning("No valid targets found."))
	revert_cast(user)
	return FALSE

/obj/effect/proc_holder/spell/invoked/mark_target/proc/select_mark(mob/living/user, excluded_identity)
	var/list/valid_targets = get_valid_targets(user, excluded_identity)
	if(!length(valid_targets))
		return FALSE

	var/mob/living/carbon/human/target = pick(valid_targets)
	remove_mark(user.mind)
	marked_target = target
	tracking_spell = new
	tracking_spell.marked_target = target
	tracking_spell.parent_spell = src
	tracking_spell.revival_mark = (target.stat == DEAD)
	user.mind.AddSpell(tracking_spell)

	var/datum/component/dreamwalker_mark/mark_component = user.GetComponent(/datum/component/dreamwalker_mark)
	if(!mark_component)
		mark_component = user.AddComponent(/datum/component/dreamwalker_mark)
	if(tracking_spell.revival_mark)
		mark_component.set_marked_target(null)
		RegisterSignal(target, COMSIG_LIVING_BECAME_ALIVE, PROC_REF(on_corpse_mark_revived))
	else
		living_mark_identity = mark_identity(target)
		mark_component.set_marked_target(target)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_living_mark_died))
	to_chat(user, span_notice("You mark [target.real_name] for pursuit."))
	return TRUE

/obj/effect/proc_holder/spell/invoked/mark_target/proc/on_living_mark_died(mob/living/target)
	SIGNAL_HANDLER
	lose_mark(living_mark_identity)

/obj/effect/proc_holder/spell/invoked/mark_target/proc/on_corpse_mark_revived(mob/living/target)
	SIGNAL_HANDLER
	if(QDELETED(tracking_spell) || tracking_spell.performing_revival)
		return
	queue_mark_reroll("My mark escaped Necra's grasp without my intervention. The dream seeks another.")

/obj/effect/proc_holder/spell/invoked/mark_target/proc/lose_mark(excluded_identity)
	if(!QDELETED(tracking_spell) && tracking_spell.revival_mark && !tracking_spell.mark_lost && !QDELETED(marked_target))
		LAZYSET(failed_corpse_marks, marked_target, TRUE)
	queue_mark_reroll("My mark is grasped by Necra. The dream seeks another.", excluded_identity)

/obj/effect/proc_holder/spell/invoked/mark_target/proc/queue_mark_reroll(message, excluded_identity)
	if(QDELETED(tracking_spell) || tracking_spell.mark_lost)
		return
	tracking_spell.mark_lost = TRUE
	addtimer(CALLBACK(src, PROC_REF(reroll_mark), tracking_spell, message, excluded_identity), 0)

/obj/effect/proc_holder/spell/invoked/mark_target/proc/reroll_mark(obj/effect/proc_holder/spell/invoked/track_mark/previous_spell, message, excluded_identity)
	var/mob/living/user = action?.owner
	if(QDELETED(user) || !user.mind || QDELETED(previous_spell) || tracking_spell != previous_spell)
		return
	to_chat(user, span_notice(message))
	if(!select_mark(user, excluded_identity))
		remove_mark(user.mind)
		finish_recharge()
		to_chat(user, span_notice("No other mark is available. I can cast Mark Target again."))

/obj/effect/proc_holder/spell/invoked/mark_target/proc/mark_identity(mob/living/target)
	return ckey(target.mind?.key) || target.mind

/obj/effect/proc_holder/spell/invoked/mark_target/proc/get_valid_targets(mob/user, excluded_identity)
	var/list/returnable_bodies = list()
	var/list/spirit_keys = list()
	var/list/living_targets = list()
	for(var/mob/player as anything in GLOB.player_list)
		if(QDELETED(player))
			continue
		if(ishuman(player))
			if(player != user && player != marked_target && player.stat != DEAD && is_valid_target(player, excluded_identity = excluded_identity))
				living_targets += player
			continue
		if(!player.client)
			continue
		if(isobserver(player))
			var/mob/dead/observer/ghost = player
			if(ghost.can_reenter_corpse && ghost.mind?.current)
				returnable_bodies[ghost.mind.current] = ghost.mind
		else if(istype(player, /mob/living/carbon/spirit))
			if(player.ckey)
				spirit_keys[player.ckey] = TRUE
			var/mind_key = ckey(player.mind?.key)
			if(mind_key)
				spirit_keys[mind_key] = TRUE

	var/list/corpse_targets = list()
	for(var/mob/living/carbon/human/corpse in GLOB.dead_mob_list)
		if(corpse != user && corpse != marked_target && is_valid_target(corpse, returnable_bodies, spirit_keys, excluded_identity))
			corpse_targets += corpse
	return length(corpse_targets) ? corpse_targets : living_targets

/obj/effect/proc_holder/spell/invoked/mark_target/proc/is_valid_target(mob/living/carbon/human/target, list/returnable_bodies, list/spirit_keys, excluded_identity)
	if(QDELETED(target) || !target.mind || (excluded_identity && excluded_identity == mark_identity(target)))
		return FALSE
	if(target.stat != DEAD)
		return (target.mind.assigned_role in valid_target_roles) && has_target_player(target)
	if(failed_corpse_marks?[target] || !get_turf(target) || target.mob_biotypes & MOB_UNDEAD || HAS_TRAIT(target, TRAIT_DNR) || HAS_TRAIT(target, TRAIT_NECRAS_VOW))
		return FALSE
	if(!target.get_bodypart(BODY_ZONE_HEAD) || !target.getorganslot(ORGAN_SLOT_BRAIN) || !target.getorganslot(ORGAN_SLOT_HEART) || target.has_foreign_brain())
		return FALSE
	return has_target_player(target, returnable_bodies, spirit_keys)

/obj/effect/proc_holder/spell/invoked/mark_target/proc/has_target_player(mob/living/carbon/human/target, list/returnable_bodies, list/spirit_keys)
	return target.client || (target.mind && returnable_bodies?[target] == target.mind) || spirit_keys?[ckey(target.key || target.mind?.key)]

/obj/effect/proc_holder/spell/invoked/mark_target/proc/remove_mark(datum/mind/caster)
	if(marked_target)
		UnregisterSignal(marked_target, list(COMSIG_LIVING_BECAME_ALIVE, COMSIG_LIVING_DEATH))
		marked_target = null
	living_mark_identity = null
	if(!QDELETED(tracking_spell))
		caster?.spell_list -= tracking_spell
	QDEL_NULL(tracking_spell)

/obj/effect/proc_holder/spell/invoked/track_mark
	name = "Track Marked Target"
	desc = "Track your mark. Extract Sylveric from an adjacent, downed mark who was chosen alive. A mark chosen dead must be revived through this spell to yield an ingot."
	recharge_time = 2 SECONDS
	var/mob/living/marked_target = null
	var/obj/effect/proc_holder/spell/invoked/mark_target/parent_spell = null
	var/revival_mark = FALSE
	var/performing_revival = FALSE
	var/mark_lost = FALSE
	releasedrain = 75
	chargedrain = 1
	chargetime = 0
	overlay_state = "dream_track"
	invocations = list("Dream... Find them.")
	invocation_type = "whisper"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/invoked/track_mark/cast(list/targets, mob/user)
	if(mark_lost)
		return
	var/mob/living/mark = marked_target
	if(QDELETED(mark))
		if(revival_mark && parent_spell)
			parent_spell.lose_mark()
			return
		to_chat(user, span_warning("The mark has faded!"))
		user.mind.RemoveSpell(src)
		return

	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(mark)
	if(!user_turf)
		return
	if(!target_turf)
		if(revival_mark)
			parent_spell?.lose_mark()
		return

	if(user_turf.z != target_turf.z)
		// Different z-level
		var/z_direction = "unknown"
		if(user_turf.z > target_turf.z)
			z_direction = "below"
		else
			z_direction = "above"

		to_chat(user, span_notice("The target is on a level [z_direction] you."))
	else
		// Same z-level
		var/distance = get_dist(user, mark)
		var/direction = get_dir(user, mark)

		if(distance == 0)
			to_chat(user, span_notice("The target is here!"))
		else
			var/direction_text = dir2text(direction)
			to_chat(user, span_notice("The target is [distance] tiles away to the [direction_text]."))

	if(!user.Adjacent(mark))
		return
	if(revival_mark)
		if(mark.stat != DEAD)
			return
		if(mark.mob_biotypes & MOB_UNDEAD)
			parent_spell?.lose_mark()
			return
		to_chat(user, span_notice("You reach into the dream to bring your mark back."))
	else
		if(mark.stat == DEAD)
			to_chat(user, span_warning("I can only pull metal from this mark while they live."))
			return
		if(mark.mobility_flags & MOBILITY_STAND)
			return
		to_chat(user, span_notice("The target is vulnerable. You begin to pull metal from their mind..."))

	var/completed = do_after(user, 10 SECONDS, target = mark)
	if(QDELETED(src) || QDELETED(user) || mark_lost)
		return
	if(revival_mark && (QDELETED(mark) || mark.mob_biotypes & MOB_UNDEAD))
		parent_spell?.lose_mark()
		return
	if(!completed)
		to_chat(user, span_warning("You were interrupted."))
		return
	if(marked_target != mark || QDELETED(mark))
		to_chat(user, span_warning("The mark has faded!"))
		return
	if(revival_mark)
		if(mark.stat != DEAD)
			return
		var/obj/effect/proc_holder/spell/invoked/resurrect/abyssor/rite = new
		performing_revival = TRUE
		var/succeeded = rite.perform_revival(list(mark), user)
		performing_revival = FALSE
		qdel(rite)
		if(!succeeded || QDELETED(mark) || mark.stat == DEAD)
			parent_spell?.lose_mark()
			return
		playsound(mark, 'sound/magic/whale.ogg', 50, TRUE)
	else
		if(mark.stat == DEAD)
			to_chat(user, span_warning("My mark died before I could pull the metal free."))
			return
		if(mark.mobility_flags & MOBILITY_STAND)
			to_chat(user, span_warning("My mark got back up before I could pull the metal free."))
			return
		mark.Stun(10)
		mark.apply_status_effect(/datum/status_effect/debuff/dreamfiend_curse)

	new /obj/item/ingot/sylveric(get_turf(user))
	to_chat(user, span_notice("You successfully manifest an ingot of strange metal using your target's psyche."))
	if(parent_spell)
		parent_spell.finish_recharge()
		parent_spell.remove_mark(user.mind)
	else
		user.mind.RemoveSpell(src)

/obj/effect/proc_holder/spell/invoked/jaunt
	name = "Dream Jaunt"
	desc = "Teleports you to a random coastal area after a short channel, leaving a temporary portal behind. You may be followed."
	chargedrain = 0
	chargetime = 2 SECONDS
	recharge_time = 15 MINUTES
	invocation_type = "whisper"
	invocations = list("Whisper of the dream...")
	movement_interrupt = FALSE
	charging_slowdown = 1
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "dream_jaunt"

/obj/effect/proc_holder/spell/invoked/jaunt/cast(list/targets, mob/user)
	var/turf/original_turf = get_turf(user)
	if(!original_turf)
		revert_cast()
		return

	// Find destination area
	var/static/list/possible_areas = list(
		/area/rogue/outdoors/beach,
		/area/rogue/outdoors/beach/north,
		/area/rogue/outdoors/beach/south,
		/area/rogue/outdoors/beach/harbor,
		/area/rogue/outdoors/bograt/sunken,
		/area/rogue/under/cavewet/river,
	)
	var/area/destination_area = GLOB.areas_by_type[pick(possible_areas)]
	if(!destination_area)
		revert_cast()
		return

	// Find safe turfs in destination area
	var/list/safe_turfs = list()
	for(var/turf/T in get_area_turfs(destination_area))
		if(istype(T, /turf/open/water/ocean/deep))
			continue
		if(T.density)
			continue
		var/valid = TRUE
		for(var/atom/movable/AM in T)
			if(AM.density && AM.anchored)
				valid = FALSE
				break
		if(valid)
			safe_turfs += T

	if(!safe_turfs.len)
		revert_cast()
		return

	var/turf/destination = pick(safe_turfs)
	
	// Create portal at origin
	var/obj/structure/portal_jaunt/portal = new(original_turf)
	portal.linked_turf = destination

	// Teleport user
	if(do_teleport(user, destination))
		// Create return portal at destination
		return TRUE

	qdel(portal)
	revert_cast()
	return FALSE

// Summon marked target spell
/obj/effect/proc_holder/spell/invoked/summon_marked
	name = "Summon Marked"
	desc = "Summons your marked target to your location, leaving a temporary portal behind. Requires the target to be marked for at least 10 minutes."
	chargedrain = 0
	chargetime = 1.5 SECONDS
	recharge_time = 30 SECONDS
	invocation_type = "whisper"
	invocations = list("I invoke the dream connection, come to me!")
	movement_interrupt = FALSE
	charging_slowdown = 1
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "dream_summon"

/obj/effect/proc_holder/spell/invoked/summon_marked/cast(list/targets, mob/user)
	var/datum/component/dreamwalker_mark/mark_component = user.GetComponent(/datum/component/dreamwalker_mark)
	if(!mark_component || !mark_component.marked_target)
		to_chat(user, span_warning("You have no target marked for summoning!"))
		revert_cast()
		return

	// Check if we can summon (10 minutes have passed)
	if(!mark_component.can_summon())
		revert_cast()
		return

	var/mob/living/target = mark_component.marked_target

	if(!target.has_status_effect(/datum/status_effect/dream_mark))
		to_chat(user, span_warning("Your connection with [target] has faded!"))
		revert_cast()
		return

	if(target.stat == DEAD)
		to_chat(user, span_warning("[target] is dead and cannot be summoned!"))
		revert_cast()
		return

	to_chat(target, span_userdanger("YOU CAN FEEL THE DREAMWALKER BEGIN TO SUMMON YOU BY FORCE."))
	if(!do_after(user, 20 SECONDS, FALSE, user))
		to_chat(user, span_warning("You must stand still to summon your target!"))
		// Counts as a finished spellcast to make it impossible to spam your target with messages...
		return TRUE

	var/turf/original_turf = get_turf(target)
	var/turf/destination = get_turf(user)

	if(!original_turf || !destination)
		revert_cast()
		return

	// Create portal at target's original location
	var/obj/structure/portal_jaunt/portal = new(original_turf)
	portal.linked_turf = destination

	// Teleport target
	if(do_teleport(target, destination))
		to_chat(user, span_warning("You summon [target] to your location!"))
		to_chat(target, span_userdanger("You're violently pulled through the dream realm to [user]'s location!"))
		// Reset mark after teleport.
		target.remove_status_effect(/datum/status_effect/dream_mark)
		mark_component.marked_target = null
		return TRUE

	qdel(portal)
	revert_cast()
	return FALSE


/obj/effect/proc_holder/spell/invoked/dream_bind
	name = "Dream Bind"
	desc = "Bind a dream item to your soul, allowing you to summon it at will. Cast on a dream item to bind it, or cast on anything else to summon your bound item."
	chargedrain = 0
	chargetime = 0.5 SECONDS
	recharge_time = 10 SECONDS
	invocation_type = "whisper"
	invocations = list("From dream to hand...")
	movement_interrupt = FALSE
	charging_slowdown = 0
	associated_skill = /datum/skill/magic/arcane
	var/obj/item/bound_item = null
	overlay_state = "dream_bind"

/obj/effect/proc_holder/spell/invoked/dream_bind/cast(list/targets, mob/user)
	var/atom/target = targets[1]

	// If targeting a dream item, bind it
	if(istype(target, /obj/item))
		var/obj/item/dream_item = target
		if(dream_item.item_flags & DREAM_ITEM)
			bound_item = dream_item
			to_chat(user, span_notice("You bind [bound_item] to your soul. You can now summon it at will."))
			return TRUE

	// If not targeting a dream item, try to summon the bound item
	if(!bound_item)
		to_chat(user, span_warning("You don't have any dream item bound!"))
		revert_cast()
		return

	if(bound_item.loc == user) // Already in inventory
		to_chat(user, span_notice("[bound_item] is already in your possession."))
		return

	// Check if the item still exists
	if(QDELETED(bound_item))
		to_chat(user, span_warning("Your bound item has been destroyed!"))
		bound_item = null
		revert_cast()
		return

	// Summon the item to the user's hand
	bound_item.forceMove(get_turf(user))
	user.put_in_hands(bound_item)
	to_chat(user, span_notice("You summon [bound_item] to your hand."))
	return TRUE

//Dream meditation
/obj/effect/proc_holder/spell/invoked/dream_trance
	name = "Dream Trance"
	desc = "Draw dream energy into your being to banish any fatigue."
	chargedrain = 0
	chargetime = 0
	recharge_time = 10 SECONDS
	invocation_type = "whisper"
	invocations = list("Humm...")
	movement_interrupt = TRUE
	charging_slowdown = 0
	associated_skill = /datum/skill/magic/arcane
	overlay_state = "dream_lotus"

/obj/effect/proc_holder/spell/invoked/dream_trance/cast(list/targets, mob/user)
	var/mob/living/carbon/human/H = user

	to_chat(user, span_info("I begin meditating."))
	while(TRUE)
		if(do_after(H, 15 SECONDS, FALSE, H))
			H.energy_add(0.2 * H.max_energy)
			H.apply_status_effect(/datum/status_effect/buff/healing, 5)
		else
			to_chat(user, span_info("I must remain still to focus energies and recover."))
			break

/obj/effect/proc_holder/spell/self/wake_from_dream
	name = "Wake from the Dream"
	desc = "Return to your old life. You cannot take up the Dreamwalker mantle again this round."

/obj/effect/proc_holder/spell/self/wake_from_dream/cast(list/targets, mob/living/user)
	var/datum/antagonist/dreamwalker/dreamwalker = user.mind?.has_antag_datum(/datum/antagonist/dreamwalker)
	if(!istype(dreamwalker) || !dreamwalker.forged_empowered_weapon || dreamwalker.has_awakened)
		revert_cast(user)
		return FALSE
	if(user != dreamwalker.dream_body || user.doing || !isturf(user.loc))
		to_chat(user, span_warning("I must be in my own body and finish what I am doing before I can wake."))
		revert_cast(user)
		return FALSE
	// The spell removes itself after the cast finishes.
	addtimer(CALLBACK(dreamwalker, TYPE_PROC_REF(/datum/antagonist/dreamwalker, wake_from_dream), user), 0)
	return TRUE
