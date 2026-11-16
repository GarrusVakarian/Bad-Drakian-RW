// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/datum/alch_cauldron_recipe/trait
	abstract_type = /datum/alch_cauldron_recipe/trait
	skill_required = SKILL_LEVEL_JOURNEYMAN // the difficulty in these is making the rubedo catalyst

/datum/alch_cauldron_recipe/trait/sleepdraught
	name = "Restful Draught"
	smells_like = "calming florescence"
	output_reagents =list(/datum/reagent/medicine/trait/sleepdraught = 90)

/datum/alch_cauldron_recipe/trait/waterbreathing
	name = "Elixir of Hadal Grace"
	smells_like = "the sea"
	output_reagents =list(/datum/reagent/medicine/trait/waterbreathing = 90) // this one's slightly gamer potentially edit: no it wasn't lmao

/datum/alch_cauldron_recipe/trait/ravenous
	name = "Ravenous Elixir"
	smells_like = "raw meat"
	output_reagents =list(/datum/reagent/medicine/trait/ravenous = 90)

/datum/alch_cauldron_recipe/trait/antidepressants
	name = "Draught of Numbness"
	smells_like = "tingly absence"
	output_reagents =list(/datum/reagent/medicine/trait/antidepressants = 90)

/datum/alch_cauldron_recipe/trait/wyrdlaborer
	name = "Laborer's Draught"
	smells_like = "earthiness"
	output_reagents =list(/datum/reagent/medicine/trait/wyrdlaborer = 90)

/datum/alch_cauldron_recipe/trait/negative
	abstract_type = /datum/alch_cauldron_recipe/trait/negative
	skill_required = SKILL_LEVEL_EXPERT // poisons are harder...

/datum/alch_cauldron_recipe/trait/negative/prodepressants
	name = "Stress Toxin"
	smells_like = "paranoia"
	output_reagents = list(/datum/reagent/medicine/trait/negative/prodepressants = 30) // ...and yield less
