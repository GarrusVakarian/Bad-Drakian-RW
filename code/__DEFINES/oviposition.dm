// Oviposition - egg forming organs (ovipositors and egg-laying wombs) and eggs implanted into hosts.
// Implementation lives in modular_rmh/code/modules/oviposition.

/// Most eggs an organ can hold in a clutch.
#define OVI_EGG_MAX_CLUTCH 6
/// Default clutch size for new characters.
#define OVI_EGG_DEFAULT_CLUTCH 3
/// Time for an organ to form one egg.
#define OVI_EGG_FORM_TIME (8 MINUTES)
/// Nutrition spent forming a single egg.
#define OVI_EGG_NUTRITION_COST 40
/// Most implanted eggs a host can carry at once.
#define OVI_HOST_MAX_EGGS 6
/// Time an implanted egg takes to become ready to lay.
#define OVI_INCUBATION_TIME (10 MINUTES)
/// Time after ripening before the host's body pushes the eggs out on its own.
#define OVI_OVERDUE_TIME (10 MINUTES)
/// Time it takes to lay eggs by hand.
#define OVI_LAY_TIME (5 SECONDS)

#define OVI_EGG_MAX_NAME_LENGTH 42
#define OVI_EGG_MAX_DESC_LENGTH 300
