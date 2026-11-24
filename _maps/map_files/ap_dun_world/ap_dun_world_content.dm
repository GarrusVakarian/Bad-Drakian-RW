// Map-only compatibility for Azure Peak 7ad83097faa4d90dc116294fa4bfbc4561e88d3c.
// Custom definitions are scoped to AP placements; native types remain unchanged.

/obj/effect/landmark/start/ap_dun_world/ap_sexton
	parent_type = /obj/effect/landmark/start
	name = "Churchling"
	jobspawn_override = list("Churchling")
	delete_after_roundstart = FALSE

/area/rogue/ap_dun_world/druidsgrove
	parent_type = /area/rogue/outdoors
	name = "Druids grove"
	icon_state = "rtfield"
	first_time_text = "Druids grove"
	droning_sound = list('sound/ambience/riverday (1).ogg','sound/ambience/riverday (2).ogg','sound/ambience/riverday (3).ogg')
	droning_sound_dusk = 'sound/music/area/septimus.ogg'
	droning_sound_night = list ('sound/ambience/rivernight (1).ogg','sound/ambience/rivernight (2).ogg','sound/ambience/rivernight (3).ogg' )

/area/rogue/ap_dun_world/indoors/eventarea/multiz
	parent_type = /area/rogue/indoors/eventarea
	name = "Event Area Multiz"
	deathsight_message = "a place shielded from mortal eyes"

/area/rogue/ap_dun_world/indoors/inq/chapel
	parent_type = /area/rogue/indoors/inq
	name = "The Psydonic Chapel"
	icon_state = "chapel"
	first_time_text = "THE PSYDONIC CHAPEL"

/area/rogue/ap_dun_world/indoors/inq/embassy
	parent_type = /area/rogue/indoors/inq
	name = "The Otavan Embassy"
	icon_state = "chapel"
	first_time_text = "THE OTAVAN EMBASSY"

/area/rogue/ap_dun_world/indoors/shelter/bog/bogmanfort
	parent_type = /area/rogue/indoors/shelter/bog
	name = "Bogman Fort"
	icon_state = "bog"
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a wretched, fetid bog"

/area/rogue/ap_dun_world/indoors/shelter/bog/skeletonfort
	parent_type = /area/rogue/indoors/shelter/bog
	name = "Skeleton Fort"
	icon_state = "bog"
	droning_sound = 'sound/music/area/bog.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a wretched, fetid bog"

/area/rogue/ap_dun_world/indoors/shelter/mountains/decap/banditcamp
	parent_type = /area/rogue/indoors/shelter/mountains/decap
	name = "Bandit Camp"
	icon_state = "decap"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	first_time_text = "BANDIT CAMP"
	ceiling_protected = TRUE

/area/rogue/ap_dun_world/indoors/town/pestra_sanctum
	parent_type = /area/rogue/indoors/town
	name = "Sanctum of Pestra"
	icon_state = "pestrasanctum"
	first_time_text = "THE SANCTUM OF PESTRA"
	droning_sound_dusk = null
	droning_sound_night = null
	keep_area = TRUE

/area/rogue/ap_dun_world/indoors/town/zhurch
	parent_type = /area/rogue/indoors/town
	name = "Chapel of the Ecclesial"
	droning_sound_dusk = null
	droning_sound_night = null

/area/rogue/ap_dun_world/outdoors/beach/central
	parent_type = /area/rogue/outdoors/beach
	name = "Central Coast"
	first_time_text = "CENTRAL COAST"
	threat_region = THREAT_REGION_AZUREAN_COAST

/area/rogue/ap_dun_world/outdoors/mountains/decap/banditcamp
	parent_type = /area/rogue/outdoors/mountains/decap
	name = "Bandit Camp"
	icon_state = "decap"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	first_time_text = "BANDIT CAMP"
	ceiling_protected = TRUE
	threat_region = THREAT_REGION_MOUNT_DECAP

/area/rogue/ap_dun_world/outdoors/woods/wretch_lair
	parent_type = /area/rogue/outdoors/woods
	warden_area = FALSE
	threat_region = ""

