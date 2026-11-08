/*
avast, ye lirvan tithebound abilities live here
INVOKE is a self-buff that scales w/ money
DRAKKYRMAW is a katar that scales w money
SUNSET is a little leap :3
raze is a fire breath thing
Last, the specials for DRAKKYRMAW and the golden quarterstaff.
*/

#define LIRVAN_BLING_FILTER "lirvan_titheaura"
#define LIRVAN_GOLD "#f5d96c"

/proc/get_moni_value(atom/movable/movable)
	var/wealth = 0
	if(istype(movable, /obj/item/roguecoin))
		var/obj/item/roguecoin/coin = movable
		wealth += coin.quantity * coin.sellprice
	else if(istype(movable, /obj/item))
		var/obj/item/item = movable
		var/item_value = item.get_real_price()
		if(item_value)
			wealth += item_value
	for(var/atom/movable/content in movable.contents)
		wealth += get_moni_value(content)
	return wealth

// INVOKE

/obj/effect/proc_holder/spell/self/lirvan_tithe
	name = "INVOKE"
	desc = "Draw strength from the wealth you carry. Armor, jewelry, and raw mammon counted equally. More WEALTH means more POWER. More POWER at 160, 200, 300, 360, 440, 600, 800, 1000, and 1200 mammon."
	antimagic_allowed = TRUE
	clothes_req = FALSE
	recharge_time = 90 SECONDS
	invocations = list("'s scales harden and glow softly!")
	invocation_type = "emote"

/obj/effect/proc_holder/spell/self/lirvan_tithe/cast(list/targets, mob/living/user = usr)
	if(!ishuman(user))
		return FALSE
	user.apply_status_effect(/datum/status_effect/buff/lirvan_tithe)
	return TRUE

/atom/movable/screen/alert/status_effect/buff/lirvan_tithe
	name = "Mammon's Bulwark"
	desc = "The air burns with POWER."
	icon_state = "buff"

/datum/status_effect/buff/lirvan_tithe
	id = "lirvan_tithe"
	examine_text = "<font color='red'>SUBJECTPRONOUN radiates POWER.</font>"
	alert_type = /atom/movable/screen/alert/status_effect/buff/lirvan_tithe
	duration = 1 MINUTES
	var/wealth_value = 0
	var/obj/effect/dummy/lighting_obj/moblight/lirvanlight
	var/gonna_fort = FALSE //like, we're gonna use fortitude. we'll apply fortitude to...ah, nevermind.

/datum/status_effect/buff/lirvan_tithe/on_apply()
	update_effects()
	. = ..()
	if(!.)
		return
	if(!owner.get_filter(LIRVAN_BLING_FILTER))
		owner.add_filter(LIRVAN_BLING_FILTER, 2, list("type" = "outline", "color" = LIRVAN_GOLD, "alpha" = 120, "size" = 1))
	if(!lirvanlight)
		lirvanlight = owner.mob_light(LIRVAN_GOLD, 7, 7)
	if(wealth_value < 160)
		to_chat(owner, span_notice("WEALTH answers my call. Every single one of my- ONLY [wealth_value] MAMMONS?!"))
		owner.emote("whimper", forced = TRUE)
		return
	to_chat(owner, span_notice("WEALTH answers my call. Every single one of my [wealth_value] pieces of it."))
	if(wealth_value >= 300)
		ADD_TRAIT(owner, TRAIT_FORTITUDE, TRAIT_STATUS_EFFECT(id))
		gonna_fort = TRUE
		to_chat(owner, span_userdanger("FORTIFIED."))
	playsound(owner, 'sound/combat/hits/burn (2).ogg', 100, TRUE)

/datum/status_effect/buff/lirvan_tithe/on_remove()
	. = ..()
	if(gonna_fort)
		REMOVE_TRAIT(owner, TRAIT_FORTITUDE, TRAIT_STATUS_EFFECT(id))
		gonna_fort = FALSE
	owner.remove_filter(LIRVAN_BLING_FILTER)
	QDEL_NULL(lirvanlight)
	to_chat(owner, span_warning("POWER fades."))

