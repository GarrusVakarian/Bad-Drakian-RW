/*
Mercenary statue backend. Ported from Azure-Peak's talkstatue_mercenary.dm as-is.

ES port note (Step 9e): landed the backend procs below (message_single_mercenary(),
broadcast_to_mercenaries(), the Topic() register/response link handlers) plus a stopgap
input()-menu attack_hand() standing in for AP's real TGUI, since talkstatue_tgui.dm was
deferred at the time.

ES port note (Step 9f): the stopgap attack_hand() (and its cycle_mercenary_status() helper)
have been REMOVED and replaced by the real attack_hand() -> ui_interact() -> Talkstatue TGUI
wiring, now living in talkstatue_tgui.dm alongside ui_state()/ui_data()/ui_act(). Status is
now set via ui_act("set_merc_status") calling talkstatue_tgui.dm's set_role_status() against
mercenary_status, rather than the old three-way cycle. message_single_mercenary() and
broadcast_to_mercenaries() below are unchanged and are called directly from
talkstatue_tgui.dm's ui_act() ("contact_merc" / "broadcast_mercs").

This also replaces ES's old noticeboard-embedded mercenary DM system (silver/gold roguecoin
gate, GLOB.sellsword_noticeboardposts, MERC_STATUS_*, mercdmcooldown/mercbroadcastcooldown
status effects) - see noticeboard.dm's header comment for the full note. One behavioral
difference to flag: the old ES system required paying a roguecoin (silver to DM one merc,
gold to broadcast to all) to use it; this ported system has no coin cost, matching AP
upstream. That cost gate was not reimplemented here - flagged for follow-up if wanted.
*/

/obj/structure/roguemachine/talkstatue/mercenary/Initialize(mapload)
	. = ..()
	if(SSroguemachine.mercenary_statue == null)
		SSroguemachine.mercenary_statue = src
	SSroguemachine.mercenary_statues |= src

/obj/structure/roguemachine/talkstatue/mercenary/Destroy()
	SSroguemachine.mercenary_statues -= src
	if(SSroguemachine.mercenary_statue == src)
		SSroguemachine.mercenary_statue = length(SSroguemachine.mercenary_statues) ? SSroguemachine.mercenary_statues[1] : null
	return ..()

/// Real player entry point (Step 9f) - opens the Talkstatue TGUI (see talkstatue_tgui.dm)
/// instead of the old input() menu.
/obj/structure/roguemachine/talkstatue/mercenary/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return
	user.changeNext_move(CLICK_CD_INTENTCAP)
	playsound(loc, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)
	ui_interact(user)

/// Enroll after class selection; an advertisement is optional and only lasts this round.
/obj/structure/roguemachine/talkstatue/mercenary/proc/auto_register(mob/living/carbon/human/H)
	if(QDELETED(H) || !H.mind || !H.advjob || H.stat == DEAD)
		return FALSE
	var/list/registry
	var/role_name
	if(role_matches(H, "Mercenary"))
		registry = mercenary_status
		role_name = "Mercenary"
	else if(role_matches(H, "Adventurer"))
		registry = adventurer_status
		role_name = "Adventurer"
	else if(role_matches(H, "Wretch"))
		registry = wretch_status
		role_name = "Wretch"
	else
		return FALSE
	var/list/data = registry[H.real_name]
	if(data && data["mob"] == H)
		return FALSE // Re-equipping must not erase an ad, change status, or renew the link.
	registry[H.real_name] = list("status" = "Available", "mob" = H, "message" = "")
	if(role_name == "Wretch")
		registry[H.real_name]["nom_de_guerre"] = wretch_descriptor(H)
	if(H.key)
		pending_registrations -= H.key
		// Let class fluff, job greetings and the login dawn notice finish first.
		addtimer(CALLBACK(src, PROC_REF(send_spawn_ad_link), H, role_name, H.key), 5 SECONDS)
	return TRUE

