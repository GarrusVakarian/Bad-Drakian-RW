
/obj/effect/proc_holder/spell/self/claws/dragon
	name = "Dragon claws"
	claw_type = /obj/item/rogueweapon/werewolf_claw/dragon

/obj/effect/proc_holder/spell/self/dragon_gate_control
	name = "Lair gate"
	desc = "Remotely opens or closes the gate to your lair."
	recharge_time = 10 SECONDS

/obj/effect/proc_holder/spell/self/dragon_gate_control/cast(mob/living/user)
	log_game("[key_name(user)] magically pulled the dragon gate lever.")
	var/obj/structure/lever/wall/dragon_gate_control/linked_lever = locate("pdragonexit")
	if(linked_lever && istype(linked_lever))
		linked_lever.magic_flip()

/obj/structure/lever/wall/dragon_gate_control
	redstone_id = "pdragonexit"
	max_integrity = 999999

/obj/structure/lever/wall/dragon_gate_control/proc/magic_flip()
	for(var/obj/structure/O in redstone_attached)
		addtimer(CALLBACK(O, TYPE_PROC_REF(/obj/structure, redstone_triggered)), 0)
	toggled = !toggled
	icon_state = "leverwall[toggled]"
	playsound(src, 'sound/foley/lever.ogg', 100, extrarange = 3)


/obj/effect/proc_holder/spell/self/dragon_hoard_challenge
	name = "Offer Hoard Challenge"
	desc = "Post a contract for a gem from your hoard. Cast again to withdraw it while nobody is carrying the gem. Once the challenge is complete, it cannot be offered again this round."
	recharge_time = 10 SECONDS

/obj/effect/proc_holder/spell/self/dragon_hoard_challenge/cast(mob/living/user)
	var/datum/antagonist/dragon/D = user.mind?.has_antag_datum(/datum/antagonist/dragon)
	if(!istype(D))
		revert_cast(user)
		return FALSE
	if(GLOB.dragon_hoard_completed)
		to_chat(user, span_warning("The hoard challenge has already been completed this round."))
		revert_cast(user)
		return FALSE
	var/datum/quest/retrieval/dragon_hoard/quest = D.hoard_quest_ref?.resolve()
	var/obj/item/gem = quest?.hoard_item_ref?.resolve()
	if(isliving(get_atom_on_turf(gem, /mob/living)))
		to_chat(user, span_warning("Someone is carrying the hoard gem. You cannot withdraw the challenge."))
		revert_cast(user)
		return FALSE
	if(D.withdraw_hoard_quest(rescinded_by_dragon = TRUE))
		to_chat(user, span_notice("You withdraw your hoard challenge."))
		return TRUE
	if(D.post_hoard_quest())
		to_chat(user, span_notice("You offer a challenge for a gem from your hoard."))
		return TRUE
	to_chat(user, span_warning("You cannot offer a hoard challenge here."))
	revert_cast(user)
	return FALSE

/obj/effect/proc_holder/spell/self/dragon_realm_roar
	name = "Roar to the Realm"
	desc = "Broadcast your words across the realm from within your lair."
	recharge_time = 2 MINUTES
	is_cdr_exempt = TRUE

/obj/effect/proc_holder/spell/self/dragon_realm_roar/start_recharge()
	last_process_time = world.time
	START_PROCESSING(SSfastprocess, src)

/obj/effect/proc_holder/spell/self/dragon_realm_roar/check_cast_requirements(skipcharge, mob/user, check_charge = TRUE)
	if(!istype(get_area(user), /area/rogue/under/cavewet/dragon_lair))
		to_chat(user, span_warning("I can only roar to the realm from within my lair!"))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/self/dragon_realm_roar/cast(mob/living/user)
	var/datum/antagonist/dragon/D = user.mind?.has_antag_datum(/datum/antagonist/dragon)
	var/client/speaker_client = user.client
	if(!istype(D) || !speaker_client)
		revert_cast(user)
		return FALSE
	var/message = tgui_input_text(user, "What will you roar to the realm?", name, max_length = MAX_MESSAGE_LEN, encode = FALSE, timeout = 30 SECONDS)
	if(QDELETED(src) || QDELETED(user))
		return FALSE
	if(!message || user.client != speaker_client || QDELETED(D) || D.owner?.current != user || !check_cast_requirements(TRUE, user, check_charge = FALSE))
		revert_cast(user)
		return FALSE
	message = trim(STRIP_HTML_SIMPLE(message, MAX_MESSAGE_LEN))
	if(!length(message))
		revert_cast(user)
		return FALSE
	priority_announce(message, "The dragon roars:", 'sound/vo/mobs/vdragon/drgnroar.ogg', sender = user, text_color = "#C8A4E0")
	return TRUE
