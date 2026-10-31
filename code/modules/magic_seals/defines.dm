// Stable identifiers for hand seals. Do not rename these when adding new recipes.
#define MAGIC_SEAL_A "A"
#define MAGIC_SEAL_B "B"
#define MAGIC_SEAL_C "C"
#define MAGIC_SEAL_D "D"
#define MAGIC_SEAL_E "E"

// Key-down signals emitted by Paradise's base keybinding implementation.
#define COMSIG_KB_MOB_MAGIC_SEALS_SEAL_A "keybinding_magic_seals_seal_a"
#define COMSIG_KB_MOB_MAGIC_SEALS_SEAL_B "keybinding_magic_seals_seal_b"
#define COMSIG_KB_MOB_MAGIC_SEALS_SEAL_C "keybinding_magic_seals_seal_c"
#define COMSIG_KB_MOB_MAGIC_SEALS_SEAL_D "keybinding_magic_seals_seal_d"
#define COMSIG_KB_MOB_MAGIC_SEALS_SEAL_E "keybinding_magic_seals_seal_e"

// Keybinding signals emitted by Paradise for the configured command presses.
#define COMSIG_KB_MOB_MAGIC_SEALS_FINISH "keybinding_magic_seals_finish"
#define COMSIG_KB_MOB_MAGIC_SEALS_CANCEL "keybinding_magic_seals_cancel"
#define COMSIG_KB_MOB_MAGIC_SEALS_CONCENTRATE "keybinding_magic_seals_concentrate"

// Personal magic energy reserve. Only mobs with the magic_seals component use it.
#define MAGIC_ENERGY_MAX 100
#define MAGIC_ENERGY_INITIAL 100

// Energy regeneration cadence and rates. One BYOND tick is 1/10 second.
#define MAGIC_ENERGY_REGEN_INTERVAL 10

// How many signs to include in each chat message when the whole sequence is requested.
#define MAGIC_SEAL_SEQUENCE_DISPLAY_CHUNK 30
#define MAGIC_ENERGY_ZONE_REGEN 1
#define MAGIC_ENERGY_CONCENTRATION_REGEN 5

// Duration in BYOND deciseconds before a seal hold invokes its contextual action.
#define MAGIC_SEAL_HOLD_THRESHOLD 4

// Ignore a trailing duplicate signal for the same seal immediately after a held press.
#define MAGIC_SEAL_RELEASE_DEBOUNCE 2

// Seal B: temporary access bypass for a nearby airlock.
#define MAGIC_SEAL_DOOR_RANGE 1
#define MAGIC_SEAL_DOOR_ENERGY_COST 10

// Compact magical glyphs displayed above the character.
#define MAGIC_SEAL_VISUAL_PIXEL_Y 24
// Short-tap glyph lifetime in BYOND deciseconds (12 = 1.2 seconds).
#define MAGIC_SEAL_VISUAL_TAP_DURATION 12
#define MAGIC_SEAL_GESTURE_OVERLAY_ID "magic_seal_hand_pose"