/obj/structure/roguemachine/talkstatue/mercenary/proc/send_spawn_ad_link(mob/living/carbon/human/H, role_name, expected_key)
	if(QDELETED(H) || H.stat == DEAD || H.key != expected_key || !role_matches(H, role_name))
		return
	var/list/registry
	switch(role_name)
		if("Mercenary")
			registry = mercenary_status
		if("Adventurer")
			registry = adventurer_status
		if("Wretch")
			registry = wretch_status
		else
			return
	var/list/data = registry[H.real_name]
	if(!data || data["mob"] != H)
		return
	pending_message_links[H.key] = H
	// Give the player the full five minutes after the notice actually appears.
	addtimer(CALLBACK(src, PROC_REF(expire_message_link), H.key, H), 5 MINUTES)
	var/link_text = role_name == "Wretch" ? "Set my status, alias and advertisement for this round" : "Set my status and advertisement for this round"
	to_chat(H, span_notice("I am listed on the [role_name] roster at the mercenary statue. <a href='?src=[REF(src)];set_message_remote=[REF(H)]'>[link_text]</a> (one use, expires in 5 minutes). I can visit the statue later to make further changes."))

/obj/structure/roguemachine/talkstatue/mercenary/proc/message_single_mercenary(mob/living/carbon/human/sender)
	var/list/available_mercenaries = list()
	var/list/stale_keys = list()

	for(var/merc_key in mercenary_status)
		var/list/merc_data = mercenary_status[merc_key]
		var/mob/living/carbon/human/merc = merc_data["mob"]

		if(!merc || QDELETED(merc))
			stale_keys += merc_key
			continue
		if(merc.stat == DEAD)
			continue
		if(merc_data["status"] == "Do not Disturb")
			continue

		var/status_text = merc_data["status"] || "Available"
		var/display_name = "[merc.real_name] ([status_text])"
		available_mercenaries[display_name] = merc

	for(var/key in stale_keys)
		mercenary_status -= key

	if(!available_mercenaries.len)
		to_chat(sender, span_warning("There are no mercenaries currently available."))
		return

	var/choice = input(sender, "Which mercenary do I wish to contact?", "Mercenary Contact") as null|anything in available_mercenaries
	if(!choice)
		return

	var/mob/living/carbon/human/target_merc = available_mercenaries[choice]

	var/cooldown_key = "[sender.real_name]_[target_merc.real_name]"
	if(sender_cooldowns[cooldown_key])
		var/time_left = sender_cooldowns[cooldown_key] + single_cooldown - world.time
		if(time_left > 0)
			var/mins_left = max(1, round(time_left / 600))
			to_chat(sender, span_warning("I need to wait [mins_left] minute[mins_left == 1 ? "" : "s"] before contacting [target_merc.real_name] again."))
			return

	if(!Adjacent(sender))
		to_chat(sender, span_warning("I need to stay close to the statue."))
		return

	var/message = stripped_input(sender, "What message do I wish to send? (Max [message_char_limit] characters)", "Mercenary Contact", "", message_char_limit)
	if(!message)
		return

	if(!Adjacent(sender))
		to_chat(sender, span_warning("I moved too far from the statue."))
		return

	sender_cooldowns[cooldown_key] = world.time

	response_id_counter++
	var/response_id = "[target_merc.real_name]_[world.time]_[response_id_counter]"
	if(!QDELETED(target_merc) && !QDELETED(sender))
		pending_direct_responses[response_id] = list("responder" = target_merc, "sender" = sender)
		addtimer(CALLBACK(src, PROC_REF(expire_direct_response), response_id), response_timeout)

	to_chat(target_merc, span_boldnotice("The mercenary statue whispers in my mind: <i>[message]</i> - [sender.real_name]<br><a href='?src=[REF(src)];direct_response=yae;response_id=[response_id]'>\[YAE\]</a> | <a href='?src=[REF(src)];direct_response=nae;response_id=[response_id]'>\[NAE\]</a>"))
	to_chat(sender, span_notice("My message has been sent to [target_merc.real_name]."))
	playsound(target_merc.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)

	sender.log_talk(message, LOG_SAY, tag="mercenary statue (to [key_name(target_merc)])")
	target_merc.log_talk(message, LOG_SAY, tag="mercenary statue (from [key_name(sender)])", log_globally=FALSE)

