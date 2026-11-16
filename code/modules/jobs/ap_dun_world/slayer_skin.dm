// Adapted from Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/obj/item/clothing/suit/roguetown/armor/manual
	name = "manually regenerating skin"
	break_sound = 'sound/foley/cloth_rip.ogg'
	drop_sound = 'sound/foley/dropsound/cloth_drop.ogg'
	icon_state = null
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR

	resistance_flags = FIRE_PROOF
	body_parts_covered = COVERAGE_FULL //everything but head and it's subzones (neck, skull, ears, eyes, nose, mouth)
	body_parts_inherent = COVERAGE_FULL
	flags_inv = null //Exposes the chest and-or breasts.
	surgery_cover = FALSE //Should permit surgery and other invasive processes.
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL
	armor_class = ARMOR_CLASS_LIGHT
	blocksound = SOFTUNDERHIT //chest underlayers must use a different hit sound, or they cannot be applied.
	armor = ARMOR_PADDED
	max_integrity = ARMOR_INT_CHEST_CIVILIAN
	blocking_behavior = 0 //skin roles either start with a secondary skin layer or are intended to layer with armor.

	var/repairmsg_end = "My skin has become taut with newfound vigor!"
	var/repairmsg_continue = "My armour mends some of its abuse.."
	/// Shown when a repair is attempted while the skin is already at full integrity.
	var/repairmsg_full = "My skin isn't wounded."
	/// Fraction of max_integrity restored per repair cycle. Overridden per repair method (resting/sewing/prayer/etc.).
	var/repair_fraction = 0.35
	/// Flat integrity restored per cycle. Defaults to repair_fraction * max_integrity at Initialize; set directly for a flat per-armour override.
	var/repair_percent

/obj/item/clothing/suit/roguetown/armor/manual/Initialize(mapload)
	..()
	if(isnull(repair_percent))
		repair_percent = repair_fraction * max_integrity
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/suit/roguetown/armor/manual/dropped(mob/living/carbon/human/user)
	..()
	if(QDELETED(src))
		return
	qdel(src)

/obj/item/clothing/suit/roguetown/armor/manual/proc/armour_regen(repair_amount = repair_percent)
	if(obj_integrity >= max_integrity)
		to_chat(loc, span_notice(repairmsg_end))
	to_chat(loc, span_notice(repairmsg_continue))
	obj_integrity = min(obj_integrity + repair_amount, max_integrity)
	if(obj_broken)
		obj_fix(full_repair = FALSE)

/// TRUE while this skin is actually worn on its owner's body (armour or shirt slot), not merely held.

/obj/item/clothing/suit/roguetown/armor/manual/proc/worn_on_body(mob/living/carbon/human/user)
	return user?.wear_armor == src || user?.wear_shirt == src




//TIME
//Repair time is roughly based on apprentice armor repair, with a slight penalty. Ballpark 20-30s for a single layer, 35-40s for two.
//Pushup skin repairs in 2 sets (20-22s), but only one layer, the other needs resting. If both were on pushup repair, 3 sets (~30s) because stamina management etc is already a drawback.
//Sewable skin repairs in ~21s, but only one layer at a time, so ~42s total. Slow, but anywhere and can focus-repair a specific layer on demand.
//Resting skin repairs in 20s, both layers simultaniously, making it the fastest to mend, but also most restrictive on mending conditions.
//Meditation skin repairs in 40s, both layers simultaniously. Tattoo armors drop this to 30s (one meditation cycle) because they suffer honorbound restrictions.

//STATS
//The default skin armor is equivalent to a full-body gambeson + chest-only leather armor. This makes it decent, but outclassed by real light armor that upgrades to heavy gambeson/arming jacket and leather coat/light brigadine.
//Skin armor should be easier to use and more convenient than using actual armor, usually by having better coverage at roundstart, but never be able to reach the heights that a proper/high end light armor setup can, for most roles. Essentially, they are not optimal, but are comfortable.
//Roles that have on-spawn access to high quality armor / faction wealth can have their gambeson layer be a heavy gambeson without issue (disciple).
//Theoretically, skin armors with medium/heavy typing could have a similar relationship to generic armor of those tiers.

//UNIQUE CASES
//If a role has a gimmick (rage, miracles, magic etc), or is on a limited power budget (advent, noncombatant) the above should always apply.
//However, if the role's  gimmick is its skin armor (most notably ruma, partially mistwalker), then it can step away from that baseline to a degree. Note that Honorbound or equivalent is advised to manage layering potential on full-body skins with advanced protection types (plate, maille etc), or head coverage (skin + helm + coif + arming cap all on the same zone is pain, and also makes chest the boring easy target again).

/obj/item/clothing/suit/roguetown/armor/manual/pushups
	name = "muscular skin"
	desc = "The reward for all your hard work. </br>THE INFLUENCE OF THE HAM SANDWYCH RACE IS WANING. I MUST DO PUSH-UPS, TO REMIND MY MUSCLES OF THEIR OWN STRENGTH."
	repair_fraction = 0.50 //50% per 10-pushup set, stronger per chunk due to stamina management and the fact that secondary skin layers are going to rely on resting instead, extending total repair time.

	repairmsg_end = "My muscles sheen with vitality!"
	repairmsg_continue = "My muscles are reminded of their own strength."

/obj/item/clothing/suit/roguetown/armor/manual/pushups/get_mechanics_examine(mob/user)
	. = ..()

	. += span_info("Repairable via push-up emotes.")
