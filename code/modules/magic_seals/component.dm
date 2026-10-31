/**
 * Stores the current hand-seal sequence, recipe presets, and prepared spell
 * for one mob. This component is opt-in: it must only be added to the mob
 * types that are supposed to have access to this magic system.
 */
// Compatibility helper for Paradise forks without the QDELETED() macro.
// gc_destroyed is accessed dynamically so this file can compile on older revisions.
/proc/magic_seals_datum_is_deleted(datum/target)
	if(!target)
		return TRUE
	if(target:gc_destroyed)
		return TRUE
	return FALSE

/datum/component/magic_seals

	var/mob/living/magic_user
	var/list/current_sequence
	/// TRUE after the current chain stops matching every known spell-recipe prefix.
	var/sequence_prefix_lost = FALSE
	/// Associative list: preset name -> copied list of seal IDs.
	var/list/presets
	var/list/magic_actions
	/// Seal currently being monitored for a contextual hold action.
	var/pressed_seal_id
	/// Token invalidates the held-key monitor after key release or component cleanup.
	var/pressed_seal_token = 0
	/// TRUE once a contextual hold action has started for the current key press.
	var/held_action_triggered = FALSE
	/// Last seal consumed as a long press, used to ignore a trailing duplicate input signal.
	var/last_held_seal_id
	/// world.time when the last long press ended.
	var/last_held_seal_time = 0
	/// Shared, stateless definition of the action currently being held.
	var/datum/magic_seal_action/active_held_action
	var/datum/action/cooldown/spell/prepared_spell
	/// Current amount of personal magical energy. External sources can change this through adjust_magic_energy().
	var/magic_energy = MAGIC_ENERGY_INITIAL
	/// Maximum amount of personal magical energy.
	var/magic_energy_max = MAGIC_ENERGY_MAX
	/// TRUE while the user is actively concentrating to accelerate regeneration.
	var/is_concentrating = FALSE
	/// Turf where concentration began; movement interrupts concentration.
	var/turf/concentration_start_turf
	/// Previous tick's zone status, used to avoid spamming entry messages.
	var/was_in_magic_energy_zone = FALSE
	/// Stops the spawned regeneration loop when the component is removed.
	var/energy_processing_stopped = FALSE
	/// TRUE while a held seal gesture overlay is attached to the mob.
	var/magic_seal_gesture_overlay_active = FALSE

/datum/component/magic_seals/Initialize()
	// Older Paradise forks do not define COMPONENT_INCOMPATIBLE.
	// This component is intended to be attached only to /mob/living types.
	if(!istype(parent, /mob/living))
		return

	magic_user = parent
	current_sequence = list()
	presets = list()
	magic_actions = list()
	magic_energy_max = MAGIC_ENERGY_MAX
	magic_energy = MAGIC_ENERGY_INITIAL

/datum/component/magic_seals/RegisterWithParent()
	if(!magic_user)
		return

	// All keyboard bindings use the signal-based path supported by this SS1984 revision.
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_SEAL_A, PROC_REF(on_keybind_seal_a))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_SEAL_B, PROC_REF(on_keybind_seal_b))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_SEAL_C, PROC_REF(on_keybind_seal_c))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_SEAL_D, PROC_REF(on_keybind_seal_d))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_SEAL_E, PROC_REF(on_keybind_seal_e))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_FINISH, PROC_REF(on_keybind_finish))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_CANCEL, PROC_REF(on_keybind_cancel))
	RegisterSignal(magic_user, COMSIG_KB_MOB_MAGIC_SEALS_CONCENTRATE, PROC_REF(on_keybind_concentrate))

	// Individual seals and sequence controls are registered as dedicated keybindings.
	// Only preset management remains as HUD actions for this prototype.
	var/list/action_types = list(
		/datum/action/magic_seal/save_preset,
		/datum/action/magic_seal/use_preset,
		/datum/action/magic_seal/show_sequence,
		/datum/action/magic_seal/check_energy,
		/datum/action/magic_seal/concentrate,
	)

	for(var/action_type in action_types)
		var/datum/action/magic_seal/action = new action_type(magic_user)
		action.Grant(magic_user)
		magic_actions += action

	to_chat(magic_user, span_notice("Магия печатей: Ctrl+Z/X/C/V/B добавляют печати A–E. Быстрое нажатие добавляет знак. Удержание Ctrl+Z в энергетической зоне запускает концентрацию; удержание Ctrl+X рядом с закрытым шлюзом без вашего ID-доступа временно открывает его за [MAGIC_SEAL_DOOR_ENERGY_COST] энергии. Ctrl+N — завершить комбинацию; Ctrl+M — отменить."))
	to_chat(magic_user, span_notice("Запас магической энергии: [magic_energy]/[magic_energy_max]. Ctrl+G и кнопка HUD пока оставлены как резервный переключатель концентрации."))
	spawn(0)
		process_magic_energy_regeneration()

