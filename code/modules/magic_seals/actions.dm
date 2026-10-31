/** Base type for the two preset-management HUD actions. Hand seals themselves are keyboard-driven. */
/datum/action/magic_seal
	name = "Магия печатей"
	desc = "Действие системы магии печатей."
	button_icon_state = "default"

/datum/action/magic_seal/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	if(clicker != owner || !owner)
		return FALSE
	// In this older Paradise fork, stat == 0 means the mob is conscious.
	if(owner.stat)
		return FALSE

	var/datum/component/magic_seals/component = owner.GetComponent(/datum/component/magic_seals)
	if(!component)
		return FALSE
	return activate(component)

/datum/action/magic_seal/proc/activate(datum/component/magic_seals/component)
	return FALSE

/datum/action/magic_seal/save_preset
	name = "Сохранить заготовку"
	desc = "Сохраняет текущую последовательность под выбранным названием."

/datum/action/magic_seal/save_preset/activate(datum/component/magic_seals/component)
	return component.save_preset()

/datum/action/magic_seal/use_preset
	name = "Использовать заготовку"
	desc = "Быстро подготавливает заклинание из сохранённой последовательности."

/datum/action/magic_seal/use_preset/activate(datum/component/magic_seals/component)
	return component.use_preset()


/datum/action/magic_seal/show_sequence
	name = "Показать последовательность"
	desc = "Выводит текущую последовательность печатей, включая длинные комбинации."

/datum/action/magic_seal/show_sequence/activate(datum/component/magic_seals/component)
	return component.show_sequence()


/datum/action/magic_seal/check_energy
	name = "Показать запас энергии"
	desc = "Показывает текущий запас магической энергии."

/datum/action/magic_seal/check_energy/activate(datum/component/magic_seals/component)
	return component.show_energy()


/datum/action/magic_seal/concentrate
	name = "Концентрация энергии"
	desc = "В энергетической зоне ускоряет восстановление запаса. Требует оставаться на месте. Нажмите ещё раз, чтобы прекратить."

/datum/action/magic_seal/concentrate/activate(datum/component/magic_seals/component)
	return component.perform_magic_seal_action("energy_concentration")
