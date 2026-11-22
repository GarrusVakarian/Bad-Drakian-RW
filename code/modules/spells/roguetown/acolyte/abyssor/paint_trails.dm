/obj/effect/ink_trail/healing
	name = "soothing paint"
	desc = "A soothing, shimmering paint that restores vitality to anyone who steps on it."
	icon_state = "paint_gray"
	color = "#b6e6b6"
	buff_payload = /datum/status_effect/buff/umbral_recovery
	debuff_payload = /datum/status_effect/buff/umbral_recovery
	consume_buff = TRUE
	deny_buff = TRUE
	apply_to_pulled = TRUE
	duration = 15 SECONDS

/obj/effect/ink_trail/invigorating
	name = "invigorating paint"
	desc = "An energetic, glowing paint trail that restores missing energy."
	icon_state = "paint_gray"
	color = "#3a86ff"
	buff_payload = /datum/status_effect/buff/invigoration/ink_trail
	debuff_payload = /datum/status_effect/buff/invigoration/ink_trail
	consume_buff = TRUE
	deny_buff = TRUE
	apply_to_pulled = TRUE

/datum/status_effect/buff/invigoration/ink_trail
	duration = 20 SECONDS
	energy_per_tick = 20

/datum/status_effect/buff/invigoration/ink_trail/on_creation(mob/living/new_owner)
	return ..(new_owner, 20 SECONDS)

/obj/effect/ink_trail/evil
	name = "spiked paint"
	desc = "A sinister, dark crimson paint that threatens to pierce anyone who steps onto it."
	icon_state = "paint_gray"
	color = "#580000"
	buff_payload = /datum/status_effect/debuff/ink_spike/weak
	debuff_payload = /datum/status_effect/debuff/ink_spike
	consume_buff = FALSE
	deny_buff = FALSE
	apply_to_pulled = FALSE
	duration = 20 SECONDS
