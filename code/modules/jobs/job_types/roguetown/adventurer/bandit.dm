/datum/job/roguetown/bandit //pysdon above there's like THREE bandit.dms now I'm so sorry. This one is latejoin bandits, the one in villain is the antag datum, and the one in the 'antag' folder is an old adventurer class we don't use. Good luck!
	title = "Bandit"
	flag = BANDIT
	department_flag = WANDERERS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	antag_job = TRUE
	allowed_races = RACES_ALL_KINDS
	tutorial = "At some point in your lyfe, you'd fallen to the wrong side of the carriage. Whether by butchery or finesse, you're known throughout the land. \
	Yet one of many faces in a tavern, hung up on a wall. A tale told by the locals. Now, you lyve in a camp with your fellows, to avoid an unpleasant end."

	outfit = null
	outfit_female = null

	obsfuscated_job = TRUE

	display_order = JDO_BANDIT
	announce_latejoin = FALSE
	min_pq = 15
	max_pq = null
	round_contrib_points = 5
	allowed_patrons = ALL_INHUMEN_PATRONS
	quirk_restrictions = list(/datum/quirk/assassintarget)
	advclass_cat_rolls = list(CTAG_BANDIT = 20)
	PQ_boost_divider = 10

	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = FALSE
	job_reopens_slots_on_death = FALSE //no endless stream of bandits, unless the migration waves deem it so
	job_traits = list(TRAIT_SELF_SUSTENANCE, TRAIT_DEATHBYSNUSNU, TRAIT_STEELHEARTED, TRAIT_HERESIARCH)
	same_job_respawn_delay = 1 MINUTES
	cmode_music = 'sound/music/cmode/antag/combat_deadlyshadows.ogg'
	job_subclasses = list(
		/datum/advclass/brigand,
		/datum/advclass/hedgeknight,
		/datum/advclass/iconoclast,
		/datum/advclass/knave,
		/datum/advclass/roguemage,
		/datum/advclass/sawbones,
		/datum/advclass/sellsword,
		/datum/advclass/pioneer
	)

/datum/job/roguetown/bandit/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(!H.mind)
			return
		H.ambushable = FALSE

/datum/outfit/job/roguetown/bandit/pre_equip(mob/living/carbon/human/H)
	. = ..()
	H.verbs |= /mob/proc/haltyell_exhausting

/datum/outfit/job/roguetown/bandit/post_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
		H.mind.add_antag_datum(new_antag)
		H.grant_language(/datum/language/thievescant)
		H.choose_name_popup("BANDIT")
		bandit_select_bounty(H)

// Bandits may decline a bounty entirely.
/proc/bandit_select_bounty(mob/living/carbon/human/H)
	if(QDELETED(H) || !H.client)
		return
	var/list/preset = H.bounty_presets?["Bandit"]
	var/wanted_choice = preset ? (preset["declined"] ? "No" : "Yes") : input(H, "Are you wanted by the kingdom?", "Bounty") as anything in list("Yes", "No")
	if(wanted_choice != "Yes")
		to_chat(H, span_warning("I am still relatively new to the gang. My crimes have gone unnoticed so far, but I lack experience."))
		return
	if(QDELETED(H) || !H.client)
		return
	var/issuer = preset ? preset["issuer"] : choose_character_bounty_issuer(H, "Bandit")
	var/bounty_poster = character_bounty_issuer(issuer)
	if(QDELETED(H) || !H.client || !bounty_poster)
		return
	var/bounty_severity = preset ? preset["tier"] : choose_character_bounty_tier(H, "Bandit")
	var/bounty_total = roll_character_bounty_reward("Bandit", bounty_severity)
	if(!bounty_total || QDELETED(H) || !H.client)
		return
	var/description_level = BOUNTY_DESCRIPTION_FULL
	var/recognition = BOUNTY_RECOGNITION_FACE
	if(bounty_severity == "Small Game")
		var/visibility = preset ? preset["visibility"] : choose_bounty_description(H, "Bandit")
		if(visibility != "full")
			description_level = BOUNTY_DESCRIPTION_BUILD
	else if(bounty_severity == "Realm Boogeyman")
		recognition = preset ? preset["recognition"] : choose_bounty_recognition(H)
		if(isnull(recognition))
			recognition = BOUNTY_RECOGNITION_FACE
	if(QDELETED(H) || !H.client)
		return
	var/my_crime = preset ? preset["crime"] : input(H, "What is your crime?", "Crime") as text|null
	if(QDELETED(H))
		return
	if(!my_crime)
		my_crime = "Brigandry"
	ADD_TRAIT(H, TRAIT_KNOWNCRIMINAL, TRAIT_GENERIC)
	add_character_bounty(H, bounty_total, TRUE, my_crime, bounty_poster, description_level, recognition)
	to_chat(H, span_danger("You are playing an Antagonist role. By choosing to spawn as a Bandit, you are expected to actively create conflict with other players regardless of bounty status. Failing to play this role with the appropriate gravitas may result in punishment for Low Roleplay standards."))
