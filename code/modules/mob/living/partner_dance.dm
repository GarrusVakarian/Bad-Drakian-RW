// Adapted from Ochre Valley's Dancing! PR (#542).
#define DANCE_TOTAL_TIME (2 SECONDS)
#define DANCE_CLOSER_DISTANCE 8
#define DANCE_HIDDEN_ALPHA 1

/mob/living
	var/datum/partner_dance/active_partner_dance

/// Handles only right-clicks on the person whose hand we are passively holding.
/mob/living/proc/try_partner_dance(atom/target)
	if(!iscarbon(src) || !iscarbon(target) || target == src || cmode)
		return FALSE
	var/mob/living/carbon/leader = src
	var/mob/living/carbon/partner = target
	var/obj/item/grabbing/grip = leader.get_active_held_item()
	if(!istype(grip) || QDELETED(grip) || grip.grabbee != leader || grip.grabbed != partner)
		return FALSE
	if(grip.sublimb_grabbed != BODY_ZONE_PRECISE_L_HAND && grip.sublimb_grabbed != BODY_ZONE_PRECISE_R_HAND)
		return FALSE
	if(grip.grab_state != GRAB_PASSIVE || leader.grab_state != GRAB_PASSIVE || leader.pulling != partner || !(grip in partner.grabbedby))
		return FALSE

	if(leader.active_partner_dance || partner.active_partner_dance)
		return TRUE
	if(partner.cmode || !leader.can_partner_dance() || !partner.can_partner_dance())
		to_chat(leader, span_warning("I can't dance with [partner] right now."))
		return TRUE
	if(!leader.Adjacent(partner) || get_dist(leader, partner) != 1 || !(get_dir(leader, partner) in GLOB.cardinals))
		to_chat(leader, span_warning("I need to stand directly beside [partner] to dance."))
		return TRUE
	// A dance must not drag, release, or move a third party's pull.
	if(partner.pulledby != leader || (leader.pulledby && leader.pulledby != partner) || (partner.pulling && partner.pulling != leader))
		return TRUE

	leader.changeNext_move(CLICK_CD_RAPID)
	var/datum/partner_dance/dance = new()
	if(!dance.start(leader, partner, grip, !!(leader.active_hand_index % 2)))
		qdel(dance)
		to_chat(leader, span_warning("There's no room to dance with [partner] here."))
	return TRUE

/mob/living/proc/can_partner_dance()
	return !QDELETED(src) && isturf(loc) && !incapacitated() && !anchored && !buckled && !has_buckled_mobs() && !throwing && !moving_from_pull && !wallpressed && (mobility_flags & MOBILITY_STAND) && (mobility_flags & MOBILITY_MOVE)

/// Owns both participants and all temporary visuals for a single swap.
/datum/partner_dance
	var/mob/living/carbon/leader
	var/mob/living/carbon/partner
	var/obj/item/grabbing/grip
	var/swapping = FALSE
	var/list/visuals
	var/list/original_alpha
	var/end_timer
	var/static/list/interrupt_signals = list(
		COMSIG_MOVABLE_MOVED, COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_QDELETING,
		COMSIG_MOB_COMBAT_MODE_ENABLED, COMSIG_MOB_ITEM_BEING_ATTACKED, COMSIG_MOB_ATTACKED_BY_HAND,
		COMSIG_ATOM_ATTACK_ANIMAL, COMSIG_ATOM_BULLET_ACT,
		COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_UNCONSCIOUS,
	)

