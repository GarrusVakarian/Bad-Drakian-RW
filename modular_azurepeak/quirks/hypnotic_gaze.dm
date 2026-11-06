#define HYPNOTIC_GAZE_CHANNEL_TIME (5 SECONDS)
#define HYPNOTIC_GAZE_REMINDER_TIME (20 MINUTES)

/proc/hypnotic_gaze_styles()
	return list("Hypnotext", "Purple", "Pink", "Velvet", "Gold", "Cult Red")

/proc/sanitize_hypnotic_gaze_text(text)
	if(!istext(text))
		return "Their eyes are enticing to gaze into."
	text = trim(copytext_char(html_decode(strip_html(text)), 1, 101))
	return length(text) ? text : "Their eyes are enticing to gaze into."

/proc/sanitize_hypnotic_gaze_style(style)
	return (style in hypnotic_gaze_styles()) ? style : "Hypnotext"

/proc/hypnotic_gaze_format(text, style = "Hypnotext")
	text = html_encode(text)
	switch(sanitize_hypnotic_gaze_style(style))
		if("Purple")
			return "<span style='color:#b56cff'>[text]</span>"
		if("Pink")
			return "<span style='color:#ff8fca'>[text]</span>"
		if("Velvet")
			return "<span style='color:#c45b85'>[text]</span>"
		if("Gold")
			return "<span style='color:#e8c65a'>[text]</span>"
		if("Cult Red")
			return "<span class='cult'>[text]</span>"
	return span_hypnophrase(text)

/datum/quirk/hypnotic_gaze
	name = "Hypnotic Gaze"
	desc = "My gaze draws others in, leaving my words lingering deep within their thoughts."
	point_cost = 1
	custom_text = "Grants Hypnotic Gaze: a two-tile, five-second stationary channel. The next words the target hears from me become a lasting suggestion. Recasting releases them."

/datum/quirk/hypnotic_gaze/apply_to_human(mob/living/carbon/human/recipient)
	recipient.hypnotic_gaze_text = sanitize_hypnotic_gaze_text(recipient.client?.prefs?.hypnotic_gaze_text)
	recipient.hypnotic_gaze_style = sanitize_hypnotic_gaze_style(recipient.client?.prefs?.hypnotic_gaze_style)
	if(locate(/obj/effect/proc_holder/spell/invoked/hypnotic_gaze) in recipient.mob_spell_list)
		return
	if(recipient.mind)
		if(!recipient.mind.has_spell(/obj/effect/proc_holder/spell/invoked/hypnotic_gaze))
			recipient.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/hypnotic_gaze)
	else if(!(locate(/obj/effect/proc_holder/spell/invoked/hypnotic_gaze) in recipient.mob_spell_list))
		recipient.AddSpell(new /obj/effect/proc_holder/spell/invoked/hypnotic_gaze)

/mob/living/carbon/human
	var/hypnotic_gaze_text
	var/hypnotic_gaze_style = "Hypnotext"
	var/datum/hypnotic_gaze_channel/hypnotic_gaze_channel

/mob/living/carbon/human/proc/hypnotic_eyes_visible()
	if(wear_mask || !getorganslot(ORGAN_SLOT_EYES) || get_eye_protection() > 0)
		return FALSE
	if((head?.flags_cover & HEADCOVERSEYES) || (glasses?.flags_cover & GLASSESCOVERSEYES))
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/hypnotic_gaze_examine(mob/viewer)
	if(viewer == src || !viewer || !hypnotic_gaze_text || !hypnotic_eyes_visible())
		return null
	if(isliving(viewer))
		var/mob/living/L = viewer
		if(L.eye_blind)
			return null
	return hypnotic_gaze_format(hypnotic_gaze_text, hypnotic_gaze_style)

