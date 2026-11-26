/// One entry per wanted name, shared by local wanted boards and the round-end Chronicle.
/datum/wanted_poster
	var/name
	var/amount = 0
	var/has_active_bounty = FALSE
	var/list/crimes
	var/penance_status
	var/list/claimed_crimes

/datum/wanted_poster/New(subject_name)
	. = ..()
	name = subject_name

/proc/collect_wanted_posters(include_hidden = FALSE)
	var/list/posters = list()
	for(var/outlaw_name in GLOB.outlawed_players)
		posters[outlaw_name] = new /datum/wanted_poster(outlaw_name)
	for(var/datum/bounty/bounty as anything in GLOB.head_bounties)
		if(QDELETED(bounty))
			continue
		var/target_name = bounty.target || (include_hidden ? bounty.target_hidden : null)
		if(!target_name)
			continue
		var/datum/wanted_poster/poster = posters[target_name]
		if(!poster)
			poster = new /datum/wanted_poster(target_name)
			posters[target_name] = poster
		if(isnum(bounty.amount))
			poster.amount += bounty.amount
		poster.has_active_bounty = TRUE
		if(bounty.reason)
			LAZYINITLIST(poster.crimes)
			poster.crimes |= bounty.reason
	for(var/subject_name in GLOB.castifico_penance_records)
		var/datum/castifico_penance_record/record = GLOB.castifico_penance_records[subject_name]
		if(QDELETED(record))
			continue
		var/lists_public_crimes = islist(record.public_wanted_crimes)
		var/lists_hidden_crimes = include_hidden && islist(record.hidden_wanted_crimes)
		if(!lists_public_crimes && !lists_hidden_crimes)
			continue
		var/datum/wanted_poster/poster = posters[subject_name]
		if(!poster)
			poster = new /datum/wanted_poster(subject_name)
			posters[subject_name] = poster
		poster.penance_status = !QDELETED(record.active_collar) ? "SERVING PENANCE" : "PENANCE INCOMPLETE"
		poster.claimed_crimes = list()
		if(lists_public_crimes)
			poster.claimed_crimes |= record.public_wanted_crimes
		if(lists_hidden_crimes)
			poster.claimed_crimes |= record.hidden_wanted_crimes
	. = list()
	for(var/subject_name in posters)
		. += posters[subject_name]

/// Resolve uncached names in one pass. A unique player takes priority over any NPC namesakes.
/proc/find_wanted_portrait_targets(list/subject_names)
	var/list/players = list()
	var/list/npcs = list()
	for(var/mob/living/carbon/human/candidate as anything in GLOB.human_list)
		if(QDELETED(candidate) || !subject_names[candidate.real_name])
			continue
		var/list/matches = candidate.mind?.key ? players : npcs
		var/subject_name = candidate.real_name
		matches[subject_name] = isnull(matches[subject_name]) ? candidate : FALSE
	. = list()
	for(var/subject_name in subject_names)
		var/mob/living/carbon/human/target = isnull(players[subject_name]) ? npcs[subject_name] : players[subject_name]
		if(istype(target))
			.[subject_name] = target

/datum/controller/subsystem/crediticons/proc/prepare_wanted_portraits(list/posters)
	var/list/missing
	for(var/datum/wanted_poster/poster as anything in posters)
		if(!wanted_portraits[poster.name] && !(poster.name in wanted_portrait_queue))
			LAZYINITLIST(missing)
			missing[poster.name] = TRUE
	if(!length(missing))
		return
	var/list/targets = find_wanted_portrait_targets(missing)
	for(var/subject_name in targets)
		queue_wanted_portrait(subject_name, targets[subject_name])

/datum/controller/subsystem/crediticons/proc/queue_wanted_portrait(subject_name, mob/living/carbon/human/target)
	if(!subject_name)
		return
	if(!target)
		if(wanted_portraits[subject_name] || (subject_name in wanted_portrait_queue))
			return
		var/list/missing = list()
		missing[subject_name] = TRUE
		var/list/targets = find_wanted_portrait_targets(missing)
		target = targets[subject_name]
	if(QDELETED(target) || target.real_name != subject_name)
		return
	if(wanted_portrait_queue[subject_name] == target)
		return
	if(wanted_portraits[subject_name])
		var/datum/weakref/owner = wanted_portrait_owners[subject_name]
		if(owner?.resolve() == target)
			return
		wanted_portraits -= subject_name
		wanted_portrait_owners -= subject_name
	wanted_portrait_queue[subject_name] = target
	if(!wanted_worker_running)
		wanted_worker_running = TRUE
		addtimer(CALLBACK(src, PROC_REF(build_wanted_portraits)), 2 SECONDS)

