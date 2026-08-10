// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define SIGH 0
#define ANNOYED 1
#define DELIGHT 2

/mob/living/simple_animal/bot/mulebot
	name = "MULEbot"
	desc = "Многофункциональный Узкоспециализированный Легкомоторный робот. Нет, это не просто случайные слова, подобранные для красивого написания. Честно."
	icon_state = "mulebot0"
	move_resist = MOVE_FORCE_STRONG
	animate_movement = FORWARD_STEPS
	health = 50
	maxHealth = 50
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	a_intent = INTENT_HARM //No swapping
	buckle_lying = 0
	can_buckle_to = FALSE
	mob_size = MOB_SIZE_LARGE
	buckle_prevents_pull = TRUE // No pulling loaded shit
	radio_channel = SUP_FREQ_NAME

	bot_type = MULE_BOT
	bot_filter = RADIO_MULEBOT
	model = "MULE"
	bot_purpose = "доставлять ящики и другие посылки получателям"
	bot_core_type = /obj/machinery/bot_core/mulebot
	path_image_color = "#7F5200"

	suffix = ""

	/// Delay in deciseconds between each step
	var/step_delay = 2 SECONDS
	/// world.time of next move
	var/next_move_time = 0

	var/static/mulebot_count = 0
	var/atom/movable/load = null
	var/mob/living/passenger = null
	/// This is turf to navigate to (location of beacon).
	var/turf/target
	/// This the direction to unload onto/load from.
	var/loaddir = 0
	/// Tag of home beacon.
	var/home_destination = ""

	/// `TRUE` if already reached the target.
	var/reached_target = TRUE

	/// `TRUE` if auto return to home beacon after unload.
	var/auto_return = TRUE
	/// `TRUE` if auto-pickup at beacon.
	var/auto_pickup = TRUE
	/// `TRUE` if bot will announce an arrival to a location.
	var/report_delivery = TRUE

	var/obj/item/stock_parts/cell/cell
	var/datum/wires/mulebot/wires = null
	var/bloodiness = 0
	var/currentBloodColor = BLOOD_COLOR_RED
	var/currentDNA = null

/mob/living/simple_animal/bot/mulebot/get_ru_names()
	return alist(
		NOMINATIVE = "МУЛбот",
		GENITIVE = "МУЛбота",
		DATIVE = "МУЛботу",
		ACCUSATIVE = "МУЛбота",
		INSTRUMENTAL = "МУЛботом",
		PREPOSITIONAL = "МУЛботе",
	)

/mob/living/simple_animal/bot/mulebot/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/mulebot(src)
	var/datum/job/supply/cargo_tech/J = new/datum/job/supply/cargo_tech
	access_card.access = J.get_access()
	prev_access = access_card.access
	cell = new /obj/item/stock_parts/cell/upgraded(src)

	mulebot_count++
	set_suffix(suffix ? suffix : "#[mulebot_count]")
	RegisterSignal(src, COMSIG_ATOM_ENTERING, PROC_REF(on_entering))

/mob/living/simple_animal/bot/mulebot/Destroy()
	SStgui.close_uis(wires)
	unload(0)
	QDEL_NULL(wires)
	QDEL_NULL(cell)
	passenger = null
	target = null
	return ..()

/mob/living/simple_animal/bot/mulebot/get_cell()
	return cell

/mob/living/simple_animal/bot/mulebot/proc/set_suffix(_suffix)
	suffix = _suffix
	if(paicard)
		bot_name = "MULEbot ([suffix])"
	else
		name = "MULEbot ([suffix])"

/mob/living/simple_animal/bot/mulebot/bot_reset()
	..()
	reached_target = FALSE

