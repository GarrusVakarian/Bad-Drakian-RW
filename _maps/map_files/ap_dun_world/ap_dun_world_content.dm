// Map content adapted from Azure Peak at 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.

/obj/effect/landmark/start/ap_sexton
	name = "Sexton"
	jobspawn_override = list("Churchling", "Sexton")
	delete_after_roundstart = FALSE

/area/rogue/druidsgrove
	parent_type = /area/rogue/outdoors
	name = "Druids grove"
	icon_state = "rtfield"
	first_time_text = "Druids grove"
	droning_sound = list('sound/ambience/riverday (1).ogg','sound/ambience/riverday (2).ogg','sound/ambience/riverday (3).ogg')
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = list ('sound/ambience/rivernight (1).ogg','sound/ambience/rivernight (2).ogg','sound/ambience/rivernight (3).ogg' )

/area/rogue/indoors/eventarea/multiz
	name = "Event Area Multiz"
	deathsight_message = "a place shielded from mortal eyes"

/area/rogue/indoors/inq/chapel
	name = "The Psydonic Chapel"
	icon_state = "chapel"
	first_time_text = "THE PSYDONIC CHAPEL"

/area/rogue/indoors/inq/embassy
	name = "The Otavan Embassy"
	icon_state = "chapel"
	first_time_text = "THE OTAVAN EMBASSY"

/area/rogue/indoors/shelter/bog/bogmanfort
	name = "Bogman Fort"
	icon_state = "bog"
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a wretched, fetid bog"

/area/rogue/indoors/shelter/bog/skeletonfort
	name = "Skeleton Fort"
	icon_state = "bog"
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a wretched, fetid bog"

/area/rogue/indoors/shelter/mountains/decap/banditcamp
	name = "Bandit Camp"
	icon_state = "decap"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	first_time_text = "BANDIT CAMP"
	ceiling_protected = TRUE

/area/rogue/indoors/town/pestra_sanctum
	name = "Sanctum of Pestra"
	icon_state = "pestrasanctum"
	first_time_text = "THE SANCTUM OF PESTRA"
	droning_sound_dusk = null
	droning_sound_night = null
	keep_area = TRUE

/area/rogue/indoors/town/zhurch
	name = "Chapel of the Ecclesial"
	droning_sound_dusk = null
	droning_sound_night = null

/area/rogue/outdoors/beach/central
	name = "Central Coast"
	first_time_text = "CENTRAL COAST"
	threat_region = THREAT_REGION_AZUREAN_COAST

/area/rogue/outdoors/mountains/decap/banditcamp
	name = "Bandit Camp"
	icon_state = "decap"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	first_time_text = "BANDIT CAMP"
	ceiling_protected = TRUE
	threat_region = THREAT_REGION_MOUNT_DECAP

/area/rogue/outdoors/woods/wretch_lair
	warden_area = FALSE
	threat_region = ""

/area/rogue/under/cave/abyssor
	name = "abyssal grotto"
	icon_state = "caves"
	droning_sound = 'sound/music/area/peace.ogg'
	droning_sound_dusk = null
	droning_sound_night = null

/area/rogue/under/cave/abyssor/inner
	name = "inner abyssal grotto"
	first_time_text = "THE ABYSSAL GROTTO"

/area/rogue/under/cave/inhumen
	name = "forsaken cathedral"
	icon_state = "cave"
	first_time_text = "FORSAKEN CATHEDRAL"
	droning_sound = 'sound/music/unholy.ogg'
	droning_sound_dusk = 'sound/music/unholy.ogg'
	droning_sound_night = 'sound/music/unholy.ogg'

/area/rogue/under/cave/menageriedeep
	name = "Menagerie Deep"
	icon_state = "under"
	first_time_text = "BENEATH"
	droning_sound = 'sound/music/area/dungeon2.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ceiling_protected = TRUE
	deathsight_message = "a twisted collection of cages and cells"

/area/rogue/under/cave/menageriedungeon
	name = "Menagerie"
	icon_state = "under"
	first_time_text = "MENAGERIE"
	droning_sound = 'sound/music/area/dungeon.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ceiling_protected = TRUE
	deathsight_message = "a twisted collection of cages and cells"