/datum/status_effect/buff/lirvan_tithe/proc/update_effects()
	wealth_value = get_moni_value(owner)
	if(wealth_value < 160)
		effectedstats = list(STATKEY_CON = 1, STATKEY_LCK = 1)
	else if(wealth_value < 200)
		effectedstats = list(STATKEY_STR = 1, STATKEY_CON = 1, STATKEY_LCK = 1)
	else if(wealth_value < 300)
		effectedstats = list(STATKEY_STR = 2, STATKEY_CON = 1, STATKEY_LCK = 1)
	else if(wealth_value < 360)
		effectedstats = list(STATKEY_STR = 2, STATKEY_CON = 2, STATKEY_LCK = 1, STATKEY_SPD = 1)
	else if(wealth_value < 440)
		effectedstats = list(STATKEY_STR = 3, STATKEY_CON = 2, STATKEY_LCK = 2, STATKEY_SPD = 1)
	else if(wealth_value < 600)
		effectedstats = list(STATKEY_STR = 3, STATKEY_CON = 4, STATKEY_LCK = 2, STATKEY_SPD = 2, STATKEY_PER = 1)
	else if(wealth_value < 800)
		effectedstats = list(STATKEY_STR = 3, STATKEY_CON = 4, STATKEY_LCK = 2, STATKEY_SPD = 2, STATKEY_PER = 2)
	else if(wealth_value < 1000)
		effectedstats = list(STATKEY_STR = 4, STATKEY_CON = 4, STATKEY_LCK = 2, STATKEY_SPD = 2, STATKEY_PER = 2)
	else if(wealth_value < 1200)
		effectedstats = list(STATKEY_STR = 4, STATKEY_CON = 5, STATKEY_LCK = 3, STATKEY_SPD = 2, STATKEY_PER = 2)
	else
		effectedstats = list(STATKEY_STR = 5, STATKEY_CON = 5, STATKEY_LCK = 3, STATKEY_SPD = 3, STATKEY_PER = 2)

// DRAKKYRMAW

/obj/effect/proc_holder/spell/self/lirvan_talon
	name = "DRAKKYRMAW"
	desc = "WEALTH TO POWER; the drakkyr's maw opens. Turn thy gluttony to wrath. Damage scales with wealth."
	antimagic_allowed = TRUE
	clothes_req = FALSE
	recharge_time = 120 SECONDS
	invocations = list("draws 'pon DRAKKYRMAW.")
	invocation_type = "emote"
	var/obj/item/rogueweapon/katar/lirvan_talon/summoned_talon

/obj/effect/proc_holder/spell/self/lirvan_talon/Destroy()
	if(summoned_talon && !QDELETED(summoned_talon))
		UnregisterSignal(summoned_talon, COMSIG_QDELETING)
		QDEL_NULL(summoned_talon)
	return ..()

/obj/effect/proc_holder/spell/self/lirvan_talon/cast(list/targets, mob/living/user = usr)
	if(!ishuman(user))
		return FALSE
	if(summoned_talon && !QDELETED(summoned_talon))
		qdel(summoned_talon)
		to_chat(user, span_danger("WHY STOP NOW?"))
		return TRUE

	var/wealth_value = get_moni_value(user)
	summoned_talon = new(user)
	summoned_talon.attuned_owner = user
	summoned_talon.attune_to_wealth(wealth_value)
	RegisterSignal(summoned_talon, COMSIG_QDELETING, PROC_REF(on_talon_destroyed))
	if(!user.put_in_hands(summoned_talon))
		qdel(summoned_talon)
		if(user.get_num_arms() <= 0)
			to_chat(user, span_userdanger("WITH WHAT FUCKING ARMS???"))
			user.emote("cry", forced = TRUE)
		else
			to_chat(user, span_warning("My hands are full!"))
		return FALSE
	to_chat(user, span_danger("[wealth_value] TEETH ARRANGED IN MACABRE SMILE."))
	QDEL_IN(summoned_talon, 60 SECONDS)
	return TRUE

/obj/effect/proc_holder/spell/self/lirvan_talon/proc/on_talon_destroyed(datum/source)
	SIGNAL_HANDLER
	summoned_talon = null

// SUNSET

/obj/effect/proc_holder/spell/invoked/saxtonhale
	name = "SUNSET"
	desc = "Channel but a mote of the power of a Drakkyn. Take to the skies, before crashing into the ground with a punishing slam after a delay. All caught within are damaged. Hit can be riposted. Center tile takes triple damage."
	clothes_req = FALSE
	range = 5
	overlay_state = "thunderstrike"
	releasedrain = 30
	chargedrain = 0
	chargetime = 0
	recharge_time = 20 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = FALSE
	charging_slowdown = 1
	chargedloop = /datum/looping_sound/invokegen
	invocations = list("Drakkyr Voldta!") //draconic doesn't have any linguistic inspirations i think. 'dragon walk' if you want to be super literal abt the greek translation but like idk man im just a polyglot dont get mad at me
	invocation_type = "shout"
	gesture_required = TRUE
	var/damage = 40
	var/delay = 1 SECONDS
	var/obj/effect/temp_visual/lirvan_sunset_dragon/dragon_afterimage

