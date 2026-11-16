// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/area/rogue/indoors/shelter/bog_hag
	name = "Hag hut"
	icon_state = "bog"
	first_time_text = "A HUT BETWIXT THE ROOTS"
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a nasty wicked place deep betwixt the roots of the bog"
	var/list/recent_intruders = list()

/area/rogue/indoors/shelter/bog_hag/root_maze
	name = "The Deepest Roots"
	icon_state = "bog"
	first_time_text = "THE DEEPROOT"
//PILGRIM

/area/rogue/indoors/shelter/bog_hag/Entered(atom/movable/AM)
	..()
	if(!GLOB.active_hags.len)
		return

	var/mob/living/L = AM
	if(!istype(L) || !L.client || L.stat == DEAD)
		return

	if(L in GLOB.active_hags)
		return

	GLOB.bogged_players += L.real_name

	if(recent_intruders[L] && recent_intruders[L] > world.time)
		return

	recent_intruders[L] = world.time + 1 MINUTES
	for(var/mob/living/H in GLOB.active_hags)
		to_chat(H, span_boldwarning("The roots of your sanctum shiver... a soul has stepped within [src.name]."))

/area/rogue/indoors/shelter/bog_hag/Exited(atom/movable/AM)
	. = ..()
	if(!GLOB.active_hags.len)
		return

	var/mob/living/L = AM
	if(!istype(L) || !L.client || L.stat == DEAD)
		return

	if(L in GLOB.active_hags)
		return

	GLOB.bogged_players -= L.real_name