/obj/structure/roguemachine/talkstatue/mercenary/proc/broadcast_to_mercenaries(mob/living/carbon/human/sender)
	var/broadcast_key = "broadcast_[sender.real_name]"
	if(sender_cooldowns[broadcast_key])
		var/time_left = sender_cooldowns[broadcast_key] + broadcast_cooldown_time - world.time
		if(time_left > 0)
			var/mins_left = max(1, round(time_left / 600))
			to_chat(sender, span_warning("I need to wait [mins_left] minute[mins_left == 1 ? "" : "s"] before broadcasting again."))
			return

	if(!Adjacent(sender))
		to_chat(sender, span_warning("I need to stay close to the statue."))
		return

	var/list/valid_recipients = list()
	for(var/merc_key in mercenary_status)
		var/list/merc_data = mercenary_status[merc_key]
		var/mob/living/carbon/human/merc = merc_data["mob"]

		if(!merc || merc.stat == DEAD)
			continue
		if(merc_data["status"] == "Do not Disturb")
			continue

		valid_recipients += merc

	if(valid_recipients.len == 0)
		to_chat(sender, span_warning("There are no mercenaries available to broadcast to."))
		return

	var/message = stripped_input(sender, "What message do I wish to broadcast to all mercenaries? (Max [message_char_limit] characters)", "Mercenary Broadcast", "", message_char_limit)
	if(!message)
		return

	if(!Adjacent(sender))
		to_chat(sender, span_warning("I moved too far from the statue."))
		return

	sender_cooldowns[broadcast_key] = world.time

	var/list/recipient_keys = list()
	for(var/mob/living/carbon/human/merc in valid_recipients)
		recipient_keys += key_name(merc)

	for(var/mob/living/carbon/human/merc in valid_recipients)
		response_id_counter++
		var/response_id = "[merc.real_name]_[world.time]_[response_id_counter]"
		if(!QDELETED(merc) && !QDELETED(sender))
			pending_broadcast_responses[response_id] = list("responder" = merc, "sender" = sender)
			addtimer(CALLBACK(src, PROC_REF(expire_broadcast_response), response_id), response_timeout)

		to_chat(merc, span_boldannounce("The mercenary statue calls out: <i>[message]</i> - [sender.real_name]<br><a href='?src=[REF(src)];broadcast_interest=[response_id]'>\[Signal Interest\]</a>"))
		playsound(merc.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)

	var/merc_count = valid_recipients.len
	to_chat(sender, span_notice("My message has been broadcast to [merc_count] mercenary[merc_count == 1 ? "" : "s"]."))
	src.statue_bark(1)

	sender.log_talk(message, LOG_SAY, tag="mercenary statue broadcast (to [recipient_keys.Join(", ")])")

