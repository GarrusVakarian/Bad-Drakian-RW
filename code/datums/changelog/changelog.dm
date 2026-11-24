/datum/changelog
	var/static/list/changelog_items = list()

/datum/changelog/ui_state()
	return GLOB.always_state

/datum/changelog/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return TRUE

	ui = new(user, src, "Changelog")
	if(ui.open())
		return TRUE
	qdel(ui)
	return FALSE

/datum/changelog/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "get_month")
		var/datum/asset/changelog_item/changelog_item = changelog_items[params["date"]]
		if (!changelog_item)
			changelog_item = new /datum/asset/changelog_item(params["date"])
			changelog_items[params["date"]] = changelog_item
		return ui.send_asset(changelog_item)

/// Monthly archive filenames, newest first.
/proc/changelog_archive_files()
	var/list/archive_files = list()
	var/static/regex/monthly_archive = regex(@"^\d{4}-\d{2}\.yml$")
	for(var/archive_file in flist("html/changelogs/archive/"))
		if(monthly_archive.Find(archive_file))
			archive_files += archive_file
	return sort_list(archive_files, GLOBAL_PROC_REF(cmp_text_dsc))

/datum/changelog/ui_static_data()
	var/list/dates = list()
	for(var/archive_file in changelog_archive_files())
		dates += copytext(archive_file, 1, 8)
	return list("dates" = dates)