/obj/effect/proc_holder/spell/invoked/hypnotic_gaze
	name = "Hypnotic Gaze"
	desc = "Hold another's gaze for five seconds. Your next words they hear become a lasting suggestion. Cast again to release an existing suggestion."
	range = 2
	chargetime = 0
	no_early_release = FALSE
	recharge_time = 5 SECONDS
	invocation_type = "none"
	ignore_los = FALSE
	is_cdr_exempt = TRUE
	mute_allowed = TRUE
	releasedrain = 0
	var/datum/hypnotic_gaze_channel/channel

// A channel is not a cooldown, and neither stats nor Leyline Haste alter these times.
/obj/effect/proc_holder/spell/invoked/hypnotic_gaze/process()
	if(channel)
		return
	return ..()

/obj/effect/proc_holder/spell/invoked/hypnotic_gaze/start_recharge()
	recharge_time = initial(recharge_time)
	last_process_time = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/effect/proc_holder/spell/invoked/hypnotic_gaze/Destroy()
	if(channel)
		channel.cancelled = TRUE
	return ..()

/obj/effect/proc_holder/spell/invoked/hypnotic_gaze/on_deactivation(mob/living/user)
	if(channel)
		channel.cancelled = TRUE

/obj/effect/proc_holder/spell/invoked/hypnotic_gaze/cast(list/targets, mob/living/user)
	var/mob/living/carbon/human/caster = user
	var/mob/living/carbon/human/target = length(targets) ? targets[1] : null
	if(channel || !hypnotic_gaze_can_channel(caster, target) || caster.hypnotic_gaze_channel || target.hypnotic_gaze_channel)
		to_chat(user, span_warning("I cannot establish eye contact right now."))
		charge_counter = 0
		start_recharge()
		return FALSE
	var/releasing = !!target.mind.hypnotic_suggestion
	var/datum/weakref/original_suggestion_ref = releasing ? WEAKREF(target.mind.hypnotic_suggestion) : null
	channel = new(caster, target)
	var/datum/hypnotic_gaze_channel/attempt = channel
	to_chat(caster, span_hypnophrase("You fix your gaze upon them, beginning to pierce the surface of their mind."))
	to_chat(target, span_hypnophrase("Their gaze draws you in. You feel compelled to meet their eyes."))
	var/success = FALSE
	try
		success = attempt.await_channel()
	catch(var/exception/error)
		stack_trace("Hypnotic Gaze channel failed: [error]")
	qdel(attempt)
	if(QDELETED(src))
		return FALSE
	channel = null
	charge_counter = 0
	start_recharge()
	if(!success)
		if(!QDELETED(caster))
			to_chat(caster, span_hypnophrase("Your concentration breaks, and their thoughts slip beyond your reach."))
		if(!QDELETED(target))
			to_chat(target, span_hypnophrase("The gaze breaks before it can settle into your thoughts."))
		return FALSE
	var/datum/hypnotic_suggestion/existing = target.mind.hypnotic_suggestion
	if(releasing)
		if(existing && existing != original_suggestion_ref?.resolve())
			return FALSE
		if(existing)
			qdel(existing)
		to_chat(target, span_hypnophrase("Your mind clears. Those words no longer command your thoughts."))
		to_chat(caster, span_hypnophrase("You release their mind from its lingering suggestion."))
	else
		if(existing)
			return FALSE
		new /datum/hypnotic_suggestion(target.mind, caster.mind)
		to_chat(target, span_hypnophrase("Your thoughts soften beneath their gaze. Your mind feels especially receptive to their next words."))
		to_chat(caster, span_hypnophrase("Their mind lies open. The next words they hear from you will become a lasting suggestion, remembered until another gaze releases them."))
	return ..()

/proc/hypnotic_gaze_can_channel(mob/living/carbon/human/caster, mob/living/carbon/human/target)
	if(!istype(caster) || !istype(target) || QDELETED(caster) || QDELETED(target) || caster == target)
		return FALSE
	if(!caster.client || !target.client || !caster.mind || !target.mind || caster.stat != CONSCIOUS || target.stat != CONSCIOUS)
		return FALSE
	if(!caster.hypnotic_eyes_visible() || !target.hypnotic_eyes_visible() || caster.eye_blind || target.eye_blind)
		return FALSE
	var/turf/A = get_turf(caster)
	var/turf/B = get_turf(target)
	return A && B && A.z == B.z && get_dist(A, B) <= 2 && (target in view(2, caster))

