/// Read the same shared lore as character creation; never apply patron effects to a reader.
/datum/book_entry/gods
	abstract_type = /datum/book_entry/gods
	category = null
	var/faith_type
	var/patron_type

/datum/book_entry/gods/inner_book_html(mob/user)
	if(faith_type)
		var/datum/faith/faith = GLOB.faithlist[faith_type]
		if(!istype(faith))
			return "<p>This faith's information is unavailable.</p>"
		return "<p><strong>Background:</strong> [html_encode(faith.desc)]</p><p><strong>Likely Worshippers:</strong> [html_encode(faith.worshippers)]</p>"
	var/datum/patron/patron = GLOB.patronlist[patron_type]
	if(!istype(patron))
		return "<p>This patron's information is unavailable.</p>"
	return {"
		<p><strong>Domain:</strong> [html_encode(patron.domain)]</p>
		<p><strong>Background:</strong> [html_encode(patron.desc)]</p>
		<p><strong>Likely Worshippers:</strong> [html_encode(patron.worshippers)]</p>
		<p><strong>Virtues:</strong> [html_encode(patron.virtues)]</p>
		<p><strong>Sins:</strong> [html_encode(patron.sins)]</p>
	"}

/datum/book_entry/gods/divine
	name = "Divine Pantheon"
	chapter_order = 1
	faith_type = /datum/faith/divine

/datum/book_entry/gods/abyssor
	name = "Abyssor"
	chapter_order = 2
	patron_type = /datum/patron/divine/abyssor

/datum/book_entry/gods/astrata
	name = "Astrata"
	chapter_order = 3
	patron_type = /datum/patron/divine/astrata

/datum/book_entry/gods/dendor
	name = "Dendor"
	chapter_order = 4
	patron_type = /datum/patron/divine/dendor

/datum/book_entry/gods/eora
	name = "Eora"
	chapter_order = 5
	patron_type = /datum/patron/divine/eora

/datum/book_entry/gods/malum
	name = "Malum"
	chapter_order = 6
	patron_type = /datum/patron/divine/malum

/datum/book_entry/gods/necra
	name = "Necra"
	chapter_order = 7
	patron_type = /datum/patron/divine/necra

/datum/book_entry/gods/noc
	name = "Noc"
	chapter_order = 8
	patron_type = /datum/patron/divine/noc

/datum/book_entry/gods/pestra
	name = "Pestra"
	chapter_order = 9
	patron_type = /datum/patron/divine/pestra

/datum/book_entry/gods/ravox
	name = "Ravox"
	chapter_order = 10
	patron_type = /datum/patron/divine/ravox

/datum/book_entry/gods/xylix
	name = "Xylix"
	chapter_order = 11
	patron_type = /datum/patron/divine/xylix

/datum/book_entry/gods/ascendants
	name = "Ascendants"
	chapter_order = 12
	faith_type = /datum/faith/inhumen

/datum/book_entry/gods/baotha
	name = "Baotha"
	chapter_order = 13
	patron_type = /datum/patron/inhumen/baotha

/datum/book_entry/gods/graggar
	name = "Graggar"
	chapter_order = 14
	patron_type = /datum/patron/inhumen/graggar

/datum/book_entry/gods/matthios
	name = "Matthios"
	chapter_order = 15
	patron_type = /datum/patron/inhumen/matthios

/datum/book_entry/gods/zizo
	name = "Zizo"
	chapter_order = 16
	patron_type = /datum/patron/inhumen/zizo

/datum/book_entry/gods/old_god
	name = "Old God"
	chapter_order = 17
	faith_type = /datum/faith/old_god

/datum/book_entry/gods/psydon
	name = "Psydon"
	chapter_order = 18
	patron_type = /datum/patron/old_god
