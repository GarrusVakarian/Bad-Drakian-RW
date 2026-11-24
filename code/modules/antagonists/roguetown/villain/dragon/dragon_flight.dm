#define DRAGON_FLIGHT_GROUNDED 0
#define DRAGON_FLIGHT_TAKING_OFF 1
#define DRAGON_FLIGHT_FLYING 2
#define DRAGON_FLIGHT_ASCENDING 3
#define DRAGON_FLIGHT_DESCENDING 4
#define DRAGON_FLIGHT_LANDING 5

#define DRAGON_FLIGHT_TAKEOFF_TIME 3 SECONDS
#define DRAGON_FLIGHT_TAKEOFF_COST 10
#define DRAGON_FLIGHT_STAMINA_COST 2
#define DRAGON_FLIGHT_ASCENT_TIME 1.5 SECONDS
#define DRAGON_FLIGHT_ASCENT_BASE_COST 10
#define DRAGON_FLIGHT_DESCENT_TIME 0.75 SECONDS
#define DRAGON_FLIGHT_PASSENGER_MULTIPLIER 2
#define DRAGON_FLIGHT_FATIGUE_WARNING 0.75

/obj/effect/proc_holder/spell/self/dragon_flight
	name = "Dragon Flight"
	desc = "Take flight into the skies and soar like a dragon! (Page Up to fly up - Page Down to fly down)"
	overlay_state = "zad"
	releasedrain = 0
	chargetime = 0
	recharge_time = 0.5 SECONDS
	associated_skill = null
	human_req = TRUE
	antimagic_allowed = TRUE
	ignore_cockblock = TRUE
	ignores_combat_action_restrictions = TRUE

/obj/effect/proc_holder/spell/self/dragon_flight/cast(mob/living/carbon/human/user)
	var/datum/status_effect/debuff/dragon_flight/flight = user.has_status_effect(/datum/status_effect/debuff/dragon_flight)
	if(flight)
		flight.land()
		return TRUE
	flight = user.apply_status_effect(/datum/status_effect/debuff/dragon_flight)
	if(QDELETED(flight))
		return FALSE
	return flight.start_takeoff()

/datum/status_effect/debuff/dragon_flight
	id = "dragon_flight"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/dragon_flight
	tick_interval = 1 SECONDS

	var/state = DRAGON_FLIGHT_GROUNDED
	var/flight_generation = 0
	var/mob/living/carbon/human/dragon
	var/mob/living/passenger
	var/moving_passenger = FALSE
	var/passenger_had_flying_movement = FALSE
	var/was_flying = FALSE
	var/had_flying_movement = FALSE
	var/initial_pixel_y
	var/shown_fatigue_warning = FALSE
	var/obj/effect/flyer_shadow/shadow
	var/datum/looping_sound/takeoff_sound

