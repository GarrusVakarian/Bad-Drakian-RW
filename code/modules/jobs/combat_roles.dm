// Shared combat-role policy. Keep NO_COMBAT_RACES in roguetown.dm as the species list.
// Each entry marks a type and its descendants; civilian/support exceptions override it.
// Similar names with underscores can still be unrelated types and need separate entries.
#define COMBAT_ROLE(role_type) role_type { combat_role = TRUE }

// Dedicated combat jobs (mixed jobs are classified by subclass).
// Dragon and Gnoll replace the selected species before subclass selection.
// Assassin is open to Seelies across the job, subclasses, and migration.
COMBAT_ROLE(/datum/job/roguetown/bandit)
COMBAT_ROLE(/datum/job/roguetown/templar)
COMBAT_ROLE(/datum/job/roguetown/martyr)
COMBAT_ROLE(/datum/job/roguetown/dungeoneer)
COMBAT_ROLE(/datum/job/roguetown/baron_retainer)
COMBAT_ROLE(/datum/job/roguetown/rookie)
COMBAT_ROLE(/datum/job/roguetown/sergeant)
COMBAT_ROLE(/datum/job/roguetown/squire)
COMBAT_ROLE(/datum/job/roguetown/guardsman)
COMBAT_ROLE(/datum/job/roguetown/vanguard)
COMBAT_ROLE(/datum/job/roguetown/veteran)
COMBAT_ROLE(/datum/job/roguetown/warden)
COMBAT_ROLE(/datum/job/roguetown/wardenmaster)
COMBAT_ROLE(/datum/job/roguetown/watchcaptain)
COMBAT_ROLE(/datum/job/roguetown/knight)
COMBAT_ROLE(/datum/job/roguetown/manorguard)
COMBAT_ROLE(/datum/job/roguetown/puritan)
COMBAT_ROLE(/datum/job/roguetown/mercenary)
COMBAT_ROLE(/datum/job/roguetown/marshal)
COMBAT_ROLE(/datum/job/roguetown/captain)
COMBAT_ROLE(/datum/job/roguetown/goblin)
COMBAT_ROLE(/datum/job/roguetown/greater_skeleton)
COMBAT_ROLE(/datum/job/roguetown/vampire_guard)
COMBAT_ROLE(/datum/job/roguetown/vampire_spawn)
COMBAT_ROLE(/datum/job/roguetown/azeb)
COMBAT_ROLE(/datum/job/roguetown/azebagha)
COMBAT_ROLE(/datum/job/roguetown/cataphract)
COMBAT_ROLE(/datum/job/roguetown/janissarysergeant)
COMBAT_ROLE(/datum/job/roguetown/janissary)
COMBAT_ROLE(/datum/job/roguetown/slavemaster)
COMBAT_ROLE(/datum/job/roguetown/tribalguard)
COMBAT_ROLE(/datum/job/roguetown/tribalrabble)
COMBAT_ROLE(/datum/job/roguetown/heartfelt/knight)
COMBAT_ROLE(/datum/job/roguetown/adventurer/courtagent)
// Combat subclasses. Descendants inherit this unless explicitly exempted below.
COMBAT_ROLE(/datum/advclass/mercenary)
COMBAT_ROLE(/datum/advclass/sfighter)
COMBAT_ROLE(/datum/advclass/ranger)
COMBAT_ROLE(/datum/advclass/rogue)
COMBAT_ROLE(/datum/advclass/mage)
COMBAT_ROLE(/datum/advclass/cleric)
COMBAT_ROLE(/datum/advclass/noble)
COMBAT_ROLE(/datum/advclass/foreigner)
COMBAT_ROLE(/datum/advclass/nudist)
COMBAT_ROLE(/datum/advclass/brigand)
COMBAT_ROLE(/datum/advclass/dragon)
COMBAT_ROLE(/datum/advclass/hedgeknight)
COMBAT_ROLE(/datum/advclass/iconoclast)
COMBAT_ROLE(/datum/advclass/knave)
COMBAT_ROLE(/datum/advclass/pioneer)
COMBAT_ROLE(/datum/advclass/roguemage)
COMBAT_ROLE(/datum/advclass/sellsword)
COMBAT_ROLE(/datum/advclass/gnoll)
COMBAT_ROLE(/datum/advclass/gnoll_impure)
COMBAT_ROLE(/datum/advclass/wretch)
COMBAT_ROLE(/datum/advclass/templar)
COMBAT_ROLE(/datum/advclass/martyr)
COMBAT_ROLE(/datum/advclass/dungeoneer)
COMBAT_ROLE(/datum/advclass/baron_retainer)
COMBAT_ROLE(/datum/advclass/rookie)
COMBAT_ROLE(/datum/advclass/sergeant)
COMBAT_ROLE(/datum/advclass/squire)
COMBAT_ROLE(/datum/advclass/guardsman)
COMBAT_ROLE(/datum/advclass/vanguard)
COMBAT_ROLE(/datum/advclass/veteran)
COMBAT_ROLE(/datum/advclass/warden)
COMBAT_ROLE(/datum/advclass/wardenmaster)
COMBAT_ROLE(/datum/advclass/watchcaptain)
COMBAT_ROLE(/datum/advclass/knight)
COMBAT_ROLE(/datum/advclass/manorguard)
COMBAT_ROLE(/datum/advclass/puritan)
COMBAT_ROLE(/datum/advclass/marshal)
COMBAT_ROLE(/datum/advclass/captain)
COMBAT_ROLE(/datum/advclass/greater_skeleton)
COMBAT_ROLE(/datum/advclass/vampire_spawn)
COMBAT_ROLE(/datum/advclass/azeb)
COMBAT_ROLE(/datum/advclass/azebagha)
COMBAT_ROLE(/datum/advclass/cataphract)
COMBAT_ROLE(/datum/advclass/janissarysergeant)
COMBAT_ROLE(/datum/advclass/janissary)
COMBAT_ROLE(/datum/advclass/slavemaster)
COMBAT_ROLE(/datum/advclass/tribalguard)
COMBAT_ROLE(/datum/advclass/tribalrabble)
COMBAT_ROLE(/datum/advclass/tribalchieftain/warrior)
COMBAT_ROLE(/datum/advclass/psydoniantemplar)
COMBAT_ROLE(/datum/advclass/arbalist)
COMBAT_ROLE(/datum/advclass/confessor)
COMBAT_ROLE(/datum/advclass/disciple)
COMBAT_ROLE(/datum/advclass/sojourner)
COMBAT_ROLE(/datum/advclass/hand/blademaster)
COMBAT_ROLE(/datum/advclass/hand/spymaster)
COMBAT_ROLE(/datum/advclass/lord/warrior)
COMBAT_ROLE(/datum/advclass/baron/landed_knight)
COMBAT_ROLE(/datum/advclass/lady/heartthrob)
COMBAT_ROLE(/datum/advclass/heir/daring)
COMBAT_ROLE(/datum/advclass/councillor/huntmaster)
COMBAT_ROLE(/datum/advclass/hunter)
COMBAT_ROLE(/datum/advclass/thug)
COMBAT_ROLE(/datum/advclass/prisoner_thug)
COMBAT_ROLE(/datum/advclass/prisoner_hunter)
COMBAT_ROLE(/datum/advclass/slave/slave_sentry)
COMBAT_ROLE(/datum/advclass/crusader)
COMBAT_ROLE(/datum/advclass/crusader_Captain)
COMBAT_ROLE(/datum/advclass/crusader_paladin)
COMBAT_ROLE(/datum/advclass/crusader_footman)
COMBAT_ROLE(/datum/advclass/crusader_marksman)
COMBAT_ROLE(/datum/advclass/guard)
COMBAT_ROLE(/datum/advclass/grenzel_guard)
COMBAT_ROLE(/datum/advclass/otavan_knight)
COMBAT_ROLE(/datum/advclass/otavan_guard)
COMBAT_ROLE(/datum/advclass/otavan_preacher)
COMBAT_ROLE(/datum/advclass/zybantine_janissary)
COMBAT_ROLE(/datum/advclass/czwarteki/hussar)
COMBAT_ROLE(/datum/advclass/czwarteki/retainer)
COMBAT_ROLE(/datum/advclass/heartfelt/knight)
COMBAT_ROLE(/datum/advclass/heartfelt/hand/marshal)
COMBAT_ROLE(/datum/advclass/heartfelt/retinue/houseguard)
COMBAT_ROLE(/datum/advclass/heartfelt/retinue/housearb)
COMBAT_ROLE(/datum/advclass/heartfelt/retinue/squire)
COMBAT_ROLE(/datum/advclass/kj_knight)
COMBAT_ROLE(/datum/advclass/kj_knight_outrider)
COMBAT_ROLE(/datum/advclass/kj_squire)
COMBAT_ROLE(/datum/advclass/kj_squire_hobelar)
COMBAT_ROLE(/datum/advclass/kj_squire_bidower)
COMBAT_ROLE(/datum/advclass/kj_chaplain)
COMBAT_ROLE(/datum/advclass/slaver/mercenary)
COMBAT_ROLE(/datum/advclass/slaver/slave/battle)
COMBAT_ROLE(/datum/advclass/slaver/slave/arcyne)
COMBAT_ROLE(/datum/advclass/ukj_dark_itinerant)
COMBAT_ROLE(/datum/advclass/ukj_dark_itinerant_harbinger)
COMBAT_ROLE(/datum/advclass/ukj_varlet)
COMBAT_ROLE(/datum/advclass/ukj_varlet_harrier)
// Civilian, support, and stealth exceptions under otherwise combat-oriented parents.
/datum/advclass/rogue/bard
	combat_role = FALSE