/datum/controller/subsystem/crediticons/proc/build_wanted_portraits()
	while(length(wanted_portrait_queue))
		var/subject_name = wanted_portrait_queue[1]
		var/mob/living/carbon/human/target = wanted_portrait_queue[subject_name]
		var/portrait
		if(!QDELETED(target) && target.real_name == subject_name)
			try
				portrait = make_wanted_portrait(target, subject_name)
			catch(var/exception/error)
				log_runtime("Wanted portrait generation failed: [error]")
		// A new warrant can replace the target while icon generation yields.
		if(wanted_portrait_queue[subject_name] != target)
			continue
		if(portrait && !QDELETED(target))
			wanted_portraits[subject_name] = portrait
			wanted_portrait_owners[subject_name] = WEAKREF(target)
		wanted_portrait_queue -= subject_name
		for(var/datum/wanted_poster_view/page as anything in GLOB.wanted_poster_views.Copy())
			if(page.ready && (subject_name in page.pending))
				page.deliver(subject_name)
		CHECK_TICK
	wanted_worker_running = FALSE

/// Freeze standing clothing and body layers before yielding. Keep the target's visible headgear.
/datum/controller/subsystem/crediticons/proc/make_wanted_portrait(mob/living/carbon/human/target, subject_name)
	var/static/list/excluded_layers = list(HANDS_LAYER, HANDS_BEHIND_LAYER, HANDCUFF_LAYER, LEGCUFF_LAYER, FIRE_LAYER, SUNDER_LAYER, HALO_LAYER, TURF_LAYER, DAMAGE_LAYER, ARM_DAMAGE_LAYER, LEG_DAMAGE_LAYER, MUTATIONS_LAYER, FRONT_MUTATIONS_LAYER, BLACK_ROT_LAYER, POTENCE_LAYER, JOYBRINGER_LAYER)
	var/list/layers = list()
	var/list/standing = target.overlays_standing
	for(var/index in 1 to length(standing))
		if(index in excluded_layers)
			continue
		var/overlays = standing[index]
		if(islist(overlays))
			layers += overlays
		else if(overlays)
			layers += overlays
	if(!length(layers))
		return
	sortTim(layers, GLOBAL_PROC_REF(cmp_atom_layer_asc))
	var/icon/canvas = icon('icons/blanks/32x32.dmi', "nothing")
	var/list/dimensions = target.icon ? get_icon_dimensions(target.icon) : null
	var/body_width = dimensions?["width"] || 32
	var/body_height = dimensions?["height"] || 32
	if(body_width != 32 || body_height != 32)
		canvas.Scale(body_width, body_height)
	for(var/mutable_appearance/overlay as anything in layers)
		if(overlay.alpha)
			var/icon/part = getFlatIcon(image(overlay), SOUTH, no_anim = TRUE)
			if(part)
				canvas.Blend(part, ICON_OVERLAY, overlay.pixel_x + 1, overlay.pixel_y + 1)
		CHECK_TICK
	// Use the same species-aware head crop as the credits, then trim the label space.
	if(QDELETED(target) || target.real_name != subject_name)
		return
	var/icon/portrait = crop_credit_headshot(canvas, target)
	portrait.Crop(1, 49, 96, 96)
	return icon2base64(portrait)

GLOBAL_LIST_EMPTY(wanted_poster_views)

/// The page asks for delivery once the browser is ready. Later builds deliver on completion.
/datum/wanted_poster_view
	var/client/viewer
	var/window_id
	var/token
	var/list/pending = list()
	var/ready = FALSE
	var/expiry_timer

/datum/wanted_poster_view/New(client/recipient, window_id)
	. = ..()
	viewer = recipient
	src.window_id = window_id
	token = md5("[REF(src)]-[world.time]-[world.realtime]")
	GLOB.wanted_poster_views += src
	expiry_timer = addtimer(CALLBACK(src, PROC_REF(expire)), 45 SECONDS, TIMER_STOPPABLE)

/datum/wanted_poster_view/Destroy()
	GLOB.wanted_poster_views -= src
	if(expiry_timer)
		deltimer(expiry_timer)
	pending = null
	viewer = null
	return ..()

/datum/wanted_poster_view/proc/expire()
	expiry_timer = null
	qdel(src)

/datum/wanted_poster_view/proc/deliver(subject_name)
	if(!viewer?.mob)
		qdel(src)
		return
	var/base64 = SScrediticons.wanted_portraits[subject_name]
	if(base64)
		viewer << output(list2params(list(pending[subject_name], base64)), "[window_id].browser:wanted_poster_ready")
	pending -= subject_name
	if(!length(pending))
		qdel(src)

/proc/clear_wanted_poster_view(client/viewer, window_id)
	for(var/datum/wanted_poster_view/page as anything in GLOB.wanted_poster_views.Copy())
		if(page.viewer == viewer && (!window_id || page.window_id == window_id))
			qdel(page)
			if(window_id)
				return

/proc/wanted_poster_page_ready(client/viewer, token)
	for(var/datum/wanted_poster_view/page as anything in GLOB.wanted_poster_views)
		if(page.viewer != viewer || page.token != token || page.ready)
			continue
		page.ready = TRUE
		for(var/subject_name in page.pending.Copy())
			if(!(subject_name in SScrediticons.wanted_portrait_queue))
				page.deliver(subject_name)
		return

