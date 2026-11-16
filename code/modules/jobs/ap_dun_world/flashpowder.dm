// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/obj/effect/proc_holder/spell/invoked/projectile/ap_flashpowder
	name = "Flashpowder"
	desc = "Throw a handful of explosive powder, stunning and blinding your opponent."
	action_icon = 'icons/mob/actions/antiquarianspells.dmi'
	overlay_state = "flashpowder"
	projectile_type = /obj/projectile/magic/flashpowder
	range = 7

	releasedrain = 15
	recharge_time = 12 SECONDS
	associated_skill = /datum/skill/misc/reading
	invocations = list("%CASTER flicks their wrist, tossing a handful of crackling powder.")
	invocation_type = "emote"

/obj/projectile/magic/flashpowder
	name = "flashpowder"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "spark"
	damage = 25 //ever get hit with a cherry bomb? shit hurts a bit. this is a little less than spitfire, with no ignite
	damage_type = BURN
	woundclass = BCLASS_BURN
	nodamage = FALSE
	flag = "fire"
	speed = 1
	range = 7
	hitsound = list('sound/misc/explode/incendiary (1).ogg','sound/misc/explode/incendiary (2).ogg')


/obj/projectile/magic/flashpowder/on_hit(target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		if(blocked >= 100)
			return
		M.apply_status_effect(/datum/status_effect/debuff/flashpowder)
		M.apply_status_effect(/datum/status_effect/debuff/clickcd, 3 SECONDS)
		if(iscarbon(target))
			M.blur_eyes(5) //affects both blur duration and intensity, minor blur for about 15 seconds
			M.adjust_blurriness(5) //affects both blur duration and intensity, no idea why they both do the same thing
	visible_message(
		span_warning("[target] is blasted with a sparking cloud!"),
		span_warning("The flashpowder blinded me! I can't see!")
		)

/datum/status_effect/debuff/flashpowder
	id = "flashpowder"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/flashpowder
	effectedstats = list(STATKEY_PER = -2, STATKEY_LCK = -2)
	duration = 10 SECONDS

/atom/movable/screen/alert/status_effect/debuff/flashpowder
	name = "Flashpowder"
	desc = "Sparking powder has clouded my senses."
	icon_state = "debuff"
