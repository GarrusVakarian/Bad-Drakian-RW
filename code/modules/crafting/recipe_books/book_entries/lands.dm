/// Region lore and bonuses come from the same origin datums used by character creation.
/datum/book_entry/lands
	abstract_type = /datum/book_entry/lands
	category = null
	var/origin_type

/datum/book_entry/lands/inner_book_html(mob/user)
	var/datum/origin/origin = GLOB.origins[origin_type]
	if(!istype(origin))
		return "<p>This land's information is unavailable.</p>"
	. = "<p>[html_encode(origin.desc)]</p><h3>Region Traits</h3><ul>"
	for(var/trait in origin.origin_traits)
		var/description = GLOB.roguetraits[trait]
		if(description)
			description = html_encode(GLOB.html_tags.Replace(description, ""))
		. += "<li><strong>[html_encode(trait)]</strong>[description ? ": [description]" : ""]</li>"
	. += "</ul><h3>Language Bonus</h3>"
	if(ispath(origin.origin_language, /datum/language))
		var/datum/language/language = origin.origin_language
		. += "<p><strong>[html_encode(initial(language.name))]</strong> is granted by this origin and occupies the free language slot.</p>"
	else
		. += "<p>No fixed regional language. The free language slot remains available to choose a language.</p>"

/datum/book_entry/lands/ferentia
	name = "Ferentia"
	chapter_order = 1
	origin_type = /datum/origin/ferentia

/datum/book_entry/lands/otava
	name = "Otava"
	chapter_order = 2
	origin_type = /datum/origin/otava

/datum/book_entry/lands/grenzelhoft
	name = "Grenzelhoft"
	chapter_order = 3
	origin_type = /datum/origin/grenzelhoft

/datum/book_entry/lands/gronn
	name = "Gronn"
	chapter_order = 4
	origin_type = /datum/origin/gronn

/datum/book_entry/lands/naledi
	name = "Naledi"
	chapter_order = 5
	origin_type = /datum/origin/naledi

/datum/book_entry/lands/hammerhold
	name = "Hammerhold"
	chapter_order = 6
	origin_type = /datum/origin/hammerhold

/datum/book_entry/lands/etrusca
	name = "Etrusca"
	chapter_order = 7
	origin_type = /datum/origin/etrusca

/datum/book_entry/lands/avar
	name = "Avar"
	chapter_order = 8
	origin_type = /datum/origin/avar

/datum/book_entry/lands/kazengun
	name = "Kazengun"
	chapter_order = 9
	origin_type = /datum/origin/kazengun

/datum/book_entry/lands/zybantine
	name = "Zybantine"
	chapter_order = 10
	origin_type = /datum/origin/zybantine

/datum/book_entry/lands/underdark
	name = "The Underdark"
	chapter_order = 11
	origin_type = /datum/origin/underdark