/area/rogue/ap_dun_world/under/cave/abyssor
	parent_type = /area/rogue/under/cave
	name = "abyssal grotto"
	icon_state = "caves"
	droning_sound = 'sound/music/area/peace.ogg'
	droning_sound_dusk = null
	droning_sound_night = null

/area/rogue/ap_dun_world/under/cave/abyssor/inner
	parent_type = /area/rogue/ap_dun_world/under/cave/abyssor
	name = "inner abyssal grotto"
	first_time_text = "THE ABYSSAL GROTTO"

/area/rogue/ap_dun_world/under/cave/inhumen
	parent_type = /area/rogue/under/cave
	name = "forsaken cathedral"
	icon_state = "cave"
	first_time_text = "FORSAKEN CATHEDRAL"
	droning_sound = 'sound/music/unholy.ogg'
	droning_sound_dusk = 'sound/music/unholy.ogg'
	droning_sound_night = 'sound/music/unholy.ogg'

/area/rogue/ap_dun_world/under/cave/menageriedeep
	parent_type = /area/rogue/under/cave
	name = "Menagerie Deep"
	icon_state = "under"
	first_time_text = "BENEATH"
	droning_sound = 'sound/music/area/dungeon2.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ceiling_protected = TRUE
	deathsight_message = "a twisted collection of cages and cells"

/area/rogue/ap_dun_world/under/cave/menageriedungeon
	parent_type = /area/rogue/under/cave
	name = "Menagerie"
	icon_state = "under"
	first_time_text = "MENAGERIE"
	droning_sound = 'sound/music/area/dungeon.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	ceiling_protected = TRUE
	deathsight_message = "a twisted collection of cages and cells"

/area/rogue/ap_dun_world/under/cave/minotaurcave
	parent_type = /area/rogue/under/cave
	name = "Minotaur Cave"
	icon_state = "under"
	first_time_text = "MINOTAUR CAVE"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a twisted tangle of soaring peaks"
	threat_region = THREAT_REGION_MOUNT_DECAP

/area/rogue/ap_dun_world/under/cave/taricheamanor
	parent_type = /area/rogue/under/cave
	name = "Manor of Tarichea"
	icon_state = "under"
	first_time_text = "MANOR OF TARICHEA"
	droning_sound = 'sound/music/area/decap.ogg'
	droning_sound_dusk = null
	droning_sound_night = null
	deathsight_message = "a twisted tangle of soaring peaks"
	threat_region = THREAT_REGION_MOUNT_DECAP

/obj/item/roguekey/ap_dun_world/apothecary
	parent_type = /obj/item/roguekey
	name = "clinic key"
	desc = "An elegant key which should permit access to secure areas in the city clinic. Its surface is \
	covered by a very thin patina of corrosion."
	icon_state = "ekey"
	lockid = "apothecary"

/obj/item/roguekey/ap_dun_world/church/roomi
	parent_type = /obj/item/roguekey/church
	name = "church bedroom I key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_1"

/obj/item/roguekey/ap_dun_world/church/roomii
	parent_type = /obj/item/roguekey/church
	name = "church bedroom II key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_2"

/obj/item/roguekey/ap_dun_world/church/roomiii
	parent_type = /obj/item/roguekey/church
	name = "church bedroom III key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_3"

/obj/item/roguekey/ap_dun_world/church/roomiv
	parent_type = /obj/item/roguekey/church
	name = "church bedroom IV key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_4"

/obj/item/roguekey/ap_dun_world/church/roomix
	parent_type = /obj/item/roguekey/church
	name = "church bedroom IX key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_9"

/obj/item/roguekey/ap_dun_world/church/roomv
	parent_type = /obj/item/roguekey/church
	name = "church bedroom V key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_5"

/obj/item/roguekey/ap_dun_world/church/roomvi
	parent_type = /obj/item/roguekey/church
	name = "church bedroom VI key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_6"

/obj/item/roguekey/ap_dun_world/church/roomvii
	parent_type = /obj/item/roguekey/church
	name = "church bedroom VII key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_7"

/obj/item/roguekey/ap_dun_world/church/roomviii
	parent_type = /obj/item/roguekey/church
	name = "church bedroom VIII key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_8"

