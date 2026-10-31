/**
 * Magic-energy support is a flag on an area, not a replacement area hierarchy.
 * Prefer setting magic_energy_zone = TRUE on an existing map area so its
 * inherited station/department properties are preserved.
 *
 * /area/magic_energy remains available for new dedicated map areas, but it is
 * intentionally a plain /area subtype and does not inherit station-area setup.
 */
/area
	var/magic_energy_zone = FALSE

/area/magic_energy
	name = "Зона магической энергии"
	magic_energy_zone = TRUE
