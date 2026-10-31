/**
 * Generic non-spell actions performed through the hand-seal system.
 *
 * Spell construction remains data-driven in recipes.dm. These actions are a
 * separate layer for contextual interactions such as energy concentration,
 * door manipulation, machinery interaction, etc.
 *
 * Action datums are stateless shared definitions. Per-character state belongs
 * in /datum/component/magic_seals, never in these global registry instances.
 */
/datum/magic_seal_action
	/// Stable ID used by component.perform_magic_seal_action().
	var/id
	/// Human-readable action name.
	var/name
	/// Seal associated with this action. A seal may have multiple actions.
	var/seal_id

/datum/magic_seal_action/proc/can_activate(datum/component/magic_seals/component)
	if(!component || !component.magic_user || component.magic_user.stat)
		return FALSE
	return TRUE

/// TRUE when this action is currently active for the supplied component.
/datum/magic_seal_action/proc/is_active(datum/component/magic_seals/component)
	return FALSE

/// Start or execute this action. Instant actions should return TRUE on success.
/datum/magic_seal_action/proc/activate(datum/component/magic_seals/component)
	return FALSE

/// Stop a running action. Instant actions can leave this unimplemented.
/datum/magic_seal_action/proc/deactivate(datum/component/magic_seals/component)
	return FALSE

/datum/magic_seal_action/energy_concentration
	id = "energy_concentration"
	name = "Концентрация энергии"
	seal_id = MAGIC_SEAL_A

/datum/magic_seal_action/energy_concentration/can_activate(datum/component/magic_seals/component)
	if(!..())
		return FALSE
	if(!component.is_in_magic_energy_zone())
		to_chat(component.magic_user, span_warning("Для концентрации необходимо находиться в энергетической зоне."))
		return FALSE
	if(component.magic_energy >= component.magic_energy_max)
		to_chat(component.magic_user, span_notice("Ваш запас магической энергии уже полон."))
		return FALSE
	return TRUE

/datum/magic_seal_action/energy_concentration/is_active(datum/component/magic_seals/component)
	return component && component.is_concentrating

/datum/magic_seal_action/energy_concentration/activate(datum/component/magic_seals/component)
	return component.start_concentration()

/datum/magic_seal_action/energy_concentration/deactivate(datum/component/magic_seals/component)
	return component.stop_concentration(TRUE, "Вы прекращаете концентрацию. Текущий запас: [component.magic_energy]/[component.magic_energy_max].")


/**
 * Temporarily opens a nearby ID-protected airlock for a character without access.
 * This does not change the airlock's access list or bolts; the normal door
 * autoclose and all mechanical safety checks remain in effect.
 */
/datum/magic_seal_action/door_unlock
	id = "door_unlock"
	name = "Магическое открытие шлюза"
	seal_id = MAGIC_SEAL_B

/datum/magic_seal_action/door_unlock/can_activate(datum/component/magic_seals/component)
	if(!..())
		return FALSE

	var/obj/machinery/door/airlock/target_door = find_target_airlock(component)
	if(target_door)
		return TRUE

	// Give contextual feedback instead of failing silently. This also confirms
	// that the B-hold input reached the universal-action registry.
	var/obj/machinery/door/airlock/nearest_door = find_nearest_closed_airlock(component)
	if(!nearest_door)
		to_chat(component.magic_user, span_notice("Печать B не находит поблизости закрытый воздушный шлюз."))
		return FALSE

	var/failure_reason = get_airlock_failure_reason(nearest_door, component.magic_user)
	if(failure_reason)
		to_chat(component.magic_user, span_notice("Печать B не может открыть [nearest_door]: [failure_reason]"))
	return FALSE

