/obj/item/rogueweapon/mace/woodclub/militia // it literally just has an aura, and demolish intent
	name = "bogbark club"
	desc = "A primitive cudgel carved of a stout piece of treefall, from the deepest parts of the Terrorbog. An unmistakable aura of power surrounds it. This thing looks dangerously strong."
	gripped_intents = list(/datum/intent/mace/strike/wood/, /datum/intent/mace/smash/wood, /datum/intent/effect/daze, /datum/intent/mace/lesserdemolish)
	w_class = WEIGHT_CLASS_NORMAL // it's just a stick, can put it in your backpack


/obj/item/rogueweapon/scythe/militia
	desc = "The bane of fields, the trimmer of grass, the harvester of wheat, and - depending on who you ask - the shepherd of souls to the afterlyfe. This one has been reinforced."
	name = "militia scythe"
	smeltresult = /obj/item/ingot/iron
	force = 18
	force_wielded = 28


/obj/item/clothing/cloak/stabard/bog/ap_levy
	name = "levy militia tabard"
	desc = "A tabard colored in a glorious green of the mighty protectors of the BOG. Except you are not a TRAITOR. Yet."
	color = CLOTHING_GREEN
	detail_color = CLOTHING_DARK_GREEN


/obj/item/clothing/cloak/stabard/bog/ap_levy/hood
	name = "levy militia hood"
	desc = "A hood colored in a glorious green of the mighty protectors of the BOG. Except you are not a TRAITOR. Yet."
	slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_NECK|ITEM_SLOT_MASK|ITEM_SLOT_CLOAK
	color = CLOTHING_GREEN
	detail_color = CLOTHING_DARK_GREEN
	icon_state = "guard_hood"
	item_state = "guard_hood"
	detail_tag = "_spl"



/obj/item/rogueweapon/mace/woodclub/militia/Initialize()
	. = ..()
	filters += filter(type = "outline", size = 1, color = "#00ff00")

/datum/intent/mace/lesserdemolish
	name = "break"
	desc = "A deliberate structure-breaking blow. Deals triple the damage to structures"
	icon_state = "incrush"
	blade_class = BCLASS_SMASH
	attack_verb = list("demolishes", "crushes", "wrecks")
	animname = "strike"
	hitsound = list('sound/combat/hits/blunt/metalblunt (1).ogg', 'sound/combat/hits/blunt/metalblunt (2).ogg', 'sound/combat/hits/blunt/metalblunt (3).ogg')
	item_d_type = "blunt"
	penfactor = 0
	demolition_mod = 3
	clickcd = CLICK_CD_HEAVY
	swingdelay = 10
