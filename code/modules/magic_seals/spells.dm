/**
 * One-use version of Paradise's existing fireball action.
 * The projectile logic remains inherited from the base Paradise spell.
 */
/datum/action/cooldown/spell/pointed/projectile/fireball/magic_seals
	name = "Огненный шар"
	desc = "Одноразовый огненный шар, подготовленный последовательностью печатей."

/datum/action/cooldown/spell/pointed/projectile/fireball/magic_seals/after_cast(atom/cast_on)
	var/mob/living/caster = owner
	..()

	if(caster)
		var/datum/component/magic_seals/component = caster.GetComponent(/datum/component/magic_seals)
		if(component)
			component.prepared_spell_finished(src)

	qdel(src)
