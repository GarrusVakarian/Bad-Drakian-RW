/datum/reagent/medicine/trait
	var/trait	// applied on ingest, removed when the reagent clears the system
	var/addmsg	// ex. "my body feels lighter", displayed to the imbiber on effect start
	var/delmsg	// ex. "the weight of the world rests upon my shoulders once more", displayed to the imbiber on effect end
	metabolization_rate = 0.05 * REAGENTS_METABOLISM // these REALLY aren't that impactful - this makes drinking one actually last a decent time instead of like 2 seconds

/datum/reagent/medicine/trait/on_mob_metabolize(mob/living/L)
	. = ..()
	if(trait && !HAS_TRAIT(L, trait))
		ADD_TRAIT(L, trait, "[type]")
		if(addmsg)
			to_chat(L, span_warning(addmsg)) // standard style for buff add/remove messages

/datum/reagent/medicine/trait/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(trait && HAS_TRAIT_FROM(L, trait, "[type]"))
		REMOVE_TRAIT(L, trait, "[type]")
		if(delmsg)
			to_chat(L, span_warning(delmsg)) // ditto

/datum/reagent/medicine/trait/sleepdraught
	name = "Restful Draught"
	description = "Calms yet invigorates the mind, maximizing the benefits of the next rest."
	taste_description = "chamomilesque herbs"
	scent_description = "calming florescence"
	trait = TRAIT_BETTER_SLEEP
	color = "#8300ee"
	addmsg = "I feel calm, yet my mind races. I will surely dream furiously."
	delmsg = "The surge of nocturnal inspiration fades."

/datum/reagent/medicine/trait/waterbreathing
	name = "Elixir of Hadal Grace"
	description = "Draws upon Abyssor's blessing, allowing one to persist without breath - for a time."
	taste_description = "abyssal saltiness"
	scent_description = "the sea"
	trait = TRAIT_NOBREATH
	color = "#00255eff"
	addmsg = "I choke momentarily as my lungs adjust; then, suddenly, I stop breathing entirely."
	delmsg = "With a gasp, air floods my lungs once more."

/datum/reagent/medicine/trait/waterbreathing/on_mob_end_metabolize(mob/living/L)
	. = ..()
	L.emote("gasp", forced = TRUE)

/datum/reagent/medicine/trait/ravenous
	name = "Ravenous Elixir"
	description = "Taps into Dendor's feral nature, granting the ability to safely digest even the most dubious of foods. Won't save you from poisons, though."
	taste_description = "viscera and marrow"
	scent_description = "raw meat"
	trait = TRAIT_NASTY_EATER
	color = "#d61d6a"
	addmsg = "I feel a ravenous hunger overtake me. After a mote, it fades to a manageable level."
	delmsg = "My wyld hunger fades completely."

/datum/reagent/medicine/trait/antidepressants
	name = "Draught of Numbness"
	description = "Deadens the heart, protecting one from the ravages of stress - but dulling the joys of lyfe just as much."
	taste_description = "rapidly-fading melancholy"
	scent_description = "tingly absence"
	trait = TRAIT_NOMOOD
	color = "#4d008b"
	addmsg = "I feel my stress drain away as all emotion dulls and fades."
	delmsg = "The stresses - and joys - of the world return to me."

/datum/reagent/medicine/trait/wyrdlaborer
	name = "Laborer's Draught"
	description = "Strengthens the body, granting increased efficiency in tasks such as mining and woodcutting."
	taste_description = "strangely invigorating earthiness"
	scent_description = "earthiness"
	trait = TRAIT_WYRD_LABOURER
	color = "#ad4f10"
	addmsg = "I feel a strange strength growing. The world seems like parchment, or clay - as easily sculpted as it is cleaved."
	delmsg = "The surge of strength fades."

/datum/reagent/medicine/trait/negative
	harmful = TRUE
	metabolization_rate = 0.1 * REAGENTS_METABOLISM

/datum/reagent/medicine/trait/negative/prodepressants
	name = "Stress Toxin"
	description = "Inflicts the mind with paranoia, enhancing any and all stresses for the duration."
	taste_description = "a metallic tang"
	scent_description = "a foreboding odor"
	trait = TRAIT_BAD_MOOD
	color = "#ff9f9f"
	addmsg = "What was in that? I feel awful, all my burdens weigh on me more heavily."
	delmsg = "My stress returns to a manageable level."
