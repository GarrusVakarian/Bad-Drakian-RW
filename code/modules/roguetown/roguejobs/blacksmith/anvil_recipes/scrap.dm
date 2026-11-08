// SCRAP SLAG
// Mirrors the decrepit recipes, but forged from scrap slag and open to anyone - scrap is what apprentices learn on.

/datum/anvil_recipe/armor/scrap
	abstract_type = /datum/anvil_recipe/armor/scrap
	req_bar = /obj/item/ingot/scrap
	craftdiff = 0

/datum/anvil_recipe/weapons/scrap
	abstract_type = /datum/anvil_recipe/weapons/scrap
	req_bar = /obj/item/ingot/scrap
	craftdiff = 0

/datum/anvil_recipe/tools/scrap
	abstract_type = /datum/anvil_recipe/tools/scrap
	req_bar = /obj/item/ingot/scrap
	craftdiff = 0

// ARMOR

/datum/anvil_recipe/armor/scrap/barbute
	name = "Barbute, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/head/roguetown/helmet/heavy/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_HELMETS

/datum/anvil_recipe/armor/scrap/savoyard
	name = "Savoyard, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/head/roguetown/helmet/heavy/guard/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_HELMETS

/datum/anvil_recipe/armor/scrap/bascinet
	name = "Bascinet, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/head/roguetown/helmet/heavy/knight/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_HELMETS

/datum/anvil_recipe/armor/scrap/helmetkettle
	name = "Kettle Helmet, Scrap"
	created_item = /obj/item/clothing/head/roguetown/helmet/kettle/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_HELMETS

/datum/anvil_recipe/armor/scrap/mask
	name = "Mask, Scrap"
	created_item = /obj/item/clothing/mask/rogue/facemask/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_MASKS

/datum/anvil_recipe/armor/scrap/coif
	name = "Coif, Scrap"
	created_item = /obj/item/clothing/neck/roguetown/chaincoif/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_NECK

/datum/anvil_recipe/armor/scrap/gorget
	name = "Gorget, Scrap"
	created_item = /obj/item/clothing/neck/roguetown/gorget/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_NECK

/datum/anvil_recipe/armor/scrap/cuirass
	name = "Cuirass, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/suit/roguetown/armor/plate/half/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_CHESTPIECES

/datum/anvil_recipe/armor/scrap/halfplate
	name = "Half-Plate, Scrap (+1 Cuirass, Scrap, +2 Cured Leather)"
	additional_items = list(/obj/item/clothing/suit/roguetown/armor/plate/half/ancient/decrepit/scrap, /obj/item/natural/hide/cured, /obj/item/natural/hide/cured)
	created_item = /obj/item/clothing/suit/roguetown/armor/plate/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_CHESTPIECES

/datum/anvil_recipe/armor/scrap/chainmail
	name = "Chainmail, Scrap"
	created_item = /obj/item/clothing/suit/roguetown/armor/chainmail/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_CHESTPIECES

/datum/anvil_recipe/armor/scrap/hauberk
	name = "Hauberk, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_CHESTPIECES

/datum/anvil_recipe/armor/scrap/bracers
	name = "Bracers, Scrap"
	created_item = /obj/item/clothing/wrists/roguetown/bracers/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_BRACERS

/datum/anvil_recipe/armor/scrap/maillebracers
	name = "Chainsleeves, Scrap"
	created_item = /obj/item/clothing/wrists/roguetown/bracers/chain/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_BRACERS

/datum/anvil_recipe/armor/scrap/chaingaunts
	name = "Chain Gauntlets, Scrap"
	created_item = /obj/item/clothing/gloves/roguetown/chain/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_GLOVES

/datum/anvil_recipe/armor/scrap/plategaunts
	name = "Plate Gauntlets, Scrap"
	created_item = /obj/item/clothing/gloves/roguetown/plate/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_GLOVES

/datum/anvil_recipe/armor/scrap/plateboots
	name = "Plate Boots, Scrap"
	created_item = /obj/item/clothing/shoes/roguetown/boots/armor/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_BOOTS

/datum/anvil_recipe/armor/scrap/chainkilt
	name = "Chainkilt, Scrap"
	created_item = /obj/item/clothing/under/roguetown/chainlegs/kilt/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_LEGS

/datum/anvil_recipe/armor/scrap/platelegs
	name = "Plated Chausses, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/clothing/under/roguetown/platelegs/ancient/decrepit/scrap
	display_category = ITEM_CAT_ARMOR_LEGS

// WEAPONS

/datum/anvil_recipe/weapons/scrap/flail
	name = "Flail, Scrap"
	created_item = /obj/item/rogueweapon/flail/sflail/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_FLAILS

/datum/anvil_recipe/weapons/scrap/dagger
	name = "Dagger, Scrap"
	created_item = /obj/item/rogueweapon/huntingknife/idagger/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_DAGGERS

