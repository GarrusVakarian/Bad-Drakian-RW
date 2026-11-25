#define ACTION_BUTTON_DEFAULT_BACKGROUND "default"
#define ACTION_BUTTON_REARRANGE_TINT "#96ff96"
#define ACTION_BUTTON_DROP_TINT "#40ff40"

/atom/movable/screen/movable/action_button
	var/datum/action/linked_action
	var/actiontooltipstyle = ""
	screen_loc = null
	var/mutable_appearance/blank_icon

	var/button_icon_state
	var/appearance_cache
	locked = TRUE
	var/id
	var/ordered = TRUE //If the button gets placed into the default bar
	nomouseover = FALSE
	var/atom/movable/screen/action_hotkey_label/hotkey_label

	var/atom/movable/screen/maptext_holder/maptext_holder

/atom/movable/screen/movable/action_button/New()
	. = ..()
	maptext_holder = new(src)
	vis_contents.Add(maptext_holder)

/atom/movable/screen/movable/action_button/Destroy()
	QDEL_NULL(maptext_holder)
	QDEL_NULL(hotkey_label)
	return ..()

/atom/movable/screen/movable/action_button/proc/can_use(mob/user)
	if (linked_action)
		return linked_action.owner == user
	else if (isobserver(user))
		var/mob/dead/observer/O = user
		return !O.observetarget
	else
		return TRUE

/// The drag source and destination must both be current buttons belonging to the viewer.
/atom/movable/screen/movable/action_button/proc/is_rearrange_button(mob/user)
	return !QDELETED(user) && !QDELETED(src) && !QDELETED(linked_action) && linked_action.owner == user && linked_action.button == src

/atom/movable/screen/movable/action_button/proc/update_action_drag_target(mob/user, atom/over_object)
	var/datum/hud/hud = user?.hud_used
	if(!hud?.action_buttons_rearranging || hud.mymob != user || hud.hud_shown != HUD_STYLE_STANDARD || !is_rearrange_button(user))
		return
	var/atom/movable/screen/movable/action_button/target = over_object
	if(!istype(target) || !target.screen_loc || target == src || !target.is_rearrange_button(user))
		target = null
	hud.set_action_drop_target(target)

/atom/movable/screen/movable/action_button/MouseDrop(atom/over_object)
	var/mob/user = usr
	var/datum/hud/hud = user?.hud_used
	if(!hud?.action_buttons_rearranging || hud.mymob != user || hud.hud_shown != HUD_STYLE_STANDARD || !is_rearrange_button(user))
		return
	hud.set_action_drop_target(null)
	var/atom/movable/screen/movable/action_button/target = over_object
	if(!istype(target) || !target.screen_loc)
		return
	if(swap_action_position(user, target))
		user.update_action_buttons()

/atom/movable/screen/movable/action_button/proc/swap_action_position(mob/user, atom/movable/screen/movable/action_button/target)
	if(!target || target == src || !is_rearrange_button(user) || !target.is_rearrange_button(user))
		return FALSE
	var/list/current_actions = user.actions
	var/from_index = current_actions.Find(linked_action)
	var/to_index = current_actions.Find(target.linked_action)
	if(!from_index || !to_index)
		return FALSE
	current_actions.Swap(from_index, to_index)
	moved = FALSE
	ordered = TRUE
	target.moved = FALSE
	target.ordered = TRUE
	if(user.mind?.current == user)
		user.mind.sync_spell_order_from_actions()
	return TRUE

/datum/hud/proc/set_action_drop_target(atom/movable/screen/movable/action_button/target)
	var/atom/movable/screen/movable/action_button/previous = action_drop_target?.resolve()
	if(previous == target)
		return
	action_drop_target = target ? WEAKREF(target) : null
	previous?.linked_action?.UpdateButtonIcon(TRUE)
	target?.linked_action?.UpdateButtonIcon(TRUE)

/datum/hud/proc/toggle_action_rearranging(mob/user)
	if(mymob != user || !user.client || action_buttons_hidden || hud_shown != HUD_STYLE_STANDARD)
		return
	action_buttons_rearranging = !action_buttons_rearranging
	set_action_drop_target(null)
	if(action_buttons_rearranging)
		to_chat(user, span_notice("Drag one action button onto another to swap them. Ctrl-click again to finish."))
	else
		to_chat(user, span_notice("Action button rearranging finished."))
	user.update_action_buttons()

