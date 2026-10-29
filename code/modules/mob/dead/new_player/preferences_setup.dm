
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override, antag_override = FALSE, ft_reset = TRUE)
	if(!pref_species)
		random_species()
	real_name = pref_species.random_name(gender,1)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	age = AGE_ADULT
	var/list/skins = pref_species.get_skin_list()
	skin_tone = skins[pick(skins)]
	eye_color = random_eye_color()
	if(ft_reset)
		flavortext = null
		nsfwflavortext = null
		ooc_extra_img = null
		ooc_extra_img_link = null
		nsfw_ooc_extra_img = null
		nsfw_ooc_extra_img_link = null
		erpprefs = null
		ooc_notes = null
		ooc_extra = null
		song_title = null
		song_artist = null
		headshot_link = null
		img_gallery = null
		nsfw_img_gallery = null
	features = pref_species.get_random_features()
	body_markings = pref_species.get_random_body_markings(features)
	accessory = "Nothing"
	bark_id = pick(GLOB.bark_random_list)
	bark_pitch = BARK_PITCH_RAND(gender)
	bark_variance = BARK_VARIANCE_RAND
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()

/datum/preferences/proc/random_species()
	var/random_species_type = GLOB.species_list[pick(get_selectable_species())]
	pref_species = new random_species_type
	if(randomise[RANDOM_NAME])
		real_name = pref_species.random_name(gender,1)
	set_new_race(new random_species_type)

/datum/preferences/proc/get_preview_job()
	var/datum/job/preview_job
	var/highest_priority = 0
	for(var/job in job_preferences)
		if(job_preferences[job] <= highest_priority)
			continue
		var/datum/job/candidate = SSjob.GetJob(job)
		if(candidate)
			preview_job = candidate
			highest_priority = job_preferences[job]
	return preview_job

/datum/preferences/proc/update_preview_icon(jobOnly = FALSE)
	set waitfor = 0
	clear_hair_preview_cache()
	if(!parent)
		return
	if(parent.is_new_player())
		return
//	last_preview_update = world.time
	// Set up the dummy for its photoshoot
	var/datum/job/previewJob = get_preview_job()
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	var/mutable_appearance/preview_appearance
	try
		copy_to(mannequin, 1, TRUE, TRUE)

		if(jobOnly && previewJob)
			mannequin.job = previewJob.title
			previewJob.equip(mannequin, TRUE, preference_source = parent)

		if(preview_subclass && !jobOnly && previewJob)
			testing("previewjob")
			mannequin.job = previewJob.title
			mannequin.patron = selected_patron
			preview_subclass.equipme(mannequin, dummy = TRUE)

		mannequin.regenerate_clothes()
		apply_preview_erect_state_to_mannequin(mannequin)
		mannequin.update_body()
		mannequin.update_hair()
		mannequin.rebuild_obscured_flags()
		preview_appearance = new /mutable_appearance(mannequin)
	catch(var/exception/error)
		unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
		throw error
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	// Release the shared mannequin before touching a client that may have disconnected.
	parent?.show_character_previews(preview_appearance)

/datum/preferences/proc/apply_preview_erect_state_to_mannequin(mob/living/carbon/human/mannequin)
	if(!mannequin)
		return
	// The oviduct reads the dummy's arousal controller, even when it has no penis.
	if(mannequin.sexcon)
		switch(preview_erect_state)
			if(ERECT_STATE_HARD)
				mannequin.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_FULL
			if(ERECT_STATE_PARTIAL)
				mannequin.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_PARTIAL
			else
				mannequin.sexcon.manual_arousal = SEX_MANUAL_AROUSAL_UNAROUSED
	var/obj/item/organ/penis/preview_penis = mannequin.getorganslot(ORGAN_SLOT_PENIS)
	if(preview_penis)
		preview_penis.erect_state = preview_erect_state
	mannequin.update_body_parts(TRUE)

/datum/preferences/proc/spec_check(mob/user)
	if(!istype(pref_species))
		return FALSE
	if(!(pref_species.name in get_selectable_species()))
		return FALSE
	if(!pref_species.check_roundstart_eligible())
		return FALSE
	if(user && (pref_species.patreon_req > user.patreonlevel()))
		return FALSE
	return TRUE

/mob/proc/patreonlevel()
	if(client)
		return client.patreonlevel()