/datum/magic_seal_action/door_unlock/activate(datum/component/magic_seals/component)
	var/obj/machinery/door/airlock/target_door = find_target_airlock(component)
	if(!target_door || !component || !component.magic_user)
		return FALSE

	// Recheck the conditions immediately before spending energy.
	var/failure_reason = get_airlock_failure_reason(target_door, component.magic_user)
	if(failure_reason)
		to_chat(component.magic_user, span_warning("Магическое воздействие не удалось: [failure_reason]"))
		return FALSE
	if(!component.spend_magic_energy(MAGIC_SEAL_DOOR_ENERGY_COST, "магическое открытие шлюза"))
		return FALSE

	component.magic_user.visible_message(
		span_notice("[component.magic_user] направляет сложенные пальцы к [target_door], и замок шлюза щёлкает."),
		span_notice("Вы направляете печать B на [target_door]. Замок поддаётся магическому воздействию.")
	)

	// Use the regular airlock proc: it still enforces bolts, welding, power,
	// emag state and the open-door wire. Only the ID/access check is bypassed.
	INVOKE_ASYNC(target_door, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
	return TRUE

/// Find the nearest closed airlock which satisfies every magical opening condition.
/datum/magic_seal_action/door_unlock/proc/find_target_airlock(datum/component/magic_seals/component)
	if(!component || !component.magic_user)
		return null

	var/obj/machinery/door/airlock/best_target
	var/best_distance = MAGIC_SEAL_DOOR_RANGE + 1
	for(var/obj/machinery/door/airlock/door in range(MAGIC_SEAL_DOOR_RANGE, component.magic_user))
		if(get_airlock_failure_reason(door, component.magic_user))
			continue
		var/door_distance = get_dist(component.magic_user, door)
		if(door_distance < best_distance)
			best_target = door
			best_distance = door_distance
	return best_target

/// Find the nearest closed airlock even if it cannot currently be opened.
/// Used only to explain why a contextual seal action did not activate.
/datum/magic_seal_action/door_unlock/proc/find_nearest_closed_airlock(datum/component/magic_seals/component)
	if(!component || !component.magic_user)
		return null

	var/obj/machinery/door/airlock/best_target
	var/best_distance = MAGIC_SEAL_DOOR_RANGE + 1
	for(var/obj/machinery/door/airlock/door in range(MAGIC_SEAL_DOOR_RANGE, component.magic_user))
		if(!door.density)
			continue
		var/door_distance = get_dist(component.magic_user, door)
		if(door_distance < best_distance)
			best_target = door
			best_distance = door_distance
	return best_target

/// Return null when the door can be opened, otherwise a short reason for failure.
/datum/magic_seal_action/door_unlock/proc/get_airlock_failure_reason(obj/machinery/door/airlock/door, mob/living/user)
	if(!door || !user)
		return "цель недоступна"
	if(!door.density)
		return "шлюз уже открыт"
	if(door.operating)
		return "шлюз уже выполняет другое действие"
	if(door.welded)
		return "шлюз заварен"
	if(door.locked)
		return "физические болты шлюза опущены"
	if(door.emagged)
		return "электронные системы шлюза повреждены"
	if(!door.arePowerSystemsOn())
		return "у шлюза нет питания"
	if(!door.requiresID())
		return "ID-сканер шлюза отключён или не требуется"
	if(door.allowed(user))
		return "у вас уже есть доступ к этому шлюзу"
	if(!door.wires || door.wires.is_cut(WIRE_OPEN_DOOR))
		return "провод управления открытием повреждён"
	return null


/// Global action definition cache, keyed by stable action ID.
var/global/list/GLOB_MAGIC_SEAL_ACTION_REGISTRY
/// Secondary index: seal ID -> list of action definition datums.
var/global/list/GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY

/proc/build_magic_seal_action_registries()
	if(GLOB_MAGIC_SEAL_ACTION_REGISTRY && GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY)
		return
	GLOB_MAGIC_SEAL_ACTION_REGISTRY = list()
	GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY = list()
	for(var/action_type in subtypesof(/datum/magic_seal_action))
		var/datum/magic_seal_action/action = new action_type()
		if(!action.id)
			qdel(action)
			continue
		if(GLOB_MAGIC_SEAL_ACTION_REGISTRY[action.id])
			// Duplicate IDs are ignored rather than silently replacing a definition.
			qdel(action)
			continue
		GLOB_MAGIC_SEAL_ACTION_REGISTRY[action.id] = action
		if(action.seal_id)
			if(!GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY[action.seal_id])
				GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY[action.seal_id] = list()
			var/list/actions_for_seal = GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY[action.seal_id]
			actions_for_seal += action

/proc/get_magic_seal_action_registry()
	build_magic_seal_action_registries()
	return GLOB_MAGIC_SEAL_ACTION_REGISTRY

/proc/get_magic_seal_actions_by_seal_registry()
	build_magic_seal_action_registries()
	return GLOB_MAGIC_SEAL_ACTIONS_BY_SEAL_REGISTRY