/atom/movable/screen/movable/action_button/proc/rearrange_tint(datum/hud/hud)
	return hud.action_drop_target?.resolve() == src ? ACTION_BUTTON_DROP_TINT : ACTION_BUTTON_REARRANGE_TINT

/atom/movable/screen/movable/action_button/proc/set_hotkey_label(number)
	if(!number)
		if(hotkey_label)
			hotkey_label.maptext = null
		return
	if(!hotkey_label)
		hotkey_label = new(src)
		vis_contents.Add(hotkey_label)
	var/label = MAPTEXT("<span style='color:#ffe14d; -dm-text-outline:1 #000000; font-weight:bold;'>[number]</span>")
	if(hotkey_label.maptext != label)
		hotkey_label.maptext = label

/atom/movable/screen/action_hotkey_label
	layer = ABOVE_HUD_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	maptext_x = 1
	maptext_y = 20
	maptext_width = 12
	maptext_height = 11

/atom/movable/screen/movable/action_button/Click(location,control,params)
	if (!can_use(usr))
		return

	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		if(!usr.hud_used?.action_buttons_rearranging)
			to_chat(usr, span_warning("Ctrl-click to rearrange action buttons first."))
			return TRUE
		moved = FALSE
		usr.update_action_buttons()
		return TRUE
	if(modifiers["ctrl"])
		usr.hud_used?.toggle_action_rearranging(usr)
		return TRUE
	if(modifiers["shift"])
		var/datum/action/spell_action/SA = linked_action
		if(istype(SA))
			SA.examine(usr)
		else
			examine_ui(usr)
		to_chat(usr, "[span_medradio("Ctrl-click: Rearrange action buttons | Drag to swap buttons | Alt-click in rearrange mode: Reset position")]") // Yes I just stole the medical_radio color
		return TRUE
	if(usr.hud_used?.action_buttons_rearranging || modifiers["middle"] || !linked_action)
		return TRUE
	if(usr.next_click > world.time)
		return
	usr.next_click = world.time + 1
	if(ismob(usr))
		var/mob/M = usr
		M.playsound_local(M, 'sound/misc/click.ogg', 100)
	linked_action.Trigger()
	return TRUE

//Hide/Show Action Buttons ... Button
/atom/movable/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	desc = ""
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_default"
	locked = TRUE
	var/hidden = 0
	var/hide_icon = 'icons/mob/actions.dmi'
	var/hide_state = "hide"
	var/show_state = "show"
	var/mutable_appearance/hide_appearance
	var/mutable_appearance/show_appearance

/atom/movable/screen/movable/action_button/hide_toggle/Initialize(mapload)
	. = ..()
	var/static/list/icon_cache = list()

	var/cache_key = "[hide_icon][hide_state]"
	hide_appearance = icon_cache[cache_key]
	if(!hide_appearance)
		hide_appearance = icon_cache[cache_key] = mutable_appearance(hide_icon, hide_state)

	cache_key = "[hide_icon][show_state]"
	show_appearance = icon_cache[cache_key]
	if(!show_appearance)
		show_appearance = icon_cache[cache_key] = mutable_appearance(hide_icon, show_state)


/atom/movable/screen/movable/action_button/hide_toggle/Click(location,control,params)
	if (!can_use(usr))
		return

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		if(locked)
			to_chat(usr, span_warning("Action button \"[name]\" is locked, unlock it first."))
			return TRUE
		moved = FALSE
		usr.update_action_buttons(TRUE)
		return TRUE
	if(modifiers["ctrl"])
		locked = !locked
		to_chat(usr, span_notice("Action button \"[name]\" [locked ? "" : "un"]locked."))
		if(id && usr.client) //try to (un)remember position
			usr.client.prefs.action_buttons_screen_locs["[name]_[id]"] = locked ? moved : null
		return TRUE
	if(modifiers["alt"])
		for(var/V in usr.actions)
			var/datum/action/A = V
			var/atom/movable/screen/movable/action_button/B = A.button
			B.moved = FALSE
			if(B.id && usr.client)
				usr.client.prefs.action_buttons_screen_locs["[B.name]_[B.id]"] = null
			B.locked = usr.client.prefs.buttons_locked
		locked = usr.client.prefs.buttons_locked
		moved = FALSE
		if(id && usr.client)
			usr.client.prefs.action_buttons_screen_locs["[name]_[id]"] = null
		usr.update_action_buttons(TRUE)
		to_chat(usr, span_notice("Action button positions have been reset."))
		return TRUE
	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden
	if(usr.hud_used.action_buttons_hidden)
		usr.hud_used.action_buttons_rearranging = FALSE
		usr.hud_used.set_action_drop_target(null)

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	update_icon()
	usr.update_action_buttons()

