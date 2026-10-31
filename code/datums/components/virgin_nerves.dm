/proc/virgin_attraction_options()
	return list("Any", "He/him", "She/her", "They/them", "It/its")

/proc/sanitize_virgin_attraction(choice)
	return (choice in virgin_attraction_options()) ? choice : "Any"

/datum/component/virgin_nerves
	/// This component belongs to one body; quirk definitions are shared.
	var/next_check = 0
	var/next_affection = 0
	var/attraction = "Any"

/datum/component/virgin_nerves/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	next_check = world.time + 1 MINUTES

/datum/component/virgin_nerves/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(on_life))

/datum/component/virgin_nerves/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_LIFE)

/datum/component/virgin_nerves/proc/matches_attraction(mob/living/carbon/human/partner)
	switch(attraction)
		if("Any")
			return TRUE
		if("He/him")
			return partner.pronouns in list(HE_HIM, HE_HIM_F)
		if("She/her")
			return partner.pronouns in list(SHE_HER, SHE_HER_M)
		if("They/them")
			return partner.pronouns in list(THEY_THEM, THEY_THEM_F)
		if("It/its")
			return partner.pronouns == IT_ITS
	return FALSE

/datum/component/virgin_nerves/proc/check_virginity(mob/living/carbon/human/recipient)
	if(recipient.virginity)
		return TRUE
	recipient.remove_stress(/datum/stressevent/virgin_nerves)
	recipient.remove_stress(/datum/stressevent/virgin_discomfort)
	recipient.add_stress(/datum/stressevent/virgin_confidence)
	REMOVE_TRAIT(recipient, TRAIT_VIRGIN_NERVES, TRAIT_VIRTUE)
	to_chat(recipient, span_notice("I feel more confident about intimacy now."))
	to_chat(recipient, span_info("The nervous flutter I felt around attractive people has faded."))
	qdel(src)
	return FALSE

/datum/component/virgin_nerves/proc/show_fluster(mob/living/carbon/human/recipient)
	if(prob(35))
		INVOKE_ASYNC(recipient, TYPE_PROC_REF(/mob, emote), "blush")
	// Do not change general jitteriness or disturb an existing jitter animation.
	if(!recipient.jitteriness && !recipient.lying)
		var/resting_pixel_x = recipient.pixel_x
		animate(recipient, pixel_x = resting_pixel_x + 1, time = 1, loop = 2)
		animate(pixel_x = resting_pixel_x, time = 1)

/datum/component/virgin_nerves/proc/on_life(mob/living/carbon/human/recipient)
	SIGNAL_HANDLER
	if(!recipient.client || !recipient.mind || recipient.stat != CONSCIOUS)
		return
	if(!check_virginity(recipient))
		return
	if(world.time < next_check)
		return
	next_check = world.time + 1 MINUTES
	if(is_blind(recipient))
		return
	for(var/mob/living/carbon/human/nearby in view(7, recipient))
		if(nearby == recipient || nearby.stat == DEAD || !matches_attraction(nearby))
			continue
		if(!HAS_TRAIT(nearby, TRAIT_PRETTY) && !HAS_TRAIT(nearby, TRAIT_BEAUTIFUL))
			continue
		recipient.add_stress(/datum/stressevent/virgin_nerves)
		to_chat(recipient, span_notice(pick("Their looks leave me a little flustered.", "I feel butterflies around someone so attractive.", "I try to compose myself, but my cheeks feel warm.")))
		show_fluster(recipient)
		break

/datum/component/virgin_nerves/proc/on_affection(mob/living/carbon/human/recipient, mob/living/carbon/human/partner)
	if(!recipient.client || !recipient.mind || recipient.stat != CONSCIOUS)
		return
	if(!check_virginity(recipient))
		return
	if(partner == recipient || partner.stat == DEAD || !recipient.Adjacent(partner) || world.time < next_affection)
		return
	if(!matches_attraction(partner))
		next_affection = world.time + 1 MINUTES
		recipient.add_stress(/datum/stressevent/virgin_discomfort)
		to_chat(recipient, span_warning(pick("This closeness leaves me uneasy rather than excited.", "I feel uncomfortable with their intimate attention.")))
		to_chat(partner, span_notice("[recipient]'s heart pounds audibly, and a nervous sheen of sweat forms on their skin. They seem uneasy with the contact."))
		return
	if(!HAS_TRAIT(partner, TRAIT_PRETTY) && !HAS_TRAIT(partner, TRAIT_BEAUTIFUL))
		return
	next_affection = world.time + 1 MINUTES
	recipient.add_stress(/datum/stressevent/virgin_nerves)
	to_chat(recipient, span_notice(pick("Their touch makes my heart race. I can hardly hide how flustered I feel.", "I feel a nervous warmth spread through me at their affection.")))
	to_chat(partner, span_notice("I can hear [recipient]'s heart pounding, and notice a nervous sheen of sweat on their skin."))
	show_fluster(recipient)

/mob/living/carbon/human/proc/react_to_virgin_affection(mob/living/carbon/human/partner)
	if(QDELETED(src) || QDELETED(partner) || !ishuman(partner))
		return
	var/datum/component/virgin_nerves/nerves = GetComponent(/datum/component/virgin_nerves)
	if(istype(nerves))
		nerves.on_affection(src, partner)
