/mob/living/simple_animal/hostile/retaliate/araneus
	name = "Сержант Аранеус"
	real_name = "Сержант Аранеус"
	voice_name = "неизвестный голос"
	desc = "Свирепый компаньон любого влиятельного лица, эта паучиха была тщательно обучена специалистами NanoTrasen. От пристального взгляда её глаз-бусинок у вас по спине бегают мурашки."
	faction = list("spiders")
	icon_state = "guard(old)"
	icon_living = "guard(old)"
	icon_dead = "guard_dead(old)"
	icon_gib = "guard_dead(old)"
	tts_seed = "Elder"
	turns_per_move = 8
	response_help = "pets"
	emote_hear = list("chitters")
	maxHealth = 250
	health = 250
	harm_intent_damage = 3
	melee_damage_lower = 15
	melee_damage_upper = 20
	unique_pet = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 2, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	gender = FEMALE

/mob/living/simple_animal/hostile/retaliate/araneus/a_intent_change(input as text)
	set name = "a-intent"
	set hidden = 1
	if(can_change_intents)
		switch(input)
			if(INTENT_HELP,INTENT_DISARM,INTENT_HARM)
				a_intent = input
			if("right")
				if(a_intent == INTENT_HELP)
					a_intent = INTENT_DISARM
				else if(a_intent == INTENT_DISARM)
					a_intent = INTENT_HARM
				else if(a_intent == INTENT_HARM)
					a_intent = INTENT_HELP
			if("left")
				if(a_intent == INTENT_HELP)
					a_intent = INTENT_HARM
				else if(a_intent == INTENT_DISARM)
					a_intent = INTENT_HELP
				else if(a_intent == INTENT_HARM)
					a_intent = INTENT_DISARM
		if(hud_used && hud_used.action_intent)
			hud_used.action_intent.icon_state = "[a_intent]"

/mob/living/simple_animal/hostile/retaliate/araneus/AttackingTarget()
	if(a_intent == INTENT_DISARM && isliving(target))
		var/mob/living/L = target
		playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE)
		L.apply_damage(25, STAMINA)
		src.do_attack_animation(target)
		target.visible_message("<span class='danger'>[src] выбивает [target] из равновесия!</span>", \
						"<span class='userdanger'>[src] пытается вас повалить!</span>")
		add_attack_logs(src, target, "Disarm")
	else
		..()