/mob/living/simple_animal/bot/mulebot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		var/atom/cached_load = load
		. = ..()
		if(!ATTACK_CHAIN_CANCEL_CHECK(.) && knock_off(1 + I.force * 2))
			user.visible_message(
				span_danger("[user] столкнул [cached_load] с [declent_ru(GENITIVE)]!"),
				span_danger("Вы столкнули [cached_load] с [declent_ru(GENITIVE)]!"),
			)
		return .

	if(iscell(I))
		add_fingerprint(user)
		if(!open)
			balloon_alert(user, "техпанель закрыта!")
			return ATTACK_CHAIN_PROCEED
		if(cell)
			balloon_alert(user, "слот батареи занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		visible_message(span_notice("[user] вставил батарею в [declent_ru(GENITIVE)]."))
		balloon_alert(user, "вы вставили батарею внутрь")
		update_controls()
		return ATTACK_CHAIN_BLOCKED_ALL

	var/atom/cached_load = load
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.) && knock_off(1 + I.force * 2))
		user.visible_message(
			span_danger("[user] столкнул [cached_load] с [declent_ru(GENITIVE)]!"),
			span_danger("Вы столкнули [cached_load] с [declent_ru(GENITIVE)]!"),
		)

/// Chance to knock off the rider
/mob/living/simple_animal/bot/mulebot/proc/knock_off(probability)
	if(!ismob(load) || !prob(probability))
		return FALSE
	unload(NONE)
	return TRUE

/mob/living/simple_animal/bot/mulebot/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return .

	if(open)
		on = FALSE
	update_controls()
	update_icon()

/mob/living/simple_animal/bot/mulebot/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(health >= maxHealth)
		add_fingerprint(user)
		balloon_alert(user, "ремонт не требуется")
		return .
	user.visible_message(
		span_notice("[user] ремонтиру[PLUR_ET_YUT(user)] [declent_ru(GENITIVE)]."),
		span_notice("Вы ремонтируете [declent_ru(GENITIVE)].")
	)
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || health >= maxHealth)
		return .
	heal_damage_type(25, BRUTE)

