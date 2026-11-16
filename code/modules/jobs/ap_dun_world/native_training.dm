// The port uses Drakian's spell learning and spellblade abilities.
/datum/outfit/job/roguetown/proc/ap_spellblade_training(mob/living/carbon/human/H)
	var/list/styles = list("Blade" = "blade", "Polearm" = "phalangite", "Mace" = "macebearer")
	var/choice = H.client ? input(H, "Choose your martial focus.", "Spellblade training") as null|anything in styles : null
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/airblade)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/enchant_weapon)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/conjure_weapon)
	if(choice && styles[choice])
		return styles[choice]
	return "blade"

/obj/effect/proc_holder/spell/invoked/mockery/ap_maestro
	miracle = FALSE
	devotion_cost = 0
	associated_skill = /datum/skill/misc/music

/datum/inspiration
	var/ap_allegro = FALSE
	var/ap_allegro_counter = 0