/// Short-lived reservation and movement listeners, only while actually channeling.
/datum/hypnotic_gaze_channel
	var/mob/living/carbon/human/caster
	var/mob/living/carbon/human/target
	var/cancelled = FALSE
	var/list/movement_sources = list()

/datum/hypnotic_gaze_channel/New(mob/living/carbon/human/new_caster, mob/living/carbon/human/new_target)
	caster = new_caster
	target = new_target
	caster.hypnotic_gaze_channel = src
	target.hypnotic_gaze_channel = src
	RegisterSignal(caster, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_MIND_TRANSFER, COMSIG_QDELETING), PROC_REF(interrupt))
	RegisterSignal(target, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_MIND_TRANSFER, COMSIG_QDELETING), PROC_REF(interrupt))
	for(var/mob/participant in list(caster, target))
		var/atom/movable/mover = participant
		while(istype(mover))
			movement_sources |= mover
			mover = mover.loc
	for(var/atom/movable/mover as anything in movement_sources)
		RegisterSignal(mover, COMSIG_MOVABLE_MOVED, PROC_REF(interrupt))
	return ..()

/datum/hypnotic_gaze_channel/proc/interrupt()
	SIGNAL_HANDLER
	cancelled = TRUE

/datum/hypnotic_gaze_channel/proc/await_channel()
	var/deadline = world.time + HYPNOTIC_GAZE_CHANNEL_TIME
	while(world.time < deadline)
		if(cancelled || !hypnotic_gaze_can_channel(caster, target))
			return FALSE
		stoplag(1)
	return !cancelled && hypnotic_gaze_can_channel(caster, target)

/datum/hypnotic_gaze_channel/Destroy()
	if(!QDELETED(caster))
		UnregisterSignal(caster, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_MIND_TRANSFER, COMSIG_QDELETING))
		if(caster.hypnotic_gaze_channel == src)
			caster.hypnotic_gaze_channel = null
	if(!QDELETED(target))
		UnregisterSignal(target, list(COMSIG_MOB_LOGOUT, COMSIG_MOB_DEATH, COMSIG_MIND_TRANSFER, COMSIG_QDELETING))
		if(target.hypnotic_gaze_channel == src)
			target.hypnotic_gaze_channel = null
	for(var/atom/movable/mover as anything in movement_sources)
		if(!QDELETED(mover))
			UnregisterSignal(mover, COMSIG_MOVABLE_MOVED)
	movement_sources.Cut()
	caster = null
	target = null
	return ..()

/datum/mind
	var/datum/hypnotic_suggestion/hypnotic_suggestion

/mob/living
	/// Non-null only while waiting for the caster's next intelligible local sentence.
	var/datum/hypnotic_suggestion/hypnotic_pending

/datum/hypnotic_suggestion
	var/datum/weakref/target_mind_ref
	var/datum/weakref/caster_mind_ref
	var/datum/weakref/body_ref
	var/phrase
	var/reminder_timer

/datum/hypnotic_suggestion/New(datum/mind/target_mind, datum/mind/caster_mind)
	target_mind_ref = WEAKREF(target_mind)
	caster_mind_ref = WEAKREF(caster_mind)
	target_mind.hypnotic_suggestion = src
	RegisterSignal(target_mind, COMSIG_QDELETING, PROC_REF(owner_deleted))
	RegisterSignal(caster_mind, COMSIG_QDELETING, PROC_REF(caster_deleted))
	bind_body(target_mind.current)
	return ..()

