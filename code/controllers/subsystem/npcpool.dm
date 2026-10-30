SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/currentrun = list()

/datum/controller/subsystem/npcpool/stat_entry()
	var/list/activelist = GLOB.simple_animals[AI_ON]
	..("NPCS:[activelist.len]")

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

	if (!resumed || !src.currentrun.len)
		var/list/activelist = GLOB.simple_animals[AI_ON]
		src.currentrun = activelist.Copy()

	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len

		if(!can_process_npc(SA))
			continue
		SA.handle_automated_action()
		if(can_process_npc(SA))
			SA.handle_automated_movement()
			if(can_process_npc(SA))
				SA.handle_automated_speech()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/npcpool/proc/can_process_npc(mob/living/simple_animal/animal)
	return !QDELETED(animal) && !animal.ckey && !animal.notransform && animal.stat != DEAD && animal.AIStatus == AI_ON

/datum/controller/subsystem/npcpool/proc/handle_automated_action(mob/living/simple_animal/mobinput)
	if(!mobinput)
		return
	if(QDELETED(mobinput))
		return
	mobinput.handle_automated_action()
	mobinput.action_skip = FALSE

/datum/controller/subsystem/npcpool/proc/handle_automated_movement(mob/living/simple_animal/mobinput)
	if(!mobinput)
		return
	if(QDELETED(mobinput))
		return
	mobinput.handle_automated_movement()
	mobinput.move_skip = FALSE
