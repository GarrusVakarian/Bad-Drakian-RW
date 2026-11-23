/datum/keybinding/dsay
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST
	hotkey_keys = list("U")
	name = "DSAY"
	full_name = "Dead Chat"
	description = "Chat for dead players."

/datum/keybinding/dsay/down(client/user)
	user.get_dead_say()
	return TRUE


/mob/proc/is_deadchat_participant()
	return isobserver(src) || (isliving(src) && stat == DEAD)

/client/proc/get_dead_say(from_say_hotkey = FALSE)
	var/mob/speaker = mob
	if(!holder && !speaker?.is_deadchat_participant())
		to_chat(src, span_danger("I need to be dead to use deadchat!"))
		return

	var/msg = input(src, null, "dsay \"text\"") as text|null

	if(isnull(msg) || QDELETED(speaker) || mob != speaker)
		return
	if(from_say_hotkey && speaker.get_say_hotkey_channel() != "dsay")
		return

	do_dsay(msg)


/client/verb/dsay()
	set name = "DSAY"
	set desc = "Dead Chat. OOC chat for dead players."
	set category = "OOC"

	get_dead_say()


/client/proc/do_dsay(msg as text)
	var/mob/speaker = mob
	if(QDELETED(speaker) || (!holder && !speaker.is_deadchat_participant()))
		return

	if(!holder)
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in DSAY: [msg]")
			return

	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(src, span_danger("Speech is currently admin-disabled."))
		return

	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, span_danger("I cannot use DSAY (temp muted)."))
		return

	if(is_banned_from(ckey, "Deadchat"))
		to_chat(src, span_danger("I cannot use DSAY (perma muted)."))
		return

	if(QDELETED(speaker) || mob != speaker || (!holder && !speaker.is_deadchat_participant()))
		return

	if(handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	if(!(prefs.chat_toggles & CHAT_DSAY))
		to_chat(src, span_danger("You have DSAY muted."))
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	mob.log_talk(msg, LOG_DSAY)

	if(!msg)
		return

	var/rank_name
	var/player_name = mob.name
	var/deadbarks = pick("moans", "groans", "complains", "whines")
	var/adjectives = pick("Ghastly", "Spectral", "Phantom", "Spooky")

	if(src in GLOB.admins)
		rank_name = holder.rank
		if(holder.fakekey)
			rank_name = pick(strings("admin_nicknames.json", "ranks", "config"))
			player_name = pick(strings("admin_nicknames.json", "names", "config"))
	if(ckey in GLOB.anonymize)
		player_name = "[adjectives] Spectator"

	for(var/mob/M in GLOB.player_list)
		var/client/recipient = M.client
		if(!recipient || !(recipient.prefs.chat_toggles & CHAT_DSAY))
			continue
		var/admin_recipient = (recipient in GLOB.admins)
		if(!admin_recipient && !M.is_deadchat_participant())
			continue

		var/prefix = "DSAY: "
		if(admin_recipient)
			prefix += "([mob.ckey]) <A href='?_src_=holder;[HrefToken()];adminplayeropts=[REF(mob)]]'>\[PP\]</font></a>"

		var/rendered = span_gamedeadsay("<span class='prefix'>[prefix]</span> <span class='name'>[rank_name ? "([rank_name])" : ""][player_name]</span> [deadbarks], <span class='message'>\"[emoji_parse(msg)]\"</span>")
		to_chat(recipient, rendered)
