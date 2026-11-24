/datum/charflaw/lawless
	name = "Lawless"
	desc = "I've always felt the rules were a bit more like guidelines than actual rules, and have accrued enough notoriety to have a bounty out on my head. (Taking this vice when on a class that already has a roundstart bounty will randomize your flaw instead.)"
	var/attempts_left = 2

/datum/charflaw/lawless/on_mob_creation(mob/H)
	if(istype(H, /mob/living/carbon/human/dummy)) // DON'T TRY TO APPLY THIS FUCKING FLAW TO PREVIEW DUMMIES HOLY SHIT
		return
	addtimer(CALLBACK(src, PROC_REF(set_up), H), 30 SECONDS)

/datum/charflaw/lawless/proc/set_up(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	if (has_bounty(H) || (H.job && H.job == "Wretch") || (H.advjob && H.advjob == "Wanted") || (H.job && H.job == "Bandit"))
		// no doubling up on this stuff, you just get a random flaw instead.
		var/list/flaws_without_random = GLOB.character_flaws.Copy()
		flaws_without_random -= "Random or No Flaw"
		var/datum/charflaw/our_new_flaw = GLOB.character_flaws[pick(flaws_without_random)]
		H.charflaw = new our_new_flaw()
		H.charflaw.on_mob_creation(H)
		to_chat(H, span_warning("The thrill of lawlessness is not enough anymore... fate renders my flaw to be: <b>[H.charflaw.name]</b>."))
		return

	// if our mob has no client, input will runtime
	if(!H.client) // if our player somehow disconnected, give them another shot
		if(attempts_left <= 0)
			return // give up
		attempts_left--
		addtimer(CALLBACK(src, PROC_REF(set_up), H), 30 SECONDS)
		return
	var/list/preset = H.bounty_presets?["Lawless"]
	var/visibility = preset ? preset["visibility"] : choose_lawless_bounty_visibility(H)
	if(QDELETED(H) || !H.client)
		return
	var/issuer = preset ? preset["issuer"] : choose_character_bounty_issuer(H, "Lawless")
	if(QDELETED(H) || !H.client)
		return
	if(!issuer)
		issuer = "justiciary"
	var/bounty_poster = character_bounty_issuer(issuer)
	var/bounty_size = preset ? preset["tier"] : choose_character_bounty_tier(H, "Lawless")
	if(QDELETED(H) || !H.client)
		return
	var/bounty_total = roll_character_bounty_reward("Lawless", bounty_size)
	if(!bounty_total)
		bounty_total = rand(100, 200)
	var/my_crime = preset ? preset["crime"] : input(H, "What is your crime?", "Crime") as text|null
	if (!my_crime)
		my_crime = "crimes against the Crown"
	if(QDELETED(H))
		return
	var/description_level = visibility == "build" ? BOUNTY_DESCRIPTION_BUILD : BOUNTY_DESCRIPTION_FULL
	var/recognition = BOUNTY_RECOGNITION_NONE
	if(visibility == "face")
		recognition = BOUNTY_RECOGNITION_FACE
	add_character_bounty(H, bounty_total, FALSE, my_crime, bounty_poster, description_level, recognition)
	if(HAS_TRAIT(H, TRAIT_NOBLE))
		REMOVE_TRAIT(H, TRAIT_NOBLE, JOB_TRAIT)
		REMOVE_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		REMOVE_TRAIT(H, TRAIT_NOBLE, ADVENTURER_TRAIT)
		ADD_TRAIT(H, TRAIT_DISGRACED_NOBLE, TRAIT_GENERIC)
		H.is_noble()
	if (visibility == "face")
		if(issuer == "justiciary")
			GLOB.outlawed_players += H.real_name
		else
			GLOB.excommunicated_players += H.real_name
	to_chat(H, span_notice("There's a sum of mammons on my head... better lay low."))
