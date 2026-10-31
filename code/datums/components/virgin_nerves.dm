/proc/virgin_attraction_options()
	return list("Any", "He/him", "She/her", "They/them", "It/its")

/proc/sanitize_virgin_attraction(choices)
	// Migrate the original single-choice saves without losing their selection.
	if(istext(choices))
		choices = list(choices)
	if(!islist(choices) || ("Any" in choices))
		return list("Any")
	var/list/selected = list()
	for(var/option in virgin_attraction_options())
		if(option != "Any" && (option in choices))
			selected += option
	return length(selected) ? selected : list("Any")

/datum/component/virgin_nerves
	/// This component belongs to one body; quirk definitions are shared.
	var/next_check = 0
	var/next_affection = 0
	var/list/attraction = list("Any")
	/// Captured when an action clears the flag, not from a previous interaction.
	var/unwanted_loss = FALSE

/datum/component/virgin_nerves/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	next_check = world.time + 2 MINUTES

/datum/component/virgin_nerves/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_LIFE, PROC_REF(on_life))

/datum/component/virgin_nerves/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HUMAN_LIFE)

/datum/component/virgin_nerves/proc/matches_attraction(mob/living/carbon/human/partner)
	for(var/group in attraction)
		switch(group)
			if("Any")
				return TRUE
			if("He/him")
				if(partner.pronouns in list(HE_HIM, HE_HIM_F))
					return TRUE
			if("She/her")
				if(partner.pronouns in list(SHE_HER, SHE_HER_M))
					return TRUE
			if("They/them")
				if(partner.pronouns in list(THEY_THEM, THEY_THEM_F))
					return TRUE
			if("It/its")
				if(partner.pronouns == IT_ITS)
					return TRUE
	return FALSE

/datum/component/virgin_nerves/proc/check_virginity(mob/living/carbon/human/recipient)
	if(recipient.virginity)
		return TRUE
	recipient.remove_stress(/datum/stressevent/virgin_nerves)
	recipient.remove_stress(/datum/stressevent/virgin_discomfort)
	REMOVE_TRAIT(recipient, TRAIT_VIRGIN_NERVES, TRAIT_VIRTUE)
	if(unwanted_loss)
		recipient.add_stress(/datum/stressevent/virgin_regret)
		to_chat(recipient, negative_message("That experience left me unsettled rather than more confident."))
	else
		recipient.add_stress(/datum/stressevent/virgin_confidence)
		to_chat(recipient, positive_message("I feel more confident about intimacy now."))
		to_chat(recipient, positive_message("The nervous flutter I felt around attractive people has faded."))
	qdel(src)
	return FALSE

/datum/component/virgin_nerves/proc/positive_message(message)
	return "<span class='warning' style='color:#ffb6c1'>[message]</span>"

/datum/component/virgin_nerves/proc/negative_message(message)
	return "<span class='love_ludicrous'>[message]</span>"

/datum/component/virgin_nerves/proc/blush(mob/living/carbon/human/recipient, passive)
	if(QDELETED(src) || QDELETED(recipient) || !recipient.client || recipient.stat != CONSCIOUS || !recipient.virginity || (passive && recipient.cmode))
		return
	recipient.emote("blush")

/datum/component/virgin_nerves/proc/show_fluster(mob/living/carbon/human/recipient, passive = FALSE)
	if(passive && recipient.cmode)
		return
	if(prob(35))
		INVOKE_ASYNC(src, PROC_REF(blush), recipient, passive)
	// A slower left-right cycle stays subtle without changing general jitteriness.
	if(!recipient.jitteriness && !recipient.lying)
		var/resting_pixel_x = recipient.pixel_x
		animate(recipient, pixel_x = resting_pixel_x - 1, time = 2, loop = 2)
		animate(pixel_x = resting_pixel_x + 1, time = 2)
		animate(pixel_x = resting_pixel_x, time = 2)

/datum/component/virgin_nerves/proc/on_life(mob/living/carbon/human/recipient)
	SIGNAL_HANDLER
	if(!recipient.client || !recipient.mind || recipient.stat != CONSCIOUS)
		return
	if(!check_virginity(recipient))
		return
	if(recipient.cmode || world.time < next_check)
		return
	next_check = world.time + 2 MINUTES
	if(is_blind(recipient))
		return
	for(var/mob/living/carbon/human/nearby in view(7, recipient))
		if(nearby == recipient || nearby.stat == DEAD || !matches_attraction(nearby))
			continue
		if(!HAS_TRAIT(nearby, TRAIT_PRETTY) && !HAS_TRAIT(nearby, TRAIT_BEAUTIFUL))
			continue
		recipient.add_stress(/datum/stressevent/virgin_nerves)
		to_chat(recipient, positive_message(pick("Their looks leave me a little flustered.", "I feel butterflies around someone so attractive.", "I try to compose myself, but my cheeks feel warm.")))
		show_fluster(recipient, TRUE)
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
		to_chat(recipient, negative_message(pick("This closeness leaves me uneasy rather than excited.", "I feel uncomfortable with their intimate attention.")))
		to_chat(partner, positive_message("[recipient]'s heart pounds audibly, and a nervous sheen of sweat forms on their skin. They seem uneasy with the contact."))
		return
	next_affection = world.time + 1 MINUTES
	recipient.add_stress(/datum/stressevent/virgin_nerves)
	to_chat(recipient, positive_message(pick("Their touch makes my heart race. I can hardly hide how flustered I feel.", "I feel a nervous warmth spread through me at their affection.")))
	to_chat(partner, positive_message("I can hear [recipient]'s heart pounding, and notice a nervous sheen of sweat on their skin."))
	show_fluster(recipient)

/mob/living/carbon/human/proc/react_to_virgin_affection(mob/living/carbon/human/partner)
	if(QDELETED(src) || QDELETED(partner) || !ishuman(partner))
		return
	var/datum/component/virgin_nerves/nerves = GetComponent(/datum/component/virgin_nerves)
	if(istype(nerves))
		nerves.on_affection(src, partner)

/// Keep the existing flag transition while attributing this first experience to its actual partner.
/mob/living/carbon/human/proc/lose_virginity(mob/living/carbon/human/partner)
	if(QDELETED(src) || !virginity)
		return FALSE
	var/datum/component/virgin_nerves/nerves = GetComponent(/datum/component/virgin_nerves)
	if(istype(nerves) && !QDELETED(partner) && ishuman(partner) && partner != src)
		nerves.unwanted_loss = !nerves.matches_attraction(partner)
	virginity = FALSE
	return TRUE
