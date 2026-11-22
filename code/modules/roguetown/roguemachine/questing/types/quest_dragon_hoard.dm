GLOBAL_VAR_INIT(dragon_hoard_completed, FALSE)

/obj/effect/landmark/dragon_cave_entrance
	name = "dragon cave entrance"

/datum/antagonist/dragon
	var/datum/weakref/hoard_quest_ref
	var/list/turf/hoard_entrances
	COOLDOWN_DECLARE(hoard_entrance_alert)

/datum/antagonist/dragon/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/dragon = mob_override || owner?.current
	if(istype(dragon))
		RegisterSignal(dragon, COMSIG_MOB_DEATH, PROC_REF(on_hoard_dragon_death))
	if(length(hoard_entrances))
		return
	for(var/obj/effect/landmark/dragon_cave_entrance/entrance in GLOB.landmarks_list)
		var/turf/threshold = get_turf(entrance)
		if(!threshold || hoard_entrances?[threshold])
			continue
		LAZYSET(hoard_entrances, threshold, entrance.dir)
		RegisterSignal(threshold, COMSIG_ATOM_ENTERED, PROC_REF(on_hoard_entrance_crossed))

/datum/antagonist/dragon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/dragon = mob_override || owner?.current
	if(istype(dragon))
		UnregisterSignal(dragon, COMSIG_MOB_DEATH)
	for(var/turf/threshold as anything in hoard_entrances)
		UnregisterSignal(threshold, COMSIG_ATOM_ENTERED)
	hoard_entrances = null
	return ..()

/datum/antagonist/dragon/proc/is_inbound_hoard_entry(turf/threshold, turf/old_turf)
	if(!isturf(old_turf) || !isturf(threshold))
		return FALSE
	if(abs(old_turf.x - threshold.x) > 1 || abs(old_turf.y - threshold.y) > 1 || abs(old_turf.z - threshold.z) > 1)
		return FALSE
	return (get_dir(old_turf, threshold) & hoard_entrances?[threshold]) != 0

/datum/antagonist/dragon/proc/on_hoard_entrance_crossed(turf/threshold, atom/movable/entrant, atom/old_location)
	SIGNAL_HANDLER
	if(!is_inbound_hoard_entry(threshold, old_location))
		return
	var/mob/living/visitor = entrant
	var/mob/living/dragon = owner?.current
	if(!istype(visitor) || !visitor.client || visitor.stat == DEAD || visitor == dragon)
		return
	if(!istype(dragon) || !dragon.client || dragon.stat == DEAD || !COOLDOWN_FINISHED(src, hoard_entrance_alert))
		return
	COOLDOWN_START(src, hoard_entrance_alert, 60 SECONDS)
	to_chat(dragon, span_notice("You sense someone entering your lair."))

/datum/antagonist/dragon/proc/on_hoard_dragon_death(mob/living/dragon)
	SIGNAL_HANDLER
	withdraw_hoard_quest()

/datum/antagonist/dragon/proc/withdraw_hoard_quest(rescinded_by_dragon = FALSE, notice)
	var/datum/quest/retrieval/dragon_hoard/Q = hoard_quest_ref?.resolve()
	if(QDELETED(Q) || Q.complete)
		return FALSE
	hoard_quest_ref = null
	if(Q in SSquestpool.pool)
		SSquestpool.pool -= Q
		SSquestpool.adjust_region_count(Q, -1)
	var/obj/item/quest_writ/writ = Q.quest_scroll_ref?.resolve()
	var/mob/living/holder = get_atom_on_turf(writ, /mob/living)
	if(!istype(holder))
		holder = Q.quest_receiver_reference?.resolve()
	if(istype(holder))
		notice ||= rescinded_by_dragon ? "The dragon's hoard writ went up in flames!" : "The dragon's hoard challenge has been withdrawn. Your writ is void."
		to_chat(holder, span_notice(notice))
	qdel(Q)
	return TRUE

/datum/antagonist/dragon/proc/post_hoard_quest()
	var/mob/living/dragon = owner?.current
	if(GLOB.dragon_hoard_completed || hoard_quest_ref?.resolve() || !istype(dragon) || QDELETED(dragon) || dragon.stat == DEAD || owner.has_antag_datum(/datum/antagonist/dragon) != src)
		return FALSE
	// Both Neuhill and Smollhill keep this marker in the cave after round start.
	var/obj/effect/landmark/start/dragonlate/lair = locate() in GLOB.start_landmarks_list
	var/turf/lair_turf = get_turf(lair)
	if(!istype(lair_turf, /turf/open/floor))
		return FALSE
	var/datum/quest/retrieval/dragon_hoard/Q = new
	if(!Q.setup(owner, lair_turf))
		qdel(Q)
		return FALSE
	hoard_quest_ref = WEAKREF(Q)
	SSquestpool.pool += Q
	SSquestpool.adjust_region_count(Q, 1)
	record_round_statistic(STATS_CONTRACTS_GENERATED)
	record_round_statistic(STATS_CONTRACTS_GENERATED_POOL)
	SSquestpool.log_event("generate", "Dragon hoard contract posted at [AREACOORD(lair_turf)]")
	var/message = "A dragon's hoard quest has been posted!"
	for(var/obj/structure/roguemachine/contractledger/ledger as anything in SSquestpool.registered_ledgers)
		if(!QDELETED(ledger))
			ledger.visible_message(span_notice(message))
	for(var/mob/living/official in GLOB.player_list)
		if(official.client && official.stat != DEAD && (official.job == "Steward" || official.job == "Clerk"))
			to_chat(official, span_notice(message))
	return TRUE