/mob/living/simple_animal/bot/mulebot/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		balloon_alert(user, "техпанель закрыта!")
		return .
	if(!cell)
		add_fingerprint(user)
		balloon_alert(user, "слот для батареи пуст!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	visible_message(span_notice("[user] вынул батарею из [declent_ru(GENITIVE)]."))
	balloon_alert(user, "батарея извлечена")
	cell.add_fingerprint(user)
	cell.forceMove(drop_location())
	cell = null

/mob/living/simple_animal/bot/mulebot/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		balloon_alert(user, "техпанель закрыта!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	attack_hand(user)

/mob/living/simple_animal/bot/mulebot/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!open)
		add_fingerprint(user)
		balloon_alert(user, "техпанель закрыта!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	attack_hand(user)

/mob/living/simple_animal/bot/mulebot/emag_act(mob/user)
	if(emagged < 1)
		emagged = 1
	if(!open)
		locked = !locked
		balloon_alert(user, "техпанель [locked ? "заблокирована" : "разблокирована"]")
	flick("mulebot-emagged", src)
	playsound(loc, 'sound/effects/sparks1.ogg', 100, FALSE)

/mob/living/simple_animal/bot/mulebot/update_icon_state()
	if(open)
		icon_state="mulebot-hatch"
	else
		icon_state = "mulebot[wires.is_cut(WIRE_MOB_AVOIDANCE)]"

/mob/living/simple_animal/bot/mulebot/update_overlays()
	. = ..()
	if(load && !ismob(load))//buckling handles the mob offsets
		var/image/load_overlay = image(icon = load.icon, icon_state = load.icon_state)
		load_overlay.pixel_z = initial(load.pixel_y) + 9
		if(load.layer < layer)
			load_overlay.layer = layer + 0.1
		load_overlay.overlays = load.overlays
		. += load_overlay

/mob/living/simple_animal/bot/mulebot/ex_act(severity, target)
	unload(0)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			wires.cut_random()
			wires.cut_random()
		if(EXPLODE_LIGHT)
			wires.cut_random()

/mob/living/simple_animal/bot/mulebot/bullet_act(obj/projectile/Proj)
	if(..())
		if(prob(50) && !isnull(load))
			unload(0)
		if(prob(25))
			visible_message(span_danger("Что-то замыкается внутри [declent_ru(GENITIVE)]!"))
			wires.cut_random()

/mob/living/simple_animal/bot/mulebot/proc/toggle_lock(mob/user)
	if(bot_core.allowed(user))
		locked = !locked
		update_controls()
		return TRUE
	else
		balloon_alert(user, "отказано в доступе!")
		return FALSE

/mob/living/simple_animal/bot/mulebot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "BotMule", name)
		ui.open()

// TODO: remove this; PDAs currently depend on it
/mob/living/simple_animal/bot/mulebot/show_controls(mob/user)
	ui_interact(user)

/mob/living/simple_animal/bot/mulebot/ui_data(mob/user)
	var/list/data = list()

	data["on"] = on
	data["locked"] = locked
	data["noaccess"] = topic_denied(user)

	data["open"] = open
	data["ai"] = issilicon(user)

	data["suffix"] = suffix

	data["mode"] = mode
	data["mode_name"] = mode_name

	data["load"] = load ? load.name : ""
	data["destination"] = destination || ""

	data["charge"] = cell ? cell.percent() : 0

	data["auto_return"] = auto_return
	data["auto_pickup"] = auto_pickup
	data["report_delivery"] = report_delivery

	data["cell"] = !!cell

	data["canhack"] = canhack(user)
	data["emagged"] = emagged

	data["painame"] = paicard ? paicard.pai.name : null

	return data

/mob/living/simple_animal/bot/mulebot/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	var/mob/user = usr

	switch(action)

		if("power")
			if(topic_denied(user))
				return TRUE

			on = !on
			update_icon()
			return TRUE

		if("stop")
			if(topic_denied(user))
				return TRUE

			// СЮДА переносится существующая логика op=stop
			return TRUE

		if("go")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика op=go
			return TRUE

		if("home")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика op=home
			return TRUE

		if("destination")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика задания destination
			return TRUE

		if("setid")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика задания ID
			return TRUE

		if("sethome")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика задания home
			return TRUE

		if("autoret")
			if(topic_denied(user))
				return TRUE

			auto_return = !auto_return
			return TRUE

		if("autopick")
			if(topic_denied(user))
				return TRUE

			auto_pickup = !auto_pickup
			return TRUE

		if("report")
			if(topic_denied(user))
				return TRUE

			report_delivery = !report_delivery
			return TRUE

		if("unload")
			if(topic_denied(user))
				return TRUE

			// СЮДА существующая логика op=unload
			return TRUE

		if("cellremove")
			if(!issilicon(user))
				// здесь переносится существующая проверка
				return TRUE

			// существующая логика снятия батареи
			return TRUE

		if("cellinsert")
			if(!issilicon(user))
				// здесь переносится существующая проверка
				return TRUE

			// существующая логика установки батареи
			return TRUE

		if("wires")
			if(!open || issilicon(user))
				return TRUE

			wires.Interact(user)
			return TRUE

	return FALSE

// returns true if the bot has power
/mob/living/simple_animal/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && !wires.is_cut(WIRE_MAIN_POWER1) && !wires.is_cut(WIRE_MAIN_POWER2)

/mob/living/simple_animal/bot/mulebot/proc/buzz(type)
	switch(type)
		if(SIGH)
			audible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] разочарованно гудит.")
			playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		if(ANNOYED)
			audible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] раздражённо жужжит.")
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, FALSE)
		if(DELIGHT)
			audible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] восторженно звенит!")
			playsound(loc, 'sound/machines/ping.ogg', 50, FALSE)

// mousedrop a crate to load the bot
// can load anything if hacked
/mob/living/simple_animal/bot/mulebot/mouse_drop_receive(atom/movable/AM, mob/user, params)
	if(!istype(AM) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !in_range(user, src))
		return

	load(AM)

