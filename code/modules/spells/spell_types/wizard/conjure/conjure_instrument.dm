/obj/effect/proc_holder/spell/self/conjure_instrument
	name = "Conjure Instrument"
	desc = "Conjure an instrument in your hand or at your feet. Conjuring another replaces it."
	overlay_icon = 'icons/mob/actions/mage_conjure.dmi'
	action_icon = 'icons/mob/actions/mage_conjure.dmi'
	overlay_state = "conjinstrum"
	sound = list('sound/magic/buffrollaccent.ogg')
	releasedrain = 20
	chargedrain = 1
	chargetime = 1 SECONDS
	no_early_release = TRUE
	recharge_time = 1 MINUTES
	charging_slowdown = 3
	antimagic_allowed = FALSE
	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	cost = 1
	invocations = list("Tempus spectaculi!")
	invocation_type = "shout"

/obj/effect/proc_holder/spell/self/conjure_instrument/cast(list/targets, mob/living/user)
	var/static/list/instruments = list(
		"Accordion" = /obj/item/rogue/instrument/accord,
		"Bagpipe" = /obj/item/rogue/instrument/bagpipe,
		"Banjo" = /obj/item/rogue/instrument/banjo,
		"Drum" = /obj/item/rogue/instrument/drum,
		"Flute" = /obj/item/rogue/instrument/flute,
		"Guitar" = /obj/item/rogue/instrument/guitar,
		"Harmonica" = /obj/item/rogue/instrument/harmonica,
		"Harp" = /obj/item/rogue/instrument/harp,
		"Hurdy-Gurdy" = /obj/item/rogue/instrument/hurdygurdy,
		"Jaw Harp" = /obj/item/rogue/instrument/jawharp,
		"Lute" = /obj/item/rogue/instrument/lute,
		"Psyaltery" = /obj/item/rogue/instrument/psyaltery,
		"Shamisen" = /obj/item/rogue/instrument/shamisen,
		"Trumpet" = /obj/item/rogue/instrument/trumpet,
		"Viola" = /obj/item/rogue/instrument/viola,
		"Vocal Talisman" = /obj/item/rogue/instrument/vocals,
	)
	if(!ishuman(user) || !user.client)
		return FALSE
	var/datum/mind/caster = user.mind
	var/choice = tgui_input_list(user, "Choose an instrument.", name, instruments)
	if(QDELETED(src) || QDELETED(user) || user.mind != caster)
		return FALSE
	var/instrument_type = choice && instruments[choice]
	var/atom/destination = user.drop_location()
	if(!ispath(instrument_type, /obj/item/rogue/instrument) || !destination || !user.client || user.incapacitated() || !arcane_speech_allowed(user, TRUE))
		revert_cast(user)
		return FALSE
	var/obj/item/rogue/instrument/instrument = new instrument_type(destination)
	if(QDELETED(instrument))
		return FALSE
	dispel_conjured_item()
	set_conjured_item(instrument)
	user.put_in_hands(instrument)
	return TRUE
