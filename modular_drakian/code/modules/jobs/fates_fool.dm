// Adapted from Ochre Valley #341 by SatinIsle. Uses BD's existing skills, gear and magic.
/datum/advclass/fates_fool
	name = "Fate's Fool"
	tutorial = "You are someone, from somewhere, with some skills, probably some equipment and some experiences. The ultimate true random experience, start with completely random skills, stats and equipment."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/adventurer/fates_fool
	cmode_music = 'sound/music/cmode/adventurer/combat_outlander2.ogg'
	class_select_category = CLASS_CAT_ROGUE
	category_tags = list(CTAG_ADVENTURER)
	townie_contract_gate_exempt = TRUE
	townie_contract_gate_hide_in_list = TRUE

/datum/outfit/job/roguetown/adventurer/fates_fool
	// Keep all rollable combat skills here, including skills that don't use a weapon.
	var/static/list/combat_weapons = list(
		/datum/skill/combat/knives = list(/obj/item/rogueweapon/huntingknife, /obj/item/rogueweapon/huntingknife/idagger/steel),
		/datum/skill/combat/swords = list(/obj/item/rogueweapon/sword/short/iron, /obj/item/rogueweapon/sword/sabre),
		/datum/skill/combat/polearms = list(/obj/item/rogueweapon/spear/billhook, /obj/item/rogueweapon/eaglebeak/lucerne),
		/datum/skill/combat/maces = list(/obj/item/rogueweapon/mace/cudgel, /obj/item/rogueweapon/mace/warhammer),
		/datum/skill/combat/axes = list(/obj/item/rogueweapon/stoneaxe/battle, /obj/item/rogueweapon/greataxe),
		/datum/skill/combat/whipsflails = list(/obj/item/rogueweapon/whip, /obj/item/rogueweapon/flail),
		/datum/skill/combat/bows = list(/obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve),
		/datum/skill/combat/crossbows = list(/obj/item/gun/ballistic/revolver/grenadelauncher/crossbow),
		/datum/skill/combat/firearms = list(/obj/item/gun/ballistic/firearm/handgonne),
		/datum/skill/combat/wrestling = null,
		/datum/skill/combat/unarmed = list(/obj/item/rogueweapon/knuckles, /obj/item/rogueweapon/katar/bronze),
		/datum/skill/combat/shields = list(/obj/item/rogueweapon/shield/iron, /obj/item/rogueweapon/shield/wood),
		/datum/skill/combat/slings = list(/obj/item/gun/ballistic/revolver/grenadelauncher/sling),
	)

/datum/outfit/job/roguetown/adventurer/fates_fool/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(QDELETED(H))
		return
	if(!visualsOnly)
		roll_character(H)
	roll_equipment(H)
	if(visualsOnly)
		return
	roll_weapon(H)
	to_chat(H, span_warning("Xylix laughs either at or with you, strange person with such unusual skills and tools."))
	if(H.client)
		to_chat(H, span_warningbig("Do not leave and respawn as this class to get better rolls, live with what you are given. Admins will be informed if you try."))
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

	for(var/skill in combat_weapons)
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