/obj/item/roguekey/ap_dun_world/church/roomx
	parent_type = /obj/item/roguekey/church
	name = "church bedroom X key"
	icon_state = "brownkey"
	lockid = "church_bedroom_up_10"

/obj/item/roguekey/ap_dun_world/heir/one
	parent_type = /obj/item/roguekey/heir
	name = "heir room I key"
	lockid = "heir1"

/obj/item/roguekey/ap_dun_world/heir/two
	parent_type = /obj/item/roguekey/heir
	name = "heir room II key"
	lockid = "heir2"

/obj/item/roguekey/ap_dun_world/inhumen/four
	parent_type = /obj/item/roguekey/inhumen
	name = "cell key four"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen4"

/obj/item/roguekey/ap_dun_world/inhumen/one
	parent_type = /obj/item/roguekey/inhumen
	name = "cell key one"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen1"

/obj/item/roguekey/ap_dun_world/inhumen/three
	parent_type = /obj/item/roguekey/inhumen
	name = "cell key three"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen3"

/obj/item/roguekey/ap_dun_world/inhumen/two
	parent_type = /obj/item/roguekey/inhumen
	name = "cell key two"
	desc = "A ancient, rusty key. Seems like it goes to some kind of cell."
	icon_state = "rustkey"
	lockid = "inhumen2"

/obj/item/roguekey/ap_dun_world/inquisitionmanor
	parent_type = /obj/item/roguekey
	name = "inquisition manor key"
	desc = "This key opens the doors to the inquisition manor."
	icon_state = "brownkey"
	lockid = "inquisition"

/obj/item/roguekey/ap_dun_world/manor/councillor
	parent_type = /obj/item/roguekey/manor
	name = "councillor bedroom I key"
	lockid = "manor_councillor_one"

/obj/item/roguekey/ap_dun_world/manor/councillor/three
	parent_type = /obj/item/roguekey/ap_dun_world/manor/councillor
	name = "councillor bedroom III key"
	lockid = "manor_councillor_three"

/obj/item/roguekey/ap_dun_world/manor/councillor/two
	parent_type = /obj/item/roguekey/ap_dun_world/manor/councillor
	name = "councillor bedroom II key"
	lockid = "manor_councillor_two"

/obj/item/roguekey/ap_dun_world/manor/guest
	parent_type = /obj/item/roguekey/manor
	name = "guest bedroom I key"
	lockid = "guest_knight_one"

/obj/item/roguekey/ap_dun_world/manor/guest/four
	parent_type = /obj/item/roguekey/ap_dun_world/manor/guest
	name = "guest bedroom IV key"
	lockid = "guest_knight_four"

/obj/item/roguekey/ap_dun_world/manor/guest/three
	parent_type = /obj/item/roguekey/ap_dun_world/manor/guest
	name = "guest bedroom III key"
	lockid = "guest_knight_three"

/obj/item/roguekey/ap_dun_world/manor/guest/two
	parent_type = /obj/item/roguekey/ap_dun_world/manor/guest
	name = "guest bedroom II key"
	lockid = "guest_knight_two"