/obj/structure/roguemachine/talkstatue/mercenary/Topic(href, href_list)
	. = ..()

	if(href_list["register"])
		var/mob/living/carbon/human/H = locate(href_list["register"])
		if(!H || usr != H)
			return
		if(pending_registrations[H.key] != H)
			to_chat(usr, span_warning("That registration link has expired."))
			return
		if(H.mind?.assigned_role != "Mercenary")
			to_chat(usr, span_warning("I am no longer a mercenary."))
			pending_registrations -= H.key
			return
		if(!H.mind)
			return
		if(!H.advjob)
			to_chat(H, span_warning("I need to select my mercenary class before registering with the statue."))
			return

		var/list/merc_data = mercenary_status[H.real_name]
		if(!merc_data || merc_data["mob"] != H)
			mercenary_status[H.real_name] = list("status" = "Available", "mob" = H, "message" = "")
		pending_registrations -= H.key

		to_chat(H, span_boldnotice("I have registered with the Mercenary Guild! I am now listed as <b>Available</b>."))
		to_chat(H, span_notice("I can visit the statue in person to change my status, or <a href='?src=[REF(src)];set_message_remote=[REF(H)]'>recall my mercenary message</a> from afar. (This link expires in 2 minutes)"))
		playsound(H.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)

		if(!QDELETED(H))
			pending_message_links[H.key] = H
			addtimer(CALLBACK(src, PROC_REF(expire_message_link), H.key, H), 2 MINUTES)
		return

	if(href_list["set_message_remote"])
		var/mob/living/carbon/human/H = locate(href_list["set_message_remote"])
		if(!H)
			return
		if(usr != H)
			to_chat(usr, span_warning("That link is not for me."))
			return
		if(pending_message_links[H.key] != H)
			to_chat(usr, span_warning("That message link has expired."))
			return
		var/list/registry
		var/role_name
		if(role_matches(H, "Mercenary"))
			registry = mercenary_status
			role_name = "Mercenary"
		else if(role_matches(H, "Adventurer"))
			registry = adventurer_status
			role_name = "Adventurer"
		else if(role_matches(H, "Wretch"))
			registry = wretch_status
			role_name = "Wretch"
		else
			return
		var/list/data = registry[H.real_name]
		if(!data || data["mob"] != H || H.stat == DEAD)
			return
		// Consume before opening input so the same link cannot open multiple editors.
		pending_message_links -= H.key
		var/list/status_options
		switch(role_name)
			if("Mercenary")
				status_options = list("Available", "Contracted", "Do not Disturb")
			if("Adventurer")
				status_options = list("Available", "Away", "Resting", "Do not Disturb")
			if("Wretch")
				status_options = list("Available", "On a Job", "Lying Low", "Do not Disturb")
		var/new_status = input(H, "Choose my status for this round. Afterwards, I can edit my advertisement.", "[role_name] Status", data["status"]) as null|anything in status_options
		if(!(new_status in status_options) || QDELETED(H) || usr != H || H.stat == DEAD)
			return
		if(!role_matches(H, role_name) || registry[H.real_name] != data || data["mob"] != H)
			return
		data["status"] = new_status
		to_chat(H, span_notice("I set my status to: <b>[new_status]</b>"))
		log_admin_private("[key_name(H)] set statue status to [new_status]")
		if(role_name == "Wretch")
			var/new_nom = stripped_input(H, "Choose my nom de guerre for this round (max 60 characters). Empty to use my physical descriptor.", "Nom de Guerre", data["nom_de_guerre"] || "", 60)
			if(QDELETED(H) || usr != H || H.stat == DEAD)
				return
			if(!role_matches(H, role_name) || registry[H.real_name] != data || data["mob"] != H)
				return
			if(new_nom != null)
				data["nom_de_guerre"] = new_nom
				to_chat(H, span_notice("My nom de guerre has been updated."))
				log_admin_private("[key_name(H)] set wretch nom de guerre: \"[new_nom]\"")
		var/new_msg = stripped_input(H, "Enter my advertisement for this round (max [message_char_limit] characters):", "[role_name] Advertisement", data["message"] || "", message_char_limit)
		if(new_msg == null || QDELETED(H) || usr != H || H.stat == DEAD)
			return
		if(!role_matches(H, role_name) || registry[H.real_name] != data || data["mob"] != H)
			return
		data["message"] = new_msg
		to_chat(H, span_notice("My advertisement has been updated. I can visit the statue to make further changes."))
		log_admin_private("[key_name(H)] set [role_name] statue advertisement: \"[new_msg]\"")
		return

	if(href_list["broadcast_interest"])
		if(!ishuman(usr))
			return
		var/mob/living/carbon/human/responder = usr
		var/response_id = href_list["broadcast_interest"]

		if(!pending_broadcast_responses[response_id])
			to_chat(responder, span_warning("That response link has expired or already been used."))
			return

		var/list/response_data = pending_broadcast_responses[response_id]
		var/mob/living/carbon/human/stored_responder = response_data["responder"]
		var/mob/living/carbon/human/sender = response_data["sender"]

		if(responder != stored_responder)
			to_chat(responder, span_warning("That response link is not for me."))
			return

		if(!sender || QDELETED(sender))
			to_chat(responder, span_warning("The sender is no longer available."))
			pending_broadcast_responses -= response_id
			return

		if(!responder.mind || responder.mind.assigned_role != "Mercenary")
			to_chat(responder, span_warning("I am not a mercenary."))
			return

		pending_broadcast_responses -= response_id

		to_chat(sender, span_notice("[responder.real_name] signaled [responder.p_their()] interest in my missive."))
		playsound(sender.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)

		to_chat(responder, span_notice("I signaled my interest to [sender.real_name]."))
		playsound(responder.loc, 'sound/misc/beep.ogg', 100, FALSE, -1)

		responder.log_talk("signaled interest", LOG_SAY, tag="mercenary statue broadcast response (to [key_name(sender)])")
		return

	if(href_list["direct_response"])
		if(!ishuman(usr))
			return
		var/mob/living/carbon/human/responder = usr
		var/response_type = href_list["direct_response"]
		var/response_id = href_list["response_id"]

		if(!pending_direct_responses[response_id])
			to_chat(responder, span_warning("That response link has expired or already been used."))
			return

		var/list/response_data = pending_direct_responses[response_id]
		var/mob/living/carbon/human/stored_responder = response_data["responder"]
		var/mob/living/carbon/human/sender = response_data["sender"]

		if(responder != stored_responder)
			to_chat(responder, span_warning("That response link is not for me."))
			return

		if(!sender || QDELETED(sender))
			to_chat(responder, span_warning("The sender is no longer available."))
			pending_direct_responses -= response_id
			return

		pending_direct_responses -= response_id
		var/responder_name = role_matches(responder, "Wretch") ? wretch_display_name(responder) : responder.real_name
		var/sender_name = role_matches(sender, "Wretch") ? wretch_display_name(sender) : sender.real_name

		if(response_type == "yae")
			to_chat(sender, span_notice("[responder_name] responded in affirmation to my message."))
			to_chat(responder, span_notice("I responded in affirmation to [sender_name]."))
		else
			to_chat(sender, span_notice("[responder_name] responded negatively to my message."))
			to_chat(responder, span_notice("I responded negatively to [sender_name]."))

		playsound(sender.loc, 'sound/misc/notice (2).ogg', 100, FALSE, -1)
		playsound(responder.loc, 'sound/misc/beep.ogg', 100, FALSE, -1)

		responder.log_talk("direct response: [response_type]", LOG_SAY, tag="mercenary statue direct response (to [key_name(sender)])")
		return

