// ---------------------------------------------------------------------------
// Physical attributes for dolls using the Magic Seals system.
// These values are intentionally isolated from /mob/living itself.
// ---------------------------------------------------------------------------

#define DOLL_ATTRIBUTE_STRENGTH "strength"
#define DOLL_ATTRIBUTE_AGILITY "agility"
#define DOLL_ATTRIBUTE_ENDURANCE "endurance"
#define DOLL_ATTRIBUTE_MIN 0
#define DOLL_ATTRIBUTE_MAX 100
#define DOLL_ATTRIBUTE_DEFAULT 50

/**
 * Stores a doll's physical attributes and temporary bonuses.
 *
 * This first implementation is a data layer only: it does not modify combat,
 * movement or stamina yet. Those integrations will be added independently
 * after the attribute ranges and balance are tested.
 */
/datum/component/doll_attributes
	var/mob/living/attribute_owner
	var/list/base_attributes
	/// modifier id -> associative list of attribute id -> bonus
	var/list/attribute_modifiers
	/// modifier id -> token; invalidates an older temporary modifier timer
	var/list/modifier_tokens

/datum/component/doll_attributes/Initialize(initial_strength = DOLL_ATTRIBUTE_DEFAULT, initial_agility = DOLL_ATTRIBUTE_DEFAULT, initial_endurance = DOLL_ATTRIBUTE_DEFAULT)
	if(!istype(parent, /mob/living))
		return

	attribute_owner = parent
	base_attributes = list(
		DOLL_ATTRIBUTE_STRENGTH = clamp(round(initial_strength), DOLL_ATTRIBUTE_MIN, DOLL_ATTRIBUTE_MAX),
		DOLL_ATTRIBUTE_AGILITY = clamp(round(initial_agility), DOLL_ATTRIBUTE_MIN, DOLL_ATTRIBUTE_MAX),
		DOLL_ATTRIBUTE_ENDURANCE = clamp(round(initial_endurance), DOLL_ATTRIBUTE_MIN, DOLL_ATTRIBUTE_MAX),
	)
	attribute_modifiers = list()
	modifier_tokens = list()

/datum/component/doll_attributes/Destroy()
	attribute_owner = null
	base_attributes = null
	attribute_modifiers = null
	modifier_tokens = null
	return ..()

/// Returns the base value without temporary or permanent bonuses.
/datum/component/doll_attributes/proc/get_base_attribute(attribute_id)
	if(!base_attributes || (attribute_id != DOLL_ATTRIBUTE_STRENGTH && attribute_id != DOLL_ATTRIBUTE_AGILITY && attribute_id != DOLL_ATTRIBUTE_ENDURANCE))
		return null
	return base_attributes[attribute_id]

/// Returns the effective value after all modifiers, clamped to 0..100.
/datum/component/doll_attributes/proc/get_attribute(attribute_id)
	var/value = get_base_attribute(attribute_id)
	if(!isnum(value))
		return null

	if(attribute_modifiers)
		for(var/modifier_id in attribute_modifiers)
			var/list/modifier = attribute_modifiers[modifier_id]
			if(!modifier)
				continue
			var/bonus = modifier[attribute_id]
			if(isnum(bonus))
				value += bonus

	return clamp(round(value), DOLL_ATTRIBUTE_MIN, DOLL_ATTRIBUTE_MAX)

/// Sets one doll's base attribute. Values outside 0..100 are clamped.
/datum/component/doll_attributes/proc/set_base_attribute(attribute_id, new_value)
	if(!base_attributes || (attribute_id != DOLL_ATTRIBUTE_STRENGTH && attribute_id != DOLL_ATTRIBUTE_AGILITY && attribute_id != DOLL_ATTRIBUTE_ENDURANCE) || !isnum(new_value))
		return FALSE
	base_attributes[attribute_id] = clamp(round(new_value), DOLL_ATTRIBUTE_MIN, DOLL_ATTRIBUTE_MAX)
	return TRUE

/// Sets all three base attributes at once; useful for per-doll initialization.
/datum/component/doll_attributes/proc/set_base_attributes(new_strength, new_agility, new_endurance)
	if(!set_base_attribute(DOLL_ATTRIBUTE_STRENGTH, new_strength))
		return FALSE
	if(!set_base_attribute(DOLL_ATTRIBUTE_AGILITY, new_agility))
		return FALSE
	if(!set_base_attribute(DOLL_ATTRIBUTE_ENDURANCE, new_endurance))
		return FALSE
	return TRUE

/**
 * Creates or replaces a named modifier. Reusing an id updates that modifier
 * instead of stacking duplicates, which is important for toggle/refresh buffs.
 */
/datum/component/doll_attributes/proc/set_attribute_modifier(modifier_id, strength_bonus = 0, agility_bonus = 0, endurance_bonus = 0)
	if(!modifier_id || !attribute_modifiers)
		return FALSE
	if(!isnum(strength_bonus) || !isnum(agility_bonus) || !isnum(endurance_bonus))
		return FALSE

	attribute_modifiers[modifier_id] = list(
		DOLL_ATTRIBUTE_STRENGTH = strength_bonus,
		DOLL_ATTRIBUTE_AGILITY = agility_bonus,
		DOLL_ATTRIBUTE_ENDURANCE = endurance_bonus,
	)
	return TRUE