/atom/movable/screen/movable/action_button/hide_toggle/AltClick(mob/user)
	for(var/V in user.actions)
		var/datum/action/A = V
		var/atom/movable/screen/movable/action_button/B = A.button
		B.moved = FALSE
	if(moved)
		moved = FALSE
	user.update_action_buttons(TRUE)
	to_chat(user, span_notice("Action button positions have been reset."))


/atom/movable/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(datum/hud/owner_hud)
	var/settings = owner_hud.get_action_buttons_icons()
	icon = settings["bg_icon"]
	icon_state = settings["bg_state"]
	hide_icon = settings["toggle_icon"]
	hide_state = settings["toggle_hide"]
	show_state = settings["toggle_show"]
	update_icon()

/atom/movable/screen/movable/action_button/hide_toggle/update_overlays()
	. = ..()
	if(hidden)
		. += show_appearance
	else
		. += hide_appearance

/atom/movable/screen/movable/action_button/MouseExited()
	..()

/datum/hud/proc/get_action_buttons_icons()
	. = list()
	.["bg_icon"] = ui_style
	.["bg_state"] = "template"

	//TODO : Make these fit theme
	.["toggle_icon"] = 'icons/mob/actions.dmi'
	.["toggle_hide"] = "hide"
	.["toggle_show"] = "show"

//see human and alien hud for specific implementations.

/mob/proc/update_action_buttons_icon(status_only = FALSE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon(status_only)

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	var/button_number = 0
	var/hotkey_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A in actions)
			A.button.screen_loc = null
			A.button.set_hotkey_label(null)
			if(reload_screen)
				client.screen += A.button
	else
		for(var/datum/action/A in actions)
			A.UpdateButtonIcon()
			var/atom/movable/screen/movable/action_button/B = A.button
			if(B.ordered)
				button_number++
			hotkey_number++
			B.set_hotkey_label(hotkey_number <= 9 ? hotkey_number : null)
			if(B.moved)
				B.screen_loc = B.moved
			else
				B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			if(reload_screen)
				client.screen += B

//		if(!button_number)
//			hud_used.hide_actions_toggle.screen_loc = null
//			return

//	if(!hud_used.hide_actions_toggle.moved)
//		hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
//	else
//		hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.moved
//	if(reload_screen)
//		client.screen += hud_used.hide_actions_toggle



#define AB_MAX_COLUMNS 12

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number - 1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1

	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4 + 2 * col

	var/coord_row = "[row ? "+[row]" : "+0"]"

	return "WEST[coord_col]:[coord_col_offset],SOUTH[coord_row]:3"

/datum/hud/proc/SetButtonCoords(atom/movable/screen/button,number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + 4 + 2*col
	var/y_offset = -32*(row+1) + 26

	var/matrix/M = matrix()
	M.Translate(x_offset,y_offset)
	button.transform = M

/atom/movable/screen/movable/action_button/proc/update_maptext(cd_time_deciseconds, color_cd = "#800000", color_neutral = "#ffffff")
	maptext_holder.update_maptext(cd_time_deciseconds, color_cd, color_neutral)

/atom/movable/screen/maptext_holder
	layer = ABOVE_HUD_LAYER
	maptext_x = 8
	maptext_y = 4

/atom/movable/screen/maptext_holder/proc/update_maptext(cd_time_deciseconds, color_cd = "#800000", color_neutral = "#ffffff")
	if(cd_time_deciseconds <= 0)
		maptext = null
		color = color_neutral
		return
	var/seconds_left = round(cd_time_deciseconds / (1 SECONDS), 0.1)
	if(seconds_left >= 60)
		var/mins = round(seconds_left / 60)
		var/secs = round(seconds_left) % 60
		maptext = MAPTEXT("[mins]:[secs < 10 ? "0[secs]" : "[secs]"]")
	else
		maptext = MAPTEXT("[seconds_left]s")
	color = color_cd

#undef AB_MAX_COLUMNS

#undef ACTION_BUTTON_REARRANGE_TINT
#undef ACTION_BUTTON_DROP_TINT
