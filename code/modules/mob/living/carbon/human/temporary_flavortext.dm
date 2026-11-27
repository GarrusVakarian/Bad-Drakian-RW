/mob/living/carbon/human
	var/temporary_flavortext = null
	var/temporary_flavortext_cache_source = null
	var/temporary_flavortext_formatted = null
	/// The formatted cut preview examine shows, null when the text fits whole
	var/temporary_flavortext_preview = null

/mob/living/carbon/human/verb/temp_flavor()
	set name = "Set temporary flavortext"
	set category = "IC"

	var/new_temp_flavortext = input(usr, "Choose a new flavortext (Empty will remove any active ones)", "Temporary flavortext") as null|text
	if(isnull(new_temp_flavortext))
		return
	if(new_temp_flavortext == "")
		temporary_flavortext = null
		return
	else
		temporary_flavortext = new_temp_flavortext

/mob/living/carbon/human/Topic(href, href_list)
	. = ..()
	if(href_list["task"] == "show_temp_ft" && !is_species(src, /datum/species/dragon))
		var/output = "<span class='info' style='color: #eaeaea'>[temporary_flavortext]</span>"
		if(!usr.client.prefs.no_examine_blocks)
			output = examine_block(output)
		to_chat(usr, output)