/datum/status_effect/debuff/dragon_flight/on_apply()
	dragon = owner
	if(dragon.dna?.species?.id != "dragon" || length(dragon.buckled_mobs))
		return FALSE
	RegisterSignal(dragon, COMSIG_MOB_CHECK_COMBAT_ACTION, PROC_REF(on_combat_action))
	RegisterSignal(dragon, COMSIG_MOB_FLIGHT_MOVE, PROC_REF(on_flight_move))
	RegisterSignal(dragon, COMSIG_MOVABLE_MOVED, PROC_REF(update_shadow))
	RegisterSignal(dragon, COMSIG_MOVABLE_PREBUCKLE, PROC_REF(on_prebuckle))
	RegisterSignal(dragon, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/can_take_off(show_message = TRUE)
	if(dragon.dna?.species?.id != "dragon")
		return FALSE
	if(!isturf(dragon.loc) || !can_stay_airborne() || dragon.restrained(ignore_grab = FALSE))
		if(show_message)
			to_chat(dragon, span_warning("I need to be upright, unrestrained, and free of another's grip to take flight."))
		return FALSE
	if(length(dragon.buckled_mobs) || (dragon.pulling && !isliving(dragon.pulling)))
		if(show_message)
			to_chat(dragon, span_warning("I can only take flight carrying one person in my grasp, without a mounted rider."))
		return FALSE
	if(isliving(dragon.pulling))
		var/mob/living/carried_mob = dragon.pulling
		if(carried_mob.buckled || carried_mob == dragon || !dragon.Adjacent(carried_mob))
			return FALSE
	var/first_tick_cost = DRAGON_FLIGHT_STAMINA_COST
	if(dragon.pulling)
		first_tick_cost *= DRAGON_FLIGHT_PASSENGER_MULTIPLIER
	if(dragon.stamina + DRAGON_FLIGHT_TAKEOFF_COST + first_tick_cost >= dragon.max_stamina)
		if(show_message)
			to_chat(dragon, span_warning("I need to recover before taking flight."))
		return FALSE
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/start_takeoff()
	if(state != DRAGON_FLIGHT_GROUNDED)
		return FALSE
	if(!can_take_off())
		land()
		return FALSE
	dragon.stop_attack()
	state = DRAGON_FLIGHT_TAKING_OFF
	flight_generation++
	var/generation = flight_generation
	dragon.visible_message(span_notice("[dragon] spreads their wings and prepares to take flight."))
	takeoff_sound = new /datum/looping_sound/dragon_takeoff(dragon, TRUE)
	var/prepared = move_after(dragon, DRAGON_FLIGHT_TAKEOFF_TIME, target = dragon)
	if(QDELETED(src) || QDELETED(dragon) || generation != flight_generation)
		return FALSE
	if(!prepared || !can_take_off())
		land()
		return FALSE
	dragon.stamina_add(DRAGON_FLIGHT_TAKEOFF_COST)
	return start_flying()

/datum/status_effect/debuff/dragon_flight/proc/start_flying()
	QDEL_NULL(takeoff_sound)
	was_flying = dragon.flying
	had_flying_movement = !!(dragon.movement_type & FLYING)
	initial_pixel_y = dragon.pixel_y
	state = DRAGON_FLIGHT_FLYING
	tick_interval = world.time + initial(tick_interval)
	dragon.flying = TRUE
	dragon.movement_type |= FLYING
	dragon.remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)
	if(isliving(dragon.pulling) && !attach_passenger(dragon.pulling))
		land()
		return FALSE
	animate(dragon, pixel_y = initial_pixel_y + 3, time = 6, loop = -1)
	animate(pixel_y = initial_pixel_y - 3, time = 6)
	playsound(dragon, 'sound/foley/footsteps/flight_sounds/dragon_launch.ogg', 50, TRUE)
	dragon.apply_status_effect(/datum/status_effect/debuff/flight_sound_loop)
	update_shadow()
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/can_stay_airborne()
	if(dragon.dna?.species?.id != "dragon" || dragon.stat != CONSCIOUS)
		return FALSE
	if(!(dragon.mobility_flags & MOBILITY_STAND) || dragon.buckled || dragon.pulledby)
		return FALSE
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/is_airborne()
	return state == DRAGON_FLIGHT_FLYING || state == DRAGON_FLIGHT_ASCENDING || state == DRAGON_FLIGHT_DESCENDING

/datum/status_effect/debuff/dragon_flight/tick()
	if(!is_airborne())
		return
	if(!can_stay_airborne())
		land()
		return
	if(passenger && (QDELETED(passenger) || passenger.buckled != dragon || dragon.pulling != passenger))
		release_passenger()
	var/cost = DRAGON_FLIGHT_STAMINA_COST
	if(passenger)
		cost *= DRAGON_FLIGHT_PASSENGER_MULTIPLIER
	dragon.stamina_add(cost)
	if(!shown_fatigue_warning && dragon.stamina >= dragon.max_stamina * DRAGON_FLIGHT_FATIGUE_WARNING)
		shown_fatigue_warning = TRUE
		to_chat(dragon, span_warning("My wings are tiring. I should find somewhere to land!"))
	if(dragon.stamina >= dragon.max_stamina)
		to_chat(dragon, span_warning("My wings can no longer hold me aloft!"))
		land()

