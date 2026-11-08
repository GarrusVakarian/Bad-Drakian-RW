// Whether or not an item can be worked.
#define FORGING_STAGE_READY 0
#define FORGING_STAGE_ACTIVE 1
#define FORGING_STAGE_COMPLETE 2

// Scrap slag
/// Rocks needed per ore/coal/salt to cook a batch of scrap slag in a furnace.
#define SCRAP_ROCKS_PER_FLUX 3
/// Furnaces need at least this many slots to cook scrap slag (3 rocks + 1 flux).
#define SCRAP_BATCH_SIZE 4
/// Export value of anything forged from scrap slag. Rocks are free, so this stays near worthless.
#define SCRAP_SELLPRICE 2