// called to load a crate
/mob/living/simple_animal/bot/mulebot/proc/load(atom/movable/AM)
	if(!on || load || AM.anchored || get_dist(src, AM) > 1)
		return

	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!isitem(AM) && !ismachinery(AM) && !isstructure(AM) && !ismob(AM))
		return
	if(!isturf(AM.loc)) //To prevent the loading from stuff from someone's inventory or screen icons.
		return

	var/obj/structure/closet/crate/CRATE
	if(is_crate(AM))
		CRATE = AM
	else
		if(!wires.is_cut(WIRE_LOADCHECK) && !hijacked)
			buzz(SIGH)
			return	// if not hacked, only allow crates to be loaded

	if(CRATE) // if it's a crate, close before loading
		CRATE.close()

	if(isobj(AM))
		var/obj/O = AM
		if(O.has_buckled_mobs() || (locate(/mob) in AM)) //can't load non crates objects with mobs buckled to it or inside it.
			buzz(SIGH)
			return

	if(isliving(AM))
		if(!load_mob(AM))
			return
	else
		AM.forceMove(src)

	load = AM
	mode = BOT_IDLE
	update_icon(UPDATE_OVERLAYS)

/mob/living/simple_animal/bot/mulebot/proc/load_mob(mob/living/M)
	can_buckle = TRUE
	if(buckle_mob(M, check_loc = FALSE))
		passenger = M
		load = M
		can_buckle = FALSE
		return TRUE
	return FALSE

/mob/living/simple_animal/bot/mulebot/post_buckle_mob(mob/living/target)
	add_offsets(UID(), y_add = 9)
	if(target.layer < layer)
		target.layer = layer + 0.01

/mob/living/simple_animal/bot/mulebot/post_unbuckle_mob(mob/living/target)
	load = null
	target.layer = initial(target.layer)
	remove_offsets(UID())

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/mob/living/simple_animal/bot/mulebot/proc/unload(dirn)
	if(!load)
		return

	mode = BOT_IDLE

	unbuckle_all_mobs(force = TRUE)

	if(load)
		if(!ismob(load))	// already unbuckled otherwise
			load.forceMove(loc)
		if(dirn)
			var/turf/newT = get_step(load.loc, dirn)
			if(newT.CanPass(load, get_dir(newT, src))) //Can't get off onto anything that wouldn't let you pass normally
				step(load, dirn)
		load = null

	update_icon(UPDATE_OVERLAYS)

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/thing as anything in src)
		if(thing == cell || thing == access_card || thing == Radio || thing == paicard || thing == bot_core || ispulsedemon(thing))
			continue
		thing.forceMove(loc)

/mob/living/simple_animal/bot/mulebot/call_bot()
	..()
	var/area/dest_area
	if(path && length(path))
		target = ai_waypoint //Target is the end point of the path, the waypoint set by the AI.
		dest_area = get_area(target)
		destination = format_text(dest_area.name)
		pathset = TRUE //Indicates the AI's custom path is initialized.
		start()

/mob/living/simple_animal/bot/mulebot/handle_automated_action()
	diag_hud_set_botmode()

	if(!has_power())
		on = FALSE
		return
	if(!on)
		return

	// 2 / 1.5 / 1 seconds, depending on how many wires we have cut
	step_delay = initial(step_delay) - wires.is_cut(WIRE_MOTOR1) * 0.5 SECONDS - wires.is_cut(WIRE_MOTOR2) * 0.5 SECONDS
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSfastprocess, src)