/datum/status_effect/debuff/dragon_flight/proc/change_altitude(direction)
	if(state != DRAGON_FLIGHT_FLYING || (direction != UP && direction != DOWN))
		return FALSE
	var/turf/destination = get_step_multiz(dragon, direction)
	if(!dragon.canZMove(direction, destination))
		to_chat(dragon, span_warning("There is no clear passage in that direction."))
		return FALSE
	var/cost = 0
	var/travel_time = DRAGON_FLIGHT_DESCENT_TIME
	if(direction == UP)
		cost = max(DRAGON_FLIGHT_ASCENT_BASE_COST - dragon.get_skill_level(/datum/skill/misc/athletics), 1)
		travel_time = DRAGON_FLIGHT_ASCENT_TIME
	var/mob/living/carried_mob = passenger
	if(carried_mob)
		cost *= DRAGON_FLIGHT_PASSENGER_MULTIPLIER
		travel_time *= DRAGON_FLIGHT_PASSENGER_MULTIPLIER
	if(cost && dragon.stamina + cost >= dragon.max_stamina)
		to_chat(dragon, span_warning("I am too tired to climb higher."))
		return FALSE
	if(direction == UP)
		state = DRAGON_FLIGHT_ASCENDING
	else
		state = DRAGON_FLIGHT_DESCENDING
	flight_generation++
	var/generation = flight_generation
	dragon.stop_attack()
	var/prepared = do_after(dragon, travel_time, target = dragon)
	if(QDELETED(src) || QDELETED(dragon) || generation != flight_generation)
		return FALSE
	state = DRAGON_FLIGHT_FLYING
	destination = get_step_multiz(dragon, direction)
	if(!prepared || passenger != carried_mob || !can_stay_airborne() || !dragon.canZMove(direction, destination))
		return FALSE
	if(cost && dragon.stamina + cost >= dragon.max_stamina)
		return FALSE
	moving_passenger = TRUE
	dragon.forceMove(destination)
	if(carried_mob && !QDELETED(carried_mob))
		carried_mob.forceMove(destination)
	moving_passenger = FALSE
	if(cost)
		dragon.stamina_add(cost)
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/attach_passenger(mob/living/new_passenger)
	passenger = new_passenger
	passenger_had_flying_movement = !!(new_passenger.movement_type & FLYING)
	new_passenger.movement_type |= FLYING
	var/previous_grab_state = dragon.grab_state
	moving_passenger = TRUE
	var/attached = dragon.buckle_mob(new_passenger, TRUE, FALSE)
	if(attached && dragon.pulling != new_passenger)
		dragon.start_pulling(new_passenger, previous_grab_state, supress_message = TRUE)
	moving_passenger = FALSE
	return attached && dragon.pulling == new_passenger

/datum/status_effect/debuff/dragon_flight/proc/release_passenger()
	var/mob/living/released_passenger = passenger
	passenger = null
	if(QDELETED(released_passenger))
		return
	if(released_passenger.buckled == dragon)
		dragon.unbuckle_mob(released_passenger, TRUE)
	if(dragon.pulling == released_passenger)
		dragon.stop_pulling()
	if(!passenger_had_flying_movement)
		released_passenger.movement_type &= ~FLYING
	var/turf/below = get_turf(released_passenger)
	below?.zFall(released_passenger)

/datum/status_effect/debuff/dragon_flight/proc/cancel_preparation()
	if(state == DRAGON_FLIGHT_TAKING_OFF)
		to_chat(dragon, span_warning("I abandon my takeoff to act."))
		land()
	else if(state == DRAGON_FLIGHT_ASCENDING || state == DRAGON_FLIGHT_DESCENDING)
		flight_generation++
		to_chat(dragon, span_warning("I abandon my change in altitude to act."))
		state = DRAGON_FLIGHT_FLYING

/datum/status_effect/debuff/dragon_flight/proc/can_attack_or_cast(atom/target)
	if(state == DRAGON_FLIGHT_TAKING_OFF || state == DRAGON_FLIGHT_ASCENDING || state == DRAGON_FLIGHT_DESCENDING)
		cancel_preparation()
		return FALSE
	if(passenger)
		to_chat(dragon, span_warning("I cannot attack or cast while carrying someone in flight."))
		return FALSE
	var/turf/target_turf = get_turf(target)
	if(target_turf && target_turf.z != dragon.z)
		to_chat(dragon, span_warning("I cannot strike someone on another level."))
		return FALSE
	return TRUE

/datum/status_effect/debuff/dragon_flight/proc/land()
	if(state == DRAGON_FLIGHT_LANDING || !dragon)
		return
	var/was_airborne = is_airborne()
	state = DRAGON_FLIGHT_LANDING
	flight_generation++
	UnregisterSignal(dragon, list(COMSIG_MOB_CHECK_COMBAT_ACTION, COMSIG_MOB_FLIGHT_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_PREBUCKLE, COMSIG_MOVABLE_UNBUCKLE))
	QDEL_NULL(shadow)
	QDEL_NULL(takeoff_sound)
	if(was_airborne)
		dragon.remove_status_effect(/datum/status_effect/debuff/flight_sound_loop)
		if(!had_flying_movement)
			dragon.movement_type &= ~FLYING
		dragon.flying = was_flying
		animate(dragon)
		dragon.pixel_y = initial_pixel_y
		// The passenger remains protected until the carrier's fall finishes.
		var/turf/below = get_turf(dragon)
		below?.zFall(dragon)
		if(passenger && !QDELETED(passenger) && passenger.buckled == dragon && isturf(dragon.loc))
			passenger.forceMove(dragon.loc)
		release_passenger()
		if(isopenturf(dragon.loc))
			dragon.update_turf_movespeed(dragon.loc)
	dragon.remove_status_effect(type)
	state = DRAGON_FLIGHT_GROUNDED