/obj/effect/proc_holder/spell/invoked/saxtonhale/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		revert_cast()
		return FALSE

	var/turf/target_turf = get_turf(targets[1])
	var/turf/start_turf = get_turf(H)
	if(!target_turf || !start_turf)
		revert_cast()
		return FALSE

	if(target_turf.z != start_turf.z)
		to_chat(H, span_warning("I cannot reach that level!"))
		revert_cast()
		return FALSE

	// Invoked spells don't check range on their own.
	if(get_dist(start_turf, target_turf) > range)
		to_chat(H, span_warning("Too far, even for a Drakkyn!"))
		revert_cast()
		return FALSE

	if(target_turf.density)
		to_chat(H, span_warning("I need open ground for my landing!"))
		revert_cast()
		return FALSE

	var/obj/item/held_weapon = H.get_active_held_item()
	if(!held_weapon)
		to_chat(H, span_warning("...with WHAT WEAPON?"))
		revert_cast()
		return FALSE

	var/def_zone = H.zone_selected || BODY_ZONE_CHEST

	for(var/turf/affected_turf in range(1, target_turf))
		new /obj/effect/temp_visual/lirvan_telegraph/sunset(affected_turf, delay)

	H.visible_message(span_warning("[H] vaults skywards in a half-crescent of gold...!"), span_notice("CRUSH."))
	playsound(start_turf, 'sound/combat/wooshes/bladed/wooshsmall (1).ogg', 60, TRUE)
	playsound(start_turf, 'sound/vo/mobs/wwolf/idle (1).ogg', 60, TRUE)
	dragon_afterimage = new /obj/effect/temp_visual/lirvan_sunset_dragon(start_turf)

	if(H.buckled)
		H.buckled.unbuckle_mob(H, TRUE)

	var/old_pass = H.pass_flags
	var/prev_pixel_z = H.pixel_z
	H.pass_flags |= PASSMOB
	animate(H, pixel_z = prev_pixel_z + 24, time = 2, easing = EASE_OUT)

	sleep(delay)

	if(QDELETED(H) || H.stat == DEAD)
		return FALSE

	var/max_leap_steps = max(1, get_dist(start_turf, target_turf) + 1)
	var/turf/landing_turf = target_turf
	while(get_turf(H) != target_turf && max_leap_steps-- > 0)
		var/turf/current_turf = get_turf(H)
		if(dragon_afterimage)
			dragon_afterimage.forceMove(current_turf)
		var/dir_to_target = get_dir(current_turf, target_turf)
		var/turf/next = get_step(current_turf, dir_to_target)
		if(!next || next.density)
			landing_turf = current_turf
			break
		if(!step(H, dir_to_target))
			landing_turf = current_turf
			break
		H.forceMove(next)

	animate(H, pixel_z = prev_pixel_z, time = 1, easing = EASE_IN)
	H.pass_flags = old_pass
	if(dragon_afterimage)
		dragon_afterimage.fade_out()
		dragon_afterimage = null

	if(get_turf(H) != target_turf)
		landing_turf = get_turf(H)

	playsound(landing_turf, pick('sound/combat/ground_smash1.ogg', 'sound/combat/ground_smash2.ogg', 'sound/combat/ground_smash3.ogg'), 80, TRUE)
	for(var/turf/affected_turf in range(1, landing_turf))
		new /obj/effect/temp_visual/kinetic_blast(affected_turf)
		var/impact_damage = (affected_turf == landing_turf) ? damage * 3 : damage
		for(var/mob/living/L in affected_turf)
			if(L == H || L.stat == DEAD)
				continue
			if(L.anti_magic_check())
				L.visible_message(span_warning("POWER shatters 'pon [L]!"))
				playsound(affected_turf, 'sound/magic/magic_nulled.ogg', 100)
				continue
			if(L.has_status_effect(/datum/status_effect/buff/clash))
				L.remove_status_effect(/datum/status_effect/buff/clash)
				L.visible_message(span_warning("[L] braces and survives the impact!"))
				continue
			slam(H, L, held_weapon, impact_damage, def_zone)

	return TRUE