/datum/outfit/job/roguetown/adventurer/fates_fool/proc/roll_equipment(mob/living/carbon/human/H)
	// Reset conditional slots when an outfit datum is reused for another preview or character.
	for(var/slot in list("shirt", "armor", "pants", "belt", "beltl", "beltr", "cloak", "shoes", "wrists", "gloves", "neck", "backl", "backr", "r_hand", "l_hand", "mask", "head", "mouth"))
		vars[slot] = null

	if(prob(80))
		shirt = pick_wearable(H, list(/obj/item/clothing/suit/roguetown/armor/gambeson,
				/obj/item/clothing/suit/roguetown/shirt/tunic/random,
				/obj/item/clothing/suit/roguetown/shirt/undershirt/black,
				/obj/item/clothing/suit/roguetown/armor/chainmail,
				/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/iron,
				/obj/item/clothing/suit/roguetown/armor/gambeson/light,
				/obj/item/clothing/suit/roguetown/armor/chainmail/iron,
				/obj/item/clothing/suit/roguetown/shirt/undershirt,
				/obj/item/clothing/suit/roguetown/shirt/undershirt/eastshirt1,
				/obj/item/clothing/suit/roguetown/armor/corset,
		))
	if(prob(60))
		armor = pick_wearable(H, list(/obj/item/clothing/suit/roguetown/armor/plate/half/iron,
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
		))
	if(prob(80))
		pants = pick_wearable(H, list(/obj/item/clothing/under/roguetown/tights/black,
				/obj/item/clothing/under/roguetown/chainlegs/iron,
				/obj/item/clothing/under/roguetown/chainlegs/iron/kilt,
				/obj/item/clothing/under/roguetown/splintlegs,
				/obj/item/clothing/under/roguetown/trou/leather,
				/obj/item/clothing/under/roguetown/chainlegs/kilt,
				/obj/item/clothing/under/roguetown/loincloth,
				/obj/item/clothing/under/roguetown/heavy_leather_pants,
				/obj/item/clothing/under/roguetown/skirt/red,
		))
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
	if(prob(40))
		cloak = pick_wearable(H, list(/obj/item/clothing/cloak/raincloak/furcloak,
				/obj/item/clothing/cloak/half,
				/obj/item/clothing/cloak/apron,
				/obj/item/clothing/cloak/poncho,
				/obj/item/clothing/cloak/tabard,
				/obj/item/clothing/cloak/cape,
		))
	if(prob(90))
		shoes = pick_wearable(H, list(/obj/item/clothing/shoes/roguetown/boots,
				/obj/item/clothing/shoes/roguetown/boots/leather/reinforced,
				/obj/item/clothing/shoes/roguetown/boots/furlinedboots,
				/obj/item/clothing/shoes/roguetown/boots/armor/iron,
				/obj/item/clothing/shoes/roguetown/boots/armor,
				/obj/item/clothing/shoes/roguetown/sandals,
		))
	if(prob(50))
		wrists = pick_wearable(H, list(/obj/item/clothing/wrists/roguetown/bracers/iron,
				/obj/item/clothing/wrists/roguetown/splintarms/iron,
				/obj/item/clothing/wrists/roguetown/bracers/leather,
				/obj/item/clothing/neck/roguetown/psicross/silver,
				/obj/item/clothing/neck/roguetown/psicross/naledi,
				/obj/item/clothing/wrists/roguetown/bracers/cloth/monk,
		))
	if(prob(50))
		gloves = pick_wearable(H, list(/obj/item/clothing/gloves/roguetown/angle,
				/obj/item/clothing/gloves/roguetown/chain/iron,
				/obj/item/clothing/gloves/roguetown/fingerless_leather,
				/obj/item/clothing/gloves/roguetown/leather,
				/obj/item/clothing/gloves/roguetown/bandages,
				/obj/item/clothing/gloves/roguetown/bandages/weighted,
		))
	if(prob(40))
		neck = pick_wearable(H, list(/obj/item/clothing/neck/roguetown/gorget,
				/obj/item/clothing/neck/roguetown/chaincoif/iron,
				/obj/item/clothing/neck/roguetown/coif/heavypadding,
				/obj/item/clothing/neck/roguetown/coif/padded,
				/obj/item/clothing/neck/roguetown/bevor/iron,
				/obj/item/clothing/neck/roguetown/psicross/silver,
				/obj/item/storage/belt/rogue/pouch/coins/poor,
		))
	backl = /obj/item/storage/backpack/rogue/satchel
	var/backpack_items = list(
		/obj/item/recipe_book/magic,
		/obj/item/flashlight/flare/torch/metal,
		/obj/item/storage/belt/rogue/pouch/coins/poor,
		/obj/item/rogueweapon/scabbard/sheath,
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
		backr = pick(/obj/item/rogueweapon/scabbard/gwstrap,
				/obj/item/rogue/instrument/lute,
				/obj/item/flashlight/flare/torch/metal,
				/obj/item/storage/backpack/rogue/satchel,
		)
	if(prob(20))
		mask = pick_wearable(H, list(/obj/item/clothing/head/roguetown/roguehood/black,
			/obj/item/clothing/mask/rogue/duelmask,
			/obj/item/clothing/mask/rogue/facemask/steel,
			/obj/item/clothing/mask/rogue/eyepatch,
			/obj/item/clothing/mask/rogue/wildguard,
			/obj/item/clothing/head/roguetown/armingcap,
			/obj/item/clothing/mask/rogue/spectacles,
		))
	if(prob(35))
		head = pick_wearable(H, list(/obj/item/clothing/head/roguetown/witchhat,
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
		))
	if(prob(5))
		mouth = pick_wearable(H, list(/obj/item/clothing/mask/cigarette/pipe/westman,
			/obj/item/alch/rosa,
			/obj/item/clothing/mask/cigarette/rollie,
		))

/datum/outfit/job/roguetown/adventurer/fates_fool/proc/pick_wearable(mob/living/carbon/human/H, list/options)
	var/can_wear_medium = HAS_TRAIT(H, TRAIT_MEDIUMARMOR)
	var/can_wear_heavy = HAS_TRAIT(H, TRAIT_HEAVYARMOR)
	for(var/i in length(options) to 1 step -1)
		var/obj/item/clothing/option = options[i]
		if(!ispath(option, /obj/item/clothing))
			continue
		var/armor_class = initial(option.armor_class)
		if((armor_class == ARMOR_CLASS_MEDIUM && !can_wear_medium) || (armor_class == ARMOR_CLASS_HEAVY && !can_wear_heavy))
			options.Cut(i, i + 1)
	return length(options) ? pick(options) : null

/datum/outfit/job/roguetown/adventurer/fates_fool/proc/roll_weapon(mob/living/carbon/human/H)
	var/best_rank = 0
	var/list/best_weapon_skills = list()
	for(var/skill in combat_weapons)
		var/rank = H.get_skill_level(skill)
		if(!rank || rank < best_rank)
			continue
		if(rank > best_rank)
			best_rank = rank
			best_weapon_skills.Cut()
		if(combat_weapons[skill])
			best_weapon_skills += skill

	if(!length(best_weapon_skills))
		return
	var/skill = pick(best_weapon_skills)
	var/list/weapons = combat_weapons[skill]
	r_hand = pick(weapons)
	switch(skill)
		if(/datum/skill/combat/bows)
			beltr = /obj/item/quiver/arrows
		if(/datum/skill/combat/crossbows)
			beltr = /obj/item/quiver/bolts
		if(/datum/skill/combat/slings)
			beltr = /obj/item/quiver/sling/iron
		if(/datum/skill/combat/firearms)
			beltr = /obj/item/quiver/bullet/lead
			backpack_contents[/obj/item/powderflask] = 1