/datum/hypnotic_suggestion/proc/bind_body(mob/body)
	unbind_body()
	if(!istype(body) || QDELETED(body))
		return
	body_ref = WEAKREF(body)
	if(!phrase && isliving(body))
		var/mob/living/L = body
		L.hypnotic_pending = src
	RegisterSignal(body, COMSIG_MIND_TRANSFER, PROC_REF(body_transferred))
	RegisterSignal(body, COMSIG_QDELETING, PROC_REF(body_deleted))

/datum/hypnotic_suggestion/proc/unbind_body()
	var/mob/body = body_ref?.resolve()
	if(!QDELETED(body))
		if(isliving(body))
			var/mob/living/L = body
			if(L.hypnotic_pending == src)
				L.hypnotic_pending = null
		UnregisterSignal(body, list(COMSIG_MIND_TRANSFER, COMSIG_QDELETING))
	body_ref = null

/datum/hypnotic_suggestion/proc/body_transferred(datum/source, mob/new_body)
	SIGNAL_HANDLER
	bind_body(new_body)

/datum/hypnotic_suggestion/proc/body_deleted()
	SIGNAL_HANDLER
	unbind_body()

/datum/hypnotic_suggestion/proc/owner_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/hypnotic_suggestion/proc/caster_deleted()
	SIGNAL_HANDLER
	if(!phrase)
		qdel(src)

/// Called only for fully delivered local speech, never eavesdropped fragments/emotes.
/datum/hypnotic_suggestion/proc/capture(mob/living/listener, atom/movable/speaker, datum/language/language, raw_message, radio_freq, message_mode, allow_sleeping)
	if(phrase || QDELETED(listener) || !listener.client || !listener.can_hear() || listener.stat == DEAD)
		return FALSE
	if(listener.stat != CONSCIOUS && !(allow_sleeping && listener.IsSleeping()))
		return FALSE
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	var/datum/mind/caster_mind = caster_mind_ref?.resolve()
	if(!target_mind || !caster_mind || listener.mind != target_mind || !isliving(speaker))
		return FALSE
	var/mob/living/caster = speaker
	if(caster.mind != caster_mind || radio_freq || !language || !(listener.has_language(language) || listener.check_language_hear(language)))
		return FALSE
	if(message_mode && message_mode != MODE_WHISPER && message_mode != MODE_WHISPER_CRIT)
		return FALSE
	phrase = trim(copytext_char(html_decode(strip_html(raw_message)), 1, MAX_MESSAGE_LEN))
	if(!length(phrase))
		phrase = null
		return FALSE
	if(listener.hypnotic_pending == src)
		listener.hypnotic_pending = null
	reminder_timer = addtimer(CALLBACK(src, PROC_REF(remind)), HYPNOTIC_GAZE_REMINDER_TIME, TIMER_STOPPABLE)
	log_game("HYPNOTIC GAZE: [key_name(caster)] suggested '[phrase]' to [key_name(listener)].")
	return TRUE

/datum/hypnotic_suggestion/proc/remind()
	reminder_timer = null
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	if(!target_mind || target_mind.hypnotic_suggestion != src || !phrase)
		qdel(src)
		return
	var/mob/living/body = target_mind.current
	if(istype(body) && !QDELETED(body) && body.client && body.stat != DEAD)
		to_chat(body, hypnotic_gaze_format("You feel compelled to obey: [phrase]"))
	reminder_timer = addtimer(CALLBACK(src, PROC_REF(remind)), HYPNOTIC_GAZE_REMINDER_TIME, TIMER_STOPPABLE)

/datum/hypnotic_suggestion/Destroy()
	if(reminder_timer)
		deltimer(reminder_timer)
		reminder_timer = null
	unbind_body()
	var/datum/mind/target_mind = target_mind_ref?.resolve()
	var/datum/mind/caster_mind = caster_mind_ref?.resolve()
	if(target_mind)
		UnregisterSignal(target_mind, COMSIG_QDELETING)
		if(target_mind.hypnotic_suggestion == src)
			target_mind.hypnotic_suggestion = null
	if(caster_mind)
		UnregisterSignal(caster_mind, COMSIG_QDELETING)
	return ..()
