// lirvasgear

/obj/item/clothing/cloak/ordinatorcape/lirvas
	name = "ornate silks"
	desc = "Fine silks. Only the best for me, of course. You need to look good while beating someone to death. </br> </br>...In truth, this garb only wields but a fraction of the golden might you wish to attain, but they needn't know that."
	icon = 'modular_drakian/icons/clothing/lirvan_cloak.dmi'
	mob_overlay_icon = 'modular_drakian/icons/clothing/onmob/lirvan_cloak.dmi'
	sleeved = 'modular_drakian/icons/clothing/onmob/lirvan_cloak.dmi'
	icon_state = "lirvastabard"
	item_state = "lirvastabard"
	nodismemsleeves = TRUE
	sellprice = 100

/obj/item/clothing/wrists/roguetown/bracers/lirvas
	name = "gold-plated pauldrons"
	desc = "Oversized gold pauldrons that protect the forearms and upper-arms. Surprisingly protective and flashy, but heavy...!"
	icon = 'modular_drakian/icons/clothing/lirvan_wrists.dmi'
	mob_overlay_icon = 'modular_drakian/icons/clothing/onmob/lirvan_wrists.dmi'
	sleeved = 'modular_drakian/icons/clothing/onmob/lirvan_wrists.dmi'
	icon_state = "goldpauldron"
	sellprice = 20

/obj/item/clothing/neck/roguetown/gorget/steel/gold
	name = "gold-plated gorget"
	desc = "A series of steel plates designed to protect the neck, traditionally worn atop a jacket or cuirass. It bears a mammon-sized divet along its right flank; the certification of its 'proofedness' against a longbow's strike. This one is covered in a thin layer of gold."
	color = "#f9a602"

/obj/item/clothing/under/roguetown/chainlegs/kilt/gold
	color = "#f9a602"

/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/gold
	color = "#f9a602"

//high and good armor, but full body, so constant dmg	U N G O D L Y	high regen time. get owned when it breaks or swap to a sidearm
/obj/item/clothing/suit/roguetown/armor/regenerating/skin/lirvas
	name = "hardened scales"
	desc = "Scales hardened by Gilded rituo. </br> </br>Who is more worthy to inherit the wealth of the Sun than those who fly closest?"
	repairmsg_begin = "My scales harden and begin mending."
	repairmsg_continue = "Golden light seeps 'tween myne mending scales."
	repairmsg_stop = "The onslaught stops my scales' regeneration!"
	repairmsg_end = "My scales are as strong as stone once more!"
	repair_time = 30 SECONDS
	combat_taggable = TRUE //this should stop skin regen while hit?
	armor = ARMOR_PLATE
	max_integrity = ARMOR_INT_CHEST_LIGHT_ELITE
	body_parts_covered = COVERAGE_FULL | HANDS | FEET | COVERAGE_HEAD //all but eyes/nose, seems fair.

/obj/item/rogueweapon/woodstaff/quarterstaff/gold
	name = "golden quarterstaff"
	desc = "The astute may point out that this staff is poorly designed. They would be correct. Gold, even low karat, is a bad material for a \
	weapon. This one additionally manages to be doubly-sinned by having a heavy chunk of gold at the end. It's almost a polehammer. Practical? \
	No. But it makes a statement."
	icon = 'modular_drakian/icons/obj/weapons/lirvan_polearms64.dmi'
	icon_state = "quarterstaff_gold"
	force = 23
	force_wielded = 30
	special = /datum/special_intent/gilded_dragon_sweep
	sellprice = 80
	no_loot_taint = TRUE
	max_integrity = 250 //equal to silver; putting it at half of this was a neat little experiment but agonizing

/datum/intent/katar/lirvasbite //snowflake intent
	name = "gouge"
	icon_state = "instrike"
	attack_verb = list("gouges", "bites into")
	animname = "bite"
	blade_class = BCLASS_BITE //i really hope this shit's going to work well
	hitsound = list('sound/combat/hits/bladed/smallslash (1).ogg', 'sound/combat/hits/bladed/smallslash (2).ogg', 'sound/combat/hits/bladed/smallslash (3).ogg')
	penfactor = 25
	swingdelay = 1 SECONDS
	clickcd = CLICK_CD_MASSIVE
	damfactor = 1.5 //bites you bites you bites yo
	item_d_type = "stab"

/obj/item/rogueweapon/katar/lirvan_talon
	name = "DRAKKYRMAW"
	desc = "Goldmaw. Infinite teeth. Damage scales with wealth. You know what this is. <br> <br>Do you remember your first mammon?; the becoming of the -self tied to the wealthpulse of the world. In that moment, when you became part of the living beast of economy, did you realize its weight? Do you even remember it? Or has it been yet drowned out? No matter what, there is, of course, only one way to stay as part of the beast instead of its feed. Kill. Trade or tax or blade- kill."
	icon = 'modular_drakian/icons/obj/weapons/lirvan_unarmed32.dmi'
	icon_state = "drakkyrfist"
	possible_item_intents = list(/datum/intent/katar/cut, /datum/intent/katar/thrust, /datum/intent/katar/lirvasbite)
	max_blade_int = 999
	max_integrity = 999
	wdefense = 6 //lil boost
	w_class = WEIGHT_CLASS_HUGE
	can_parry = TRUE
	special = /datum/special_intent/drakkyrmaw_bite
	var/mob/living/attuned_owner
	var/wealth_value = 0

/obj/item/rogueweapon/katar/lirvan_talon/proc/attune_to_wealth(new_wealth_value)
	wealth_value = new_wealth_value
	force = clamp(round(15 + (wealth_value / 10)), 20, 32)
	throwforce = clamp(round(force / 2), 10, 30) //if this ever becomes relevant lol
	update_force_dynamic()
	name = "[wealth_value]-toothed DRAKKYRMAW"

/obj/item/rogueweapon/katar/lirvan_talon/examine(mob/user)
	. = ..()
	. += span_notice(" [wealth_value] teeth. [force] force.")

/obj/item/rogueweapon/katar/lirvan_talon/dropped(mob/living/user, silent)
	. = ..()
	if(user == attuned_owner)
		qdel(src)
