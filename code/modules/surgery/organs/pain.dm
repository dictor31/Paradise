#define MIN_SHOCK_REDUCTION 50 //The minimum amount of shock reduction in reagents for absence of pain

/**
 * Whether or not a mob can feel pain.
 *
 * Returns TRUE if the mob can feel pain, FALSE otherwise
 */
/mob/proc/has_pain()
	if(stat)
		return FALSE

	return TRUE

/mob/living/carbon/has_pain()
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_PAIN))
		return FALSE

	if(shock_reduction() >= MIN_SHOCK_REDUCTION)
		return FALSE

	return TRUE

// partname is the name of a body part
// amount is a num from 1 to 100
/mob/living/carbon/proc/pain(partname, amount)
	if(!client?.prefs || reagents.has_reagent(/datum/reagent/medicine/sal_acid))
		return

	if(!has_pain())
		return

	if(!COOLDOWN_FINISHED(src, pain_cd))
		return

	var/msg
	switch(amount)
		if(1 to 10)
			msg = span_userdanger("<b>Вы чувствуете боль в [partname].</b>")

		if(11 to 90)
			msg = span_userdanger(span_bold(span_fontsize2("<b>Вы чувствуете сильную боль в [partname]!")))

		if(91 to INFINITY)
			msg = span_userdanger(span_bold(span_fontsize3("Ох чёрт! Вы чувствуете невыносимую боль в [partname]!")))

	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		if(client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB)
			pain_blurb(msg)
		else
			to_chat(src, msg)

	COOLDOWN_START(src, pain_cd, (client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB ? 30 SECONDS : 10 SECONDS) - amount)

// message is the custom message to be displayed
/mob/living/carbon/proc/custom_pain(message)
	if(!client?.prefs || !has_pain())
		return

	if(client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB && !COOLDOWN_FINISHED(src, pain_cd))
		return

	// Anti message spam checks
	if(!message || message == last_pain_message && !COOLDOWN_FINISHED(src, pain_cd))
		COOLDOWN_START(src, pain_cd, (client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB ? 30 SECONDS : 10 SECONDS))
		return

	last_pain_message = message
	if(client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB)
		pain_blurb(message)
	else
		to_chat(src, span_userdanger("[message]"))

	COOLDOWN_START(src, pain_cd, client.prefs.toggles3 & PREFTOGGLE_3_PAIN_BLURB ? 30 SECONDS : 10 SECONDS)

/mob/living/carbon/proc/is_hand_pain_blocked(hand_id)
	return FALSE

/// Sum the local pain values of every living, non-robotic external bodypart.
/mob/living/carbon/human/proc/get_total_pain()
	var/total_pain = 0
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.status & (ORGAN_DEAD|ORGAN_ROBOT))
			continue
		total_pain += bodypart.pain_level
	return total_pain

/// Maximum possible pain for the currently present pain-sensitive bodyparts.
/mob/living/carbon/human/proc/get_max_pain()
	var/painful_parts = 0
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.status & (ORGAN_DEAD|ORGAN_ROBOT))
			continue
		painful_parts++
	return painful_parts * 100

/// Return total pain as a percentage, so characters with different body configurations use the same thresholds.
/mob/living/carbon/human/proc/get_overall_pain()
	var/max_pain = get_max_pain()
	if(max_pain <= 0)
		return 0
	return clamp((get_total_pain() / max_pain) * 100, 0, 100)

/// Get the most severe pain affecting a body zone, including pain in its parent limb.
/mob/living/carbon/human/proc/get_limb_pain(zone)
	var/obj/item/organ/external/bodypart = get_organ(zone)
	if(!bodypart || (bodypart.status & (ORGAN_DEAD|ORGAN_ROBOT)))
		return 0

	. = bodypart.pain_level
	if(bodypart.parent && !(bodypart.parent.status & (ORGAN_DEAD|ORGAN_ROBOT)))
		. = max(., bodypart.parent.pain_level)

/// A hand at maximum local pain cannot perform hand-based actions until its pain subsides.
/mob/living/carbon/human/is_hand_pain_blocked(hand_id)
	if(!has_pain())
		return FALSE

	var/zone
	switch(hand_id)
		if(ITEM_SLOT_HAND_LEFT)
			zone = BODY_ZONE_PRECISE_L_HAND
		if(ITEM_SLOT_HAND_RIGHT)
			zone = BODY_ZONE_PRECISE_R_HAND
		else
			return FALSE

	return get_limb_pain(zone) >= 100

/// Process local pain recovery first, then update organism-wide and local effects.
/mob/living/carbon/human/proc/process_pain(seconds)
	if(stat == DEAD)
		return

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		bodypart.process_pain(seconds)

	var/overall_pain = get_overall_pain()
	handle_pain()
	handle_local_pain_effects(overall_pain)
	handle_global_pain_effects(overall_pain)
	handle_pain_cardiac_risk(overall_pain, seconds)

