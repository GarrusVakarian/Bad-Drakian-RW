/// From base of /mob/living/proc/update_turf_movespeed()
#define COMSIG_LIVING_UPDATE_TURF_MOVESPEED "update_turf_movespeed"
	/// Return value if the movespeed update is blocked
	#define TURF_MOVESPEED_BLOCKED (1<<0)

/// Sent from /mob/living/proc/look_around()
#define COMSIG_LOOK_AROUND_SPOTTED "look_around_spotted"

/// After eyelid blindness is applied or removed: (eyesclosed)
#define COMSIG_LIVING_EYELIDS_UPDATED "living_eyelids_updated"

/// After carbon/update_stat() changes consciousness: (old_stat, new_stat)
#define COMSIG_LIVING_CONSCIOUSNESS_CHANGED "living_consciousness_changed"

/// Sent after a mob commits to yielding, before it drops held items.
#define COMSIG_LIVING_YIELDED "living_yielded"

#define COMSIG_LIVING_PRE_DEATH "living_pre_death"
#define COMSIG_LIVING_SUCCUMBED "living_succumbed"
#define COMSIG_LIVING_GET_SUCCUMB_WARNINGS "living_get_succumb_warnings"
#define COMSIG_LIVING_CLOSED_EYES "living_closed_eyes"
#define COMSIG_LIVING_TRY_OPEN_EYES "living_try_open_eyes"
#define COMSIG_LIVING_CAN_BE_STAKED "living_can_be_staked"
#define COMSIG_LIVING_STAKED "living_staked"
#define COMPONENT_CANCEL_DEATH (1<<0)
#define COMPONENT_STAKE_VULNERABLE (1<<0)
#define COMPONENT_STAKE_HANDLED (1<<0)
#define COMPONENT_BLOCK_OPEN_EYES (1<<0)