/datum/anvil_recipe/weapons/scrap/knuckles
	name = "Knuckles, Scrap"
	created_item = /obj/item/rogueweapon/knuckles/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_MACES

/datum/anvil_recipe/weapons/scrap/shortsword
	name = "Shortsword, Scrap"
	created_item = /obj/item/rogueweapon/sword/short/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SWORDS

/datum/anvil_recipe/weapons/scrap/gladius
	name = "Gladius, Scrap"
	created_item = /obj/item/rogueweapon/sword/short/gladius/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SWORDS

/datum/anvil_recipe/weapons/scrap/khopesh
	name = "Khopesh, Scrap"
	created_item = /obj/item/rogueweapon/sword/sabre/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SWORDS

/datum/anvil_recipe/weapons/scrap/handaxe
	name = "Axe, Scrap"
	created_item = /obj/item/rogueweapon/stoneaxe/woodcut/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_AXES

/datum/anvil_recipe/weapons/scrap/mace
	name = "Mace, Scrap"
	created_item = /obj/item/rogueweapon/mace/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_MACES

/datum/anvil_recipe/weapons/scrap/warhammer
	name = "Warhammer, Scrap"
	created_item = /obj/item/rogueweapon/mace/warhammer/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_MACES

/datum/anvil_recipe/weapons/scrap/tossblade
	name = "Tossblades, Scrap (x4)"
	created_item = /obj/item/rogueweapon/huntingknife/throwingknife/steel/ancient/decrepit/scrap
	createditem_num = 4
	display_category = ITEM_CAT_WEAPONS_DAGGERS

/datum/anvil_recipe/weapons/scrap/gsw
	name = "Greatsword, Scrap (+2 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap, /obj/item/ingot/scrap)
	created_item = /obj/item/rogueweapon/greatsword/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SWORDS

/datum/anvil_recipe/weapons/scrap/bardiche
	name = "Bardiche, Scrap (+1 Scrap Slag, +1 Small Log)"
	additional_items = list(/obj/item/ingot/scrap, /obj/item/grown/log/tree/small)
	created_item = /obj/item/rogueweapon/halberd/bardiche/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_POLEARMS

/datum/anvil_recipe/weapons/scrap/grandmace
	name = "Grand Mace, Scrap (+1 Scrap Slag, +1 Small Log)"
	additional_items = list(/obj/item/ingot/scrap, /obj/item/grown/log/tree/small)
	created_item = /obj/item/rogueweapon/mace/goden/steel/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_MACES

/datum/anvil_recipe/weapons/scrap/spear
	name = "Spear, Scrap (+1 Small Log)"
	additional_items = list(/obj/item/grown/log/tree/small)
	created_item = /obj/item/rogueweapon/spear/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_POLEARMS

/datum/anvil_recipe/weapons/scrap/javelin
	name = "Javelin, Scrap (+1 Small Log) (x2)"
	additional_items = list(/obj/item/grown/log/tree/small)
	created_item = /obj/item/ammo_casing/caseless/rogue/javelin/steel/ancient/decrepit/scrap
	createditem_num = 2
	display_category = ITEM_CAT_WEAPONS_AMMO

/datum/anvil_recipe/weapons/scrap/kiteshield
	name = "Kite Shield, Scrap (+1 Scrap Slag, +1 Cured Leather)"
	additional_items = list(/obj/item/ingot/scrap, /obj/item/natural/hide/cured)
	created_item = /obj/item/rogueweapon/shield/tower/metal/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SHIELDS

/datum/anvil_recipe/weapons/scrap/hoplon
	name = "Hoplon Shield, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/rogueweapon/shield/gilbranze/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SHIELDS

/datum/anvil_recipe/weapons/scrap/hoplon_great
	name = "Hoplon Greatshield, Scrap (+3 Scrap Slag, +1 Cured Leather)"
	additional_items = list(/obj/item/ingot/scrap, /obj/item/ingot/scrap, /obj/item/ingot/scrap, /obj/item/natural/hide/cured)
	created_item = /obj/item/rogueweapon/shield/gilbranze/great/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SHIELDS

/datum/anvil_recipe/weapons/scrap/buckler
	name = "Buckler, Scrap (+1 Scrap Slag)"
	additional_items = list(/obj/item/ingot/scrap)
	created_item = /obj/item/rogueweapon/shield/buckler/ancient/decrepit/scrap
	display_category = ITEM_CAT_WEAPONS_SHIELDS

/datum/anvil_recipe/weapons/scrap/bolts
	name = "Bolts, Scrap (+2 Stick) (x10)"
	additional_items = list(/obj/item/grown/log/tree/stick, /obj/item/grown/log/tree/stick)
	created_item = /obj/item/ammo_casing/caseless/rogue/bolt/decrepit/scrap
	createditem_num = 10
	i_type = "Ammo"
	display_category = ITEM_CAT_WEAPONS_AMMO

