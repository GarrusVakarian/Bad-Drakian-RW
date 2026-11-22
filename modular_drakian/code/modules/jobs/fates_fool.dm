// Adapted from Ochre Valley #341 by SatinIsle. Uses BD's existing skills, gear and magic.
/datum/advclass/fates_fool
	name = "Fate's Fool"
	tutorial = "Let fate choose your tools and talents. Start with random stats, skills, traits and equipment, with a chance of arcane training or miracles."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/adventurer/fates_fool
	cmode_music = 'sound/music/cmode/adventurer/combat_outlander2.ogg'
	class_select_category = CLASS_CAT_ROGUE
	category_tags = list(CTAG_ADVENTURER)
	townie_contract_gate_exempt = TRUE
	townie_contract_gate_hide_in_list = TRUE

/datum/outfit/job/roguetown/adventurer/fates_fool/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(QDELETED(H))
		return
	roll_equipment()
	if(visualsOnly)
		return
	roll_character(H)
	to_chat(H, span_warning("Xylix laughs either at or with you. Make the most of what fate has given you."))
	if(H.client)
		to_chat(H, span_warning("Keep your rolls. Do not leave and respawn for better ones."))
		message_admins("[ADMIN_LOOKUPFLW(H)] spawned as Fate's Fool. Watch for respawn rerolls.")
		log_game("[key_name(H)] spawned as Fate's Fool.")