/datum/advclass/rogue/thief
	combat_role = FALSE

/datum/advclass/cleric/cantor
	combat_role = FALSE

/datum/advclass/cleric/missionary
	combat_role = FALSE

/datum/advclass/cleric/stigmata
	combat_role = FALSE

/datum/advclass/wretch/wretchedtoiler
	combat_role = FALSE

/datum/advclass/foreigner/refugee
	combat_role = FALSE

// Migrant combat slots; mixed waves still classify individual subclasses.
COMBAT_ROLE(/datum/migrant_role/bandit)
COMBAT_ROLE(/datum/migrant_role/ea_hasir/guard)
COMBAT_ROLE(/datum/migrant_role/grenzel/bodyguard)
COMBAT_ROLE(/datum/migrant_role/otavan/knight)
COMBAT_ROLE(/datum/migrant_role/otavan/guard)
COMBAT_ROLE(/datum/migrant_role/otavan/preacher)
COMBAT_ROLE(/datum/migrant_role/zybantine/janissary)
COMBAT_ROLE(/datum/migrant_role/czwarteki/hussar)
COMBAT_ROLE(/datum/migrant_role/czwarteki/retainer)
COMBAT_ROLE(/datum/migrant_role/heartfelt/knight)
COMBAT_ROLE(/datum/migrant_role/gronn/warrior)
COMBAT_ROLE(/datum/migrant_role/gronn/tribal)
COMBAT_ROLE(/datum/migrant_role/hammerhold/volfskin)
COMBAT_ROLE(/datum/migrant_role/hammerhold/huscarl)
COMBAT_ROLE(/datum/migrant_role/kj_knight)
COMBAT_ROLE(/datum/migrant_role/kj_squire)
COMBAT_ROLE(/datum/migrant_role/slaver/slavemerc)
/datum/migrant_role/ukj_dark_itinerant
	combat_role = TRUE

#undef COMBAT_ROLE