/// janky ahh blunt hit for the landing, standin for AP's stuff we dont have here
/obj/effect/proc_holder/spell/invoked/saxtonhale/proc/slam(mob/living/carbon/human/H, mob/living/L, obj/item/weapon, dam, def_zone)
	var/accuracy_bonus = weapon.associated_skill ? H.get_skill_level(weapon.associated_skill) * 8 : 0
	def_zone = resolve_aimed_zone(def_zone, H, L, accuracy_bonus)
	H.do_attack_animation(L, ATTACK_EFFECT_SMASH, weapon)
	var/armor_block = L.run_armor_check(def_zone, "blunt", armor_penetration = 0, damage = dam, blade_dulling = BCLASS_BLUNT, used_weapon = weapon)
	playsound(get_turf(L), pick('sound/combat/hits/blunt/genblunt (1).ogg', 'sound/combat/hits/blunt/genblunt (2).ogg', 'sound/combat/hits/blunt/genblunt (3).ogg'), 100, TRUE)
	L.visible_message(span_danger("[H] crashes down on [L] with [weapon]!"), span_userdanger("[H] crashes down on me with [weapon]!"))
	if(!L.apply_damage(dam, BRUTE, def_zone, armor_block))
		return
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(def_zone)) || C.get_bodypart(BODY_ZONE_CHEST)
		affecting?.bodypart_attacked_by(BCLASS_BLUNT, dam, H, def_zone, crit_message = TRUE, armor = armor_block, weapon = weapon)
	else
		L.simple_woundcritroll(BCLASS_BLUNT, dam, H, def_zone, crit_message = TRUE)

/obj/effect/temp_visual/lirvan_sunset_dragon //SPECIAL EFFECTS DONE DIRT CHEAP
	name = "sunfall dragon"
	desc = "The fact that I'm focused on this instead of the guy that's just jumped like twenty feet into the air really says a lot about my priorities. Maybe I should stop fucking around. Hey, wait, how much can I think about this? Can I just keep thinking about this forever? Fucked up."
	icon = 'modular/icons/mob/96x96/ratwood_dragon.dmi'
	icon_state = "dragon_shadow"
	randomdir = FALSE
	duration = 2 SECONDS
	fade_time = 10
	layer = MOB_LAYER - 0.1
	plane = GAME_PLANE
	pixel_x = -32
	pixel_y = -32
	alpha = 30

/obj/effect/temp_visual/lirvan_sunset_dragon/Initialize(mapload)
	. = ..()
	add_filter("sunset_gold_outline", 1, list("type" = "outline", "color" = LIRVAN_GOLD, "size" = 1))
	add_atom_colour(LIRVAN_GOLD, FIXED_COLOUR_PRIORITY)

/obj/effect/temp_visual/lirvan_sunset_dragon/proc/fade_out()
	if(QDELETED(src))
		return
	animate(src, alpha = 0, time = 6)
	QDEL_IN(src, 6)

/obj/effect/temp_visual/lirvan_telegraph
	icon = 'icons/effects/effects.dmi'
	randomdir = FALSE
	layer = MASSIVE_OBJ_LAYER
	plane = GAME_PLANE

/obj/effect/temp_visual/lirvan_telegraph/Initialize(mapload, custom_duration)
	if(custom_duration)
		duration = custom_duration
	. = ..()

/obj/effect/temp_visual/lirvan_telegraph/sunset
	icon_state = "blip"
	color = LIRVAN_GOLD
	layer = HUD_LAYER
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/temp_visual/lirvan_telegraph/firebreath
	icon_state = "impact_bullet"
	duration = 10 SECONDS

// RAZE

/obj/effect/proc_holder/spell/invoked/lirvan_raze // Shamelessly steals Wither's cool code / Originally from Racial Perk PR for drakians
	name = "Raze"
	desc = "Exhale a cone of stolen fyre before you, scorching enemies and igniting the ground. Damage increases with Holy Skill. These flames are also strong enough to turn unworthy corpses into ashes and dust."
	action_icon = 'modular_drakian/icons/mob/actions/lirvan_spells.dmi'
	overlay_state = "breath"
	sound = 'sound/misc/bamf.ogg'
	chargedloop = /datum/looping_sound/invokefire
	chargetime = 1 SECONDS
	charging_slowdown = 1
	releasedrain = 30
	recharge_time = 2 MINUTES
	warnie = "spellwarning"
	invocation_type = "none"
	associated_skill = /datum/skill/magic/holy
	var/delay = 12
	var/strike_delay = 2
	var/damage = 20
	var/cone_range = 3

