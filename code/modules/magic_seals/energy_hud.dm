/**
 * Compact personal magical-energy HUD indicator.
 * Each state represents a 10% fill step and has a subtle two-frame idle pulse.
 */
/atom/movable/screen/magic_energy_orb
	name = "Магическая энергия"
	desc = "Сфера показывает оставшийся запас магической энергии."
	icon = 'icons/effects/magic_energy_orb.dmi'
	icon_state = "energy_100"
	screen_loc = MAGIC_ENERGY_HUD_SCREEN_LOC
	layer = MAGIC_ENERGY_HUD_LAYER
	default_click = FALSE
	clear_with_screen = TRUE

	var/last_energy_level = -1

	proc/update_energy(current_energy, max_energy)
		var/new_level = 0
		if(isnum(current_energy) && isnum(max_energy) && max_energy > 0)
			var/percent = round((current_energy / max_energy) * 100)
			percent = max(0, min(100, percent))
			new_level = round(percent / 10) * 10

		if(new_level == last_energy_level)
			return FALSE

		last_energy_level = new_level
		icon_state = "energy_[new_level]"
		return TRUE