/proc/render_wanted_posters(list/posters, empty_text, client/viewer, window_id)
	clear_wanted_poster_view(viewer, window_id)
	if(!length(posters))
		return "<div style='text-align: center; color: #999; font-style: italic;'>[empty_text]</div>"
	if(viewer)
		SScrediticons.prepare_wanted_portraits(posters)

	var/datum/wanted_poster_view/page
	var/list/html = list({"
	<style>
		.wanted-container {
			display: flex;
			flex-wrap: wrap;
			justify-content: center;
			gap: 20px;
			padding: 15px;
			max-width: calc(200px * 3 + 20px * 2);
			margin: 0 auto;
		}
		.wanted-poster {
			width: 175px;
			min-height: 228px;
			border: 3px double #5c2c0f;
			background-color: #f5e7d0;
			padding: 8px;
			box-shadow: 3px 3px 5px rgba(0,0,0,0.3);
			font-family: 'Times New Roman', serif;
			display: flex;
			flex-direction: column;
		}
		.wanted-header {
			color: #c70404;
			font-size: 28px;
			font-weight: bold;
			text-align: center;
			margin-bottom: 5px;
			text-transform: uppercase;
		}
		.wanted-divider {
			border-bottom: 2px solid #8B0000;
			margin: 5px 0;
		}
		.wanted-footer {
			color: #8B0000;
			font-size: 16px;
			font-weight: bold;
			text-align: center;
			margin-bottom: 8px;
			text-transform: uppercase;
		}
		.wanted-icon-container {
			width: 120px;
			height: 85px;
			margin: 0 auto;
			border: 2px solid #5c2c0f;
			background-color: #ccac74;
			padding: 3px;
		}
		.wanted-icon {
			width: 100%;
			height: 100%;
			object-fit: contain;
			image-rendering: pixelated;
		}
		.wanted-name-container {
			flex-grow: 1;
			display: flex;
			flex-direction: column;
			justify-content: center;
			min-height: 65px;
			margin-top: 5px;
		}
		.wanted-name {
			color: #000000;
			font-size: 18px;
			font-weight: bold;
			text-align: center;
			padding: 0 5px;
			text-transform: uppercase;
			word-break: break-word;
			overflow: hidden;
			display: -webkit-box;
			-webkit-line-clamp: 3;
			-webkit-box-orient: vertical;
		}
		.wanted-bounty {
			color: #5c2c0f;
			font-size: 15px;
			font-weight: bold;
			text-align: center;
		}
		.wanted-crime {
			color: #333;
			font-size: 13px;
			font-style: italic;
			text-align: center;
			word-break: break-word;
		}
		.wanted-status {
			color: #8b0000;
			font-size: 12px;
			font-weight: bold;
			text-align: center;
		}
	</style>
	<div class='wanted-container'>
	"})
	for(var/datum/wanted_poster/poster as anything in posters)
		var/base64 = SScrediticons.wanted_portraits[poster.name]
		var/icon_html = "<div class='wanted-icon'></div>"
		if(base64)
			icon_html = "<img class='wanted-icon' src='data:image/png;base64,[base64]' alt=''>"
		else if(viewer && (poster.name in SScrediticons.wanted_portrait_queue))
			if(!page)
				page = new(viewer, window_id)
			var/element_id = "[page.token]-[md5(poster.name)]"
			page.pending[poster.name] = element_id
			icon_html = "<div class='wanted-icon' id='[element_id]'></div>"
		var/footer = (poster.penance_status && !poster.has_active_bounty) ? poster.penance_status : "DEAD OR ALIVE"
		html += {"
		<div class='wanted-poster'>
			<div class='wanted-header'>WANTED</div>
			<div class='wanted-divider'></div>
			<div class='wanted-footer'>[footer]</div>
			<div class='wanted-icon-container'>[icon_html]</div>
			<div class='wanted-name-container'>
				<div class='wanted-name'>[html_encode(poster.name)]</div>
			</div>
		"}
		if(poster.amount > 0)
			html += "<div class='wanted-bounty'>[poster.amount] MAMMONS</div>"
		for(var/crime in poster.crimes)
			html += "<div class='wanted-crime'>[crime]</div>"
		if(poster.penance_status)
			html += "<div class='wanted-status'>REWARD CLAIMED &mdash; [poster.penance_status]</div>"
			for(var/crime in poster.claimed_crimes)
				html += "<div class='wanted-crime'>[crime]</div>"
		html += "</div>"

	html += "</div>"
	if(page)
		html += {"
		<script>
		function wanted_poster_ready(id, base64) {
			var placeholder = document.getElementById(id);
			if (!placeholder) return;
			var img = document.createElement('img');
			img.className = 'wanted-icon';
			img.alt = '';
			img.src = 'data:image/png;base64,' + base64;
			placeholder.parentNode.replaceChild(img, placeholder);
		}
		window.addEventListener('load', function () {
			window.location.href = 'byond://?wanted_posters_ready=[page.token]';
		});
		</script>
		"}
	return html.Join()