/obj/effect/proc_holder/spell/invoked/lirvan_raze/cast(list/targets, mob/living/user = usr)
	var/turf/T = get_turf(targets[1])
	var/turf/source_turf = get_turf(user)
	if(!T || !source_turf || T.z != source_turf.z)
		revert_cast()
		return FALSE

	var/direction = get_dir(source_turf, T)
	if(!direction)
		direction = user.dir
	var/list/visible_turfs = view(cone_range, source_turf)

	for(var/distance = 1, distance <= cone_range, distance++)
		var/list/current_wave = list()
		var/turf/center = source_turf

		for(var/i = 1, i <= distance, i++)
			center = get_step(center, direction)

		if(!center)
			continue

		current_wave += center

		var/width = distance - 1

		var/left_dir
		var/right_dir

		switch(direction)
			if(NORTH, SOUTH)
				left_dir = WEST
				right_dir = EAST
			if(EAST, WEST)
				left_dir = NORTH
				right_dir = SOUTH
			if(NORTHEAST, SOUTHWEST)
				left_dir = NORTHWEST
				right_dir = SOUTHEAST
			if(NORTHWEST, SOUTHEAST)
				left_dir = NORTHEAST
				right_dir = SOUTHWEST

		for(var/offset = 1, offset <= width, offset++)
			var/turf/L = center
			var/turf/R = center

			for(var/j = 1, j <= offset, j++)
				L = get_step(L, left_dir)
				R = get_step(R, right_dir)

			if(L)
				current_wave |= L
			if(R)
				current_wave |= R

		var/tile_delay = delay + (strike_delay * (distance - 1))

		for(var/turf/affected_turf in current_wave)
			if(!(affected_turf in visible_turfs))
				continue

			new /obj/effect/temp_visual/lirvan_telegraph/firebreath(affected_turf, tile_delay)
			addtimer(CALLBACK(src, PROC_REF(ignite), affected_turf, user), tile_delay)

	user.visible_message(span_yellow("[user] sharply exhales, breathing out a cloud of fyre!"))
	user.Immobilize(15)

	return TRUE

/obj/effect/proc_holder/spell/invoked/lirvan_raze/proc/ignite(turf/damage_turf, mob/living/caster)
	new /obj/effect/temp_visual/lirvan_firebreath(damage_turf)
	playsound(damage_turf, 'sound/magic/fireball.ogg', 50, TRUE)

	for(var/mob/living/L in damage_turf)
		if(L == caster)
			continue
		var/total_damage = damage + (caster ? caster.get_skill_level(associated_skill) : 0)
		L.adjustFireLoss(total_damage) // Just straight damage, no firestacks or ignite
		to_chat(L, span_userdanger("You're scorched by flames!"))

		// Vaporize dead NPC / departed player corpses
		if(L.stat == DEAD)
			if(!L.mind || (!L.key && !L.get_ghost(FALSE, TRUE)))
				addtimer(CALLBACK(L, TYPE_PROC_REF(/mob, dust)), 2 SECONDS)

	new /obj/effect/hotspot(damage_turf) // This is the actual scary part

/obj/effect/temp_visual/lirvan_firebreath
	icon = 'icons/effects/fire.dmi'
	icon_state = "2"
	light_outer_range = 2
	light_color = "#FF6A00"
	duration = 1 SECONDS

// SPECIALS

/datum/special_intent/drakkyrmaw_bite
	name = "Drakkyrmaw: Hoardbite"
	desc = "The golden maw snaps shut in a four-pace bite-line. Bite marks appear one-by-one before the whole line activates at once. Victims are dragged closer, exposed, and burned. Always targets the aimed zone."
	tile_coordinates = list(list(0,0), list(0,1, 0.15 SECONDS), list(0,2, 0.3 SECONDS), list(0,3, 0.45 SECONDS))
	post_icon_state = "bite"
	pre_icon_state = "bite"
	respect_adjacency = FALSE
	delay = 0.85 SECONDS
	cooldown = 30 SECONDS
	stamcost = 20
	var/dam = 0
	var/fire_stacks = 2

/datum/special_intent/drakkyrmaw_bite/_draw(list/turfs, newdelay)
	for(var/turf/T in turfs)
		var/obj/effect/temp_visual/special_intent/fx = new (T, delay - newdelay)
		fx.icon = _icon
		fx.icon_state = pre_icon_state

/datum/special_intent/drakkyrmaw_bite/_delay(list/turfs, newdelay)
	if(!cancelled)
		addtimer(CALLBACK(src, PROC_REF(post_delay), turfs), delay - newdelay)

