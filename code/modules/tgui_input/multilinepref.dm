/mob
	var/tgui_multiline = TRUE

/mob/verb/toggle_tgui_multiline()
	set name = "Toggle TGUI Multiline"
	set category = "Options"
	set hidden = 1

	tgui_multiline = !tgui_multiline
	if(client?.prefs && !client.prefs.content_toggles_customized)
		client.prefs.content_toggles_customized = TRUE
		client.prefs.save_preferences()
	to_chat(src,span_notice("TGUI Multiline is now [tgui_multiline ? "Enabled" : "Disabled"]"))
