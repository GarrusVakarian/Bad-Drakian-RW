// Activate the devotion prayer verb from RMB
/obj/item/clothing/neck/roguetown/psicross/attack_right(mob/user)
	if(loc != user || user.incapacitated())
		return

	user.changeNext_move(CLICK_CD_MELEE)
	var/prayer = locate(/mob/living/carbon/human/proc/clericpray) in user.verbs
	if (prayer)
		call(user, prayer)()

/obj/item/clothing/neck/roguetown/psicross/rmb_self(mob/user)
	return attack_right(user)