/area/rogue/under/cave/minotaurcave
	name = "Minotaur Cave"
	icon_state = "under"
	first_time_text = "MINOTAUR CAVE"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a twisted tangle of soaring peaks"
	threat_region = THREAT_REGION_MOUNT_DECAP

/area/rogue/under/cave/taricheamanor
	name = "Manor of Tarichea"
	icon_state = "under"
	first_time_text = "MANOR OF TARICHEA"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a twisted tangle of soaring peaks"
	threat_region = THREAT_REGION_MOUNT_DECAP

/obj/item/roguekey/apothecary
	name = "clinic key"
	desc = "An elegant key which should permit access to secure areas in the city clinic. Its surface is \
	covered by a very thin patina of corrosion."
	icon_state = "ekey"
	lockid = "apothecary"

/obj/item/roguekey/church/roomi
	name = "church bedroom I key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_1"

/obj/item/roguekey/church/roomii
	name = "church bedroom II key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_2"

/obj/item/roguekey/church/roomiii
	name = "church bedroom III key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_3"

/obj/item/roguekey/church/roomiv
	name = "church bedroom IV key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_4"

/obj/item/roguekey/church/roomix
	name = "church bedroom IX key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_9"

/obj/item/roguekey/church/roomv
	name = "church bedroom V key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_5"

/obj/item/roguekey/church/roomvi
	name = "church bedroom VI key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_6"

/obj/item/roguekey/church/roomvii
	name = "church bedroom VII key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_7"

/obj/item/roguekey/church/roomviii
	name = "church bedroom VIII key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_8"

/obj/item/roguekey/church/roomx
	name = "church bedroom X key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_10"

/obj/item/roguekey/heir/one
	name = "heir room I key"
	lockid = "heir1"

/obj/item/roguekey/heir/two
	name = "heir room II key"
	lockid = "heir2"

/obj/item/roguekey/inhumen/four
	name = "cell key four"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen4"

/obj/item/roguekey/inhumen/one
	name = "cell key one"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen1"

/obj/item/roguekey/inhumen/three
	name = "cell key three"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen3"

/obj/item/roguekey/inhumen/two
	name = "cell key two"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen2"

/obj/item/roguekey/inquisitionmanor
	name = "inquisition manor key"
	desc = "This key opens the doors to the inquisition manor."
	icon_state = "brownkey"
	lockid = "inquisition"

/obj/item/roguekey/manor/councillor
	name = "councillor bedroom I key"
	lockid = "manor_councillor_one"

/obj/item/roguekey/manor/councillor/three
	name = "councillor bedroom III key"
	lockid = "manor_councillor_three"

/obj/item/roguekey/manor/councillor/two
	name = "councillor bedroom II key"
	lockid = "manor_councillor_two"

/obj/item/roguekey/manor/guest
	name = "guest bedroom I key"
	lockid = "guest_knight_one"

/obj/item/roguekey/manor/guest/four
	name = "guest bedroom IV key"
	lockid = "guest_knight_four"

/obj/item/roguekey/manor/guest/three
	name = "guest bedroom III key"
	lockid = "guest_knight_three"

/obj/item/roguekey/manor/guest/two
	name = "guest bedroom II key"
	lockid = "guest_knight_two"