/datum/special_intent/drakkyrmaw_bite/on_create()
	. = ..()
	howner.Immobilize(0.9 SECONDS)
	howner.apply_status_effect(/datum/status_effect/debuff/clickcd, 0.9 SECONDS)
	playsound(howner, 'sound/combat/rend_start.ogg', 100, TRUE)
	to_chat(howner, span_warning("YOU KNOW WHAT TO DO."))

/datum/special_intent/drakkyrmaw_bite/apply_hit(turf/T)
	for(var/mob/living/L in get_hearers_in_view(0, T))
		if(L == howner)
			continue
		L.Slowdown(3)
		L.adjust_fire_stacks(fire_stacks)
		L.ignite_mob()
		var/turf/pull_turf = get_step_towards(L, howner)
		if(pull_turf)
			L.safe_throw_at(pull_turf, 1, 1, howner, force = MOVE_FORCE_EXTREMELY_STRONG)
		if(L.mobility_flags & MOBILITY_STAND)
			var/obj/item/W = iparent
			var/hit_zone = resolve_aimed_zone(howner.zone_selected, howner, L, howner.get_skill_level(W.associated_skill) * 8)
			apply_generic_weapon_damage(L, dam, "stab", hit_zone, bclass = BCLASS_BITE, full_pen = TRUE)
		L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
	var/sfx = pick('sound/combat/sp_axe_swing1.ogg','sound/combat/sp_axe_swing2.ogg','sound/combat/sp_axe_swing3.ogg')
	playsound(T, sfx, 100, TRUE)
	..()

/datum/special_intent/gilded_dragon_sweep
	name = "Aureate Drakkyrcoil"
	desc = "I spin my heavy golden staff thrice in front of me. The first sweep batters foes aside; the returning coil scorches and off-balances them. Always targets the chest. Requires wielding."
	tile_coordinates = list(
		list(-1,0), list(0,0), list(1,0),
		list(-1,1, 0.45 SECONDS), list(0,1, 0.45 SECONDS), list(1,1, 0.45 SECONDS),
		list(-1,0, 0.9 SECONDS), list(0,0, 0.9 SECONDS), list(1,0, 0.9 SECONDS)
	)
	post_icon_state = "sweep_fx"
	pre_icon_state = "fx_trap_long"
	sfx_pre_delay = 'sound/combat/polearm_woosh.ogg'
	sfx_post_delay = 'sound/combat/ground_smash2.ogg'
	respect_adjacency = FALSE
	delay = 0.45 SECONDS
	cooldown = 30 SECONDS
	stamcost = 25
	var/dam = 0

/datum/special_intent/gilded_dragon_sweep/check_range(atom/source, atom/target)
	var/mob/living/user = source
	var/obj/item/W = user.get_active_held_item()
	if(!W?.wielded)
		to_chat(user, span_warning("I need to wield my staff for this!"))
		return FALSE
	return ..()

/datum/special_intent/gilded_dragon_sweep/process_attack()
	var/obj/item/rogueweapon/W = iparent
	dam = W.force_dynamic * max((howner.STASTR / 10), 0.5) //i really dunno if this is too much, this is more or less copypasted
	. = ..()

/datum/special_intent/gilded_dragon_sweep/on_create()
	. = ..()
	howner.Immobilize(1.2 SECONDS)
	howner.apply_status_effect(/datum/status_effect/debuff/clickcd, 1.2 SECONDS)
	to_chat(howner, span_warning("SAMSARA; COVETOUS COIL, WEALTH-TO-PAIN."))

/datum/special_intent/gilded_dragon_sweep/apply_hit(turf/T)
	for(var/mob/living/L in get_hearers_in_view(0, T))
		if(L == howner)
			continue
		var/throwtarget = get_edge_target_turf(howner, get_dir(howner, get_step_away(L, howner)))
		L.safe_throw_at(throwtarget, 1, 1, howner, force = MOVE_FORCE_EXTREMELY_STRONG)
		L.Slowdown(2 SECONDS)
		L.adjust_fire_stacks(2)
		L.ignite_mob()
		apply_generic_weapon_damage(L, dam, "blunt", BODY_ZONE_CHEST, bclass = BCLASS_BLUNT, no_pen = TRUE)
		L.apply_status_effect(/datum/status_effect/debuff/exposed, 3 SECONDS)
	playsound(T, sfx_post_delay, 100, TRUE)
	..()

#undef LIRVAN_BLING_FILTER
#undef LIRVAN_GOLD