/mob/living/simple_animal/bot/mulebot/process()
	if(!on)
		return PROCESS_KILL

	switch(mode)
		if(BOT_IDLE) // idle
			return

		if(BOT_DELIVER, BOT_GO_HOME, BOT_BLOCKED) // navigating to deliver,home, or blocked
			if(world.time < next_move_time)
				return

			next_move_time = world.time + step_delay

			if(loc == target) // reached target
				at_target()
				return

			else if(length(path) && target) // valid path
				var/turf/next = path[1]
				reached_target = FALSE
				if(next == loc)
					increment_path()
					path -= next
					return
				if(isturf(next))
					var/oldloc = loc
					var/moved = step_towards(src, next) // attempt to move
					if(moved && oldloc!=loc) // successful move
						blockcount = 0
						increment_path()
						path -= loc
						if(destination == home_destination)
							mode = BOT_GO_HOME
						else
							mode = BOT_DELIVER

					else // failed to move

						blockcount++
						mode = BOT_BLOCKED
						if(blockcount == 3)
							buzz(ANNOYED)

						if(blockcount > 10) // attempt 10 times before recomputing
							// find new path excluding blocked turf
							buzz(SIGH)
							mode = BOT_WAIT_FOR_NAV
							blockcount = 0
							addtimer(CALLBACK(src, PROC_REF(process_blocked), next), 2 SECONDS)
							return
						return
				else
					buzz(ANNOYED)
					mode = BOT_NAV
					return
			else
				mode = BOT_NAV
				return

		if(BOT_NAV) // calculate new path
			mode = BOT_WAIT_FOR_NAV
			INVOKE_ASYNC(src, PROC_REF(process_nav))

/mob/living/simple_animal/bot/mulebot/proc/process_blocked(turf/next)
	calc_path(avoid = next)
	if(length(path))
		buzz(DELIGHT)
	mode = BOT_BLOCKED

/mob/living/simple_animal/bot/mulebot/proc/process_nav()
	calc_path()

	if(length(path))
		blockcount = 0
		mode = BOT_BLOCKED
		buzz(DELIGHT)
	else
		buzz(SIGH)
		mode = BOT_NO_ROUTE

/**
 * calculates a path to the current destination, given an optional turf to avoid.
 */
/mob/living/simple_animal/bot/mulebot/calc_path(turf/avoid)
	check_bot_access()
	set_path(get_path_to(src, target, max_distance = 250, access = access_card.GetAccess(), exclude = avoid, diagonal_handling = DIAGONAL_REMOVE_ALL))

/**
 * Sets the current destination. Signals all beacons matching the delivery code.
 * Beacons will return a signal giving their locations.
 */
/mob/living/simple_animal/bot/mulebot/proc/set_destination(new_dest)
	new_destination = new_dest
	get_nav()

/**
 * Starts bot moving to current destination.
 */
/mob/living/simple_animal/bot/mulebot/proc/start()
	if(!on)
		return
	if(destination == home_destination)
		mode = BOT_GO_HOME
	else
		mode = BOT_DELIVER
	update_icon()
	get_nav()

/**
 * Starts bot moving to home. Sends a beacon query to find.
 */
/mob/living/simple_animal/bot/mulebot/proc/start_home()
	if(!on)
		return
	INVOKE_ASYNC(src, PROC_REF(do_start_home))

/mob/living/simple_animal/bot/mulebot/proc/do_start_home()
	set_destination(home_destination)
	mode = BOT_BLOCKED
	update_icon()

/**
 * Called when bot reaches current target.
 */
