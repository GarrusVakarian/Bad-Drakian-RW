// Retired virtue types - DO NOT DELETE THESE DECLARATIONS.
//
// preferences_savefile.dm's _load_virtue() reads virtue/virtuetwo/virtue_background by raw type path
// (WRITE_FILE(S["virtue"], virtue_typepath)), not by name string. If a type a character's save
// references stops existing entirely, the path can't resolve on load and silently falls through to
// /datum/virtue/none - no error, no warning, the player just loses that slot's content.
//
// Species avoid this class of bug entirely because _load_species() saves by NAME STRING, with an
// explicit legacy_species_names remap table for renames (preferences_savefile.dm). Virtues have no
// equivalent string-based path, so the only way to keep an old save resolving is to keep the type
// itself defined.
//
// Each stub keeps a visible "(Retired)" display name - a null name renders the player's virtue
// button with a BLANK label, which live players read as "my virtue slot is gone". `unlisted = TRUE`
// keeps them out of every picker; `retired = TRUE` marks them so the menu can nudge affected players
// to re-pick. They grant nothing: no skills, no traits, no stash, no equipment prompt.
//
// When retiring a virtue in the future: move it here as a stub like these instead of deleting the
// definition outright.

// The crafter virtues (crafter.dm) - their roles now live in the Background slot.
/datum/virtue/utility/blacksmith
	name = "Blacksmith's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Blacksmith's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/tailor
	name = "Tailor's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Tailor's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/physician
	name = "Physician's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Physician's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/hunter
	name = "Hunter's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Hunter's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/artificer
	name = "Artificer's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Artificer's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/mining
	name = "Miner's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Miner's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

// The fighting virtues (combat.dm) - their roles now live in the Background slot.
/datum/virtue/combat/duelist
	name = "Duelist's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Duelist's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/combat/executioner
	name = "Dungeoneer's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Dungeoneer's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/combat/militia
	name = "Militiaman (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Militiaman). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/combat/brawler
	name = "Brawler's Apprentice (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Brawler's Apprentice). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/combat/bowman
	name = "Toxophilite (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Toxophilite). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/combat/crossbowman
	name = "Crossbow Levy (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Toxophilite, Crossbowman loadout). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

// The skill-granting utility virtues (utility.dm) - their roles now live in the Background slot.
/datum/virtue/utility/light_steps
	name = "Light Steps (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Light Steps). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/performer
	name = "Performer (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Performer). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/granary
	name = "Cunning Provisioner (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Cunning Provisioner). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/forester
	name = "Forester (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Forester). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/tracker
	name = "Sleuth (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Sleuth). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

/datum/virtue/utility/linguist
	name = "Intellectual (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Intellectual). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE

// The item virtue (items.dm) - its role now lives in the Background slot.
/datum/virtue/items/arsonist
	name = "Arsonist (Retired)"
	desc = "This virtue has been retired - its role now lives in the Background slot (Rogue Alchemist). Pick a new virtue; it grants nothing anymore."
	unlisted = TRUE
	retired = TRUE