/datum/status_effect/debuff/dragon_flight/on_remove()
	land()
	return ..()

/datum/status_effect/debuff/dragon_flight/proc/on_combat_action(datum/source, atom/target)
	SIGNAL_HANDLER
	if(!can_attack_or_cast(target))
		return COMPONENT_BLOCK_COMBAT_ACTION
	return NONE

/datum/status_effect/debuff/dragon_flight/proc/on_flight_move(datum/source, direction)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(change_altitude), direction)
	return COMPONENT_HANDLED_FLIGHT_MOVE

/datum/status_effect/debuff/dragon_flight/proc/on_prebuckle(datum/source, mob/living/rider, force)
	SIGNAL_HANDLER
	if(moving_passenger && rider == passenger)
		return NONE
	return COMPONENT_BLOCK_BUCKLE

/datum/status_effect/debuff/dragon_flight/proc/on_unbuckle(datum/source, mob/living/rider, force)
	SIGNAL_HANDLER
	if(rider == passenger && state != DRAGON_FLIGHT_LANDING && !moving_passenger)
		release_passenger()

/datum/status_effect/debuff/dragon_flight/proc/update_shadow()
	SIGNAL_HANDLER
	if(!is_airborne())
		return
	var/turf/below = get_turf(dragon)
	if(!below)
		return
	while(isopenspace(below))
		var/turf/next = GET_TURF_BELOW(below)
		if(!next || isclosedturf(next))
			break
		below = next
	if(!shadow)
		shadow = new /obj/effect/flyer_shadow(below, dragon)
		shadow.name = "dragon shadow"
		shadow.transform = matrix() * 1.5
	shadow.forceMove(below)

/mob/living/carbon/human/start_pulling(atom/movable/target, state, force = pull_force, supress_message = FALSE, obj/item/item_override)
	var/datum/status_effect/debuff/dragon_flight/flight = has_status_effect(/datum/status_effect/debuff/dragon_flight)
	if(flight && flying && target != flight.passenger)
		to_chat(src, span_warning("I must land before picking up someone else."))
		return FALSE
	return ..()

/mob/living/carbon/human/stop_pulling(forced = TRUE)
	. = ..()
	var/datum/status_effect/debuff/dragon_flight/flight = has_status_effect(/datum/status_effect/debuff/dragon_flight)
	if(flight && !flight.moving_passenger && flight.state != DRAGON_FLIGHT_LANDING && flight.passenger && pulling != flight.passenger)
		flight.release_passenger()

/atom/movable/screen/alert/status_effect/debuff/dragon_flight
	name = "Death from above!!"
	desc = "You are flying, casting a huge shadow beneath you!"
	icon_state = "muscles"

/datum/looping_sound/dragon_takeoff
	mid_sounds = list('sound/foley/footsteps/flight_sounds/dragon_takeoff.ogg')
	mid_length = 5 SECONDS
	max_loops = 1
	repeat_sound = FALSE
	volume = 100
	vary = TRUE
	extra_range = 9

#undef DRAGON_FLIGHT_GROUNDED
#undef DRAGON_FLIGHT_TAKING_OFF
#undef DRAGON_FLIGHT_FLYING
#undef DRAGON_FLIGHT_ASCENDING
#undef DRAGON_FLIGHT_DESCENDING
#undef DRAGON_FLIGHT_LANDING
#undef DRAGON_FLIGHT_TAKEOFF_TIME
#undef DRAGON_FLIGHT_TAKEOFF_COST
#undef DRAGON_FLIGHT_STAMINA_COST
#undef DRAGON_FLIGHT_ASCENT_TIME
#undef DRAGON_FLIGHT_ASCENT_BASE_COST
#undef DRAGON_FLIGHT_DESCENT_TIME
#undef DRAGON_FLIGHT_PASSENGER_MULTIPLIER
#undef DRAGON_FLIGHT_FATIGUE_WARNING
