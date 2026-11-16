/mob/living/carbon/human
	COOLDOWN_DECLARE(hag_transform_lockout)

/obj/item/roguekey/hag
	name = "mossy key"
	desc = "A strange mossy key."
	lockid = "hag"

/atom/movable/screen/alert/hagscry
	name = "THE ROOTS OBSERVE"
	desc = "I SEE YOU."
	icon_state = "scryingeye"
	timeout = 8 SECONDS

/obj/effect/temp_visual/spore
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraph/pillar/fadein
	icon = 'icons/effects/telegraph.dmi'
	icon_state = "target_circle"
	duration = 1.6 SECONDS

/proc/thunderstrike_erupt(turf/center, mob/living/caster, radius, damage, unused, source_name, integrity_modifier)
	if(!center)
		return
	playsound(center, 'sound/magic/lightning.ogg', 80, TRUE)
	for(var/mob/living/target in range(radius, center))
		if(target != caster && target in get_hear(radius, center) && !target.anti_magic_check())
			target.apply_damage(damage, BURN, BODY_ZONE_CHEST)