/datum/partner_dance/proc/start(mob/living/carbon/lead, mob/living/carbon/follow, obj/item/grabbing/handhold, ccw)
	leader = lead
	partner = follow
	grip = handhold
	var/turf/lead_start = leader.loc
	var/turf/follow_start = partner.loc
	// Preflight both destinations without bumping blockers or ignoring anyone else on either tile.
	if(!can_enter(leader, lead_start, follow_start, partner) || !can_enter(partner, follow_start, lead_start, leader))
		return FALSE

	var/alist/offsets = alist(
		"src_base" = list(initial(leader.pixel_x), initial(leader.pixel_y)),
		"src_start" = list(leader.pixel_x, leader.pixel_y),
		"partner_base" = list(initial(partner.pixel_x), initial(partner.pixel_y)),
		"partner_start" = list(partner.pixel_x, partner.pixel_y),
	)
	leader.active_partner_dance = src
	partner.active_partner_dance = src
	swapping = TRUE
	var/did_swap = swap_places(lead_start, follow_start)
	if(!did_swap || QDELETED(grip) || !leader.can_partner_dance() || !partner.can_partner_dance() || !(grip in leader.held_items) || leader.pulling != partner)
		swapping = FALSE
		return FALSE

	leader.setDir(get_dir(leader, partner))
	partner.setDir(get_dir(partner, leader))
	swapping = FALSE
	offsets["src_end"] = list(leader.pixel_x, leader.pixel_y)
	offsets["partner_end"] = list(partner.pixel_x, partner.pixel_y)
	var/alist/animation_data = partner_dance_animation(offsets, ccw, get_dir(leader, partner))
	visuals = list()
	original_alpha = list()
	animate_dancer(leader, lead_start, animation_data["src_passes"])
	animate_dancer(partner, follow_start, animation_data["partner_passes"])

	for(var/mob/living/carbon/dancer in list(leader, partner))
		RegisterSignal(dancer, interrupt_signals, PROC_REF(interrupt))
	RegisterSignal(grip, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(interrupt))
	end_timer = addtimer(CALLBACK(src, PROC_REF(finish)), DANCE_TOTAL_TIME, TIMER_STOPPABLE)
	return TRUE

/datum/partner_dance/proc/can_enter(mob/living/carbon/dancer, turf/origin, turf/destination, mob/living/carbon/other_dancer)
	if(!origin.Exit(dancer, destination) || !destination.CanPass(dancer, destination))
		return FALSE
	for(var/atom/movable/blocker as anything in destination.contents)
		if(blocker != dancer && blocker != other_dancer && !blocker.CanPass(dancer, origin, TRUE))
			return FALSE
	return !QDELETED(dancer) && dancer.loc == origin

/datum/partner_dance/proc/swap_places(turf/lead_start, turf/follow_start)
	var/lead_dir = leader.dir
	var/follow_dir = partner.dir
	var/lead_movement = leader.animate_movement
	var/follow_movement = partner.animate_movement
	leader.animate_movement = NO_STEPS
	partner.animate_movement = NO_STEPS
	leader.moving_from_pull = partner
	partner.moving_from_pull = leader

	var/direction = get_dir(lead_start, follow_start)
	partner.Move(lead_start, turn(direction, 180))
	if(!QDELETED(partner) && partner.loc == lead_start && !QDELETED(leader) && leader.loc == lead_start)
		leader.Move(follow_start, direction)
	var/succeeded = !QDELETED(leader) && !QDELETED(partner) && leader.loc == follow_start && partner.loc == lead_start
	if(!succeeded)
		// Roll back only dancers still at their attempted destinations. A new blocker
		// or external movement still takes precedence.
		if(!QDELETED(leader) && leader.loc == follow_start)
			leader.Move(lead_start, turn(direction, 180))
		if(!QDELETED(partner) && partner.loc == lead_start)
			partner.Move(follow_start, direction)
		if(!QDELETED(leader) && leader.loc == lead_start)
			leader.setDir(lead_dir)
		if(!QDELETED(partner) && partner.loc == follow_start)
			partner.setDir(follow_dir)

	if(!QDELETED(leader))
		leader.moving_from_pull = null
		leader.animate_movement = lead_movement
		if(!QDELETED(partner) && leader.pulling == partner)
			leader.set_pull_offsets(partner, leader.grab_state)
	if(!QDELETED(partner))
		partner.moving_from_pull = null
		partner.animate_movement = follow_movement
		if(!QDELETED(leader) && partner.pulling == leader)
			partner.set_pull_offsets(leader, partner.grab_state)
	return succeeded

