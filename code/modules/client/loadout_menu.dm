/// Render only server-generated markup. Saved fields contain encoded source, never trusted HTML.
/proc/format_loadout_text(text, markdown = FALSE, is_name = FALSE, preview = FALSE)
	if(!istext(text) || !length(text))
		return null
	var/source = html_decode(text)
	var/improper_name = FALSE
	if(markdown && is_name && length(source) > 9 && findtext(source, "\\improper") == 1)
		improper_name = TRUE
		source = copytext(source, 10)
	var/rendered = is_name ? sanitize(source) : html_encode(source)
	if(markdown)
		rendered = parsemarkdown_basic(rendered)
	if(!is_name)
		rendered = replacetext(rendered, "\n", "<br>")
	if(improper_name && !preview)
		rendered = "\improper" + rendered
	return rendered

/// Per-field opt-in keeps old saves and unedited fields literal, including Markdown punctuation.
/proc/normalize_loadout_markdown_fields(fields)
	. = list()
	if(!islist(fields))
		return
	for(var/i = 1 to 10)
		for(var/kind in list("name", "desc"))
			var/field = "loadout_[i]_[kind]"
			if(field in fields)
				. += field

/datum/preferences/proc/get_loadout_text(slot, is_name = FALSE, preview = FALSE)
	if(!isnum(slot) || slot < 1 || slot > 10 || slot != round(slot))
		return null
	var/field = "loadout_[slot]_[is_name ? "name" : "desc"]"
	return format_loadout_text(vars[field], field in loadout_markdown_fields, is_name, preview)

/datum/preferences/proc/set_loadout_custom_text(slot, is_name, text)
	if(!isnum(slot) || slot < 1 || slot > 10 || slot != round(slot) || !istext(text))
		return FALSE
	var/field = "loadout_[slot]_[is_name ? "name" : "desc"]"
	var/limit = is_name ? MAX_NAME_LEN : 500
	text = copytext_char(text, 1, limit + 1)
	if(is_name)
		text = replacetext(replacetext(text, "\n", " "), "\t", " ")
	vars[field] = length(text) ? html_encode(text) : null
	loadout_markdown_fields -= field
	if(length(text))
		loadout_markdown_fields += field
	return TRUE

/datum/preferences/proc/open_loadout_menu(mob/user, slot = 1)
	if(!user || !user.client)
		return
	
	// Redirect to unified character customization menu
	if(!loadout_menu)
		loadout_menu = new(src)
	loadout_menu.ui_interact(user)
	loadout_menu.current_slot = slot