/datum/outfit/job/roguetown/adventurer/fates_fool/proc/roll_character(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	// Roll a replacement for the neutral base of ten, preserving existing modifiers and buffers.
	for(var/stat in list(STATKEY_STR, STATKEY_PER, STATKEY_INT, STATKEY_CON, STATKEY_WIL, STATKEY_SPD, STATKEY_LCK))
		var/base_roll = prob(10) ? rand(1, 20) : rand(5, 15)
		H.change_stat(stat, base_roll - 10)

	var/static/list/trait_pool = list(
		TRAIT_DODGEEXPERT,
		TRAIT_OUTDOORSMAN,
		TRAIT_EXPERT_HUNTER,
		TRAIT_MEDICINE_EXPERT,
		TRAIT_ALCHEMY_EXPERT,
		TRAIT_SMITHING_EXPERT,
		TRAIT_SEWING_EXPERT,
		TRAIT_SURVIVAL_EXPERT,
		TRAIT_HOMESTEAD_EXPERT,
		TRAIT_SELF_SUSTENANCE,
		TRAIT_NOBLE,
		TRAIT_HEAVYARMOR,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_EXPLOSIVE_SUPPLY,
		TRAIT_BOMBER_EXPERT,
		TRAIT_EMPATH,
		TRAIT_GOODLOVER,
		TRAIT_BLOOD_RESISTANCE,
		TRAIT_FENCERDEXTERITY,
		TRAIT_INTELLECTUAL,
		TRAIT_NOPAINSTUN,
		TRAIT_WOODWALKER,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_GRAVEROBBER,
		TRAIT_SEEPRICES,
		TRAIT_NASTY_EATER,
		TRAIT_WILD_EATER,
		TRAIT_KNEESTINGER_IMMUNITY,
		TRAIT_DARKVISION,
		TRAIT_STRONGBITE,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_NOSTINK,
		TRAIT_AZURENATIVE,
		TRAIT_GOODTRAINER,
	)
	var/list/available_traits = trait_pool.Copy()
	var/list/banned_traits
	if(H.dna && istype(H.dna.species))
		banned_traits = H.dna.species.banned_traits
	for(var/trait in trait_pool)
		if((trait in banned_traits) || HAS_TRAIT(H, trait))
			available_traits -= trait
	for(var/chance in list(100, 100, 80, 70, 50))
		if(!length(available_traits))
			break
		if(prob(chance))
			var/trait = pick_n_take(available_traits)
			ADD_TRAIT(H, trait, ADVENTURER_TRAIT)

	var/static/list/combat_skills = list(
		/datum/skill/combat/knives,
		/datum/skill/combat/swords,
		/datum/skill/combat/polearms,
		/datum/skill/combat/maces,
		/datum/skill/combat/axes,
		/datum/skill/combat/whipsflails,
		/datum/skill/combat/bows,
		/datum/skill/combat/crossbows,
		/datum/skill/combat/firearms,
		/datum/skill/combat/wrestling,
		/datum/skill/combat/unarmed,
		/datum/skill/combat/shields,
		/datum/skill/combat/slings,
	)
	for(var/skill in combat_skills)
		if(prob(20))
			H.adjust_skillrank_up_to(skill, rand(1, 4), TRUE)
	var/static/list/other_skills = list(
		/datum/skill/craft/crafting,
		/datum/skill/craft/weaponsmithing,
		/datum/skill/craft/armorsmithing,
		/datum/skill/craft/blacksmithing,
		/datum/skill/craft/smelting,
		/datum/skill/craft/carpentry,
		/datum/skill/craft/masonry,
		/datum/skill/craft/engineering,
		/datum/skill/craft/cooking,
		/datum/skill/craft/sewing,
		/datum/skill/craft/tanning,
		/datum/skill/craft/ceramics,
		/datum/skill/craft/alchemy,
		/datum/skill/labor/farming,
		/datum/skill/labor/mining,
		/datum/skill/labor/fishing,
		/datum/skill/labor/butchering,
		/datum/skill/labor/lumberjacking,
		/datum/skill/misc/athletics,
		/datum/skill/misc/climbing,
		/datum/skill/misc/reading,
		/datum/skill/misc/swimming,
		/datum/skill/misc/sneaking,
		/datum/skill/misc/lockpicking,
		/datum/skill/misc/riding,
		/datum/skill/misc/medicine,
		/datum/skill/misc/tracking,
		/datum/skill/misc/hunting,
		/datum/skill/misc/music,
	)
	for(var/skill in other_skills)
		if(prob(15))
			H.adjust_skillrank_up_to(skill, rand(1, 6), TRUE)

	if(H.mind && prob(20))
		var/list/arcane_training = list(TRAIT_ARCYNE_T1, TRAIT_ARCYNE_T2, TRAIT_ARCYNE_T3)
		arcane_training -= banned_traits
		if(length(arcane_training))
			ADD_TRAIT(H, pick(arcane_training), ADVENTURER_TRAIT)
			H.adjust_skillrank_up_to(/datum/skill/magic/arcane, rand(1, 6), TRUE)
			H.mind.adjust_spellpoints(rand(1, 15))
	if(H.mind && istype(H.patron) && !H.devotion && prob(20))
		var/datum/devotion/D = new(H, H.patron)
		H.adjust_skillrank_up_to(/datum/skill/magic/holy, rand(1, 6), TRUE)
		D.grant_miracles(H, cleric_tier = rand(1, 4), passive_gain = rand(1, 10) / 10, devotion_limit = rand(250, 1000))

/datum/outfit/job/roguetown/adventurer/fates_fool/proc/roll_equipment()
	// Reset conditional slots when an outfit datum is reused for another preview or character.
	for(var/slot in list("shirt", "armor", "pants", "belt", "beltl", "beltr", "cloak", "shoes", "wrists", "gloves", "neck", "backl", "backr", "r_hand", "l_hand", "mask", "head", "mouth"))
		vars[slot] = null

	if(prob(80))
		shirt = pick(/obj/item/clothing/suit/roguetown/armor/gambeson,
				/obj/item/clothing/suit/roguetown/shirt/tunic/random,
				/obj/item/clothing/suit/roguetown/shirt/undershirt/black,
				/obj/item/clothing/suit/roguetown/armor/chainmail,
				/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron,
				/obj/item/clothing/suit/roguetown/armor/gambeson/light,
				/obj/item/clothing/suit/roguetown/armor/chainmail/iron,
				/obj/item/clothing/suit/roguetown/shirt/undershirt,
				/obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1,
				/obj/item/clothing/suit/roguetown/armor/corset,
		)
	if(prob(60))
		armor = pick(/obj/item/clothing/suit/roguetown/armor/plate/half/iron,
				/obj/item/clothing/suit/roguetown/armor/leather,
				/obj/item/clothing/suit/roguetown/armor/leather/cuirass,
				/obj/item/clothing/suit/roguetown/armor/leather/hide,
				/obj/item/clothing/suit/roguetown/armor/leather/bikini,
				/obj/item/clothing/suit/roguetown/armor/plate/iron,
				/obj/item/clothing/suit/roguetown/armor/basiceast,
				/obj/item/clothing/suit/roguetown/shirt/robe/spellcasterrobe,
				/obj/item/clothing/suit/roguetown/shirt/robe/mage,
				/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat,
				/obj/item/clothing/suit/roguetown/shirt/robe/monk,
				/obj/item/clothing/suit/roguetown/shirt/dress/silkdress,
				/obj/item/clothing/suit/roguetown/armor/armordress,
		)
	if(prob(80))
		pants = pick(/obj/item/clothing/under/roguetown/tights/black,
				/obj/item/clothing/under/roguetown/chainlegs/iron,
				/obj/item/clothing/under/roguetown/chainlegs/iron/kilt,
				/obj/item/clothing/under/roguetown/splintlegs,
				/obj/item/clothing/under/roguetown/trou/leather,
				/obj/item/clothing/under/roguetown/chainlegs/kilt,
				/obj/item/clothing/under/roguetown/loincloth,
				/obj/item/clothing/under/roguetown/heavy_leather_pants,
				/obj/item/clothing/under/roguetown/skirt/red,
		)
	belt = pick(/obj/item/storage/belt/rogue/leather,
			/obj/item/storage/belt/rogue/leather/rope,
			/obj/item/storage/belt/rogue/leather/sash,
			/obj/item/storage/belt/rogue/leather/plaquesilver,
			/obj/item/storage/belt/rogue/leather/black,
			/obj/item/storage/belt/rogue/leather/cloth,
	)
	beltl = pick(/obj/item/storage/belt/rogue/pouch/coins/poor,
			/obj/item/storage/belt/rogue/pouch/coins/rich,
			/obj/item/storage/belt/rogue/pouch/coins/mid,
	)
	beltr = pick(/obj/item/rogueweapon/sword/short,
			/obj/item/rogueweapon/sword,
			/obj/item/rogueweapon/mace/steel,
			/obj/item/rogueweapon/flail/sflail,
			/obj/item/rogueweapon/mace/warhammer,
			/obj/item/rogueweapon/sword/short/iron,
			/obj/item/rogueweapon/huntingknife/idagger/steel,
			/obj/item/rogueweapon/huntingknife,
			/obj/item/rogueweapon/sword/long,
			/obj/item/rogueweapon/sword/long/broadsword,
			/obj/item/rogueweapon/whip,
			/obj/item/rogueweapon/sword/short/messer/iron,
			/obj/item/rogueweapon/sword/sabre,
			/obj/item/rogueweapon/mace/cudgel,
			/obj/item/rogueweapon/stoneaxe/woodcut,
	)
	if(prob(40))
		cloak = pick(/obj/item/clothing/cloak/raincloak/furcloak,
				/obj/item/clothing/cloak/half,
				/obj/item/clothing/cloak/apron,
				/obj/item/clothing/cloak/poncho,
				/obj/item/clothing/cloak/tabard,
				/obj/item/clothing/cloak/cape,
		)
	if(prob(90))
		shoes = pick(/obj/item/clothing/shoes/roguetown/boots,
				/obj/item/clothing/shoes/roguetown/boots/leather/reinforced,
				/obj/item/clothing/shoes/roguetown/boots/furlinedboots,
				/obj/item/clothing/shoes/roguetown/boots/armor/iron,
				/obj/item/clothing/shoes/roguetown/boots/armor,
				/obj/item/clothing/shoes/roguetown/sandals,
		)
	if(prob(50))
		wrists = pick(/obj/item/clothing/wrists/roguetown/bracers/iron,
				/obj/item/clothing/wrists/roguetown/splintarms/iron,
				/obj/item/clothing/wrists/roguetown/bracers/leather,
				/obj/item/clothing/neck/roguetown/psicross/silver,
				/obj/item/clothing/neck/roguetown/psicross/naledi,
				/obj/item/clothing/wrists/roguetown/bracers/cloth/monk,
		)
	if(prob(50))
		gloves = pick(/obj/item/clothing/gloves/roguetown/angle,
				/obj/item/clothing/gloves/roguetown/chain/iron,
				/obj/item/clothing/gloves/roguetown/fingerless_leather,
				/obj/item/clothing/gloves/roguetown/leather,
				/obj/item/clothing/gloves/roguetown/bandages,
				/obj/item/clothing/gloves/roguetown/bandages/weighted,
		)
	if(prob(40))
		neck = pick(/obj/item/clothing/neck/roguetown/gorget,
				/obj/item/clothing/neck/roguetown/chaincoif/iron,
				/obj/item/clothing/neck/roguetown/coif/heavypadding,
				/obj/item/clothing/neck/roguetown/coif/padded,
				/obj/item/clothing/neck/roguetown/bevor/iron,
				/obj/item/clothing/neck/roguetown/psicross/silver,
				/obj/item/storage/belt/rogue/pouch/coins/poor,
		)
	backl = /obj/item/storage/backpack/rogue/satchel
	var/backpack_items = list(
		/obj/item/recipe_book/magic,
		/obj/item/flashlight/flare/torch/metal,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/rogueweapon/scabbard/sheath,
		/obj/item/rogueweapon/huntingknife,
		/obj/item/chalk,
		/obj/item/flashlight/flare/torch/lantern,
		/obj/item/lockpickring/mundane,
		/obj/item/repair_kit/metal/bad,
		/obj/item/flint,
		/obj/item/lockpick,
		/obj/item/reagent_containers/glass/bottle/rogue/manapot,
		/obj/item/reagent_containers/glass/bottle/rogue/beer,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot,
		/obj/item/rope/chain,
		/obj/item/rogueweapon/huntingknife/scissors,
		/obj/item/clothing/mask/cigarette/rollie/cannabis,
		/obj/item/rope,
	)
	backpack_contents = list()
	for(var/i in 1 to 3)
		var/item_path = pick(backpack_items)
		if(!(item_path in backpack_contents))
			backpack_contents[item_path] = 0
		backpack_contents[item_path]++
	if(prob(50))
		backr = pick(/obj/item/rogueweapon/shield/iron,
				/obj/item/rogueweapon/shield/wood,
				/obj/item/rogueweapon/sword/long,
				/obj/item/rogueweapon/sword/long/broadsword/steel,
				/obj/item/rogueweapon/scabbard/gwstrap,
				/obj/item/rogueweapon/sword/long/exe,
				/obj/item/rogueweapon/woodstaff,
				/obj/item/rogueweapon/shield/tower/metal,
				/obj/item/rogue/instrument/lute,
				/obj/item/rogueweapon/shield/bronze,
				/obj/item/rogueweapon/shovel,
				/obj/item/flashlight/flare/torch/metal,
				/obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve,
				/obj/item/quiver/arrows,
				/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow,
				/obj/item/storage/backpack/rogue/satchel,
		)
	r_hand = pick(/obj/item/rogueweapon/greatsword/iron,
			/obj/item/rogueweapon/sword/short,
			/obj/item/rogueweapon/spear/billhook,
			/obj/item/rogueweapon/flail/peasantwarflail,
			/obj/item/rogueweapon/huntingknife/idagger/steel/parrying,
			/obj/item/rogueweapon/sword/rapier,
			/obj/item/rogueweapon/sword/sabre,
			/obj/item/rogueweapon/huntingknife/idagger/steel,
			/obj/item/rogueweapon/katar/bronze,
			/obj/item/rogueweapon/whip/bronze,
			/obj/item/rogueweapon/eaglebeak/lucerne,
			/obj/item/rogueweapon/greataxe,
			/obj/item/rogueweapon/mace/steel/silver,
			/obj/item/rogueweapon/mace/woodclub,
			/obj/item/rogueweapon/stoneaxe/battle,
			/obj/item/rogueweapon/scabbard/sword/noble,
			/obj/item/rogueweapon/woodstaff/quarterstaff/iron,
	)
	if(prob(40))
		l_hand = pick(/obj/item/rogueweapon/greatsword/iron,
				/obj/item/rogueweapon/sword/short,
				/obj/item/rogueweapon/spear/billhook,
				/obj/item/rogueweapon/flail/peasantwarflail,
				/obj/item/rogueweapon/huntingknife/idagger/steel/parrying,
				/obj/item/rogueweapon/sword/rapier,
				/obj/item/rogueweapon/sword/sabre,
				/obj/item/rogueweapon/huntingknife/idagger/steel,
				/obj/item/rogueweapon/katar/bronze,
				/obj/item/rogueweapon/whip/bronze,
				/obj/item/rogueweapon/eaglebeak/lucerne,
				/obj/item/rogueweapon/greataxe,
				/obj/item/rogueweapon/mace/steel/silver,
				/obj/item/rogueweapon/mace/woodclub,
				/obj/item/rogueweapon/stoneaxe/battle,
				/obj/item/rogueweapon/scabbard/sword/noble,
				/obj/item/rogueweapon/woodstaff/quarterstaff/iron,
				/obj/item/rogueweapon/shield/iron,
				/obj/item/rogueweapon/shield/wood,
				/obj/item/rogueweapon/shield/tower/metal,
				/obj/item/rogueweapon/huntingknife,
				/obj/item/bouquet,
				/obj/item/cooking/pan,
		)
	if(prob(20))
		mask = pick(/obj/item/clothing/head/roguetown/roguehood/black,
			/obj/item/clothing/mask/rogue/duelmask,
			/obj/item/clothing/mask/rogue/facemask/steel,
			/obj/item/clothing/mask/rogue/eyepatch,
			/obj/item/clothing/mask/rogue/wildguard,
			/obj/item/clothing/head/roguetown/armingcap,
			/obj/item/clothing/mask/rogue/spectacles,
		)
	if(prob(35))
		head = pick(/obj/item/clothing/head/roguetown/witchhat,
			/obj/item/clothing/head/roguetown/archercap,
			/obj/item/clothing/head/roguetown/headband/monk,
			/obj/item/clothing/head/roguetown/bardhat,
			/obj/item/clothing/head/roguetown/roguehood/shalal/purple,
			/obj/item/clothing/head/roguetown/helmet/bronzegladiator,
			/obj/item/clothing/head/roguetown/mentorhat,
			/obj/item/clothing/head/roguetown/helmet/leather/volfhelm,
			/obj/item/clothing/head/roguetown/fedora,
			/obj/item/clothing/head/roguetown/helmet/tricorn,
			/obj/item/clothing/head/roguetown/roguehood/shalal/hijab,
			/obj/item/clothing/head/roguetown/helmet/sallet/visored,
			/obj/item/clothing/head/roguetown/helmet/heavy/bucket/iron,
			/obj/item/clothing/head/roguetown/helmet/heavy/bucket,
			/obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
			/obj/item/clothing/head/roguetown/helmet/kettle/iron,
		)
	if(prob(5))
		mouth = pick(/obj/item/rogueweapon/huntingknife,
			/obj/item/clothing/mask/cigarette/pipe/westman,
			/obj/item/alch/rosa,
			/obj/item/rogueweapon/stoneaxe/hurlbat,
			/obj/item/needle,
			/obj/item/clothing/mask/cigarette/rollie,
		)
