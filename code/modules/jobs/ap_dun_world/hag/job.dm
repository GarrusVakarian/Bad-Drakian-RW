/datum/job/roguetown/hag
	title = "Hag"
	flag = (1<<8)
	department_flag = WANDERERS
	antag_job = TRUE // whoever wrote this, I'm- gghrhhah!
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	allowed_races = RACES_SHUNNED_UP
	tutorial = "You are ancient, malevolent evil. None of the known gods claim to have brought you into this world. All you know is hatred, how to sift through the grains of this land with your calloused hands, picking those who prove themselves useful."
	outfit = null
	outfit_female = null
	display_order = JDO_WRETCH + 0.1
	show_in_credits = TRUE
	// Difficult role to play right without failRP / LRP
	min_pq = 50
	max_pq = null


	advclass_cat_rolls = list(CTAG_HAG = 20)
	PQ_boost_divider = 10
	round_contrib_points = 2

	announce_latejoin = FALSE
	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = TRUE
	job_reopens_slots_on_death = FALSE
	same_job_respawn_delay = 1 MINUTES
	virtue_restrictions = list(
		/datum/virtue/utility/noble,
		/datum/virtue/combat/dualwielder, //Hags are too powerful, abusable
		/datum/virtue/utility/socialite, // Not intended to be residents
		/datum/virtue/movement/acrobatic, //This should be given to them when they are actually after a Hunted
		/datum/virtue/utility/woodwalker, //This should be given to them when they are actually after a Hunted
		/datum/virtue/utility/riding, // Hags literally get a teleportation mechanic, it doesn't make much sense.
		)

	job_subclasses = list(
		/datum/advclass/hag,
	)