/obj/structure/roguemachine/talkstatue/mercenary/proc/expire_registration(key)
	if(pending_registrations[key])
		pending_registrations -= key

/obj/structure/roguemachine/talkstatue/mercenary/proc/expire_message_link(key, mob/expected_user = null)
	if(expected_user && pending_message_links[key] != expected_user)
		return // An older character's timer must not revoke their replacement's link.
	if(pending_message_links[key])
		pending_message_links -= key

/obj/structure/roguemachine/talkstatue/mercenary/proc/expire_broadcast_response(response_id)
	if(pending_broadcast_responses[response_id])
		pending_broadcast_responses -= response_id

/obj/structure/roguemachine/talkstatue/mercenary/proc/expire_direct_response(response_id)
	if(pending_direct_responses[response_id])
		pending_direct_responses -= response_id

/obj/structure/roguemachine/talkstatue/mercenary/proc/statue_bark(mode)
	if(mode == 1)
		var/random = rand(1,4)
		switch(random)
			if(1)
				say("They heard it! Can't guarantee anything else.")
			if(2)
				say("Maybe you'll get a good deal in negotiations.")
			if(3)
				say("So, you goin' to kill somebody? Hee-haw! I'm jestin'.")
			if(4)
				say("What ye end up doin' with your gold is your business.")