/datum/component/magic_seals/UnregisterFromParent()
	energy_processing_stopped = TRUE
	stop_concentration(FALSE)
	remove_magic_seal_gesture_visual()
	pressed_seal_token++
	pressed_seal_id = null
	if(active_held_action)
		active_held_action.deactivate(src)
	active_held_action = null
	held_action_triggered = FALSE
	if(magic_user)
		UnregisterSignal(magic_user, list(
			COMSIG_KB_MOB_MAGIC_SEALS_SEAL_A,
			COMSIG_KB_MOB_MAGIC_SEALS_SEAL_B,
			COMSIG_KB_MOB_MAGIC_SEALS_SEAL_C,
			COMSIG_KB_MOB_MAGIC_SEALS_SEAL_D,
			COMSIG_KB_MOB_MAGIC_SEALS_SEAL_E,
			COMSIG_KB_MOB_MAGIC_SEALS_FINISH,
			COMSIG_KB_MOB_MAGIC_SEALS_CANCEL,
			COMSIG_KB_MOB_MAGIC_SEALS_CONCENTRATE,
		))
	if(prepared_spell && !magic_seals_datum_is_deleted(prepared_spell))
		qdel(prepared_spell)
	prepared_spell = null

	for(var/datum/action/action as anything in magic_actions)
		if(action && !magic_seals_datum_is_deleted(action))
			qdel(action)
	if(magic_actions)
		magic_actions.Cut()

/**
 * All bindings in this fork dispatch through keybind_signal. The signal payload
 * begins with the mob (not client), followed by the target turf and mouse coords.
 * For A-E we start a short input monitor that checks client.key_combos_held; we do
 * not override keybinding down()/up(), because this fork requires keybind_signal.
 */
