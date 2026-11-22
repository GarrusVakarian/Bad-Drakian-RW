// AP Dun World uses Bad Drakian's jobs and regions on Azure Peak's layout.
/datum/map_adjustment/template/dunworld/ap
	map_file_name = "ap_dun_world.dmm"
	realm_name = "Azuria"
	job_spawn_keys = list(
		/datum/job/roguetown/butler = /obj/item/roguekey/ap_seneschal,
		/datum/job/roguetown/veteran = /obj/item/roguekey/ap_veteran,
		/datum/job/roguetown/absolver = /obj/item/roguekey/ap_absolver,
		/datum/job/roguetown/puritan = /obj/item/roguekey/ap_absolver,
	)

/datum/map_adjustment/template/dunworld/ap/job_change()
	. = ..()
	// Azuria has no separate baronial court or slave market.
	change_job_position(/datum/job/roguetown/baron, 0)
	change_job_position(/datum/job/roguetown/baron_retainer, 0)
	change_job_position(/datum/job/roguetown/slaver, 0)
	change_job_position(/datum/job/roguetown/rockhillslave, 0)
	change_job_position(/datum/job/roguetown/adventurer/courtslave, 0)
	change_job_position(/datum/job/roguetown/prisonerr, 2)
	change_job_position(/datum/job/roguetown/sexton, 3)
	var/datum/job/man_at_arms = SSjob.GetJobType(/datum/job/roguetown/manorguard)
	man_at_arms.job_subclasses |= /datum/advclass/manorguard/bailiff
	var/datum/job/councillor = SSjob.GetJobType(/datum/job/roguetown/councillor)
	councillor.job_subclasses |= list(
		/datum/advclass/councillor/herald,
		/datum/advclass/councillor/cofferer,
		/datum/advclass/councillor/castellan,
	)
	var/datum/job/mercenary = SSjob.GetJobType(/datum/job/roguetown/mercenary)
	mercenary.job_subclasses |= /datum/advclass/mercenary/gronn
	var/datum/job/bandit = SSjob.GetJobType(/datum/job/roguetown/bandit)
	bandit.job_subclasses |= /datum/advclass/hedgealchemist
	var/datum/job/wretch = SSjob.GetJobType(/datum/job/roguetown/wretch)
	wretch.job_subclasses |= list(
		/datum/advclass/wretch/munitioneer,
		/datum/advclass/wretch/slasher,
		/datum/advclass/wretch/freeblade,
		/datum/advclass/wretch/profane_champion,
	)

	change_job_position(/datum/job/roguetown/lamplighter, 3)
	change_job_position(/datum/job/roguetown/hag, 0)
	add_ap_subclasses(/datum/job/roguetown/villager, list(/datum/advclass/levy))
	change_job_position(/datum/job/roguetown/painter, 1)
	add_ap_subclasses(/datum/job/roguetown/monk, list(/datum/advclass/herald))
	add_ap_subclasses(/datum/job/roguetown/templar, list(/datum/advclass/templar/maris))
	mercenary.job_subclasses |= list(
		/datum/advclass/mercenary/etrusca_condottiero,
		/datum/advclass/mercenary/blackoak_adept,
		/datum/advclass/mercenary/trollslayer,
	)
	wretch.job_subclasses |= list(
		/datum/advclass/wretch/heretic_spellblade,
		/datum/advclass/wretch/maestro,
	)
	add_ap_subclasses(/datum/job/roguetown/adventurer, list(/datum/advclass/rogue/antiquarian, /datum/advclass/mage/spellfist, /datum/advclass/foreigner/lesserblackoak))
	add_ap_subclasses(/datum/job/roguetown/templar, list(/datum/advclass/templar/noc_spellblade))
	add_ap_subclasses(/datum/job/roguetown/orphan, list(/datum/advclass/vagabond_thrall, /datum/advclass/vagabond_accursed))


/datum/map_adjustment/template/dunworld/ap/proc/add_ap_subclasses(job_type, list/additions)
	var/datum/job/job = SSjob.GetJobType(job_type)
	if(job && length(job.job_subclasses))
		job.job_subclasses |= additions