/mob/living/simple_animal/bot/mulebot/proc/at_target()
	if(!reached_target)
		radio_channel = SUP_FREQ_NAME //Supply channel
		audible_message("[DECLENT_RU_CAP(src, NOMINATIVE)] громко звенит!")
		playsound(loc, 'sound/machines/chime.ogg', 50, FALSE)
		reached_target = 1

		if(pathset) //The AI called us here, so notify it of our arrival.
			loaddir = dir //The MULE will attempt to load a crate in whatever direction the MULE is "facing".
			if(calling_ai)
				to_chat(calling_ai, span_notice("[get_examine_icon(calling_ai)] [DECLENT_RU_CAP(src, NOMINATIVE)] удалённо проигрывает звук звонка!"))
				playsound(calling_ai, 'sound/machines/chime.ogg',40, FALSE)
				calling_ai = null
				radio_channel = AI_FREQ_NAME //Report on AI Private instead if the AI is controlling us.

		if(load)		// if loaded, unload at target
			if(report_delivery)
				speak("Пункт назначения <b>[destination]</b> достигнут. Выгружаю [load].", radio_channel)
			if(is_crate(load))
				var/obj/structure/closet/crate/C = load
				C.notify_recipient(destination)
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup) // find a crate
				var/atom/movable/AM
				if(wires.is_cut(WIRE_LOADCHECK)) // if hacked, load first unanchored thing we find
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM && AM.Adjacent(src))
					load(AM)
					if(report_delivery)
						speak("Загружаю [load] в локации <b>[get_area(src)]</b>.", radio_channel)
		// whatever happened, check to see if we return home

		if(auto_return && home_destination && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = BOT_BLOCKED
		else
			bot_reset()	// otherwise go idle

/mob/living/simple_animal/bot/mulebot/Move(turf/simulated/next, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()

	if(. && istype(next))
		if(bloodiness)
			var/obj/effect/decal/cleanable/blood/tracks/B = locate() in next
			if(!B)
				B = new /obj/effect/decal/cleanable/blood/tracks(loc)
			if(blood_DNA && length(blood_DNA))
				B.blood_DNA |= blood_DNA.Copy()
			B.basecolor = currentBloodColor
			var/newdir = get_dir(next, loc)
			if(newdir == dir)
				B.setDir(newdir)
			else
				newdir = newdir | dir
				if(newdir == 3)
					newdir = 1
				else if(newdir == 12)
					newdir = 4
				B.setDir(newdir)
			B.update_icon()
			bloodiness--

/**
 * Called when bot bumps into anything.
 */
/mob/living/simple_animal/bot/mulebot/Bump(mob/living/bumped_living)
	. = ..()
	if(!wires.is_cut(WIRE_MOB_AVOIDANCE) || !isliving(bumped_living))
		return .

	// usually just bumps, but if avoidance disabled knock over mobs
	if(isrobot(bumped_living))
		visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] врезается в [bumped_living]!"))
		return .

	if(paicard)
		return .

	add_attack_logs(src, bumped_living, "Knocked down")
	visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] сбивает [bumped_living]!"))
	bumped_living.Weaken(16 SECONDS)