/datum/anvil_recipe/weapons/scrap/arrows
	name = "Broadhead Arrows, Scrap (+2 Stick) (x10)"
	additional_items = list(/obj/item/grown/log/tree/stick, /obj/item/grown/log/tree/stick)
	created_item = /obj/item/ammo_casing/caseless/rogue/arrow/iron/decrepit/scrap
	createditem_num = 10
	i_type = "Ammo"
	display_category = ITEM_CAT_WEAPONS_AMMO

/datum/anvil_recipe/weapons/scrap/slingbullets
	name = "Sling Bullets, Scrap (x10)"
	created_item = /obj/item/ammo_casing/caseless/rogue/sling_bullet/decrepit/scrap
	createditem_num = 10
	i_type = "Ammo"
	display_category = ITEM_CAT_WEAPONS_AMMO

// TOOLS

/datum/anvil_recipe/tools/scrap/thresher
	name = "Thresher, Scrap (+1 Stick)"
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/thresher/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/hoe
	name = "Hoe, Scrap (+2 Sticks)"
	additional_items = list(/obj/item/grown/log/tree/stick, /obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/hoe/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/pitchfork
	name = "Pitchfork, Scrap (+2 Sticks)"
	additional_items = list(/obj/item/grown/log/tree/stick, /obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/pitchfork/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/hammer
	name = "Hammer, Scrap (+1 Stick)"
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/hammer/ancient/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_WORKSHOP

/datum/anvil_recipe/tools/scrap/sickle
	name = "Sickle, Scrap (+1 Stick)"
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/sickle/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/tongs
	name = "Tongs, Scrap"
	created_item = /obj/item/rogueweapon/tongs/ancient/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_WORKSHOP

/datum/anvil_recipe/tools/scrap/pick
	name = "Pickaxe, Scrap (+1 Stick)"
	additional_items = list(/obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/pick/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/shovel
	name = "Shovel, Scrap (+2 Sticks)"
	additional_items = list(/obj/item/grown/log/tree/stick, /obj/item/grown/log/tree/stick)
	created_item = /obj/item/rogueweapon/shovel/decrepit/scrap
	i_type = "Tools"
	display_category = ITEM_CAT_TOOLS_FIELD

/datum/anvil_recipe/tools/scrap/sewingneedle
	name = "Needles, Scrap (x3)"
	created_item = /obj/item/needle/decrepit/scrap
	createditem_num = 3
	display_category = ITEM_CAT_TOOLS_WORKSHOP

/datum/anvil_recipe/tools/scrap/pan
	name = "Frypan, Scrap"
	created_item = /obj/item/cooking/pan/decrepit/scrap
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/goblets
	name = "Goblets, Scrap (x2)"
	created_item = /obj/item/reagent_containers/glass/cup/decrepitgob/scrap
	createditem_num = 2
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/mugs
	name = "Mug, Scrap (x3)"
	created_item = /obj/item/reagent_containers/glass/cup/decrepitmug/scrap
	createditem_num = 3
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/pot
	name = "Cooking Pot, Scrap"
	created_item = /obj/item/reagent_containers/glass/bucket/pot/decrepit/scrap
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/platter
	name = "Platter, Scrap (x3)"
	created_item = /obj/item/cooking/platter/decrepit/scrap
	createditem_num = 3
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/bowl
	name = "Bowl, Scrap"
	created_item = /obj/item/reagent_containers/glass/bowl/decrepit/scrap
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/fork
	name = "Fork, Scrap (x3)"
	created_item = /obj/item/kitchen/fork/decrepit/scrap
	createditem_num = 3
	display_category = ITEM_CAT_TOOLS_COOKWARE

/datum/anvil_recipe/tools/scrap/spoon
	name = "Spoon, Scrap (x3)"
	created_item = /obj/item/kitchen/spoon/decrepit/scrap
	createditem_num = 3
	display_category = ITEM_CAT_TOOLS_COOKWARE

// VALUABLES

/datum/anvil_recipe/valuables/scrap_statue
	name = "Statue, Scrap"
	req_bar = /obj/item/ingot/scrap
	created_item = /obj/item/roguestatue/decrepit/scrap
	display_category = ITEM_CAT_DECORATION
	craftdiff = 0

/datum/anvil_recipe/valuables/scrap_rings
	name = "Rings, Scrap (x3)"
	req_bar = /obj/item/ingot/scrap
	created_item = /obj/item/clothing/ring/decrepit/scrap
	display_category = ITEM_CAT_VALUABLES_RINGS
	createditem_num = 3
	craftdiff = 0
