
/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	mouse_drag_pointer = MOUSE_INACTIVE_POINTER
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/dummy/ignite_mob()
	return FALSE

/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays(TRUE)

/mob/living/carbon/human/dummy/setup_human_dna()
	create_dna(src)
	randomize_human(src)
	dna.initialize_dna(skip_index = TRUE) //Skip stuff that requires full round init.

//Inefficient pooling/caching way.
GLOBAL_LIST_EMPTY(human_dummy_list)
GLOBAL_LIST_EMPTY(dummy_mob_list)

/proc/generate_or_wait_for_human_dummy(slotkey)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	while(TRUE)
		// A waiting caller must recheck the slot if cleanup discarded its dummy.
		var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
		if(QDELETED(D))
			D = new
			GLOB.human_dummy_list[slotkey] = D
			GLOB.dummy_mob_list += D
		if(!D.in_use)
			D.in_use = TRUE
			return D
		stoplag()

/proc/unset_busy_human_dummy(slotnumber)
	if(!slotnumber)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotnumber]
	if(istype(D))
		try
			D.wipe_state()
		catch(var/exception/error)
			// Do not leave a broken dummy locked or hand its partial state to another caller.
			GLOB.human_dummy_list -= slotnumber
			GLOB.dummy_mob_list -= D
			qdel(D)
			throw error
		D.in_use = FALSE

// fuck if I know - fill in for unit tests later
/mob/living/carbon/human/consistent
