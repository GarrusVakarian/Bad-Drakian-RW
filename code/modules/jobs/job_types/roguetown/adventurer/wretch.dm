// Wretch, soft antagonists. Giving them a significant boon in stats due to their general presence as driving antagonists.
/datum/job/roguetown/wretch
	title = "Wretch"
	flag = WRETCH
	department_flag = WANDERERS
	faction = "Station"
	total_positions = 9
	spawn_positions = 9
	allowed_races = RACES_ALL_KINDS
	tutorial = "Somewhere in your lyfe, you fell to the wrong side of civilization. Hounded by the consequences of your actions, you spend your daes prowling the roads for easy marks and loose purses, scraping to get by."
	outfit = null
	outfit_female = null
	display_order = JDO_WRETCH
	show_in_credits = FALSE
	min_pq = 5
	max_pq = null
	quirk_restrictions = list(/datum/quirk/assassintarget)

	obsfuscated_job = TRUE
	class_categories = TRUE

	advclass_cat_rolls = list(CTAG_WRETCH = 20)
	PQ_boost_divider = 10
	round_contrib_points = 2

	announce_latejoin = FALSE
	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = FALSE
	job_reopens_slots_on_death = FALSE
	same_job_respawn_delay = 1 MINUTES
	virtue_restrictions = list(/datum/virtue/utility/zchurch_keyholder) //all wretch classes automatically get this
	carebox_table = /datum/carebox_table/wretch
	job_traits = list(TRAIT_STEELHEARTED, TRAIT_OUTLAW, TRAIT_HERESIARCH, TRAIT_SELF_SUSTENANCE, TRAIT_ZURCH, TRAIT_BANDITCAMP)
	job_subclasses = list(
		/datum/advclass/wretch/licker,
		/datum/advclass/wretch/deserter,
		/datum/advclass/wretch/deserter/maa,
		/datum/advclass/wretch/berserker,
		/datum/advclass/wretch/hedgemage,
		/datum/advclass/wretch/necromancer,
		/datum/advclass/wretch/heretic,
		/datum/advclass/wretch/heretic/spy,
		/datum/advclass/wretch/heretic/monk,
		/datum/advclass/wretch/outlaw,
		/datum/advclass/wretch/outlaw/marauder,
		/datum/advclass/wretch/buccaneer,
		/datum/advclass/wretch/wildwitch,
		/datum/advclass/wretch/lunacyembracer,
		/datum/advclass/wretch/poacher,
		/datum/advclass/wretch/plaguebearer,
		/datum/advclass/wretch/mistwalker,
		/datum/advclass/wretch/pyromaniac,
		/datum/advclass/wretch/vigilante,
		/datum/advclass/wretch/herald_of_progress,
		/datum/advclass/wretch/blackoakwyrm,
		/datum/advclass/wretch/antipope,
		/datum/advclass/wretch/wretchedtoiler,
		/datum/advclass/wretch/ancientchampion,
	)

/datum/job/roguetown/wretch/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		// Assign wretch antagonist datum so wretches appear in antag list
		if(H.mind && !H.mind.has_antag_datum(/datum/antagonist/wretch))
			var/datum/antagonist/new_antag = new /datum/antagonist/wretch()
			H.mind.add_antag_datum(new_antag)

// Proc for wretch to select a bounty
/proc/wretch_select_bounty(mob/living/carbon/human/H)
	if(QDELETED(H) || !H.client)
		return
	var/justiciary = "The Justiciary of [SSmapping.map_adjustment.realm_name]"
	var/bounty_poster = input(H, "Who placed a bounty on you?", "Bounty Poster") as anything in list(justiciary, "The Grenzelhoftian Holy See", "The Otavan Orthodoxy")
	if(QDELETED(H) || !H.client || !bounty_poster)
		return
	var/bounty_severity = choose_bounty_tier(H, "How severe are your crimes?", "Bounty Amount", list("Misdeed", "Harm towards lyfe", "Horrific atrocities"), minor_notice_requires_description = TRUE)
	var/bounty_total
	var/description_level = BOUNTY_DESCRIPTION_FULL
	var/recognition = BOUNTY_RECOGNITION_FACE
	switch(bounty_severity)
		if("Misdeed")
			bounty_total = rand(100, 200)
			description_level = choose_bounty_full_description(H) ? BOUNTY_DESCRIPTION_FULL : BOUNTY_DESCRIPTION_BUILD
			if(description_level == BOUNTY_DESCRIPTION_BUILD)
				recognition = BOUNTY_RECOGNITION_NONE
		if("Harm towards lyfe")
			bounty_total = rand(200, 300)
		if("Horrific atrocities")
			bounty_total = rand(300, 400)
			recognition = BOUNTY_RECOGNITION_ALWAYS
		else
			return
	if(QDELETED(H) || !H.client)
		return
	var/my_crime = input(H, "What is your crime?", "Crime") as text|null
	if(QDELETED(H))
		return
	if(!my_crime)
		my_crime = "crimes against the Crown"
	// Keep the existing legal or religious consequences of the highest tier.
	if(bounty_severity == "Horrific atrocities")
		if(bounty_poster == justiciary)
			GLOB.outlawed_players |= H.real_name
		else
			GLOB.excommunicated_players |= H.real_name
	add_character_bounty(H, bounty_total, FALSE, my_crime, bounty_poster, description_level, recognition)
	H.playsound_local(get_turf(H), 'sound/music/traitor.ogg', 60, FALSE, pressure_affected = FALSE)