/mob/living/simple_animal/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	if(H.player_logged)//No running over SSD people
		return
	add_attack_logs(src, H, "Run over (DAMTYPE: [uppertext(BRUTE)])")
	H.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] переезжает [H]!"),
					span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] переезжает вас!"))
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)

	var/damage = rand(5, 15)
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_HEAD, run_armor_check(BODY_ZONE_HEAD, MELEE))
	H.apply_damage(2*damage, BRUTE, BODY_ZONE_CHEST, run_armor_check(BODY_ZONE_CHEST, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_LEG, run_armor_check(BODY_ZONE_L_LEG, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_LEG, run_armor_check(BODY_ZONE_R_LEG, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_L_ARM, run_armor_check(BODY_ZONE_L_ARM, MELEE))
	H.apply_damage(0.5*damage, BRUTE, BODY_ZONE_R_ARM, run_armor_check(BODY_ZONE_R_ARM, MELEE))

	if(HAS_TRAIT(H, TRAIT_NO_BLOOD))//Does the run over mob have blood?
		return//If it doesn't it shouldn't bleed (Though a check should be made eventually for things with liquid in them, like slime people.)

	var/turf/T = get_turf(src)//Where are we?
	H.add_mob_blood(H)//Cover the victim in their own blood.
	H.add_splatter_floor(T)//Put the blood where we are.
	bloodiness += 4

	var/list/blood_dna = H.get_blood_dna_list()
	if(blood_dna)
		transfer_blood_dna(blood_dna)
		currentBloodColor = H.dna.species.blood_color

/mob/living/simple_animal/bot/mulebot/bot_control_message(command, mob/user, user_turf)
	switch(command)
		if("start")
			if(load)
				to_chat(src, span_warningbig("ДОСТАВИТЬ [load] В ЛОКАЦИЮ [destination]"))
			else
				to_chat(src, span_warningbig("ЗАБРАТЬ ГРУЗ В ЛОКАЦИИ [destination]"))

		if("unload", "load")
			if(load)
				to_chat(src, span_warningbig("ВЫГРУЗИТЬСЯ"))
			else
				to_chat(src, span_warningbig("ЗАГРУЗИТЬСЯ"))
		if("autoret", "autopick", "target")
			return
		else
			..()

/mob/living/simple_animal/bot/mulebot/receive_signal(datum/signal/signal)
	if(wires.is_cut(WIRE_REMOTE_RX) || ..())
		return

	var/r_command = signal.data["command"]
	var/user = signal.data["user"]

	if(client)
		bot_control_message(r_command, user, null)
		return

	// process control input
	switch(r_command)
		if("start")
			start()

		if("target")
			set_destination(signal.data["destination"])

		if("unload")
			if(loc == target)
				unload(loaddir)
			else
				unload(0)

		if("home")
			start_home()

		if("autoret")
			auto_return = text2num(signal.data["value"])

		if("autopick")
			auto_pickup = text2num(signal.data["value"])

/**
 * Send a radio signal with multiple data key/values.
 */
/mob/living/simple_animal/bot/mulebot/post_signal_multiple(freq, list/keyval)
	if(wires.is_cut(WIRE_REMOTE_TX))
		return
	..()

/**
 * Signals bot status etc. to controller.
 */
/mob/living/simple_animal/bot/mulebot/send_status()
	var/list/key_values = list(
		"type" = MULE_BOT,
		"name" = suffix,
		"loca" = get_area(src),
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, key_values)

/**
 * Player on mulebot attempted to move.
 */
/mob/living/simple_animal/bot/mulebot/relaymove(mob/user)
	if(ispulsedemon(user))
		return ..()
	if(user.incapacitated())
		return
	if(load == user)
		unload(0)

/**
 * Update navigation data. Called when commanded to deliver, return home, or a route update is needed...
 */
/mob/living/simple_animal/bot/mulebot/proc/get_nav()
	if(!on || wires.is_cut(WIRE_BEACON_RX))
		return

	for(var/obj/machinery/navbeacon/NB in GLOB.deliverybeacons)
		if(NB.location == new_destination)	// if the beacon location matches the set destination
			destination = new_destination	// the we will navigate there
			target = NB.loc
			var/direction = NB.dir	// this will be the load/unload dir
			loaddir = direction
			update_icon()
			calc_path()

/mob/living/simple_animal/bot/mulebot/emp_act(severity)
	if(cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()

/mob/living/simple_animal/bot/mulebot/explode()
	visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] разлетается на части!"))
	var/turf/Tsec = get_turf(src)

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if(cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	do_sparks(3, TRUE, src)

	new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/simple_animal/bot/mulebot/execute_resist()
	. = ..()
	if(load)
		unload()

/mob/living/simple_animal/bot/mulebot/OnUnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(isturf(A) && isturf(loc) && loc.Adjacent(A) && load)
		unload(get_dir(loc, A))
	else
		..()

/mob/living/simple_animal/bot/mulebot/proc/on_entering(datum/source, atom/destination, atom/oldloc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isturf(destination))
		return

	for(var/mob/living/carbon/human/mob in destination.contents)
		RunOver(mob)

#undef SIGH
#undef ANNOYED
#undef DELIGHT

/obj/machinery/bot_core/mulebot
	req_access = list(ACCESS_CARGO)