/datum/partner_dance/proc/animate_dancer(mob/living/carbon/dancer, turf/start, list/passes)
	var/obj/effect/partner_dance_visual/visual = new(start)
	visuals += visual
	visual.appearance = dancer.appearance
	visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/alist/start_pass = passes[1]
	visual.dir = start_pass["dir"]
	visual.layer = start_pass["layer"]
	visual.pixel_x = start_pass["x"]
	visual.pixel_y = start_pass["y"]
	original_alpha[dancer] = dancer.alpha
	// Keep existing zero-alpha stealth and avoid marking visible dancers as cloaked.
	dancer.alpha = min(dancer.alpha, DANCE_HIDDEN_ALPHA)

	var/step_time = DANCE_TOTAL_TIME / (length(passes) - 1)
	for(var/i in 2 to length(passes))
		var/alist/pass = passes[i]
		var/list/animate_args = list("dir" = pass["dir"], "pixel_x" = pass["x"], "pixel_y" = pass["y"])
		if(!isnull(pass["layer"]))
			animate_args["layer"] = pass["layer"]
		animate(visual, animate_args, time = step_time, flags = ANIMATION_CONTINUE)

/datum/partner_dance/proc/interrupt(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/partner_dance/proc/finish()
	end_timer = null
	qdel(src)

/datum/partner_dance/Destroy()
	if(end_timer)
		deltimer(end_timer)
	if(grip)
		UnregisterSignal(grip, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	for(var/mob/living/carbon/dancer in list(leader, partner))
		UnregisterSignal(dancer, interrupt_signals)
		if(dancer.active_partner_dance == src)
			dancer.active_partner_dance = null
		if((dancer in original_alpha) && dancer.alpha == min(original_alpha[dancer], DANCE_HIDDEN_ALPHA))
			dancer.alpha = original_alpha[dancer]
	QDEL_LIST(visuals)
	leader = null
	partner = null
	grip = null
	return ..()

/obj/effect/partner_dance_visual
	name = "dancer"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// Calculate the start, close-up, midpoint and end of Ochre's half-turn.
/proc/partner_dance_animation(
	// See input schema
	alist/pixel_offsets,
	// Counterclockwise?
	ccw = FALSE,
	// Direction after the swap
	dir_to_partner_after_swap
)
	RETURN_TYPE(/alist)
	// Reminder:
	// pixel_x: Negative is left/WEST, positive is right/EAST
	// pixel_y: Negative is down/SOUTH, positive is up/NORTH

	// Everything depends on the dir between us and them
	var/dir_to_partner_before_swap = turn(dir_to_partner_after_swap, 180)

	// Just used for easier to understand code
	var/full_step = world.icon_size
	var/half_step = world.icon_size / 2

	// Destructure our list
	var/src_base = pixel_offsets["src_base"]
	var/src_start = pixel_offsets["src_start"]
	var/src_end = pixel_offsets["src_end"]
	var/partner_base = pixel_offsets["partner_base"]
	var/partner_start = pixel_offsets["partner_start"]
	var/partner_end = pixel_offsets["partner_end"]

	var/list/src_passes = list()
	var/list/partner_passes = list()

	// Calculate passes
	// -----------------------------------------------------------------------------
	// START
	// -----------------------------------------------------------------------------
	var/src_start_layer = (dir_to_partner_before_swap & (NORTH | (ccw ? EAST : WEST))) ? ABOVE_ALL_MOB_LAYER : MOB_LAYER
	var/partner_start_layer = (dir_to_partner_before_swap & (SOUTH | (ccw ? WEST : EAST))) ? ABOVE_ALL_MOB_LAYER : MOB_LAYER
	UNTYPED_LIST_ADD(src_passes, alist(
		"x" = src_start[1],
		"y" = src_start[2],
		"dir" = dir_to_partner_before_swap,
		"layer" = src_start_layer,
	))
	UNTYPED_LIST_ADD(partner_passes, alist(
		"x" = partner_start[1],
		"y" = partner_start[2],
		"dir" = turn(dir_to_partner_before_swap, 180),
		"layer" = partner_start_layer,
	))

	// -----------------------------------------------------------------------------
	// CLOSEUP
	// -----------------------------------------------------------------------------
	var/src_closeup_dx = (dir_to_partner_before_swap & (NORTH|SOUTH)) \
		? 0 \
		: ((dir_to_partner_before_swap & EAST) ? 1 : -1) * DANCE_CLOSER_DISTANCE
	var/src_closeup_dy = (dir_to_partner_before_swap & (EAST|WEST)) \
		? 0 \
		: ((dir_to_partner_before_swap & NORTH) ? 1 : -1) * DANCE_CLOSER_DISTANCE
	var/partner_closeup_dx = -src_closeup_dx
	var/partner_closeup_dy = -src_closeup_dy

	UNTYPED_LIST_ADD(src_passes, alist(
		"x" = src_base[1] + src_closeup_dx,
		"y" = src_base[2] + src_closeup_dy,
		"dir" = dir_to_partner_before_swap,
		"layer" = null,
	))
	UNTYPED_LIST_ADD(partner_passes, alist(
		"x" = partner_base[1] + partner_closeup_dx,
		"y" = partner_base[2] + partner_closeup_dy,
		"dir" = turn(dir_to_partner_before_swap, 180),
		"layer" = null,
	))

	// -----------------------------------------------------------------------------
	// MIDDLE
	//   This is where stuff gets complex and ccw has to be taken into account...
	// -----------------------------------------------------------------------------
	var/middle_close_axis = (half_step - DANCE_CLOSER_DISTANCE) * (ccw ? 1 : -1) * (dir_to_partner_before_swap & (NORTH|WEST) ? 1 : -1)
	var/middle_far_axis = half_step * (dir_to_partner_before_swap & (NORTH|EAST) ? 1 : -1)

	var/src_middle_dx = dir_to_partner_before_swap & (NORTH|SOUTH) ? middle_close_axis : middle_far_axis
	var/src_middle_dy = dir_to_partner_before_swap & (NORTH|SOUTH) ? middle_far_axis : middle_close_axis

	var/partner_middle_dx = -src_middle_dx
	var/partner_middle_dy = -src_middle_dy

	var/src_middle_layer
	var/partner_middle_layer

	switch(dir_to_partner_before_swap)
		if(NORTH)
			src_middle_layer = MOB_LAYER
			partner_middle_layer = ABOVE_ALL_MOB_LAYER
		if(SOUTH)
			src_middle_layer = ABOVE_ALL_MOB_LAYER
			partner_middle_layer = MOB_LAYER
		if(EAST)
			src_middle_layer = ccw ? ABOVE_ALL_MOB_LAYER : MOB_LAYER
			partner_middle_layer = ccw ? MOB_LAYER : ABOVE_ALL_MOB_LAYER
		if(WEST)
			src_middle_layer = ccw ? MOB_LAYER : ABOVE_ALL_MOB_LAYER
			partner_middle_layer = ccw ? ABOVE_ALL_MOB_LAYER : MOB_LAYER

	UNTYPED_LIST_ADD(src_passes, alist(
		"x" = src_base[1] + src_middle_dx,
		"y" = src_base[2] + src_middle_dy,
		"dir" = turn(dir_to_partner_before_swap, ccw ? 90 : -90),
		"layer" = src_middle_layer,
	))
	UNTYPED_LIST_ADD(partner_passes, alist(
		"x" = partner_base[1] + partner_middle_dx,
		"y" = partner_base[2] + partner_middle_dy,
		"dir" = turn(dir_to_partner_before_swap, ccw ? -90 : 90),
		"layer" = partner_middle_layer,
	))

	// -----------------------------------------------------------------------------
	// END
	// -----------------------------------------------------------------------------
	var/src_ending_dx = (dir_to_partner_before_swap & (NORTH|SOUTH)) \
		? 0 \
		: ((dir_to_partner_before_swap & EAST) ? 1 : -1) * full_step
	var/src_ending_dy = (dir_to_partner_before_swap & (NORTH|SOUTH)) \
		? ((dir_to_partner_before_swap & NORTH) ? 1 : -1) * full_step \
		: 0
	var/partner_ending_dx = -src_ending_dx
	var/partner_ending_dy = -src_ending_dy

	UNTYPED_LIST_ADD(src_passes, alist(
		"x" = src_end[1] + src_ending_dx,
		"y" = src_end[2] + src_ending_dy,
		"dir" = turn(dir_to_partner_before_swap, 180),
		"layer" = null,
	))
	UNTYPED_LIST_ADD(partner_passes, alist(
		"x" = partner_end[1] + partner_ending_dx,
		"y" = partner_end[2] + partner_ending_dy,
		"dir" = dir_to_partner_before_swap,
		"layer" = null,
	))

	return alist(
		"src_passes" = src_passes,
		"partner_passes" = partner_passes,
	)

#undef DANCE_TOTAL_TIME
#undef DANCE_CLOSER_DISTANCE
#undef DANCE_HIDDEN_ALPHA