/// Apply limits to individual limbs without changing their physical usability state.
/mob/living/carbon/human/proc/handle_local_pain_effects(overall_pain)
	if(!has_pain())
		remove_movespeed_modifier(/datum/movespeed_modifier/pain_slowdown)
		return

	if(is_hand_pain_blocked(ITEM_SLOT_HAND_LEFT) && l_hand)
		to_chat(src, span_warning("Вы не можете удержать предмет из-за сильной боли в левой руке!"))
		drop_item_ground(l_hand, force = TRUE)

	if(is_hand_pain_blocked(ITEM_SLOT_HAND_RIGHT) && r_hand)
		to_chat(src, span_warning("Вы не можете удержать предмет из-за сильной боли в правой руке!"))
		drop_item_ground(r_hand, force = TRUE)

	var/overall_slowdown = 0
	switch(overall_pain)
		if(25 to 39)
			overall_slowdown = 0.1
		if(40 to 59)
			overall_slowdown = 0.25
		if(60 to 79)
			overall_slowdown = 0.45
		if(80 to INFINITY)
			overall_slowdown = 0.65

	var/left_leg_pain = max(get_limb_pain(BODY_ZONE_L_LEG), get_limb_pain(BODY_ZONE_PRECISE_L_FOOT))
	var/right_leg_pain = max(get_limb_pain(BODY_ZONE_R_LEG), get_limb_pain(BODY_ZONE_PRECISE_R_FOOT))
	var/local_leg_slowdown = ((left_leg_pain + right_leg_pain) / 200) * 0.5
	var/final_slowdown = max(overall_slowdown, local_leg_slowdown)

	if(final_slowdown > 0)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/pain_slowdown, multiplicative_slowdown = final_slowdown)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/pain_slowdown)

/// Handle symptoms caused by the combined pain level.
/mob/living/carbon/human/proc/handle_global_pain_effects(overall_pain)
	if(!has_pain() || overall_pain < 1)
		return

	if(COOLDOWN_FINISHED(src, pain_emote_cooldown))
		var/emote_chance = clamp(overall_pain, 10, 65)
		if(prob(emote_chance))
			emote(overall_pain >= 50 ? "scream" : "moan")
		COOLDOWN_START(src, pain_emote_cooldown, 15 SECONDS)

	if(overall_pain >= 10 && COOLDOWN_FINISHED(src, pain_blur_cooldown))
		var/blur_chance = clamp(overall_pain * 0.5, 5, 40)
		if(prob(blur_chance))
			SetEyeBlurry(2 SECONDS)
		COOLDOWN_START(src, pain_blur_cooldown, 8 SECONDS)

	if(overall_pain >= 60 && body_position != LYING_DOWN && !buckled && has_gravity() && COOLDOWN_FINISHED(src, pain_fall_cooldown))
		var/fall_chance = clamp((overall_pain - 55) * 0.7, 3, 35)
		if(prob(fall_chance))
			Knockdown(3 SECONDS)
			to_chat(src, span_userdanger("Боль становится невыносимой, и вы падаете на пол!"))
		COOLDOWN_START(src, pain_fall_cooldown, 12 SECONDS)

/// Prolonged, maximum overall pain can trigger the existing critical heart-failure condition.
/mob/living/carbon/human/proc/handle_pain_cardiac_risk(overall_pain, seconds)
	var/pain_suppressed = HAS_TRAIT(src, TRAIT_NO_PAIN) || shock_reduction() >= MIN_SHOCK_REDUCTION || reagents.has_reagent(/datum/reagent/medicine/sal_acid)
	if(overall_pain < 100 || pain_suppressed)
		pain_overload = max(0, pain_overload - (max(seconds, 0) * 2))
		return

	pain_overload = min(pain_overload + max(seconds, 0), 120)
	if(pain_overload < 30 || !COOLDOWN_FINISHED(src, pain_cardiac_cooldown))
		return

	var/obj/item/organ/internal/heart/heart = get_int_organ(/obj/item/organ/internal/heart)
	if(!heart || heart.is_dead() || locate(/datum/disease/critical/heart_failure) in diseases)
		return

	var/failure_chance = clamp(round(pain_overload - 25), 1, 25)
	if(prob(failure_chance))
		var/datum/disease/critical/heart_failure/failure = new
		failure.Contract(src)

	COOLDOWN_START(src, pain_cardiac_cooldown, 10 SECONDS)

/mob/living/carbon/human/proc/handle_pain()
	if(!has_pain())
		return

	var/max_pain = 0
	var/obj/item/organ/external/damaged_organ = null
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if((bodypart.status & (ORGAN_DEAD|ORGAN_ROBOT)) || bodypart.hidden_pain)
			continue

		if(bodypart.pain_level > max_pain)
			damaged_organ = bodypart
			max_pain = bodypart.pain_level

	if(damaged_organ)
		pain(damaged_organ.declent_ru_base(PREPOSITIONAL), max_pain)

	// Internal organ injuries retain their existing one-off pain messages.
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ.hidden_pain)
			continue

		if(organ.damage < 2 || !prob(2))
			continue

		var/obj/item/organ/external/parent = get_organ(organ.parent_organ_zone)
		if(parent)
			custom_pain("Вы чувствуете острую боль в [parent.declent_ru(PREPOSITIONAL)].")

#undef MIN_SHOCK_REDUCTION
