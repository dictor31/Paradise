/**
 * Keyboard bindings for hand-seal magic.
 *
 * IMPORTANT: this SS1984 revision relies on keybind_signal in the base
 * /datum/keybinding implementation. Do not override down()/up() here: doing so
 * caused the runtime exception about an unredefined down() without a signal.
 */
/datum/keybinding/magic_seals
	category = "Magic Seals"

/datum/keybinding/magic_seals/can_use(client/user)
	if(!user || !user.mob)
		return FALSE
	var/datum/component/magic_seals/component = user.mob.GetComponent(/datum/component/magic_seals)
	return !!component

/datum/keybinding/magic_seals/seal_a
	name = "Печать A (короткое нажатие / удерживание)"
	classic_keys = list("CtrlZ")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_SEAL_A

/datum/keybinding/magic_seals/seal_b
	name = "Печать B (короткое нажатие / удерживание)"
	classic_keys = list("CtrlX")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_SEAL_B

/datum/keybinding/magic_seals/seal_c
	name = "Печать C (короткое нажатие / удерживание)"
	classic_keys = list("CtrlC")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_SEAL_C

/datum/keybinding/magic_seals/seal_d
	name = "Печать D (короткое нажатие / удерживание)"
	classic_keys = list("CtrlV")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_SEAL_D

/datum/keybinding/magic_seals/seal_e
	name = "Печать E (короткое нажатие / удерживание)"
	classic_keys = list("CtrlB")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_SEAL_E

/datum/keybinding/magic_seals/finish
	name = "Завершить комбинацию печатей"
	classic_keys = list("CtrlN")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_FINISH

/datum/keybinding/magic_seals/cancel
	name = "Отменить комбинацию печатей"
	classic_keys = list("CtrlM")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_CANCEL

/datum/keybinding/magic_seals/concentrate
	name = "Переключить концентрацию энергии (резервное действие)"
	classic_keys = list("CtrlG")
	keybind_signal = COMSIG_KB_MOB_MAGIC_SEALS_CONCENTRATE