/obj/item/storage/keyring/ap_dun_world/manor/guest/one
	parent_type = /obj/item/storage/keyring/manor
	name = "guest room I keyring"
	keys = list(/obj/item/roguekey/ap_dun_world/manor/guest, /obj/item/roguekey/ap_dun_world/manor/guest, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/ap_dun_world/manor/guest/two
	parent_type = /obj/item/storage/keyring/manor
	name = "guest room II keyring"
	keys = list(/obj/item/roguekey/ap_dun_world/manor/guest/two, /obj/item/roguekey/ap_dun_world/manor/guest/two, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/ap_dun_world/manor/guest/three
	parent_type = /obj/item/storage/keyring/manor
	name = "guest room III keyring"
	keys = list(/obj/item/roguekey/ap_dun_world/manor/guest/three, /obj/item/roguekey/ap_dun_world/manor/guest/three, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/storage/keyring/ap_dun_world/manor/guest/four
	parent_type = /obj/item/storage/keyring/manor
	name = "guest room IV keyring"
	keys = list(/obj/item/roguekey/ap_dun_world/manor/guest/four, /obj/item/roguekey/ap_dun_world/manor/guest/four, /obj/item/roguekey/manor, /obj/item/roguekey/manor)

/obj/item/roguekey/ap_dun_world/ap_seneschal
	parent_type = /obj/item/roguekey
	name = "seneschal's key"
	desc = "A key to the Seneschal's quarters."
	icon_state = "brownkey"
	lockid = "seneschal"

/obj/item/roguekey/ap_dun_world/ap_veteran
	parent_type = /obj/item/roguekey
	name = "veteran's key"
	desc = "A key to the Veteran's house."
	icon_state = "greenkey"
	lockid = "veteran"

/obj/item/roguekey/ap_dun_world/ap_absolver
	parent_type = /obj/item/roguekey
	name = "Psydonic Chapel key"
	desc = "A key to the Psydonic Chapel and the Absolver's chambers."
	icon_state = "brownkey"
	lockid = "Absolvers"

/obj/item/roguekey/ap_dun_world/manor/knight
	parent_type = /obj/item/roguekey/manor
	name = "retinue bedroom I key"
	lockid = "manor_knight_one"

/obj/item/roguekey/ap_dun_world/manor/knight/four
	parent_type = /obj/item/roguekey/ap_dun_world/manor/knight
	name = "retinue bedroom IV key"
	lockid = "manor_knight_four"

/obj/item/roguekey/ap_dun_world/manor/knight/three
	parent_type = /obj/item/roguekey/ap_dun_world/manor/knight
	name = "retinue bedroom III key"
	lockid = "manor_knight_three"

/obj/item/roguekey/ap_dun_world/manor/knight/two
	parent_type = /obj/item/roguekey/ap_dun_world/manor/knight
	name = "retinue bedroom II key"
	lockid = "manor_knight_two"

/obj/item/roguekey/ap_dun_world/manor/servant
	parent_type = /obj/item/roguekey/manor
	name = "servant bedroom I key"
	lockid = "servant_room_one"

/obj/item/roguekey/ap_dun_world/manor/servant/five
	parent_type = /obj/item/roguekey/ap_dun_world/manor/servant
	name = "servant bedroom V key"
	lockid = "servant_room_five"

/obj/item/roguekey/ap_dun_world/manor/servant/four
	parent_type = /obj/item/roguekey/ap_dun_world/manor/servant
	name = "servant bedroom IV key"
	lockid = "servant_room_four"

/obj/item/roguekey/ap_dun_world/manor/servant/six
	parent_type = /obj/item/roguekey/ap_dun_world/manor/servant
	name = "servant bedroom VI key"
	lockid = "servant_room_six"

/obj/item/roguekey/ap_dun_world/manor/servant/three
	parent_type = /obj/item/roguekey/ap_dun_world/manor/servant
	name = "servant bedroom III key"
	lockid = "servant_room_three"

/obj/item/roguekey/ap_dun_world/manor/servant/two
	parent_type = /obj/item/roguekey/ap_dun_world/manor/servant
	name = "servant bedroom II key"
	lockid = "servant_room_two"

/obj/item/roguekey/ap_dun_world/manor/squire
	parent_type = /obj/item/roguekey/manor
	name = "squire bedroom I key"
	lockid = "squire_room_one"

/obj/item/roguekey/ap_dun_world/manor/squire/four
	parent_type = /obj/item/roguekey/ap_dun_world/manor/squire
	name = "squire bedroom IV key"
	lockid = "squire_room_four"

/obj/item/roguekey/ap_dun_world/manor/squire/three
	parent_type = /obj/item/roguekey/ap_dun_world/manor/squire
	name = "squire bedroom III key"
	lockid = "squire_room_three"

/obj/item/roguekey/ap_dun_world/manor/squire/two
	parent_type = /obj/item/roguekey/ap_dun_world/manor/squire
	name = "squire bedroom II key"
	lockid = "squire_room_two"

/obj/item/roguekey/ap_dun_world/ortho_one
	parent_type = /obj/item/roguekey
	name = "Otavan Embassy Bedroom I key"
	icon_state = "brownkey"
	lockid = "OEB1"

/obj/item/roguekey/ap_dun_world/ortho_three
	parent_type = /obj/item/roguekey
	name = "Otavan Embassy Bedroom III key"
	icon_state = "brownkey"
	lockid = "OEB3"

/obj/item/roguekey/ap_dun_world/ortho_two
	parent_type = /obj/item/roguekey
	name = "Otavan Embassy Bedroom II key"
	icon_state = "brownkey"
	lockid = "OEB2"

/obj/item/roguekey/ap_dun_world/townie_smith_extras
	parent_type = /obj/item/roguekey
	name = "town smith key"
	desc = "The key to the basement and bedroom of the towner smiths house."
	icon_state = "brownkey"
	lockid = "townie_smith_extra"

/obj/item/roguekey/ap_dun_world/university
	parent_type = /obj/item/roguekey
	name = "university key"
	desc = "This key should open all but the most secure areas of the University of Azuria."
	icon_state = "greenkey"
	lockid = "university"

/obj/item/roguekey/ap_dun_world/university_secure
	parent_type = /obj/item/roguekey
	name = "university tower key"
	desc = "This key should open the tower in the University of Azuria, where dangerous magic is contained."
	icon_state = "brownkey"
	lockid = "university_secure"

/obj/item/roguekey/ap_dun_world/zhurch/onmap
	parent_type = /obj/item/roguekey
	name = "brass key"
	desc = "A key made of brass."
	icon_state = "rustkey"
	lockid = "zhurch"

/obj/item/roguekey/ap_dun_world/zurch_bedroom
	parent_type = /obj/item/roguekey
	name = "bedroom i key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_1"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/admin
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "ancient key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "admin_event_door"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/eight
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom viii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_8"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/eleven
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom xi key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_11"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/five
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom v key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_5"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/four
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom iv key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_4"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/nine
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom ix key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_9"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/seven
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom vii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_7"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/six
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom vi key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_6"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/ten
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom x key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_10"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/three
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom iii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_3"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/twelve
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom xii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_12"

/obj/item/roguekey/ap_dun_world/zurch_bedroom/two
	parent_type = /obj/item/roguekey/ap_dun_world/zurch_bedroom
	name = "bedroom ii key"
	desc = "A ancient, rusty key."
	icon_state = "rustkey"
	lockid = "zurch_bedroom_2"

/obj/structure/roguemachine/vendor/ap_dun_world/church_bedroomset_one
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "priest"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/church/roomi,
		/obj/item/roguekey/ap_dun_world/church/roomii,
		/obj/item/roguekey/ap_dun_world/church/roomiii,
		/obj/item/roguekey/ap_dun_world/church/roomiv,
		/obj/item/roguekey/ap_dun_world/church/roomv,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/church_bedroomset_two
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "priest"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/church/roomvi,
		/obj/item/roguekey/ap_dun_world/church/roomvii,
		/obj/item/roguekey/ap_dun_world/church/roomviii,
		/obj/item/roguekey/ap_dun_world/church/roomix,
		/obj/item/roguekey/ap_dun_world/church/roomx,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/inq_keys
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "puritan"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/ortho_one,
		/obj/item/roguekey/ap_dun_world/ortho_two,
		/obj/item/roguekey/ap_dun_world/ortho_three,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_councillors
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/manor/councillor,
		/obj/item/roguekey/ap_dun_world/manor/councillor/two,
		/obj/item/roguekey/ap_dun_world/manor/councillor/three,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_guests
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/storage/keyring/ap_dun_world/manor/guest/one,
		/obj/item/storage/keyring/ap_dun_world/manor/guest/two,
		/obj/item/storage/keyring/ap_dun_world/manor/guest/three,
		/obj/item/storage/keyring/ap_dun_world/manor/guest/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_knights
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/manor/knight,
		/obj/item/roguekey/ap_dun_world/manor/knight/two,
		/obj/item/roguekey/ap_dun_world/manor/knight/three,
		/obj/item/roguekey/ap_dun_world/manor/knight/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_princes
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/heir/one,
		/obj/item/roguekey/ap_dun_world/heir/two,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_servant
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/manor/servant,
		/obj/item/roguekey/ap_dun_world/manor/servant/two,
		/obj/item/roguekey/ap_dun_world/manor/servant/three,
		/obj/item/roguekey/ap_dun_world/manor/servant/four,
		/obj/item/roguekey/ap_dun_world/manor/servant/five,
		/obj/item/roguekey/ap_dun_world/manor/servant/six,
	)

/obj/structure/roguemachine/vendor/ap_dun_world/keep_squire
	parent_type = /obj/structure/roguemachine/vendor/ap_dun_world
	keycontrol = "lord"
	key_stock = list(
		/obj/item/roguekey/ap_dun_world/manor/squire,
		/obj/item/roguekey/ap_dun_world/manor/squire/two,
		/obj/item/roguekey/ap_dun_world/manor/squire/three,
		/obj/item/roguekey/ap_dun_world/manor/squire/four,
	)

/obj/structure/roguemachine/vendor/ap_dun_world
	parent_type = /obj/structure/roguemachine/vendor
	will_hawk = FALSE
	var/list/key_stock

/obj/structure/roguemachine/vendor/ap_dun_world/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSroguemachine, src)
	for(var/key_type in key_stock)
		var/obj/item/stock_item = new key_type(src)
		held_items[stock_item] = list("NAME" = stock_item.name, "PRICE" = 0)
	update_icon()

/obj/structure/mineral_door/ap_dun_world/wood/donjon/highsecurity
	parent_type = /obj/structure/mineral_door/wood/donjon
	lockdifficulty = 1.8

/obj/structure/mineral_door/ap_dun_world/wood/donjon/stone/highsecurity
	parent_type = /obj/structure/mineral_door/wood/donjon/stone
	lockdifficulty = 1.8

/obj/structure/mineral_door/ap_dun_world/wood/towner/generic/two_keys/noble
	parent_type = /obj/structure/mineral_door/wood/towner/generic/two_keys
/obj/structure/mineral_door/ap_dun_world/wood/towner/generic/two_keys/noble/try_award_resident_key(mob/user)
	if(!ishuman(user) || !HAS_TRAIT(user, TRAIT_NOBLE))
		return FALSE
	return ..()

/obj/structure/mineral_door/ap_dun_world/wood/towner/generic/two_keys/wretch
	parent_type = /obj/structure/mineral_door/wood/towner/generic/two_keys
	resident_role = null

/obj/structure/mineral_door/ap_dun_world/wood/towner/generic/two_keys/wretch/try_award_resident_key(mob/user)
	if(!ishuman(user) || !HAS_TRAIT(user, TRAIT_ZURCH))
		return FALSE
	return ..()

/obj/structure/mineral_door/ap_dun_world/wood/towner/generic/vagabond
	parent_type = /obj/structure/mineral_door/wood/towner/generic
	resident_role = /datum/job/roguetown/orphan
	resident_key_type = /obj/item/roguekey/ap_dun_world/ap_sewer

/obj/item/roguekey/ap_dun_world/ap_sewer
	parent_type = /obj/item/roguekey
	name = "sewer key"
	desc = "An old, rusty key with the smell of the sewers."
	icon_state = "brownkey"

/obj/structure/mineral_door/ap_dun_world/wood/towner/potter
	parent_type = /obj/structure/mineral_door/wood/towner
	resident_advclass = list(/datum/advclass/potter)
	lockid = "towner_potter"

/obj/structure/ap_dun_world/bars/passage/shutter/bookcase
	parent_type = /obj/structure/bars/passage/shutter
	name = "empty bookcase"
	icon = '_maps/map_files/ap_dun_world/bookcase.dmi'
	icon_state = "decoybookcase0"

/obj/structure/ap_dun_world/bars/passage/shutter/bookcase/redstone_triggered(mob/user)
	if(obj_broken)
		return
	density = !density
	set_opacity(density)
	icon_state = density ? "decoybookcase0" : "decoybookcase1"

/obj/structure/ap_dun_world/bars/passage/shutter/bookcase/obj_break(damage_flag)
	. = ..()
	set_opacity(FALSE)
	icon_state = "decoybookcase1"

/obj/structure/ap_dun_world/lever/bookcase
	parent_type = /obj/structure/lever
	name = "bookcase"
	desc = "Refuge for few, an irrelevance to most."
	icon = '_maps/map_files/ap_dun_world/bookcase.dmi'
	icon_state = "booklever0"

/obj/structure/ap_dun_world/lever/bookcase/examine(mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/examiner = user
	if(HAS_TRAIT(examiner, TRAIT_INQUISITION))
		. += span_notice("I recognize the signs of a concealed mechanism.")
	else if(examiner.STAPER >= 15)
		. += span_notice("There may be more to this shelf than meets the eye.")

/obj/structure/ap_dun_world/lever/bookcase/attack_hand(mob/user)
	if(!isliving(user))
		return FALSE
	var/mob/living/operator = user
	if(!HAS_TRAIT(operator, TRAIT_INQUISITION) && operator.STAPER < 15)
		return FALSE
	. = ..()
	icon_state = "booklever[toggled]"

/obj/structure/ap_dun_world/lever/bookcase/onkick(mob/user)
	return FALSE

/obj/structure/ap_dun_world/decorativeladder
	parent_type = /obj/structure
	name = "ladder"
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "ladder11"
	anchored = TRUE

/obj/structure/ap_dun_world/mannequin/male/decorative/training_dummy_style
	parent_type = /obj/structure/mannequin/male/decorative
	name = "training dummy"

/obj/item/ap_dun_world/reagent_containers/glass/bottle/clayvaseclassic/holy_water
	parent_type = /obj/item/reagent_containers/glass/bottle/claybottle
	name = "vase of holy water"
	list_reagents = list(/datum/reagent/water/holywater = 65)

/obj/item/ap_dun_world/rogueweapon/huntingknife/idagger/steel/trainer
	parent_type = /obj/item/rogueweapon/huntingknife/idagger/steel
	name = "dagger trainer"
	sharpness = IS_BLUNT
	force = 7
	possible_item_intents = list(/datum/intent/mace/strike)

/obj/item/ap_dun_world/rogueweapon/spear/trainer
	parent_type = /obj/item/rogueweapon/spear
	name = "sparring spear"
	sharpness = IS_BLUNT
	force = 7
	force_wielded = 15
	possible_item_intents = list(/datum/intent/mace/strike)
	gripped_intents = list(/datum/intent/mace/strike)

/turf/open/floor/rogue/ap_dun_world/crawl_space
	parent_type = /turf/open/floor/rogue
	name = "crawlspace"
	desc = "Too small to pass without crawling."
	icon_state = "dirt"
	neighborlay = "dirtedge"

/turf/open/floor/rogue/ap_dun_world/crawl_space/CanPass(atom/movable/mover, turf/target)
	if(!..())
		return FALSE
	if(iscarbon(mover))
		var/mob/living/carbon/crawler = mover
		if(crawler.mobility_flags & MOBILITY_STAND)
			return FALSE
	return TRUE

/turf/open/floor/rogue/ap_dun_world/hotspring
	parent_type = /turf/open/floor/rogue
	name = "hot spring"
	desc = "Wisps of vapour rise delicately from this warm, mineral-rich water."
	icon = 'icons/obj/structures/hotspring.dmi'
	icon_state = "hotspring"
	slowdown = 5
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	landsound = 'sound/foley/jumpland/waterland.wav'

/turf/open/floor/rogue/ap_dun_world/underworld/space/dense
	parent_type = /turf/open/floor/rogue/underworld/space
	density = TRUE

/turf/open/floor/rogue/ap_dun_world/underworld/space/quiet/dense
	parent_type = /turf/open/floor/rogue/underworld/space/quiet
	density = TRUE

/turf/open/floor/rogue/ap_dun_world/underworld/space/sparkle_quiet/dense
	parent_type = /turf/open/floor/rogue/underworld/space/sparkle_quiet
	density = TRUE

/turf/open/water/ap_dun_world/ocean/abyssal
	parent_type = /turf/open/water/ocean/deep
	name = "darkwater"
	water_color = "#000211"

/turf/open/water/ap_dun_world/river/flow/murk
	parent_type = /turf/open/water/river/flow
	name = "murk river"
	water_color = "#705a43"
	water_reagent = /datum/reagent/water/gross

/turf/open/water/ap_dun_world/river/flow/murk/east
	parent_type = /turf/open/water/ap_dun_world/river/flow/murk
	dir = EAST
