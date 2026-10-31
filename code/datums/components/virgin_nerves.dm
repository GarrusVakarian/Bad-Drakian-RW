/datum/component/virgin_nerves
	/// This component belongs to one body; quirk definitions are shared.
	var/next_check = 0

/datum/component/virgin_nerves/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	next_check = world.time + 1 MINUTES

/datum/component/virgin_nerves/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(on_life))

/datum/component/virgin_nerves/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_LIFE)

/datum/component/virgin_nerves/proc/on_life(mob/living/carbon/human/recipient)
	SIGNAL_HANDLER
	if(!recipient.client || !recipient.mind || recipient.stat != CONSCIOUS)
		return
	if(!recipient.virginity)
		recipient.remove_stress(/datum/stressevent/virgin_nerves)
		REMOVE_TRAIT(recipient, TRAIT_VIRGIN_NERVES, TRAIT_VIRTUE)
		to_chat(recipient, span_notice("I feel more confident about intimacy now."))
		to_chat(recipient, span_info("The nervous flutter I felt around attractive people has faded."))
		qdel(src)
		return
	if(world.time < next_check)
		return
	next_check = world.time + 1 MINUTES
	if(is_blind(recipient))
		return
	for(var/mob/living/carbon/human/nearby in view(7, recipient))
		if(nearby == recipient || nearby.stat == DEAD)
			continue
		if(!HAS_TRAIT(nearby, TRAIT_PRETTY) && !HAS_TRAIT(nearby, TRAIT_BEAUTIFUL))
			continue
		recipient.add_stress(/datum/stressevent/virgin_nerves)
		to_chat(recipient, span_notice(pick("Their looks leave me a little flustered.", "I feel butterflies around someone so attractive.", "I try to compose myself, but my cheeks feel warm.")))
		if(prob(35))
			INVOKE_ASYNC(recipient, TYPE_PROC_REF(/mob, emote), "blush")
		// Do not change general jitteriness or disturb an existing jitter animation.
		if(!recipient.jitteriness && !recipient.lying)
			var/resting_pixel_x = recipient.pixel_x
			animate(recipient, pixel_x = resting_pixel_x + 1, time = 1, loop = 2)
			animate(pixel_x = resting_pixel_x, time = 1)
		break
