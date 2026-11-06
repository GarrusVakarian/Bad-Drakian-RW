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
		var/mechanics = get_trait_mechanics(trait)
		. += "<li><strong>[html_encode(trait)]</strong>[description ? ": [description]" : ""]"
		if(mechanics)
			. += "<br><strong>Effect:</strong> [html_encode(mechanics)]"
		. += "</li>"
	. += "</ul><h3>Language Bonus</h3>"
	if(ispath(origin.origin_language, /datum/language))
		var/datum/language/language = origin.origin_language
		. += "<p><strong>[html_encode(initial(language.name))]</strong> is granted by this origin and occupies the free language slot.</p>"
	else
		. += "<p>No fixed regional language. The free language slot remains available to choose a language.</p>"

/// Display-only explanations verified against the trait's consumers; never grant bonuses here.
/datum/book_entry/lands/proc/get_trait_mechanics(trait)
	switch(trait)
		if(TRAIT_LOCAL_KNOWLEDGE)
			return "Reduces random ambush chance by 25%. Walking over a maneater does not trigger it; running still can."
		if(TRAIT_WATERLOVING)
			return "Very cold water's direct cooling effect cannot lower your body temperature below normal."
		if(TRAIT_COLD_RESISTANCE)
			return "Reduces body cooling from weather by 25% and prevents cold-triggered shivering."
		if(TRAIT_HEAT_RESISTANCE)
			return "Reduces body heating from weather by 50%."
		if(TRAIT_DEADITE_RESISTANCE)
			return "Doubles the time before a deadite infection transforms you."
		if(TRAIT_STEPPE_RIDER)
			return "Improves mounted movement speed, halves the delay when urging a mount into a run, and makes it less likely that thorns will throw you from your mount."
		if(TRAIT_HEARTY_DRINKER)
			return "Strong alcohol grants +1 Luck for five minutes. Drinking more refreshes the duration."
		if(TRAIT_BATTLE_CRY)
			return "Using Warcry grants the Battle Cry buff for one minute, increasing your pain threshold by 10."
		if(TRAIT_METICULOUS)
			return "When Intelligence is above 10, adds another 2 percentage points of success chance per point above 10 to qualifying crafting checks. Skill requirements and the normal chance cap still apply."
		if(TRAIT_SLOW_METABOLISM)
			return "Reduces passive hunger drain by 10%."
		if(TRAIT_GOLD_AFFINITY)
			return "Reduces energy expenditure by 2% per equipped gold item, up to 10% with five items."
		if(TRAIT_WATCHFUL)
			return "Counts as having +1 Perception when another character attempts to pickpocket you."
		if(TRAIT_SOFT_FOOTED)
			return "Reduces footstep volume by 30% and reduces the sound's extra range by one tile."
		if(TRAIT_ANCESTOR_GUARDIAN)
			return "Gives one additional chance to pass a failed parry or dodge roll per in-game day. The opportunity is spent even if the extra roll fails."
		if(TRAIT_LIGHT_SENSITIVITY)
			return "Improves dark vision, but sunlight causes stress and can apply Sun Blinded (-5 Perception) unless suitable headgear shields you. Certain flashes also stun you for two seconds."
		if(TRAIT_BLACKLEG)
			return "Allows you to rig coin flips and dice rolls in your favour."
	return null

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
