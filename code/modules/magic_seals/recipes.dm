/**
 * Data-only recipe definitions for the hand-seal magic system.
 * Add new spell recipes as subtypes of /datum/magic_seal_recipe.
 */
/datum/magic_seal_recipe
	/// Stable internal identifier. Do not use the display name as the ID.
	var/id
	/// Name shown to the player when this recipe succeeds.
	var/name
	/// Ordered list of seal IDs required by this recipe.
	var/list/seal_sequence
	/// Action type granted when the recipe is prepared.
	var/spell_type
	/// Energy required to form/prepare this spell. It is spent when the recipe succeeds.
	var/energy_cost = 0

/datum/magic_seal_recipe/fireball
	id = "fireball"
	name = "Огненный шар"
	seal_sequence = list(MAGIC_SEAL_A, MAGIC_SEAL_C, MAGIC_SEAL_B, MAGIC_SEAL_E, MAGIC_SEAL_D)
	spell_type = /datum/action/cooldown/spell/pointed/projectile/fireball/magic_seals
	energy_cost = 25

/// Global cache, built lazily so recipe datums are not recreated for every comparison.
var/global/list/GLOB_MAGIC_SEAL_RECIPE_CACHE

/proc/get_magic_seal_recipe_registry()
	if(!GLOB_MAGIC_SEAL_RECIPE_CACHE)
		GLOB_MAGIC_SEAL_RECIPE_CACHE = list()
		for(var/recipe_type in subtypesof(/datum/magic_seal_recipe))
			var/datum/magic_seal_recipe/recipe = new recipe_type()
			if(recipe.id)
				GLOB_MAGIC_SEAL_RECIPE_CACHE[recipe.id] = recipe
	return GLOB_MAGIC_SEAL_RECIPE_CACHE
