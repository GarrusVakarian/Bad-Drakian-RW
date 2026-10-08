/obj/effect/proc_holder/spell/invoked/projectile/fetch
	name = "Fetch"
	desc = "Shoot out a magical bolt that draws in the target struck towards the caster."
	clothes_req = FALSE
	range = 15
	projectile_type = /obj/projectile/magic/fetch
	sound = list('sound/magic/magnet.ogg')
	active = FALSE
	human_req = TRUE
	releasedrain = 5
	chargedrain = 0
	chargetime = 0
	warnie = "spellwarning"
	overlay_state = "fetch"
	no_early_release = TRUE
	charging_slowdown = 1
	spell_tier = 2
	invocations = list("Recolligere")
	invocation_type = "whisper"
	hide_charge_effect = TRUE // essential for rogue mage
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	cost = 2 // Combat spell, but of slighlty less obvious use
	xp_gain = TRUE

/obj/effect/proc_holder/spell/invoked/projectile/fetch/cast(list/targets, mob/user = user)
	if(length(targets))
		var/radius
		if(range < 1)	//accounts for touch / self spells that use negative range
			radius = range
		if(get_dist(targets[1], user) < radius)
			to_chat(user, span_warning("It's too close!"))
			revert_cast()
			return FALSE

/obj/projectile/magic/fetch/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[target] repells the fetch!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