/obj/item/storage/keyring/manor/guest/one
	name = "guest room I keyring"
	keys = list(/obj/item/roguekey/manor/guest, /obj/item/roguekey/manor/guest, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/manor/guest/two
	name = "guest room II keyring"
	keys = list(/obj/item/roguekey/manor/guest/two, /obj/item/roguekey/manor/guest/two, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/manor/guest/three
	name = "guest room III keyring"
	keys = list(/obj/item/roguekey/manor/guest/three, /obj/item/roguekey/manor/guest/three, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/manor/guest/four
	name = "guest room IV keyring"
	keys = list(/obj/item/roguekey/manor/guest/four, /obj/item/roguekey/manor/guest/four, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/roguekey/ap_seneschal
	name = "seneschal's key"
	desc = "A key to the Seneschal's quarters."
	icon_state = "brownkey"
	lockid = "seneschal"

/obj/item/roguekey/ap_veteran
	name = "veteran's key"
	desc = "A key to the Veteran's house."
	icon_state = "greenkey"
	lockid = "veteran"

/obj/item/roguekey/ap_absolver
	name = "Psydonic Chapel key"
	desc = "A key to the Psydonic Chapel and the Absolver's chambers."
	icon_state = "brownkey"
	lockid = "Absolvers"

/obj/item/roguekey/manor/knight
	name = "retinue bedroom I key"
	lockid = "manor_knight_one"

/obj/item/roguekey/manor/knight/four
	name = "retinue bedroom IV key"
	lockid = "manor_knight_four"

/obj/item/roguekey/manor/knight/three
	name = "retinue bedroom III key"
	lockid = "manor_knight_three"

/obj/item/roguekey/manor/knight/two
	name = "retinue bedroom II key"
	lockid = "manor_knight_two"

/obj/item/roguekey/manor/servant
	name = "servant bedroom I key"
	lockid = "servant_room_one"

/obj/item/roguekey/manor/servant/five
	name = "servant bedroom V key"
	lockid = "servant_room_five"

/obj/item/roguekey/manor/servant/four
	name = "servant bedroom IV key"
	lockid = "servant_room_four"

/obj/item/roguekey/manor/servant/six
	name = "servant bedroom VI key"
	lockid = "servant_room_six"

/obj/item/roguekey/manor/servant/three
	name = "servant bedroom III key"
	lockid = "servant_room_three"

/obj/item/roguekey/manor/servant/two
	name = "servant bedroom II key"
	lockid = "servant_room_two"

/obj/item/roguekey/manor/squire
	name = "squire bedroom I key"
	lockid = "squire_room_one"

/obj/item/roguekey/manor/squire/four
	name = "squire bedroom IV key"
	lockid = "squire_room_four"

/obj/item/roguekey/manor/squire/three
	name = "squire bedroom III key"
	lockid = "squire_room_three"

/obj/item/roguekey/manor/squire/two
	name = "squire bedroom II key"
	lockid = "squire_room_two"

/obj/item/roguekey/ortho_one
	name = "Otavan Embassy Bedroom I key"
	icon_state = "brownkey"
	lockid = "OEB1"

/obj/item/roguekey/ortho_three
	name = "Otavan Embassy Bedroom III key"
	icon_state = "brownkey"
	lockid = "OEB3"

/obj/item/roguekey/ortho_two
	name = "Otavan Embassy Bedroom II key"
	icon_state = "brownkey"
	lockid = "OEB2"

/obj/item/roguekey/townie_smith_extras
	name = "town smith key"
	desc = "The key to the basement and bedroom of the towner smiths house."
	icon_state = "brownkey"
	lockid = "townie_smith_extra"

/obj/item/roguekey/university
	name = "university key"
	desc = "This key should open all but the most secure areas of the University of Azuria."
	icon_state = "greenkey"
	lockid = "university"

/obj/item/roguekey/university_secure
	name = "university tower key"
	desc = "This key should open the tower in the University of Azuria, where dangerous magic is contained."
	icon_state = "brownkey"
	lockid = "university_secure"

/obj/item/roguekey/zhurch/onmap
	name = "brass key"
	desc = "A key made of brass."
	icon_state = "rustkey"
	lockid = "zhurch"

/obj/item/roguekey/zurch_bedroom
	name = "bedroom i key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_1"

/obj/item/roguekey/zurch_bedroom/admin
	name = "ancient key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "admin_event_door"

/obj/item/roguekey/zurch_bedroom/eight
	name = "bedroom viii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_8"

/obj/item/roguekey/zurch_bedroom/eleven
	name = "bedroom xi key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_11"

/obj/item/roguekey/zurch_bedroom/five
	name = "bedroom v key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_5"

/obj/item/roguekey/zurch_bedroom/four
	name = "bedroom iv key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_4"

/obj/item/roguekey/zurch_bedroom/nine
	name = "bedroom ix key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_9"

/obj/item/roguekey/zurch_bedroom/seven
	name = "bedroom vii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_7"

/obj/item/roguekey/zurch_bedroom/six
	name = "bedroom vi key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_6"

/obj/item/roguekey/zurch_bedroom/ten
	name = "bedroom x key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_10"

/obj/item/roguekey/zurch_bedroom/three
	name = "bedroom iii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_3"

/obj/item/roguekey/zurch_bedroom/twelve
	name = "bedroom xii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_12"

/obj/item/roguekey/zurch_bedroom/two
	name = "bedroom ii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_2"

/obj/structure/roguemachine/vendor/ap_dun_world/church_bedroomset_one
	keycontrol = "priest"
	key_stock = list(
		/obj/item/roguekey/church/roomi,
		/obj/item/roguekey/church/roomii,
		/obj/item/roguekey/church/roomiii,
		/obj/item/roguekey/church/roomiv,
		/obj/item/roguekey/church/roomv,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/church_bedroomset_two
	keycontrol = "priest"
	key_stock = list(
		/obj/item/roguekey/church/roomvi,
		/obj/item/roguekey/church/roomvii,
		/obj/item/roguekey/church/roomviii,
		/obj/item/roguekey/church/roomix,
		/obj/item/roguekey/church/roomx,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/inq_keys
	keycontrol = "puritan"
	key_stock = list(
		/obj/item/roguekey/ortho_one,
		/obj/item/roguekey/ortho_two,
		/obj/item/roguekey/ortho_three,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_councillors
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/manor/councillor,
		/obj/item/roguekey/manor/councillor/two,
		/obj/item/roguekey/manor/councillor/three,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_guests
	keycontrol = "lord"
	key_stock = list(
		/obj/item/storage/keyring/manor/guest/one,
		/obj/item/storage/keyring/manor/guest/two,
		/obj/item/storage/keyring/manor/guest/three,
		/obj/item/storage/keyring/manor/guest/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_knights
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/manor/knight,
		/obj/item/roguekey/manor/knight/two,
		/obj/item/roguekey/manor/knight/three,
		/obj/item/roguekey/manor/knight/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_princes
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/heir/one,
		/obj/item/roguekey/heir/two,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_servant
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/manor/servant,
		/obj/item/roguekey/manor/servant/two,
		/obj/item/roguekey/manor/servant/three,
		/obj/item/roguekey/manor/servant/four,
		/obj/item/roguekey/manor/servant/five,
		/obj/item/roguekey/manor/servant/six,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_squire
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/manor/squire,
		/obj/item/roguekey/manor/squire/two,
		/obj/item/roguekey/manor/squire/three,
		/obj/item/roguekey/manor/squire/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world
	will_hawk = FALSE
	var/list/key_stock

/obj/structure/roguemachine/vendor/ap_dun_world/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSroguemachine, src)
	for(var/key_type in key_stock)
		var/obj/item/stock_item = new key_type(src)
		held_items[stock_item] = list("NAME" = stock_item.name, "PRICE" = 0)
	update_icon()

/obj/structure/mineral_door/wood/donjon/highsecurity
	lockdifficulty = 1.8

/obj/structure/mineral_door/wood/donjon/stone/highsecurity
	lockdifficulty = 1.8

/obj/structure/mineral_door/wood/towner/generic/two_keys/noble/try_award_resident_key(mob/user)
	if(!ishuman(user) || !HAS_TRAIT(user, TRAIT_NOBLE))
		return FALSE
	return ..()

/obj/structure/mineral_door/wood/towner/generic/two_keys/wretch
	resident_role = null

/obj/structure/mineral_door/wood/towner/generic/two_keys/wretch/try_award_resident_key(mob/user)
	if(!ishuman(user) || !HAS_TRAIT(user, TRAIT_ZURCH))
		return FALSE
	return ..()

/obj/structure/mineral_door/wood/towner/generic/vagabond
	resident_role = /datum/job/roguetown/orphan
	resident_key_type = /obj/item/roguekey/ap_sewer

/obj/item/roguekey/ap_sewer
	name = "sewer key"
	desc = "An old, rusty key with the smell of the sewers."
	icon_state = "brownkey"

/obj/structure/mineral_door/wood/towner/potter
	resident_advclass = list(/datum/advclass/potter)
	lockid = "towner_potter"

/obj/structure/bars/passage/shutter/bookcase
	name = "empty bookcase"
	icon = '_maps/map_files/ap_dun_world/bookcase.dmi'
	icon_state = "decoybookcase0"

/obj/structure/bars/passage/shutter/bookcase/redstone_triggered(mob/user)
	if(obj_broken)
		return
	density = !density
	set_opacity(density)
	icon_state = density ? "decoybookcase0" : "decoybookcase1"

/obj/structure/bars/passage/shutter/bookcase/obj_break(damage_flag)
	. = ..()
	set_opacity(FALSE)
	icon_state = "decoybookcase1"

/obj/structure/lever/bookcase
	name = "bookcase"
	desc = "Refuge for few, an irrelevance to most."
	icon = '_maps/map_files/ap_dun_world/bookcase.dmi'
	icon_state = "booklever0"

/obj/structure/lever/bookcase/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/examiner = user
	if(HAS_TRAIT(examiner, TRAIT_INQUISITION))
		. += span_notice("I recognize the signs of a concealed mechanism.")
	else if(examiner.STAPER >= 15)
		. += span_notice("There may be more to this shelf than meets the eye.")

/obj/structure/lever/bookcase/attack_hand(mob/user)
	if(!isliving(user))
		return FALSE
	var/mob/living/operator = user
	if(!HAS_TRAIT(operator, TRAIT_INQUISITION) && operator.STAPER < 15)
		return FALSE
	. = ..()
	icon_state = "booklever[toggled]"

/obj/structure/lever/bookcase/onkick(mob/user)
	return FALSE

/obj/structure/decorativeladder
	name = "ladder"
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladder11"
	anchored = TRUE

/obj/structure/mannequin/male/decorative/training_dummy_style
	name = "training dummy"

/mob/living/simple_animal/hostile/retaliate/rogue/voiddragon/no_loot
	loot = list(/obj/item/roguecoin/gold)

/obj/item/reagent_containers/glass/bottle/clayvaseclassic/holy_water
	parent_type = /obj/item/reagent_containers/glass/bottle/claybottle
	name = "vase of holy water"
	list_reagents = list(/datum/reagent/water/holywater = 65)

/obj/item/rogueweapon/huntingknife/idagger/steel/trainer
	name = "dagger trainer"
	sharpness = IS_BLUNT
	force = 7
	possible_item_intents = list(/datum/intent/mace/strike)

/obj/item/rogueweapon/spear/trainer
	name = "sparring spear"
	sharpness = IS_BLUNT
	force = 7
	force_wielded = 15
	possible_item_intents = list(/datum/intent/mace/strike)
	gripped_intents = list(/datum/intent/mace/strike)

/turf/open/floor/rogue/crawl_space
	name = "crawlspace"
	desc = "Too small to pass without crawling."
	icon_state = "dirt"
	neighborlay = "dirtedge"

/turf/open/floor/rogue/crawl_space/CanPass(atom/movable/mover, turf/target)
	if(!..())
		return FALSE
	if(iscarbon(mover))
		var/mob/living/carbon/crawler = mover
		if(crawler.mobility_flags & MOBILITY_STAND)
			return FALSE
	return TRUE

/turf/open/floor/rogue/hotspring
	name = "hot spring"
	desc = "Wisps of vapour rise delicately from this warm, mineral-rich water."
	icon = '_maps/map_files/ap_dun_world/hotspring.dmi'
	icon_state = "hotspring"
	slowdown = 5
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	landsound = 'sound/foley/jumpland/waterland.wav'

/turf/open/floor/rogue/underworld/space/dense
	density = TRUE

/turf/open/floor/rogue/underworld/space/quiet/dense
	density = TRUE

/turf/open/floor/rogue/underworld/space/sparkle_quiet/dense
	density = TRUE

/turf/open/water/ocean/abyssal
	parent_type = /turf/open/water/ocean/deep
	name = "darkwater"
	water_color = "#000211"

/turf/open/water/river/flow/murk
	name = "murk river"
	water_color = "#705a43"
	water_reagent = /datum/reagent/water/gross

/turf/open/water/river/flow/murk/east
	dir = EAST



/obj/effect/landmark/start/ap_trader
	name = "Trader"
	icon_state = "arrow"

/obj/effect/landmark/start/ap_lamplighter
	name = "Lamplighter"
	jobspawn_override = list("Lamplighter")
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/ap_hag
	name = "Hag"

/obj/effect/landmark/start/ap_haglate
	name = "Hag"
	jobspawn_override = list("Hag")
	delete_after_roundstart = FALSE
