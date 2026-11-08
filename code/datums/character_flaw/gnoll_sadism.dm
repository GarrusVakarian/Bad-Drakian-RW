/// Innate Sadist compatibility without addiction processing or withdrawal.
/datum/charflaw/addiction/sadist/gnoll
	name = "Gnoll Sadism"
	desc = "The suffering of others pleases me, but I suffer no ill effects from going without it."
	point_value = 0
	ephemeral = TRUE // Skip deprivation processing in the human life loop.
	needsate_text = null
	stress_event = null
	debuff = null

/datum/charflaw/addiction/sadist/gnoll/flaw_on_life(mob/user)
	return

/datum/charflaw/addiction/sadist/gnoll/on_sated(mob/living/carbon/human/user)
	if(QDELETED(user))
		return
	// Also protect callers which added an ordinary vice without its creation hook.
	if(user.has_standard_sadism())
		user.remove_gnoll_sadism()
		return
	user.add_stress(/datum/stressevent/gnoll_sadism)

/datum/charflaw/addiction/sadist/gnoll/on_removal(mob/user)
	. = ..()
	if(ishuman(user))
		user.remove_stress(/datum/stressevent/gnoll_sadism)

/datum/stressevent/gnoll_sadism
	timer = 5 MINUTES
	stressadd = -2
	desc = span_green("The suffering of others has pleased my cruel nature.")
	max_stacks = 1

/// A separate check is needed because has_flaw(Sadist) also matches Gnoll Sadism.
/mob/living/carbon/human/proc/has_standard_sadism()
	for(var/datum/charflaw/addiction/sadist/vice in vices)
		if(!istype(vice, /datum/charflaw/addiction/sadist/gnoll))
			return TRUE
	return istype(charflaw, /datum/charflaw/addiction/sadist) && !istype(charflaw, /datum/charflaw/addiction/sadist/gnoll)

/mob/living/carbon/human/proc/remove_gnoll_sadism()
	var/list/innate_vices = list()
	for(var/datum/charflaw/addiction/sadist/gnoll/vice in vices)
		innate_vices |= vice
	if(istype(charflaw, /datum/charflaw/addiction/sadist/gnoll))
		innate_vices |= charflaw
	for(var/datum/charflaw/addiction/sadist/gnoll/vice as anything in innate_vices)
		while(vice in vices)
			vices -= vice
		if(charflaw == vice)
			charflaw = null
		vice.on_removal(src)
		qdel(vice)

/// Called after Gnoll preference cleanup and safe to repeat on preference updates.
/mob/living/carbon/human/proc/ensure_gnoll_sadism()
	if(has_standard_sadism())
		remove_gnoll_sadism()
		return null
	var/datum/charflaw/addiction/sadist/gnoll/innate_vice = get_flaw(/datum/charflaw/addiction/sadist/gnoll)
	if(innate_vice)
		return innate_vice
	innate_vice = new
	LAZYADD(vices, innate_vice)
	innate_vice.on_mob_creation(src)
	return innate_vice