/datum/preferences/proc/generate_loadout_html(mob/user)
	var/total_triumphs = usr.get_triumphs()
	var/spent_triumphs = 0
	
	// Calculate spent triumphs
	for(var/i = 1 to 10)
		var/datum/loadout_item/loadout_slot = vars["loadout[i == 1 ? "" : "[i]"]"]
		if(loadout_slot && loadout_slot.triumph_cost)
			spent_triumphs += loadout_slot.triumph_cost
	
	var/remaining_triumphs = total_triumphs - spent_triumphs
	
	var/html = {"
		<!DOCTYPE html>
		<html lang="en">
		<meta charset='UTF-8'>
		<meta http-equiv='X-UA-Compatible' content='IE=edge,chrome=1'/>
		<style>
			body {
				font-family: Verdana, Arial, sans-serif;
				background: #1C0000;
				color: #e3c06f;
				margin: 0;
				padding: 20px;
			}
			.header {
				text-align: center;
				padding: 15px;
				background: rgba(0, 0, 0, 0.4);
				border: 1px solid #e3c06f;
				margin-bottom: 20px;
			}
			.header h1 {
				margin: 0;
				color: #e3c06f;
				font-size: 1.5em;
			}
			.triumph-counter {
				font-size: 1em;
				margin-top: 10px;
			}
			.triumph-available {
				color: #4CAF50;
			}
			.triumph-spent {
				color: #ff9800;
			}
			.loadout-grid {
				display: grid;
				grid-template-columns: repeat(2, 1fr);
				gap: 15px;
				padding: 20px;
			}
			.loadout-slot {
				background: rgba(0, 0, 0, 0.4);
				border: 1px solid #444;
				padding: 15px;
			}
			.loadout-slot:hover {
				border-color: #e3c06f;
			}
			.slot-header {
				display: flex;
				justify-content: space-between;
				align-items: center;
				margin-bottom: 10px;
				padding-bottom: 10px;
				border-bottom: 1px solid #444;
			}
			.slot-number {
				font-weight: bold;
				color: #e3c06f;
			}
			.slot-cost {
				background: #e3c06f;
				color: #1C0000;
				padding: 2px 8px;
				font-size: 0.9em;
				font-weight: bold;
			}
			.item-display {
				display: flex;
				align-items: center;
				margin-bottom: 10px;
			}
			.item-icon {
				width: 64px;
				height: 64px;
				background: rgba(0,0,0,0.6);
				border: 1px solid #444;
				margin-right: 15px;
				display: flex;
				align-items: center;
				justify-content: center;
			}
			.item-icon img {
				max-width: 60px;
				max-height: 60px;
			}
			.item-info {
				flex: 1;
			}
			.item-name {
				font-weight: bold;
				color: #e3c06f;
				margin-bottom: 5px;
			}
			.item-desc {
				font-size: 0.85em;
				color: #999;
			}
			.btn {
				padding: 6px 12px;
				border: 1px solid #444;
				background: rgba(0, 0, 0, 0.4);
				color: #e3c06f;
				cursor: pointer;
				font-family: Verdana, Arial, sans-serif;
				font-size: 0.85em;
				text-decoration: none;
				display: inline-block;
				margin: 2px;
			}
			.btn:hover {
				background: rgba(227, 192, 111, 0.2);
				border-color: #e3c06f;
			}
			.btn-select {
				background: rgba(76, 175, 80, 0.3);
				border-color: #4CAF50;
				color: #4CAF50;
			}
			.btn-select:hover {
				background: rgba(76, 175, 80, 0.5);
			}
			.btn-clear {
				background: rgba(244, 67, 54, 0.3);
				border-color: #f44336;
				color: #f44336;
			}
			.btn-clear:hover {
				background: rgba(244, 67, 54, 0.5);
			}
			.btn-customize {
				background: rgba(33, 150, 243, 0.3);
				border-color: #2196F3;
				color: #2196F3;
			}
			.btn-customize:hover {
				background: rgba(33, 150, 243, 0.5);
			}
			.btn-color {
				background: rgba(156, 39, 176, 0.3);
				border-color: #9C27B0;
				color: #9C27B0;
			}
			.btn-color:hover {
				background: rgba(156, 39, 176, 0.5);
			}
			.empty-slot {
				text-align: center;
				padding: 20px;
				color: #666;
				font-style: italic;
			}
			.custom-text {
				margin-top: 5px;
				font-size: 0.8em;
				color: #888;
			}
			.actions {
				margin-top: 10px;
				display: flex;
				flex-wrap: wrap;
				gap: 5px;
			}
			.info-box {
				background: rgba(227, 192, 111, 0.1);
				border: 1px solid #e3c06f;
				padding: 15px;
				margin: 15px 0;
				border-radius: 4px;
				color: #e3c06f;
			}
			.info-box h3 {
				margin: 0 0 10px 0;
				color: #e3c06f;
				font-size: 1.1em;
			}
			.info-box p {
				margin: 5px 0;
				font-size: 0.9em;
				color: #ccc;
			}
		</style>
		<body>
			<div class="header">
				<h1>⚔ Loadout Selection ⚔</h1>
				<div class="triumph-counter">
					<span class="triumph-available">Available Triumphs: [remaining_triumphs]</span> | 
					<span class="triumph-spent">Spent: [spent_triumphs]</span> / 
					<span>Total: [total_triumphs]</span>
				</div>
			</div>
			
			<div class="info-box">
				<h3>⚠ Loadout Item Modifications ⚠</h3>
				<p><b>ARMOR & HELMETS:</b> Armor rating reduced by 90% • Crit prevention removed</p>
				<p><b>WEAPONS:</b> Damage reduced by 25%</p>
				<p><b>ALL ITEMS:</b> Sell price set to 0</p>
			</div>
			
			<div class="loadout-grid">
	"}
	
	// Generate 10 loadout slots
	for(var/i = 1 to 10)
		var/slot_var = i == 1 ? "loadout" : "loadout[i]"
		var/datum/loadout_item/current_item = vars[slot_var]
		var/custom_name = vars["loadout_[i]_name"]
		var/custom_desc = vars["loadout_[i]_desc"]
		var/item_color = vars["loadout_[i]_hex"]
		
		html += "<div class='loadout-slot'>"
		html += "<div class='slot-header'>"
		html += "<span class='slot-number'>Slot [i]</span>"
		
		if(current_item && current_item.triumph_cost)
			html += "<span class='slot-cost'>[current_item.triumph_cost] Triumphs</span>"
		
		html += "</div>"
		
		if(current_item)
			// Item is selected
			var/obj/item/sample = current_item.path
			var/icon_file = initial(sample.icon)
			var/icon_state = initial(sample.icon_state)
			var/item_desc = initial(sample.desc)
			
			html += "<div class='item-display'>"
			html += "<div class='item-icon'>"
			
			// Use the item's icon with caching
			if(icon_file && icon_state)
				var/cache_key = "[icon_file]_[icon_state]"
				if(!(cache_key in GLOB.cached_loadout_icons))
					if(GLOB.cached_loadout_icons.len >= MAX_ICON_CACHE_SIZE)
						GLOB.cached_loadout_icons.Cut(1, 50)
					GLOB.cached_loadout_icons[cache_key] = icon(icon_file, icon_state)
				user << browse_rsc(GLOB.cached_loadout_icons[cache_key], "loadout_icon_[i].png")
				html += "<img src='loadout_icon_[i].png' />"
			
			html += "</div>"
			html += "<div class='item-info'>"
			html += "<div class='item-name'>[custom_name ? get_loadout_text(i, TRUE, TRUE) : current_item.name]</div>"
			html += "<div class='item-desc'>[custom_desc ? get_loadout_text(i, FALSE, TRUE) : (item_desc ? item_desc : current_item.desc)]</div>"
			
			if(custom_name || custom_desc)
				html += "<div class='custom-text'>✎ Customized</div>"
			
			if(item_color)
				html += "<div class='custom-text' style='color:[item_color]'>● Color: [item_color]</div>"
			
			html += "</div>"
			html += "</div>"
			
			html += "<div class='actions'>"
			html += "<a class='btn btn-select' href='byond://?src=\ref[src];loadout_action=change;slot=[i]'>Change Item</a>"
			html += "<a class='btn btn-customize' href='byond://?src=\ref[src];loadout_action=rename;slot=[i]'>Rename</a>"
			html += "<a class='btn btn-customize' href='byond://?src=\ref[src];loadout_action=describe;slot=[i]'>Description</a>"
			html += "<a class='btn btn-color' href='byond://?src=\ref[src];loadout_action=color;slot=[i]'>Color</a>"
			html += "<a class='btn btn-clear' href='byond://?src=\ref[src];loadout_action=clear;slot=[i]'>Clear</a>"
			html += "</div>"
		else
			// Empty slot
			html += "<div class='empty-slot'>"
			html += "Empty Slot<br><br>"
			html += "<a class='btn btn-select' href='byond://?src=\ref[src];loadout_action=select;slot=[i]'>Select Item</a>"
			html += "</div>"
		
		html += "</div>"
	
	html += {"
			</div>
		</body>
		</html>
	"}
	
	return html

// Old Topic handler removed - now handled in vices_menu.dm

/datum/preferences
	var/datum/loadout_preview_request/loadout_preview_pending
	var/loadout_preview_available_at = 0

SUBSYSTEM_DEF(loadout_previews)
	name = "Loadout previews"
	flags = SS_NO_INIT | SS_NO_FIRE
	var/list/preview_queue = list()
	var/worker_running = FALSE

/datum/controller/subsystem/loadout_previews/proc/queue_preview(datum/loadout_preview_request/request)
	preview_queue += request
	if(!worker_running)
		worker_running = TRUE
		INVOKE_ASYNC(src, PROC_REF(run_queue))

/datum/controller/subsystem/loadout_previews/proc/run_queue()
	while(length(preview_queue))
		var/datum/loadout_preview_request/request = preview_queue[1]
		preview_queue.Cut(1, 2)
		// Keep one worker across yields so requests from different players cannot pile up in a tick.
		loadout_preview_next_tick()
		try
			request.generate()
		catch(var/exception/error)
			log_runtime("Loadout preview generation failed: [error]")
		qdel(request)
	worker_running = FALSE

// Start each substantial phase with room left in the tick for the rest of the game.
#define LOADOUT_PREVIEW_TICK_BUDGET 30

/proc/loadout_preview_next_tick()
	do
		sleep(world.tick_lag)
	while(TICK_USAGE >= LOADOUT_PREVIEW_TICK_BUDGET)

/proc/loadout_preview_check_tick()
	if(TICK_USAGE >= LOADOUT_PREVIEW_TICK_BUDGET)
		loadout_preview_next_tick()

/mob/living/carbon/human/dummy/loadout_preview
	// Set after initialization. Only private preview mannequins have a yielding proc path.
	var/render_checkpoint

/mob/living/carbon/human/dummy/loadout_preview/queue_icon_update(update_type)
	// The private worker flushes these after equipping, once the body is complete.
	pending_icon_updates |= update_type

/// Wear positions that can be used without a second item, in preferred order.
/proc/get_loadout_preview_wear_slots(slot_flags)
	var/static/list/wear_flags = list(
		ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_NECK, ITEM_SLOT_CLOAK,
		ITEM_SLOT_ARMOR, ITEM_SLOT_SHIRT, ITEM_SLOT_PANTS, ITEM_SLOT_GLOVES,
		ITEM_SLOT_SHOES, ITEM_SLOT_WRISTS, ITEM_SLOT_RING, ITEM_SLOT_BELT,
		ITEM_SLOT_BACK_R, ITEM_SLOT_BACK_L, ITEM_SLOT_MOUTH,
	)
	var/static/list/wear_slots = list(
		SLOT_HEAD, SLOT_WEAR_MASK, SLOT_NECK, SLOT_CLOAK,
		SLOT_ARMOR, SLOT_SHIRT, SLOT_PANTS, SLOT_GLOVES,
		SLOT_SHOES, SLOT_WRISTS, SLOT_RING, SLOT_BELT,
		SLOT_BACK_R, SLOT_BACK_L, SLOT_MOUTH,
	)
	var/list/supported
	for(var/i in 1 to length(wear_flags))
		if(slot_flags & wear_flags[i])
			LAZYADD(supported, wear_slots[i])
	return supported

/datum/preferences/proc/show_loadout_equipped_preview(mob/user, slot, slot_var)
	if(!parent || user?.client != parent || parent.prefs != src || loadout_preview_pending || world.time < loadout_preview_available_at)
		return
	var/datum/loadout_item/selected = vars[slot_var]
	if(!istype(selected) || !ispath(selected.path, /obj/item))
		return
	var/obj/item/item_type = selected.path
	if(!get_loadout_preview_wear_slots(initial(item_type.slot_flags)) || !spec_check(user))
		return

	loadout_preview_pending = new(src, user, slot, slot_var, selected)
	loadout_preview_available_at = world.time + 2 SECONDS
	SSloadout_previews.queue_preview(loadout_preview_pending)

/datum/loadout_preview_request
	var/datum/preferences/preferences
	var/mob/user
	var/client/viewer
	var/character_slot
	var/slot_var
	var/datum/loadout_item/selected
	var/color_field
	var/dye
	var/mob/living/carbon/human/dummy/loadout_preview/mannequin

/datum/loadout_preview_request/New(datum/preferences/preferences, mob/user, slot, slot_var, datum/loadout_item/selected)
	src.preferences = preferences
	src.user = user
	src.slot_var = slot_var
	src.selected = selected
	viewer = user.client
	character_slot = preferences.default_slot
	color_field = "loadout_[slot]_hex"
	dye = preferences.vars[color_field]

/datum/loadout_preview_request/Destroy()
	QDEL_NULL(mannequin)
	if(!QDELETED(preferences) && preferences.loadout_preview_pending == src)
		preferences.loadout_preview_pending = null
	return ..()

/datum/loadout_preview_request/proc/valid()
	return !QDELETED(preferences) && !QDELETED(user) && viewer && user.client == viewer && viewer.prefs == preferences && preferences.loadout_preview_pending == src && preferences.default_slot == character_slot && preferences.vars[slot_var] == selected && preferences.vars[color_field] == dye

/datum/loadout_preview_request/proc/generate()
	if(!valid())
		return
	// The job owns this nullspace mannequin for its entire lifetime, including across ticks.
	mannequin = new(null)
	loadout_preview_next_tick()
	if(!valid() || !preferences.spec_check(user))
		return
	var/list/rendered = preferences.render_loadout_equipped_preview(mannequin, selected.path, dye, preferences.get_preview_customization_scale(), src)
	if(!valid())
		return
	show_result(rendered)

/datum/loadout_preview_request/proc/show_result(list/rendered)
	if(!rendered)
		to_chat(user, span_notice("This item can't be worn by this character on its own."))
		return

	var/view_width = max(74, rendered["width"])
	var/view_height = rendered["height"]
	var/datum/browser/popup = new(user, "loadout_equipped_preview", "Loadout Preview", max(218, 2 * view_width + 46), view_height + 114)
	popup.set_content({"<div style='text-align:center;'>
		<h3 style='margin:0 0 4px; padding:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;'>[html_encode(selected.name)]</h3>
		<div style='display:flex; justify-content:center;'>
			<div style='width:[view_width]px; margin-right:10px;'><div style='height:[view_height]px; display:flex; align-items:flex-end; justify-content:center;'>[rendered[1]]</div><b>Front</b></div>
			<div style='width:[view_width]px;'><div style='height:[view_height]px; display:flex; align-items:flex-end; justify-content:center;'>[rendered[2]]</div><b>Back</b></div>
		</div>
	</div>"})
	popup.open(FALSE)

/// Render only on request. The caller owns the mannequin and discards it even on failure.
/datum/preferences/proc/render_loadout_equipped_preview(mob/living/carbon/human/dummy/loadout_preview/mannequin, obj/item/item_type, dye, size_multiplier, datum/loadout_preview_request/request)
	mannequin.render_checkpoint = GLOBAL_PROC_REF(loadout_preview_check_tick)
	copy_to(mannequin, FALSE, FALSE, TRUE)
	loadout_preview_next_tick()
	if(request && !request.valid())
		return
	mannequin.delete_equipment()
	var/obj/item/sample = new item_type(mannequin)
	if(QDELETED(sample))
		return

	if(dye)
		sample.add_atom_colour(dye, FIXED_COLOUR_PRIORITY)
		sample.update_icon()

	var/equipped = FALSE
	for(var/wear_slot in get_loadout_preview_wear_slots(sample.slot_flags))
		if(mannequin.equip_to_slot_if_possible(sample, wear_slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE, initial = TRUE) && mannequin.get_item_by_slot(wear_slot) == sample)
			equipped = TRUE
			break
	if(!equipped)
		qdel(sample)
		return

	mannequin.regenerate_clothes()
	mannequin.rebuild_obscured_flags()
	mannequin.update_body()
	mannequin.update_hair()
	mannequin.update_body_parts(redraw = TRUE)
	// Armor and cloak updates can queue a second pass for dependent layers.
	for(var/pass in 1 to 3)
		if(!mannequin.pending_icon_updates)
			break
		mannequin.process_pending_icon_updates()

	// Flattening retains worn layers and tint. Apply body scale to the resulting
	// display dimensions because getFlatIcon does not bake the parent transform.
	var/view_scale = 3 * mannequin.dna.current_body_size * size_multiplier
	var/list/rendered = list()
	var/view_width = 0
	var/view_height = 0
	for(var/direction in list(SOUTH, NORTH))
		loadout_preview_next_tick()
		if(request && !request.valid())
			return
		mannequin.setDir(direction)
		var/icon/view = getFlatIcon(mannequin, no_anim = TRUE, between_layers = mannequin.render_checkpoint, fit_canvas = TRUE)
		if(!view || !view.Width() || !view.Height())
			return
		loadout_preview_next_tick()
		if(request && !request.valid())
			return
		var/encoded = icon2base64(view)
		if(!encoded)
			return
		var/scale = min(view_scale, 136 / view.Width(), 156 / view.Height())
		var/width = max(1, round(view.Width() * scale))
		var/height = max(1, round(view.Height() * scale))
		view_width = max(view_width, width)
		view_height = max(view_height, height)
		rendered += "<img alt='[direction == SOUTH ? "Front" : "Back"]' src='data:image/png;base64,[encoded]' style='image-rendering:pixelated; width:[width]px; height:[height]px;'>"
	rendered["width"] = view_width
	rendered["height"] = view_height
	return rendered

#undef LOADOUT_PREVIEW_TICK_BUDGET
