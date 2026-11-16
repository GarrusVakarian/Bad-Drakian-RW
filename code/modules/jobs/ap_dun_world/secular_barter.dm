// Fencing requires an empty loose item or one held by the caster.
/obj/effect/proc_holder/spell/invoked/ap_spell/matthios/barter_secular
	name = "Secular Barter"
	desc = "Fence a valuable through your contacts for a fraction of its price. Arms and armor are excluded; rings are accepted."
	action_icon = 'icons/mob/actions/antiquarianspells.dmi'
	overlay_state = "secularbarter"
	associated_skill = /datum/skill/misc/reading
	range = 1
	releasedrain = 20
	invocation_type = "none"
	recharge_time = 35 SECONDS

/obj/effect/proc_holder/spell/invoked/ap_spell/matthios/barter_secular/cast(list/targets, mob/living/user)
	var/obj/item/I = targets[1]
	if(!can_fence(I, user) || !SStreasury.has_account(user))
		return FALSE
	var/item_value = I.get_real_price()
	if(!do_after(user, 1 SECONDS + round(item_value / 50) SECONDS, target = I))
		return FALSE
	if(!can_continue(user) || !can_fence(I, user) || item_value != I.get_real_price() || !SStreasury.has_account(user))
		return FALSE
	var/reward = round(item_value * (0.4 + user.get_skill_level(associated_skill) * 0.05))
	var/datum/fund/account = SStreasury.get_account(user)
	qdel(I)
	SStreasury.mint(account, reward, "fencing valuables")
	playsound(user, 'sound/effects/secularbarter.ogg', 50, TRUE)
	to_chat(user, span_notice("My contacts transfer [reward] mammons to my account."))
	return TRUE

/obj/effect/proc_holder/spell/invoked/ap_spell/matthios/barter_secular/proc/can_fence(obj/item/I, mob/living/user)
	if(QDELETED(I) || !istype(I) || !I.Adjacent(user) || length(I.contents) || I.override_state)
		return FALSE
	if(!isturf(I.loc) && !(I in user.held_items))
		return FALSE
	if(istype(I, /obj/item/rogueweapon) || istype(I, /obj/item/clothing))
		if(!istype(I, /obj/item/clothing/ring))
			return FALSE
	return I.get_real_price() >= 2