/datum/component/magic_seals/proc/on_keybind_seal_a(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		begin_seal_input(MAGIC_SEAL_A, "Z", "CtrlZ")

/datum/component/magic_seals/proc/on_keybind_seal_b(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		begin_seal_input(MAGIC_SEAL_B, "X", "CtrlX")

/datum/component/magic_seals/proc/on_keybind_seal_c(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		begin_seal_input(MAGIC_SEAL_C, "C", "CtrlC")

/datum/component/magic_seals/proc/on_keybind_seal_d(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		begin_seal_input(MAGIC_SEAL_D, "V", "CtrlV")

/datum/component/magic_seals/proc/on_keybind_seal_e(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		begin_seal_input(MAGIC_SEAL_E, "B", "CtrlB")

/datum/component/magic_seals/proc/on_keybind_finish(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		handle_keybinding_action("finish")

/datum/component/magic_seals/proc/on_keybind_cancel(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		handle_keybinding_action("cancel")

/datum/component/magic_seals/proc/on_keybind_concentrate(mob/source, turf/target, mousepos_x, mousepos_y)
	if(source == magic_user)
		handle_keybinding_action("concentrate")

/**
 * Handles the remaining signal-based command bindings.
 */
/datum/component/magic_seals/proc/handle_keybinding_action(action_id)
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE
	if(!magic_user.client || magic_user.client.mob != magic_user)
		return FALSE
	if(magic_user.stat)
		to_chat(magic_user, span_warning("Вы не можете складывать печати в таком состоянии."))
		return TRUE

	switch(action_id)
		if("concentrate")
			perform_magic_seal_action("energy_concentration")
		if("finish")
			finish_sequence()
		if("cancel")
			cancel_sequence()
		else
			return FALSE
	return TRUE

/**
 * Begin a seal press after receiving Paradise's normal keybind signal.
 * Seals without contextual actions are appended immediately (the normal fast path).
 * If a seal has a hold action, its press is monitored via client.key_combos_held.
 */
/datum/component/magic_seals/proc/begin_seal_input(seal_id, key_name, key_combo)
	if(!magic_user || magic_seals_datum_is_deleted(magic_user) || magic_seals_datum_is_deleted(src))
		return FALSE
	if(!magic_user.client || magic_user.client.mob != magic_user || magic_user.stat)
		return FALSE

	// Ignore a trailing duplicate signal for the same seal immediately after a hold.
	if(last_held_seal_id == seal_id && world.time - last_held_seal_time <= MAGIC_SEAL_RELEASE_DEBOUNCE)
		return FALSE

	var/list/actions_for_seal = get_actions_for_seal(seal_id)
	if(!length(actions_for_seal))
		return add_seal(seal_id)

	if(pressed_seal_id)
		return FALSE
	pressed_seal_id = seal_id
	held_action_triggered = FALSE
	active_held_action = null
	pressed_seal_token++
	var/current_press_token = pressed_seal_token
	spawn(0)
		monitor_seal_key_hold(seal_id, key_name, key_combo, current_press_token)
	return TRUE

/**
 * Detect key release from the client's own held-key buffer. This keeps keybindings
 * on the proven keybind_signal path and avoids custom keybinding up() overrides.
 * SS1984 documents key_combos_held as key -> combo (e.g. "Z" -> "CtrlZ").
 */
/datum/component/magic_seals/proc/is_magic_seal_combo_held(key_name, key_combo)
	if(!magic_user || !magic_user.client)
		return FALSE
	var/client/input_client = magic_user.client
	if(!input_client.key_combos_held)
		return FALSE
	return input_client.key_combos_held[key_name] == key_combo

/datum/component/magic_seals/proc/monitor_seal_key_hold(seal_id, key_name, key_combo, press_token)
	var/press_start_time = world.time
	var/hold_action_checked = FALSE
	// Let the client's input handler finish updating key_combos_held after the keybind signal.
	sleep(1)
	while(TRUE)
		if(magic_seals_datum_is_deleted(src) || pressed_seal_token != press_token || pressed_seal_id != seal_id)
			return
		if(!magic_user || magic_seals_datum_is_deleted(magic_user) || !magic_user.client || magic_user.client.mob != magic_user)
			remove_magic_seal_gesture_visual()
			if(held_action_triggered && active_held_action)
				active_held_action.deactivate(src)
			active_held_action = null
			held_action_triggered = FALSE
			pressed_seal_id = null
			pressed_seal_token++
			return

		if(!is_magic_seal_combo_held(key_name, key_combo))
			// Classify the input by duration, not only by whether the contextual
			// action successfully activated. This prevents a completed hold from
			// falling through as a short tap when the action deactivates itself or
			// cannot activate in the current context.
			var/was_long_press = hold_action_checked || (world.time - press_start_time >= MAGIC_SEAL_HOLD_THRESHOLD)
			if(was_long_press)
				last_held_seal_id = seal_id
				last_held_seal_time = world.time
			remove_magic_seal_gesture_visual()
			if(held_action_triggered)
				if(active_held_action)
					active_held_action.deactivate(src)
			else if(!was_long_press)
				add_seal(seal_id)
			active_held_action = null
			held_action_triggered = FALSE
			pressed_seal_id = null
			pressed_seal_token++
			return

		if(!hold_action_checked && world.time - press_start_time >= MAGIC_SEAL_HOLD_THRESHOLD)
			hold_action_checked = TRUE
			var/list/actions_for_seal = get_actions_for_seal(seal_id)
			for(var/datum/magic_seal_action/action as anything in actions_for_seal)
				if(action.is_active(src))
					active_held_action = action
					held_action_triggered = TRUE
					break
				if(action.can_activate(src) && action.activate(src))
					active_held_action = action
					held_action_triggered = TRUE
					break
			// The hand pose is shown even if the contextual action cannot run here:
			// the character is still physically making the sign.
			show_magic_seal_gesture_visual(seal_id, TRUE)
		sleep(1)

/**
 * Show the hand-position pictogram above the magic user.
 * Tap gestures are short-lived; contextual hold actions keep the pose visible
 * until the key is released or the component/action is stopped.
 */
/datum/component/magic_seals/proc/show_magic_seal_gesture_visual(seal_id, persistent = FALSE)
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE

	var/icon_state_name
	switch(seal_id)
		if(MAGIC_SEAL_A)
			icon_state_name = "seal_a"
		if(MAGIC_SEAL_B)
			icon_state_name = "seal_b"
		if(MAGIC_SEAL_C)
			icon_state_name = "seal_c"
		if(MAGIC_SEAL_D)
			icon_state_name = "seal_d"
		if(MAGIC_SEAL_E)
			icon_state_name = "seal_e"
		else
			return FALSE

	if(!persistent)
		// A short tap uses BYOND's flick overlay path. It plays the dedicated
		// one-shot *_tap DMI state and is removed by flick_overlay_view itself.
		// Do not put tap glyphs into the persistent-overlay registry: that path
		// snapshots/removes overlays and can suppress the short animation.
		var/mutable_appearance/tap_gesture = mutable_appearance('icons/effects/magic_seals.dmi', "[icon_state_name]_tap")
		tap_gesture.pixel_y = MAGIC_SEAL_VISUAL_PIXEL_Y
		tap_gesture.layer = ABOVE_MOB_LAYER
		magic_user.flick_overlay_view(tap_gesture, MAGIC_SEAL_VISUAL_TAP_DURATION)
		return TRUE

	// A held gesture uses the original looping state as a named persistent overlay.
	var/mutable_appearance/held_gesture = mutable_appearance('icons/effects/magic_seals.dmi', icon_state_name)
	held_gesture.pixel_y = MAGIC_SEAL_VISUAL_PIXEL_Y
	held_gesture.layer = ABOVE_MOB_LAYER
	remove_magic_seal_gesture_visual()
	magic_user.add_persistent_overlay(held_gesture, MAGIC_SEAL_GESTURE_OVERLAY_ID)
	magic_seal_gesture_overlay_active = TRUE
	return TRUE

/datum/component/magic_seals/proc/remove_magic_seal_gesture_visual()
	if(magic_seal_gesture_overlay_active && magic_user && !magic_seals_datum_is_deleted(magic_user))
		magic_user.remove_persistent_overlay(MAGIC_SEAL_GESTURE_OVERLAY_ID)
	magic_seal_gesture_overlay_active = FALSE
	return TRUE

/// Add one seal to an unbounded sequence. The full sequence is printed only on request.
/datum/component/magic_seals/proc/add_seal(seal_id)
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE

	current_sequence += seal_id
	show_magic_seal_gesture_visual(seal_id, FALSE)
	var/seal_name = get_magic_seal_display_name(seal_id)
	var/gesture_description = get_magic_seal_gesture_description(seal_id)
	magic_user.visible_message(
		span_notice("[magic_user] [gesture_description]."),
		span_notice("Вы складываете печать [seal_name].")
	)
	to_chat(magic_user, span_notice("В последовательность добавлена печать [seal_name]. Длина последовательности: [length(current_sequence)]. Используйте «Показать последовательность», чтобы увидеть её целиком."))

	if(!sequence_prefix_lost && !has_known_recipe_prefix(current_sequence))
		sequence_prefix_lost = TRUE
		to_chat(magic_user, span_notice("Это больше не начало известного рецепта. Вы можете продолжить эксперимент или отменить последовательность."))
	return TRUE

/datum/component/magic_seals/proc/show_sequence()
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE
	if(!length(current_sequence))
		to_chat(magic_user, span_notice("Последовательность печатей пуста."))
		return TRUE
	var/list/chunk = list()
	var/chunk_size = 0
	var/chunk_index = 1
	to_chat(magic_user, span_notice("Текущая последовательность: [length(current_sequence)] печатей."))
	for(var/entry in current_sequence)
		chunk += get_magic_seal_display_name(entry)
		chunk_size++
		if(chunk_size >= MAGIC_SEAL_SEQUENCE_DISPLAY_CHUNK)
			to_chat(magic_user, span_notice("Часть [chunk_index]: [jointext(chunk, " → ")]"))
			chunk.Cut()
			chunk_size = 0
			chunk_index++
	if(length(chunk))
		to_chat(magic_user, span_notice("Часть [chunk_index]: [jointext(chunk, " → ")]"))
	return TRUE

/// Confirm the sequence. An unknown sequence is retained so the player can keep experimenting.
/datum/component/magic_seals/proc/finish_sequence()
	if(!length(current_sequence))
		to_chat(magic_user, span_warning("Сначала сложите хотя бы одну печать."))
		return FALSE

	var/datum/magic_seal_recipe/recipe = find_matching_recipe(current_sequence)
	if(!recipe)
		to_chat(magic_user, span_warning("Эта комбинация не соответствует известному заклинанию. Последовательность оставлена — можно добавить печати и попробовать снова."))
		return FALSE

	if(!prepare_recipe(recipe))
		return FALSE

	current_sequence.Cut()
	sequence_prefix_lost = FALSE
	return TRUE

/datum/component/magic_seals/proc/cancel_sequence()
	current_sequence.Cut()
	sequence_prefix_lost = FALSE
	to_chat(magic_user, span_notice("Вы отменили комбинацию печатей."))
	return TRUE

/datum/component/magic_seals/proc/save_preset()
	if(!length(current_sequence))
		to_chat(magic_user, span_warning("Нечего сохранять: сначала сложите несколько печатей."))
		return FALSE

	var/preset_name = input(magic_user, "Введите название заготовки.", "Сохранить заготовку") as null|text
	if(isnull(preset_name) || !length(preset_name) || magic_seals_datum_is_deleted(src) || !magic_user)
		return FALSE

	presets[preset_name] = current_sequence.Copy()
	to_chat(magic_user, span_notice("Заготовка «[preset_name]» сохранена."))
	return TRUE

/datum/component/magic_seals/proc/use_preset()
	if(!length(presets))
		to_chat(magic_user, span_warning("У вас пока нет сохранённых заготовок."))
		return FALSE

	var/list/preset_names = list()
	for(var/preset_name in presets)
		preset_names += preset_name

	var/selected_name = input(magic_user, "Какую заготовку подготовить?", "Заготовки") as null|anything in preset_names
	if(isnull(selected_name) || magic_seals_datum_is_deleted(src) || !magic_user)
		return FALSE
	return prepare_preset(selected_name)

/datum/component/magic_seals/proc/prepare_preset(preset_name)
	var/list/preset_sequence = presets[preset_name]
	if(!length(preset_sequence))
		to_chat(magic_user, span_warning("Эта заготовка пуста или больше недоступна."))
		return FALSE

	var/datum/magic_seal_recipe/recipe = find_matching_recipe(preset_sequence)
	if(!recipe)
		to_chat(magic_user, span_warning("Заготовка «[preset_name]» пока не соответствует известному рецепту."))
		return FALSE

	if(!prepare_recipe(recipe))
		return FALSE
	current_sequence.Cut()
	sequence_prefix_lost = FALSE
	return TRUE

/datum/component/magic_seals/proc/prepare_recipe(datum/magic_seal_recipe/recipe)
	if(!recipe || !magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE
	if(!ispath(recipe.spell_type, /datum/action/cooldown/spell))
		to_chat(magic_user, span_warning("Ошибка настройки рецепта «[recipe.name]»: тип заклинания задан неверно."))
		return FALSE

	// Check the cost before changing the currently prepared spell.
	if(!can_pay_magic_energy(recipe.energy_cost, TRUE))
		return FALSE

	var/spell_path = recipe.spell_type
	var/datum/action/cooldown/spell/new_spell = new spell_path(magic_user)
	new_spell.Grant(magic_user)

	// Energy is currently spent when the spell is formed/prepared. This gives us
	// a stable, explicit cost point without depending on spell-targeting internals.
	if(!spend_magic_energy(recipe.energy_cost, "подготовку заклинания «[recipe.name]»"))
		qdel(new_spell)
		return FALSE

	if(prepared_spell && !magic_seals_datum_is_deleted(prepared_spell))
		qdel(prepared_spell)
	prepared_spell = new_spell

	to_chat(magic_user, span_notice("Вы сложили печати и подготовили заклинание «[recipe.name]». Нажмите его новую кнопку, затем выберите цель."))
	return TRUE

/**
 * Resolve an atom's containing turf by following loc links.
 * This avoids relying on get_turf(), which is not defined in some older SS1984 revisions.
 */
/datum/component/magic_seals/proc/magic_seals_resolve_turf(atom/thing)
	var/atom/current_location = thing
	while(current_location && !isturf(current_location))
		current_location = current_location.loc
	return current_location

/**
 * Resolve an atom's containing area by following loc links.
 * This avoids relying on get_area(), which is not defined in some older SS1984 revisions.
 */
/datum/component/magic_seals/proc/magic_seals_resolve_area(atom/thing)
	var/atom/current_location = thing
	while(current_location && !istype(current_location, /area))
		current_location = current_location.loc
	return current_location

/**
 * Returns TRUE when the mob is inside an area configured as a magic energy zone.
 * The area flag is intentionally independent from area names, so renaming an area
 * does not silently change its gameplay behaviour.
 */
/datum/component/magic_seals/proc/is_in_magic_energy_zone()
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE
	var/area/current_area = magic_seals_resolve_area(magic_user)
	if(!current_area)
		return FALSE
	return current_area.magic_energy_zone

/// Backwards-compatible wrapper. All ordinary seal actions go through the action registry.
/datum/component/magic_seals/proc/toggle_concentration()
	return perform_magic_seal_action("energy_concentration")

/**
 * Run a registered non-spell action. Spell recipes remain in recipes.dm and are
 * only checked by finish_sequence(); contextual actions are independent.
 */
/datum/component/magic_seals/proc/perform_magic_seal_action(action_id)
	if(!magic_user || magic_seals_datum_is_deleted(magic_user) || magic_seals_datum_is_deleted(src))
		return FALSE
	var/list/action_registry = get_magic_seal_action_registry()
	var/datum/magic_seal_action/action = action_registry[action_id]
	if(!action)
		to_chat(magic_user, span_warning("Неизвестное магическое действие: [action_id]."))
		return FALSE
	if(action.is_active(src))
		return action.deactivate(src)
	if(!action.can_activate(src))
		return FALSE
	return action.activate(src)

/**
 * Return every ordinary action associated with a particular seal. Held input uses
 * these definitions to select the first action valid in the current context.
 */
/datum/component/magic_seals/proc/get_actions_for_seal(seal_id)
	var/list/actions_by_seal = get_magic_seal_actions_by_seal_registry()
	var/list/actions = actions_by_seal[seal_id]
	if(!actions)
		return list()
	return actions

/datum/component/magic_seals/proc/start_concentration()
	if(!magic_user || magic_seals_datum_is_deleted(magic_user) || magic_seals_datum_is_deleted(src))
		return FALSE
	if(magic_user.stat || !is_in_magic_energy_zone() || magic_energy >= magic_energy_max)
		return FALSE
	if(is_concentrating)
		return TRUE
	is_concentrating = TRUE
	concentration_start_turf = magic_seals_resolve_turf(magic_user)
	magic_user.visible_message(
		span_notice("[magic_user] замирает и концентрируется, поглощая магическую энергию."),
		span_notice("Вы концентрируетесь и поглощаете магическую энергию. Повторите действие, чтобы остановиться; движение также прервёт концентрацию.")
	)
	return TRUE

/// Stop concentration. `message_text` is optional so cleanup can stop silently.
/datum/component/magic_seals/proc/stop_concentration(show_message = TRUE, message_text = null)
	if(!is_concentrating)
		return FALSE
	is_concentrating = FALSE
	concentration_start_turf = null
	remove_magic_seal_gesture_visual()
	if(show_message && message_text && magic_user && !magic_seals_datum_is_deleted(magic_user))
		to_chat(magic_user, span_notice(message_text))
	return TRUE

/// Slow passive regeneration in a zone; concentration replaces it with a faster rate.
/datum/component/magic_seals/proc/process_magic_energy_regeneration()
	while(!energy_processing_stopped && !magic_seals_datum_is_deleted(src))
		sleep(MAGIC_ENERGY_REGEN_INTERVAL)
		if(energy_processing_stopped || magic_seals_datum_is_deleted(src))
			return
		if(!magic_user || magic_seals_datum_is_deleted(magic_user))
			return

		var/in_energy_zone = is_in_magic_energy_zone()
		if(in_energy_zone != was_in_magic_energy_zone)
			was_in_magic_energy_zone = in_energy_zone
			if(in_energy_zone)
				to_chat(magic_user, span_notice("Вы ощущаете магическую энергию в окружающем пространстве. Ваш запас медленно восстанавливается."))
			else if(is_concentrating)
				stop_concentration(TRUE, "Концентрация прервана: вы покинули энергетическую зону.")

		if(!in_energy_zone)
			continue

		if(is_concentrating && magic_seals_resolve_turf(magic_user) != concentration_start_turf)
			stop_concentration(TRUE, "Концентрация прервана: вы сдвинулись с места.")

		if(magic_energy >= magic_energy_max)
			if(is_concentrating)
				stop_concentration(TRUE, "Ваш запас магической энергии полностью восстановлен: [magic_energy]/[magic_energy_max].")
			continue

		var/regen_amount = is_concentrating ? MAGIC_ENERGY_CONCENTRATION_REGEN : MAGIC_ENERGY_ZONE_REGEN
		var/old_energy = magic_energy
		adjust_magic_energy(regen_amount, FALSE)
		if(old_energy < magic_energy_max && magic_energy >= magic_energy_max)
			if(is_concentrating)
				stop_concentration(TRUE, "Ваш запас магической энергии полностью восстановлен: [magic_energy]/[magic_energy_max].")
			else
				to_chat(magic_user, span_notice("Ваш запас магической энергии полностью восстановлен: [magic_energy]/[magic_energy_max]."))

/// Check whether the component has enough energy for a cost.
/datum/component/magic_seals/proc/can_pay_magic_energy(amount, show_warning = TRUE)
	if(amount <= 0)
		return TRUE
	if(magic_energy >= amount)
		return TRUE
	if(show_warning && magic_user && !magic_seals_datum_is_deleted(magic_user))
		to_chat(magic_user, span_warning("Недостаточно магической энергии. Требуется [amount], у вас [magic_energy]/[magic_energy_max]."))
	return FALSE

/// Spend energy for a spell preparation. Returns FALSE if the reserve is insufficient.
/datum/component/magic_seals/proc/spend_magic_energy(amount, reason = "использование магии")
	if(amount <= 0)
		return TRUE
	if(!can_pay_magic_energy(amount, TRUE))
		return FALSE
	magic_energy = max(0, magic_energy - amount)
	if(magic_user && !magic_seals_datum_is_deleted(magic_user))
		to_chat(magic_user, span_notice("Магическая энергия потрачена на [reason]: [amount]. Остаток: [magic_energy]/[magic_energy_max]."))
	return TRUE

/**
 * Change the stored energy amount. Positive values add energy; negative values drain it.
 * show_message defaults to FALSE so fields/generators can update the reserve without chat spam.
 * Returns the actual amount changed after clamping to 0..magic_energy_max.
 */
/datum/component/magic_seals/proc/adjust_magic_energy(amount, show_message = FALSE)
	if(!isnum(amount))
		return 0
	var/old_energy = magic_energy
	magic_energy = max(0, min(magic_energy_max, magic_energy + amount))
	var/actual_change = magic_energy - old_energy
	if(show_message && actual_change && magic_user && !magic_seals_datum_is_deleted(magic_user))
		if(actual_change > 0)
			to_chat(magic_user, span_notice("Вы поглощаете [actual_change] единиц магической энергии. Запас: [magic_energy]/[magic_energy_max]."))
		else
			to_chat(magic_user, span_warning("Вы теряете [abs(actual_change)] единиц магической энергии. Запас: [magic_energy]/[magic_energy_max]."))
	return actual_change

/datum/component/magic_seals/proc/show_energy()
	if(!magic_user || magic_seals_datum_is_deleted(magic_user))
		return FALSE
	var/energy_percent = 0
	if(magic_energy_max > 0)
		energy_percent = round((magic_energy / magic_energy_max) * 100)
	to_chat(magic_user, span_notice("Магическая энергия: [magic_energy]/[magic_energy_max] ([energy_percent]%)."))
	return TRUE

/datum/component/magic_seals/proc/prepared_spell_finished(datum/action/cooldown/spell/finished_spell)
	if(prepared_spell != finished_spell)
		return
	prepared_spell = null
	if(magic_user && !magic_seals_datum_is_deleted(magic_user))
		to_chat(magic_user, span_notice("Подготовленное заклинание использовано."))

/datum/component/magic_seals/proc/find_matching_recipe(list/sequence)
	var/list/recipes = get_magic_seal_recipe_registry()
	for(var/recipe_id in recipes)
		var/datum/magic_seal_recipe/recipe = recipes[recipe_id]
		if(magic_seal_sequences_equal(sequence, recipe.seal_sequence))
			return recipe
	return null

/datum/component/magic_seals/proc/has_known_recipe_prefix(list/sequence)
	var/list/recipes = get_magic_seal_recipe_registry()
	for(var/recipe_id in recipes)
		var/datum/magic_seal_recipe/recipe = recipes[recipe_id]
		if(magic_seal_sequence_is_prefix(sequence, recipe.seal_sequence))
			return TRUE
	return FALSE

/proc/magic_seal_sequences_equal(list/first, list/second)
	if(length(first) != length(second))
		return FALSE
	return magic_seal_sequence_is_prefix(first, second)

/proc/magic_seal_sequence_is_prefix(list/prefix, list/full_sequence)
	if(!length(prefix) || length(prefix) > length(full_sequence))
		return FALSE
	for(var/index in 1 to length(prefix))
		if(prefix[index] != full_sequence[index])
			return FALSE
	return TRUE

/proc/get_magic_seal_gesture_description(seal_id)
	switch(seal_id)
		if(MAGIC_SEAL_A)
			return "сводит кончики большого и указательного пальцев"
		if(MAGIC_SEAL_B)
			return "скрещивает указательный и средний пальцы"
		if(MAGIC_SEAL_C)
			return "прижимает ладони друг к другу"
		if(MAGIC_SEAL_D)
			return "переплетает пальцы обеих рук"
		if(MAGIC_SEAL_E)
			return "соединяет кончики больших пальцев, образуя треугольник"
	return "складывает пальцы в неизвестный знак"

/proc/get_magic_seal_display_name(seal_id)
	switch(seal_id)
		if(MAGIC_SEAL_A)
			return "A"
		if(MAGIC_SEAL_B)
			return "B"
		if(MAGIC_SEAL_C)
			return "C"
		if(MAGIC_SEAL_D)
			return "D"
		if(MAGIC_SEAL_E)
			return "E"
	return "?"