/// Adds or refreshes a modifier that expires after duration deciseconds.
/datum/component/doll_attributes/proc/add_temporary_attribute_modifier(modifier_id, strength_bonus = 0, agility_bonus = 0, endurance_bonus = 0, duration = 0)
	if(!set_attribute_modifier(modifier_id, strength_bonus, agility_bonus, endurance_bonus))
		return FALSE
	if(!isnum(duration) || duration <= 0)
		return TRUE

	var/current_token = modifier_tokens[modifier_id]
	if(!isnum(current_token))
		current_token = 0
	current_token++
	modifier_tokens[modifier_id] = current_token
	var/timer_token = current_token

	spawn(duration)
		if(magic_seals_datum_is_deleted(src))
			return
		if(modifier_tokens[modifier_id] == timer_token)
			remove_attribute_modifier(modifier_id)
	return TRUE

/// Removes a modifier and invalidates any pending expiration timer for it.
/datum/component/doll_attributes/proc/remove_attribute_modifier(modifier_id)
	if(!attribute_modifiers || isnull(attribute_modifiers[modifier_id]))
		return FALSE
	attribute_modifiers -= modifier_id
	var/current_token = modifier_tokens[modifier_id]
	if(!isnum(current_token))
		current_token = 0
	modifier_tokens[modifier_id] = current_token + 1
	return TRUE

/// Removes all modifiers without changing the doll's base values.
/datum/component/doll_attributes/proc/clear_attribute_modifiers()
	if(attribute_modifiers)
		attribute_modifiers.Cut()
	if(modifier_tokens)
		modifier_tokens.Cut()
	return TRUE

/datum/component/doll_attributes/proc/get_attribute_name(attribute_id)
	switch(attribute_id)
		if(DOLL_ATTRIBUTE_STRENGTH)
			return "Сила"
		if(DOLL_ATTRIBUTE_AGILITY)
			return "Ловкость"
		if(DOLL_ATTRIBUTE_ENDURANCE)
			return "Выносливость"
	return "Неизвестная характеристика"

/// Prints base and effective values, making the component easy to test in-game.
/datum/component/doll_attributes/proc/show_attributes()
	if(!attribute_owner || magic_seals_datum_is_deleted(attribute_owner))
		return FALSE

	var/strength_base = get_base_attribute(DOLL_ATTRIBUTE_STRENGTH)
	var/agility_base = get_base_attribute(DOLL_ATTRIBUTE_AGILITY)
	var/endurance_base = get_base_attribute(DOLL_ATTRIBUTE_ENDURANCE)
	var/strength_value = get_attribute(DOLL_ATTRIBUTE_STRENGTH)
	var/agility_value = get_attribute(DOLL_ATTRIBUTE_AGILITY)
	var/endurance_value = get_attribute(DOLL_ATTRIBUTE_ENDURANCE)

	to_chat(attribute_owner, span_notice("<b>Физические характеристики</b>"))
	to_chat(attribute_owner, span_notice("Сила: [strength_value]/100 (основа: [strength_base])"))
	to_chat(attribute_owner, span_notice("Ловкость: [agility_value]/100 (основа: [agility_base])"))
	to_chat(attribute_owner, span_notice("Выносливость: [endurance_value]/100 (основа: [endurance_base])"))
	return TRUE

/**
 * Convenience getter for ability code. Non-doll mobs without this component
 * receive the neutral default and are not given a component automatically.
 */
/proc/get_doll_attribute(mob/living/user, attribute_id)
	if(!user)
		return DOLL_ATTRIBUTE_DEFAULT
	var/datum/component/doll_attributes/attributes = user.GetComponent(/datum/component/doll_attributes)
	if(!attributes)
		return DOLL_ATTRIBUTE_DEFAULT
	var/value = attributes.get_attribute(attribute_id)
	if(!isnum(value))
		return DOLL_ATTRIBUTE_DEFAULT
	return value

/// HUD action for inspecting the current physical attributes of this doll.
/datum/action/magic_seal/show_attributes
	name = "Показать характеристики"
	desc = "Показывает силу, ловкость и выносливость куклы."

/datum/action/magic_seal/show_attributes/activate(datum/component/magic_seals/component)
	if(!component || !component.magic_user)
		return FALSE
	var/datum/component/doll_attributes/attributes = component.magic_user.GetComponent(/datum/component/doll_attributes)
	if(!attributes)
		return FALSE
	return attributes.show_attributes()

#undef DOLL_ATTRIBUTE_STRENGTH
#undef DOLL_ATTRIBUTE_AGILITY
#undef DOLL_ATTRIBUTE_ENDURANCE
#undef DOLL_ATTRIBUTE_MIN
#undef DOLL_ATTRIBUTE_MAX
#undef DOLL_ATTRIBUTE_DEFAULT
