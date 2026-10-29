// Per-character egg settings. Stored as a plain list on the penis/vagina customizer entries,
// carried through organ DNA and onto the organ itself so both organ kinds share one format.

/proc/default_oviposition_settings()
	return list(
		"name" = "",
		"desc" = "",
		"color" = "",
		"clutch" = OVI_EGG_DEFAULT_CLUTCH,
	)

/proc/sanitize_oviposition_settings(list/settings)
	var/list/clean = default_oviposition_settings()
	if(!islist(settings))
		return clean
	if(istext(settings["name"]))
		clean["name"] = copytext_char(settings["name"], 1, OVI_EGG_MAX_NAME_LENGTH + 1)
	if(istext(settings["desc"]))
		clean["desc"] = copytext_char(settings["desc"], 1, OVI_EGG_MAX_DESC_LENGTH + 1)
	clean["color"] = sanitize_oviposition_color(settings["color"])
	clean["clutch"] = sanitize_integer(settings["clutch"], 1, OVI_EGG_MAX_CLUTCH, OVI_EGG_DEFAULT_CLUTCH)
	return clean

/// Returns a "#rrggbb" string, or "" when the input is not a valid color.
/proc/sanitize_oviposition_color(color_input)
	if(!istext(color_input) || !findtext(color_input, regex(@"^#[0-9a-fA-F]{6}$")))
		return ""
	return lowertext(color_input)

/// Adds the egg settings rows to a genital customizer panel.
/proc/oviposition_pref_choices(list/dat, list/settings, customizer_type, enabled, toggle_label)
	dat += "<br>[toggle_label]: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ovi_toggle'>[enabled ? "YES" : "NO"]</a>"
	if(!enabled)
		return
	var/egg_name = settings["name"]
	var/egg_color = settings["color"]
	dat += "<br>Clutch size: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ovi_clutch'>[settings["clutch"]]</a>"
	dat += "<br>Egg name: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ovi_name'>[egg_name ? egg_name : "Default"]</a>"
	dat += "<br>Egg description: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ovi_desc'>[settings["desc"] ? "Custom" : "Default"]</a>"
	dat += "<br>Egg color: <a href='?_src_=prefs;task=change_customizer;customizer=[customizer_type];customizer_task=ovi_color'>[egg_color ? "<span style='border: 1px solid #161616; background-color: [egg_color];'>&nbsp;&nbsp;&nbsp;</span>" : "Default"]</a>"

/// Handles the egg settings rows. Returns TRUE if the task was one of ours.
/proc/oviposition_pref_topic(mob/user, task, list/settings)
	switch(task)
		if("ovi_clutch")
			var/new_clutch = input(user, "How many eggs form in a clutch? (1-[OVI_EGG_MAX_CLUTCH])", "Clutch Size", settings["clutch"]) as num|null
			if(!isnull(new_clutch))
				settings["clutch"] = sanitize_integer(new_clutch, 1, OVI_EGG_MAX_CLUTCH, OVI_EGG_DEFAULT_CLUTCH)
			return TRUE
		if("ovi_name")
			var/new_name = tgui_input_text(user, "Name your eggs. Leave blank for the default.", "Egg Name", settings["name"], OVI_EGG_MAX_NAME_LENGTH)
			if(!isnull(new_name))
				settings["name"] = new_name
			return TRUE
		if("ovi_desc")
			var/new_desc = tgui_input_text(user, "Describe your eggs. Leave blank for the default.", "Egg Description", settings["desc"], OVI_EGG_MAX_DESC_LENGTH, multiline = TRUE)
			if(!isnull(new_desc))
				settings["desc"] = new_desc
			return TRUE
		if("ovi_color")
			var/new_color = input(user, "Choose your egg color. Cancel to use the default.", "Egg Color", settings["color"] || "#f0e6c8") as color|null
			settings["color"] = sanitize_oviposition_color(new_color)
			return TRUE
	return FALSE
