///Change speech mannerisms
/mob/verb/change_speech_quirk()
	set name = "Speech Mannerisms"
	set category = "IC"
	set hidden = 0
	var/mob/living/carbon/human/H = usr
	if(!(H))
		to_chat(src, "Not a human mob. Try again in-round, maybe.")
		return
	var/choices = GLOB.character_mannerisms
	var/result = tgui_input_list(H, "Select speech quirk", "Speech Mannerisms", choices)
	if(result)
		
		H.char_mannerism = result
		to_chat(H, span_info("<b>[result] chosen."))
		
	return
