////////
//LEVY//
////////

// CTRL + SHIFT + RMB -- Combat Callout!

/// Point at a target and shout a context-sensitive callout. Only works if there is more than one TRAIT_AP_LEVY around you.
/mob/proc/ap_levy_callout_point(atom/A)
	if(!client || !mind)
		return

	if(!HAS_TRAIT(src, TRAIT_AP_LEVY))
		return

	if(istype(A, /obj/effect/temp_visual/point))
		return

	if(!linepoint(A))
		return

	if(world.time < mob_timers["contact_callout"] + 10 SECONDS)
		return

	var/nearby_levies = 0
	for(var/mob/living/carbon/human/H in view(8, src))
		if(H == src)
			continue

		if(HAS_TRAIT(H, TRAIT_AP_LEVY))
			nearby_levies++

	if(!nearby_levies)
		return

	mob_timers["contact_callout"] = world.time

	var/contact_desc = A.name

	if(ishuman(A))
		var/mob/living/carbon/human/H = A

		var/list/d_list = H.get_mob_descriptors_unknown(FALSE, src)
		var/trait_desc = build_coalesce_description_nofluff(d_list, H, list(MOB_DESCRIPTOR_SLOT_TRAIT), "%DESC1%")
		var/stature_desc = build_coalesce_description_nofluff(d_list, H, list(MOB_DESCRIPTOR_SLOT_STATURE), "%DESC1%")
		contact_desc = trim("[trait_desc] [stature_desc]")
		if(H.stat != CONSCIOUS)
			contact_desc = trim("[contact_desc] fallen")
		if(!length(contact_desc))
			contact_desc = "someone"

	var/dist = get_dist(src, A)
	var/dir_text = dir2text(get_dir(src, A))

	var/msg

	// Valuable loot
	if(istype(A, /obj/item/rogueore/gold) || istype(A, /obj/item/rogueore/silver) || istype(A, /obj/item/roguegem))
		msg = "Shiny! [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"

	// Living targets
	else if(ismob(A))
		var/zone_name = LOWER_TEXT(parse_zone(zone_selected))

		if(cmode)
			var/list/aggressive = list(
				"[capitalize(contact_desc)]! Get 'em!",
				"[capitalize(contact_desc)]! On 'em!",
				"[capitalize(contact_desc)]! Bring 'em down!",
				"[capitalize(contact_desc)]! There!",
				"[capitalize(contact_desc)]! Kill the bastard!",
				"[capitalize(contact_desc)]! Flank 'em!",
			)

			msg = pick(aggressive)

			if(zone_name)
				msg += " Go for the [uppertext(zone_name)]!"

		else
			if(isliving(A))
				var/mob/living/L = A

				if(L.stat != CONSCIOUS)
					if(L.resting)
						msg = "[capitalize(contact_desc)], DOWN and OUT, [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"
				else if(L.resting)
					msg = "[capitalize(contact_desc)], DOWN, [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"
				else
					msg = "[capitalize(contact_desc)], [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"

	// Ground
	else if(isturf(A))
		var/turf/T = A

		if(cmode)
			msg = "Move there! [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"
		else
			msg = "[capitalize(T.name)], [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"

	// Objects
	else
		var/object_name = capitalize(A.name)

		if(cmode)
			msg = "[object_name]! Break that! [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"
		else
			msg = "[object_name], [dist] [dist == 1 ? "pace" : "paces"] [dir_text]!"

	if(msg)
		say_verb(msg)