/datum/quest/retrieval/dragon_hoard
	title = "Recover a gem from the dragon's hoard"
	quest_difficulty = QUEST_DIFFICULTY_NOTORIOUS
	required_fellowship_size = 2
	requires_spawn_landmark = FALSE
	reward_amount = 200
	fetch_items = list(/obj/item/roguegem/ruby, /obj/item/roguegem/diamond, /obj/item/roguegem/violet)
	var/datum/weakref/dragon_mind_ref
	var/datum/weakref/hoard_item_ref

/datum/quest/retrieval/dragon_hoard/proc/setup(datum/mind/dragon_mind, turf/lair_turf)
	if(!istype(dragon_mind) || !istype(lair_turf, /turf/open/floor) || hoard_item_ref)
		return FALSE
	dragon_mind_ref = WEAKREF(dragon_mind)
	source = QUEST_SOURCE_POOL
	created_at = world.time
	issued_day = GLOB.dayspassed
	deposit_amount = calculate_deposit()
	target_spawn_area = "Dragon's Lair"
	var/area/lair_area = get_area(lair_turf)
	region = lair_area.threat_region
	circumstance_text = "Rumour tells of a prized gem guarded in a dragon's cave. Seek a bargain or find another way to recover it."
	target_item_type = pick(fetch_items)
	var/obj/item/treasure = new target_item_type(lair_turf)
	hoard_item_ref = WEAKREF(treasure)
	add_tracked_atom(treasure)
	RegisterSignal(treasure, COMSIG_QDELETING, PROC_REF(on_hoard_gem_deleted))
	treasure.AddComponent(/datum/component/quest_object/retrieval/dragon_hoard, src)
	return TRUE

/datum/quest/retrieval/dragon_hoard/proc/on_hoard_gem_deleted()
	SIGNAL_HANDLER
	// A successful delivery marks the quest complete before consuming the gem.
	if(!materialized || complete || QDELETED(src))
		return
	var/datum/mind/dragon_mind = dragon_mind_ref?.resolve()
	var/datum/antagonist/dragon/dragon = dragon_mind?.has_antag_datum(/datum/antagonist/dragon)
	if(dragon?.hoard_quest_ref?.resolve() == src)
		dragon.withdraw_hoard_quest(notice = "The marked hoard gem was destroyed. Your writ is void.")

/datum/quest/retrieval/dragon_hoard/proc/target_available()
	var/obj/item/treasure = hoard_item_ref?.resolve()
	return istype(treasure) && !QDELETED(treasure)

/datum/quest/retrieval/dragon_hoard/proc/dragon_available()
	var/datum/mind/dragon_mind = dragon_mind_ref?.resolve()
	var/mob/living/dragon = dragon_mind?.current
	return istype(dragon) && !QDELETED(dragon) && dragon.stat != DEAD && dragon_mind.has_antag_datum(/datum/antagonist/dragon)

/datum/quest/retrieval/dragon_hoard/get_lapse_time()
	if(!target_available() || !dragon_available())
		return -1
	return INFINITY

/datum/quest/retrieval/dragon_hoard/calculate_deposit()
	return 0

/datum/quest/retrieval/dragon_hoard/mark_complete()
	GLOB.dragon_hoard_completed = TRUE
	return ..()

/datum/quest/retrieval/dragon_hoard/can_claim(mob/living/user)
	if(!istype(user) || !target_available() || !dragon_available() || complete)
		return FALSE
	if(user.mind == dragon_mind_ref.resolve())
		return FALSE
	return ..()

/datum/quest/retrieval/dragon_hoard/claim_failure_reason(mob/living/user)
	if(!istype(user))
		return "You cannot sign that contract."
	if(!target_available() || !dragon_available() || complete)
		return "This hoard contract is no longer available."
	if(istype(user) && user.mind == dragon_mind_ref?.resolve())
		return "You cannot sign a contract for your own hoard."
	return ..()

/datum/quest/retrieval/dragon_hoard/materialize(obj/effect/landmark/quest_spawner/landmark)
	// The gem was placed when the contract was posted. Signing never creates another.
	return target_available() && dragon_available()

/datum/quest/retrieval/dragon_hoard/on_claim(mob/user)
	..()
	var/datum/mind/dragon_mind = dragon_mind_ref?.resolve()
	var/mob/dragon = dragon_mind?.current
	if(istype(dragon) && dragon.client)
		to_chat(dragon, span_notice("Word reaches you that a fellowship has accepted a contract for a gem from your hoard. Visitors may be coming."))

/datum/quest/retrieval/dragon_hoard/get_objective_text()
	return "Recover the marked [initial(target_item_type.name)] from the dragon's cave and deliver it to a quest ledger. Negotiate with the Dragon or find another way to obtain it."

/datum/component/quest_object/retrieval/dragon_hoard/on_item_dropped(obj/item/dropped_item, mob/user)
	var/datum/quest/retrieval/dragon_hoard/Q = quest_ref.resolve()
	if(!istype(Q) || !Q.materialized || Q.hoard_item_ref?.resolve() != dropped_item)
		return
	return ..()
