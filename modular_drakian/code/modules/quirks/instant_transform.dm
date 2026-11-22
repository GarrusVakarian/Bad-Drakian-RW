/datum/quirk/instant_transform
	name = "Instant Transform"
	desc = "I can reshape my appearance with a moment of concentration."
	point_cost = 2
	custom_text = "Grants Instant Transform. Edit your appearance and anatomy without a mirror."

/datum/quirk/instant_transform/apply_to_human(mob/living/carbon/human/recipient)
	var/spell_type = /obj/effect/proc_holder/spell/self/instant_transform
	if(locate(spell_type) in recipient.mob_spell_list)
		return
	if(recipient.mind?.has_spell(spell_type))
		return
	var/obj/effect/proc_holder/spell/self/instant_transform/spell = new
	if(recipient.mind)
		recipient.mind.AddSpell(spell)
	else
		recipient.AddSpell(spell)

/obj/effect/proc_holder/spell/self/instant_transform
	name = "Instant Transform"
	desc = "Change your appearance without a mirror."
	human_req = TRUE
	clothes_req = FALSE
	invocations = list("Effingo")
	invocation_type = "whisper"
	recharge_time = 3 SECONDS
	chargetime = 1 SECONDS
	is_cdr_exempt = TRUE
	overlay_state = "mirror"
	var/datum/instant_transform_session/editor

/obj/effect/proc_holder/spell/self/instant_transform/get_minimum_cast_time()
	return 1 SECONDS

/obj/effect/proc_holder/spell/self/instant_transform/cast(list/targets, mob/user)
	if(!ishuman(user) || QDELETED(user))
		revert_cast(user)
		return FALSE
	var/mob/living/carbon/human/human = user
	if(!QDELETED(editor) && editor.is_valid(human))
		to_chat(human, span_warning("I already have an appearance prompt open."))
		revert_cast(human)
		return FALSE
	QDEL_NULL(editor)
	editor = new(human)
	if(!editor.is_valid(human))
		QDEL_NULL(editor)
		revert_cast(human)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(open_editor), human, editor)
	return ..()

/obj/effect/proc_holder/spell/self/instant_transform/proc/open_editor(mob/living/carbon/human/human, datum/instant_transform_session/session)
	if(!QDELETED(session))
		perform_mirror_transform(human, session)
	if(editor == session)
		editor = null
	qdel(session)

/obj/effect/proc_holder/spell/self/instant_transform/Destroy()
	QDEL_NULL(editor)
	return ..()

/// An answer belongs to one uninterrupted period of control over one body.
/datum/instant_transform_session
	var/mob/living/carbon/human/body
	var/client/player
	var/datum/mind/owner
	var/invalidated = FALSE
	var/organ_slot
	var/obj/item/organ/expected_organ

/datum/instant_transform_session/New(mob/living/carbon/human/human)
	. = ..()
	body = human
	player = human.client
	owner = human.mind
	RegisterSignal(body, list(COMSIG_MOB_LOGOUT, COMSIG_MIND_TRANSFER, COMSIG_SPECIES_LOSS, COMSIG_QDELETING), PROC_REF(invalidate))

/datum/instant_transform_session/proc/invalidate()
	SIGNAL_HANDLER
	invalidated = TRUE

/datum/instant_transform_session/proc/is_valid(mob/living/carbon/human/human)
	if(QDELETED(src) || invalidated || body != human || QDELETED(body) || !has_control())
		return FALSE
	if(!body.dna || !body.dna.species || body.is_shapeshift_shell() || body.incapacitated())
		return FALSE
	if(organ_slot && body.getorganslot(organ_slot) != expected_organ)
		return FALSE
	return !expected_organ || (!QDELETED(expected_organ) && expected_organ.owner == body)

/datum/instant_transform_session/proc/has_control()
	return player && !QDELETED(owner) && body.client == player && player.mob == body && body.mind == owner && owner.current == body

/// The selected slot must stay intact until the anatomy prompt is answered.
/datum/instant_transform_session/proc/watch_organ(slot)
	organ_slot = slot
	expected_organ = body.getorganslot(slot)
	RegisterSignal(body, COMSIG_MOB_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/datum/instant_transform_session/proc/on_organ_removed(datum/source, obj/item/organ/removed)
	SIGNAL_HANDLER
	if(removed.slot == organ_slot)
		invalidated = TRUE

/datum/instant_transform_session/Destroy()
	if(body)
		UnregisterSignal(body, list(COMSIG_MOB_LOGOUT, COMSIG_MIND_TRANSFER, COMSIG_SPECIES_LOSS, COMSIG_QDELETING, COMSIG_MOB_ORGAN_REMOVED))
	body = null
	player = null
	owner = null
	expected_organ = null
	return ..()
