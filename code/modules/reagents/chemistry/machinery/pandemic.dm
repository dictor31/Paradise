/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 220"
	desc = "Высокотехнологичная машина, предназначенная для исследования и работы с вирусными культурами. Лучший друг вирусолога!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/circuitboard/pandemic
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/obj/item/reagent_containers/beaker = null
	var/list/microscope_reagents = list()
	var/list/microscope_reagent_storage = list()
	var/microscope_reagent_storage_capacity = 100
	var/microscope_reagent_type_limit = 3
	var/list/microscope_virus_seeds = list()
	var/datum/reagent/microscope_sample_reagent = null
	var/microscope_culture_generation = 0
	var/list/microscope_simulation_cells = list()
	var/list/microscope_simulation_particles = list()
	var/list/microscope_simulation_blood_cells = list()
	var/microscope_simulation_blood_cells_initialized = FALSE
	var/microscope_simulation_initialized = FALSE
	var/microscope_temperature = 15
	var/microscope_food_amount = 0
	var/microscope_food_capacity = 100
	var/wait = null
	var/printing = null

/obj/machinery/computer/pandemic/get_ru_names()
	return alist(
		NOMINATIVE = "Панд.Е.М.И.К 220",
		GENITIVE = "Панд.Е.М.И.К 220",
		DATIVE = "Панд.Е.М.И.К 220",
		ACCUSATIVE = "Панд.Е.М.И.К 220",
		INSTRUMENTAL = "Панд.Е.М.И.К 220",
		PREPOSITIONAL = "Панд.Е.М.И.К 220",
	)

/obj/machinery/computer/pandemic/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Панель техобслуживания открыта.")
	. += span_notice("Внутренний запас питательной среды: [round(microscope_food_amount, 0.1)] / [microscope_food_capacity] ед.")

/obj/machinery/computer/pandemic/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/computer/pandemic/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/computer/pandemic/update_icon_state()
	if(stat & BROKEN)
		icon_state = "mixer[beaker ? "1" : "0"]_b"
		return
	icon_state = "mixer[beaker ? "1" : "0"][(powered()) ? "" : "_nopower"]"

/obj/machinery/computer/pandemic/update_overlays()
	. = ..()
	if(!(stat & BROKEN) && !wait)
		. += "waitlight"

/obj/machinery/computer/pandemic/attack_ai(mob/user)
	add_hiddenprint(user)
	attack_hand(user)

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	add_fingerprint(user)
	if(..(user))
		return
	if(stat & (NOPOWER|BROKEN))
		return
	SStgui.update_uis(src)
	ui_interact(user)

/obj/machinery/computer/pandemic/proc/get_microscope_reagent_storage_amount()
	var/total_amount = 0
	for(var/list/stored_reagent as anything in microscope_reagent_storage)
		total_amount += stored_reagent["amount"]
	return total_amount


/obj/machinery/computer/pandemic/proc/transfer_microscope_contents(datum/reagents/source, mob/user)
	if(!source || !length(source.reagent_list))
		return FALSE

	var/has_contents = FALSE
	var/hit_reagent_type_limit = FALSE
	var/transferred_amount = 0

	// Virus food has its own reserve and does not use one of the three chemical slots.
	var/datum/reagent/food = source.get_reagent(/datum/reagent/consumable/virus_food)
	if(food && food.volume > 0)
		has_contents = TRUE
		var/food_space = microscope_food_capacity - microscope_food_amount
		var/food_transfer = min(food_space, food.volume)
		if(food_transfer > 0)
			source.remove_reagent(/datum/reagent/consumable/virus_food, food_transfer)
			microscope_food_amount += food_transfer
			transferred_amount += food_transfer

	// Normal reagents share a 100-unit store and at most three distinct reagent types.
	for(var/datum/reagent/incoming as anything in source.reagent_list.Copy())
		if(incoming.type == /datum/reagent/consumable/virus_food || incoming.volume <= 0)
			continue

		has_contents = TRUE
		var/list/existing_entry
		for(var/list/stored_reagent as anything in microscope_reagent_storage)
			if(stored_reagent["id"] == incoming.id)
				existing_entry = stored_reagent
				break

		if(!existing_entry && length(microscope_reagent_storage) >= microscope_reagent_type_limit)
			hit_reagent_type_limit = TRUE
			continue

		var/available_space = microscope_reagent_storage_capacity - get_microscope_reagent_storage_amount()
		if(available_space <= 0)
			continue

		var/incoming_type = incoming.type
		var/incoming_id = incoming.id
		var/incoming_name = incoming.name
		var/incoming_color = incoming.color
		var/incoming_is_vaccine = istype(incoming, /datum/reagent/vaccine)
		var/list/incoming_data = islist(incoming.data) ? incoming.data.Copy() : null
		var/amount_to_transfer = min(available_space, incoming.volume)
		if(amount_to_transfer <= 0)
			continue

		source.remove_reagent(incoming_type, amount_to_transfer)
		if(existing_entry)
			existing_entry["amount"] += amount_to_transfer
			if(islist(incoming_data))
				if(!islist(existing_entry["data"]))
					existing_entry["data"] = incoming_data.Copy()
				else
					var/list/combined_data = existing_entry["data"]
					combined_data |= incoming_data
		else
			microscope_reagent_storage += list(list(
				"id" = incoming_id,
				"name" = incoming_name,
				"amount" = amount_to_transfer,
				"color" = incoming_color,
				"is_vaccine" = incoming_is_vaccine,
				"type" = incoming_type,
				"data" = incoming_data,
			))
		transferred_amount += amount_to_transfer

	if(!has_contents)
		return FALSE

	if(transferred_amount > 0)
		balloon_alert(user, "реагенты залиты: [round(transferred_amount, 0.1)] ед.")
	else if(hit_reagent_type_limit)
		balloon_alert(user, "достигнут лимит в три вида реагентов")
	else
		balloon_alert(user, "хранилище реагентов заполнено")
	SStgui.update_uis(src)
	return TRUE

/obj/machinery/computer/pandemic/proc/load_microscope_sample()
	var/datum/reagent/blood_reagent = null
	if(beaker?.reagents)
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			if(reagent.type in GLOB.diseases_carrier_reagents)
				blood_reagent = reagent
				break

	// A different sample replaces the previous one. If it has already been
	// used by the microscope, it must not resurrect the old culture.
	if(blood_reagent != microscope_sample_reagent)
		microscope_sample_reagent = blood_reagent
		microscope_virus_seeds = list()
		microscope_culture_generation++
		microscope_simulation_cells = list()
		microscope_simulation_particles = list()
		microscope_simulation_blood_cells = list()
		microscope_simulation_blood_cells_initialized = FALSE
		microscope_simulation_initialized = FALSE

	if(!blood_reagent || !islist(blood_reagent.data) || !blood_reagent.data["diseases"])
		return FALSE

	// Re-inserting the exact same sample restores its still-living culture.
	// An extinct culture stays empty because the same reagent remains marked used.
	if(blood_reagent == microscope_sample_reagent && blood_reagent.data["microscope_sample_used"])
		return length(microscope_virus_seeds) > 0

	var/list/virus_seeds = list()
	// These fallback reagents are all available from a standard chemistry
	// dispenser. They fill missing microscope agents without changing the
	// disease's actual medical cure list.
	var/list/microscope_fallback_reagent_types = list(
		/datum/reagent/water,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/iron,
		/datum/reagent/copper,
		/datum/reagent/mercury,
		/datum/reagent/potassium,
		/datum/reagent/iodine,
		/datum/reagent/bromine,
		/datum/reagent/silver,
		/datum/reagent/chromium,
	)
	var/fallback_reagent_index = 1

	for(var/datum/disease/disease as anything in blood_reagent.data["diseases"])
		if(!istype(disease, /datum/disease/virus))
			continue

		var/datum/disease/virus/virus_disease = disease
		if(isnull(virus_disease.microscope_comfort_temperature))
			virus_disease.microscope_comfort_temperature = rand(0, 30)

		// The first disease cure attacks the outer shell; the second attacks
		// the nucleus once the shell is gone. Some legacy cure lists store IDs
		// as text rather than reagent type paths, so resolve both forms.
		var/list/microscope_reagent_ids = list()
		for(var/cure_type in disease.cures)
			var/datum/reagent/cure_reagent
			if(ispath(cure_type))
				cure_reagent = GLOB.chemical_reagents_list[cure_type]
			else if(istext(cure_type))
				cure_reagent = find_chemical_reagent_by_id(cure_type)

			if(istype(cure_reagent) && !(cure_reagent.id in microscope_reagent_ids))
				microscope_reagent_ids += cure_reagent.id
				if(length(microscope_reagent_ids) >= 2)
					break

		// Every virus needs two different microscope reagents. Fill any missing
		// slots with ordinary, dispenser-accessible chemistry reagents.
		while(length(microscope_reagent_ids) < 2)
			var/datum/reagent/fallback_reagent
			var/fallback_attempts = 0
			while(!fallback_reagent && fallback_attempts < length(microscope_fallback_reagent_types))
				var/fallback_type = microscope_fallback_reagent_types[fallback_reagent_index]
				fallback_reagent_index++
				if(fallback_reagent_index > length(microscope_fallback_reagent_types))
					fallback_reagent_index = 1
				fallback_attempts++

				var/datum/reagent/candidate_reagent = GLOB.chemical_reagents_list[fallback_type]
				if(istype(candidate_reagent) && !(candidate_reagent.id in microscope_reagent_ids))
					fallback_reagent = candidate_reagent

			if(!fallback_reagent)
				break
			microscope_reagent_ids += fallback_reagent.id

		// Every strain also has one hidden defensive reagent. A blue blood
		// cell will survive this virus only when that reagent has been added
		// to the sample and the virus has had time to recognize the protection.
		var/list/protective_reagent_candidates = list()
		for(var/protective_type in microscope_fallback_reagent_types)
			var/datum/reagent/protective_candidate = GLOB.chemical_reagents_list[protective_type]
			if(istype(protective_candidate) && !(protective_candidate.id in microscope_reagent_ids))
				protective_reagent_candidates += protective_candidate.id
		var/protective_reagent_id = length(protective_reagent_candidates) ? pick(protective_reagent_candidates) : null

		virus_seeds += list(list(
			"name" = disease.name,
			"disease_id" = disease.GetDiseaseID(),
			"microscope_reagents" = microscope_reagent_ids,
			"protective_reagent_id" = protective_reagent_id,
			"vaccine_allowed" = !virus_disease.no_vaccine,
			"immunity_allowed" = virus_disease.can_immunity,
			"comfortable_temperature" = virus_disease.microscope_comfort_temperature,
		))

	if(!length(virus_seeds))
		return FALSE

	// The marker stays inside this blood sample after it is removed from the machine.
	blood_reagent.data["microscope_sample_used"] = TRUE
	microscope_virus_seeds = virus_seeds
	return TRUE

/obj/machinery/computer/pandemic/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM || (stat & (NOPOWER|BROKEN)))
		return ..()

	if(istype(item, /obj/item/reagent_containers/dropper))
		var/obj/item/reagent_containers/dropper/dropper = item
		if(transfer_microscope_contents(dropper.reagents, user))
			add_fingerprint(user)
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	if(is_reagent_container(item))
		add_fingerprint(user)
		if(!(item.container_type & OPENCONTAINER))
			balloon_alert(user, "несовместимо!")
			return ATTACK_CHAIN_PROCEED

		var/obj/item/reagent_containers/container = item
		var/contains_blood_sample = FALSE
		if(container.reagents)
			for(var/datum/reagent/reagent as anything in container.reagents.reagent_list)
				if(reagent.type in GLOB.diseases_carrier_reagents)
					contains_blood_sample = TRUE
					break

		if(!contains_blood_sample && transfer_microscope_contents(container.reagents, user))
			return ATTACK_CHAIN_BLOCKED_ALL

		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()
		beaker = container
		balloon_alert(user, "ёмкость вставлена")
		var/datum/reagents/reagents = beaker.reagents
		for(var/datum/reagent/reagent as anything in reagents.reagent_list)
			var/list/reagent_data = reagent.data
			if((reagent.type in GLOB.diseases_carrier_reagents) && reagent_data && reagent_data["resistances"])
				var/list/original_resistances = reagent_data["resistances"]
				var/list/resistances = original_resistances.Copy()
				for(var/path in resistances)
					var/datum/disease/virus/virus_res = path
					if(initial(virus_res.no_vaccine))
						reagent_data["resistances"] -= path
		load_microscope_sample()
		update_icon(UPDATE_ICON_STATE)
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/machinery/computer/pandemic/screwdriver_act(mob/user, obj/item/item)
	. = TRUE
	if(!beaker)
		add_fingerprint(user)
		balloon_alert(user, "ёмкость отсутствует!")
		to_chat(user, span_warning("Ёмкость не установлена."))
		return .
	if(!item.use_tool(src, user, volume = item.tool_volume))
		return .
	eject_beaker()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/computer/pandemic/wrench_act(mob/living/user, obj/item/item)
	return default_unfasten_wrench(user, item)

// MARK: TGUI
/obj/machinery/computer/pandemic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PandemicSuper")
		ui.open()

/obj/machinery/computer/pandemic/ui_data(mob/user)
	var/list/data = list()
	// Transfer modal information if there is one
	data["modal"] = ui_modal_data(src)

	// Microscope reagents are taken from the machine's separate internal stock.
	var/list/available_microscope_reagents = list()
	for(var/list/stored_reagent as anything in microscope_reagent_storage)
		if(stored_reagent["amount"] <= 0.001)
			continue
		var/vaccine_kind = null
		if(stored_reagent["type"] == /datum/reagent/vaccine/antiviral)
			vaccine_kind = "antiviral"
		else if(stored_reagent["type"] == /datum/reagent/vaccine/immunity)
			vaccine_kind = "immunity"
		else if(stored_reagent["type"] == /datum/reagent/vaccine/combined)
			vaccine_kind = "combined"
		available_microscope_reagents += list(list(
			"id" = stored_reagent["id"],
			"name" = stored_reagent["name"],
			"volume" = stored_reagent["amount"],
			"color" = stored_reagent["color"],
			"is_vaccine" = stored_reagent["is_vaccine"],
			"vaccine_kind" = vaccine_kind,
		))
	data["microscope_available_reagents"] = available_microscope_reagents
	data["microscope_reagent_storage_amount"] = get_microscope_reagent_storage_amount()
	data["microscope_reagent_storage_capacity"] = microscope_reagent_storage_capacity
	data["microscope_reagent_storage_types"] = length(microscope_reagent_storage)
	data["microscope_reagent_type_limit"] = microscope_reagent_type_limit

	data["microscope_food_amount"] = microscope_food_amount
	data["microscope_food_capacity"] = microscope_food_capacity

	var/microscope_sample_present = FALSE
	if(beaker?.reagents && microscope_sample_reagent)
		for(var/datum/reagent/reagent as anything in beaker.reagents.reagent_list)
			if(reagent == microscope_sample_reagent)
				microscope_sample_present = TRUE
				break

	data["microscope_sample_present"] = microscope_sample_present
	data["microscope_virus_seeds"] = microscope_sample_present ? microscope_virus_seeds : list()
	data["microscope_culture_generation"] = microscope_culture_generation
	data["microscope_temperature"] = microscope_temperature
	data["microscope_simulation_initialized"] = microscope_simulation_initialized
	data["microscope_simulation_cells"] = microscope_sample_present ? microscope_simulation_cells : list()
	data["microscope_simulation_particles"] = microscope_sample_present ? microscope_simulation_particles : list()
	data["microscope_simulation_blood_cells"] = microscope_sample_present ? microscope_simulation_blood_cells : list()
	data["microscope_simulation_blood_cells_initialized"] = microscope_simulation_blood_cells_initialized
	var/list/applied_blood_reagents = list()
	if(microscope_sample_present && microscope_sample_reagent && islist(microscope_sample_reagent.data) && islist(microscope_sample_reagent.data["microscope_protective_reagents"]))
		applied_blood_reagents = microscope_sample_reagent.data["microscope_protective_reagents"].Copy()
	data["microscope_applied_protective_reagents"] = applied_blood_reagents

	var/list/added_microscope_reagents = list()
	for(var/list/added_reagent in microscope_reagents)
		added_microscope_reagents += list(list(
			"id" = added_reagent["id"],
			"name" = added_reagent["name"],
			"amount" = added_reagent["amount"],
			"color" = added_reagent["color"],
			"is_vaccine" = added_reagent["is_vaccine"],
		))
	data["microscope_added_reagents"] = added_microscope_reagents

	. = data
	data["error_message"] = null
	if(!beaker)
		data["error_message"] = "Ёмкость отсутствует!"
		data["beaker_exists"] = FALSE
		return
	data["beaker_exists"] = TRUE

	var/datum/reagents/reagents = beaker.reagents
	if(!reagents.total_volume || !length(reagents.reagent_list))
		data["error_message"] = "Ёмкость пуста!"
		return

	var/datum/reagent/blood = null
	for(var/datum/reagent/reagent in reagents.reagent_list)
		if(reagent.type in GLOB.diseases_carrier_reagents)
			blood = reagent
			if(!blood.data)
				continue
			break
	if(!blood)
		data["error_message"] = "В ёмкости отсутствует образец крови!"
		return

	if(!blood.data)
		data["error_message"] = "В ёмкости отсутствует данные крови!"
		return

	var/list/blood_data = list()
	blood_data["dna"] = blood.data["blood_DNA"] || "нет"
	blood_data["group"] = blood.data["blood_type"] || "нет"
	blood_data["type"] = blood.data["blood_species"] || "нет"
	data["blood_data"] = blood_data

	data["diseases"] = null
	if(blood.data["diseases"])
		var/list/diseases = list()
		var/i = 0
		for(var/datum/disease/disease in blood.data["diseases"])
			i++
			if(disease.visibility_flags & HIDDEN_PANDEMIC)
				continue

			var/list/disease_data = list()
			disease_data["index"] = i

			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/adv_virus = disease
				disease = GLOB.archive_diseases[adv_virus.GetDiseaseID()]
				if(disease)
					if(disease.name == UNKNOWN_STATUS_RUS)
						disease_data["name"] = "Неизвестно"
					else
						disease_data["name"] = disease.name
			else
				disease_data["name"] = disease.name

			if(!disease)
				CRASH("We weren't able to get the advance disease from the archive.")


			disease_data["agent"] = disease ? disease.agent : "нет"
			disease_data["description"] = disease.desc || "нет"
			disease_data["route"] = disease.additional_info || "нет"
			disease_data["possibleMedicine"] = disease.cure_text || "нет"
			disease_data["antibodiesPossibility"] = disease.can_immunity ? "Присутствует" : "Отсутствует"
			disease_data["allow_remove_sympthoms"] = FALSE
			disease_data["allow_add_sympthoms"] = FALSE

			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/advance_virus = disease
				var/symptoms_list = list()
				for(var/datum/symptom/symptom in advance_virus.symptoms)
					symptoms_list += symptom.name
				disease_data["symptoms"] = russian_list(symptoms_list)
				if(length(symptoms_list) > 1)
					disease_data["allow_remove_sympthoms"] = TRUE
				disease_data["allow_add_sympthoms"] = TRUE
			else
				disease_data["symptoms"] = "Отсутствуют"

			diseases += list(disease_data)

		if(length(diseases))
			data["diseases"] = diseases

		data["antibodies"] = null
		if(blood.data["resistances"])
			var/list/res = blood.data["resistances"]
			if(length(res))
				var/list/antibodies = list()
				var/index = 0
				for(var/type in blood.data["resistances"])
					index++
					var/list/antibody = list()
					antibody["index"] = index
					var/disease_name = UNKNOWN_STATUS_RUS

					if(!ispath(type))
						var/datum/disease/virus/advance/A = GLOB.archive_diseases[type]
						if(A)
							disease_name = A.name
					else
						var/datum/disease/disease = new type()
						disease_name = disease.name

					antibody["name"] = disease_name
					antibodies += list(antibody)

				data["antibodies"] = antibodies


	return data

/obj/machinery/computer/pandemic/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return FALSE
	if(action != "saveMicroscopeState" && action != "setMicroscopeTemperature")
		add_fingerprint(usr)
	if(action != "feedMicroscopeCells" && action != "saveMicroscopeState" && action != "setMicroscopeTemperature")
		playsound(loc, SFX_TERMINAL_TYPE, 25, TRUE)
	if(ui_act_modal(action, params))
		return TRUE
	. = TRUE
	switch(action)
		if("openMicroscope")
			var/datum/tgui/microscope_ui = new(usr, src, "VirusMicroscope")
			microscope_ui.open()

		if("addMicroscopeReagent")
			var/reagent_id = params["id"]
			var/transfer_amount = params["amount"]
			if(!istext(reagent_id) || !length(reagent_id))
				return TRUE
			if(!isnum(transfer_amount) || (transfer_amount != 1 && transfer_amount != 5 && transfer_amount != 10))
				return TRUE

			var/list/selected_reagent
			for(var/list/stored_reagent as anything in microscope_reagent_storage)
				if(stored_reagent["id"] == reagent_id)
					selected_reagent = stored_reagent
					break

			if(!selected_reagent || selected_reagent["amount"] <= 0)
				balloon_alert(usr, "недостаточно реагента")
				return TRUE

			var/selected_amount = 0
			var/list/existing_sample
			for(var/list/sample as anything in microscope_reagents)
				if(sample["id"] == reagent_id)
					selected_amount = sample["amount"]
					existing_sample = sample
					break

			var/available_amount = selected_reagent["amount"] - selected_amount
			if(available_amount + 0.001 < transfer_amount)
				balloon_alert(usr, "недостаточно реагента для выбранной порции")
				return TRUE

			if(existing_sample)
				existing_sample["amount"] += transfer_amount
			else
				microscope_reagents += list(list(
					"id" = reagent_id,
					"name" = selected_reagent["name"],
					"amount" = transfer_amount,
					"color" = selected_reagent["color"],
					"is_vaccine" = selected_reagent["is_vaccine"],
				))

			SStgui.update_uis(src)
			return TRUE

		if("removeMicroscopeStoredReagent")
			var/reagent_id = params["id"]
			if(!istext(reagent_id) || !length(reagent_id))
				return TRUE

			// Remove by numeric index so nested associative lists are deleted reliably.
			for(var/reagent_index = length(microscope_reagent_storage), reagent_index >= 1, reagent_index--)
				var/list/stored_reagent = microscope_reagent_storage[reagent_index]
				if(stored_reagent["id"] == reagent_id)
					microscope_reagent_storage.Cut(reagent_index, reagent_index + 1)
					break

			for(var/queued_index = length(microscope_reagents), queued_index >= 1, queued_index--)
				var/list/queued_reagent = microscope_reagents[queued_index]
				if(queued_reagent["id"] == reagent_id)
					microscope_reagents.Cut(queued_index, queued_index + 1)

			SStgui.update_uis(src)
			return TRUE

		if("clearMicroscopeReagents")
			// Queued reagents have not left the internal stock yet; clearing the
			// selection simply returns the full queued amounts to available stock.
			microscope_reagents = list()
			SStgui.update_uis(src)
			return TRUE

		if("startMicroscopeSimulation")
			if(!length(microscope_reagents))
				return TRUE

			for(var/list/sample as anything in microscope_reagents)
				var/reagent_id = sample["id"]
				var/selected_amount = sample["amount"]
				if(!istext(reagent_id) || !isnum(selected_amount) || selected_amount <= 0)
					continue

				for(var/reagent_index = length(microscope_reagent_storage), reagent_index >= 1, reagent_index--)
					var/list/stored_reagent = microscope_reagent_storage[reagent_index]
					if(stored_reagent["id"] != reagent_id)
						continue

					var/actual_amount = min(selected_amount, stored_reagent["amount"])
					stored_reagent["amount"] = max(0, stored_reagent["amount"] - actual_amount)
					// Treat tiny floating-point leftovers as depleted stock.
					if(stored_reagent["amount"] <= 0.001)
						microscope_reagent_storage.Cut(reagent_index, reagent_index + 1)
					break

			// The queued quantities are consumed once and cannot be started a second time.
			microscope_reagents = list()
			SStgui.update_uis(src)
			return TRUE

		if("extractBeaker")
			eject_beaker()

		if("feedMicroscopeCells")
			var/food_to_feed = params["amount"]
			if(!isnum(food_to_feed))
				food_to_feed = 1
			food_to_feed = round(food_to_feed)
			food_to_feed = max(1, min(5, food_to_feed))
			if(microscope_food_amount < food_to_feed)
				return TRUE
			microscope_food_amount = max(0, microscope_food_amount - food_to_feed)
			SStgui.update_uis(src)
			return TRUE

		if("addMicroscopeBloodReagent")
			var/reagent_id = params["id"]
			if(!istext(reagent_id) || !beaker?.reagents || !microscope_sample_reagent)
				return TRUE

			var/sample_present = FALSE
			for(var/datum/reagent/sample_reagent as anything in beaker.reagents.reagent_list)
				if(sample_reagent == microscope_sample_reagent)
					sample_present = TRUE
					break
			if(!sample_present || !islist(microscope_sample_reagent.data))
				balloon_alert(usr, "образец крови отсутствует")
				return TRUE

			var/list/stored_entry
			var/stored_index = 0
			for(var/index = 1, index <= length(microscope_reagent_storage), index++)
				var/list/entry = microscope_reagent_storage[index]
				if(entry["id"] == reagent_id)
					stored_entry = entry
					stored_index = index
					break
			if(!stored_entry || stored_entry["is_vaccine"] || stored_entry["amount"] < 1)
				balloon_alert(usr, "нужен один юнит обычного реагента")
				return TRUE

			var/list/applied_reagents = microscope_sample_reagent.data["microscope_protective_reagents"]
			if(!islist(applied_reagents))
				applied_reagents = list()
				microscope_sample_reagent.data["microscope_protective_reagents"] = applied_reagents
			if(reagent_id in applied_reagents)
				balloon_alert(usr, "этот реагент уже добавлен в образец")
				return TRUE

			applied_reagents += reagent_id
			stored_entry["amount"] = max(0, stored_entry["amount"] - 1)
			if(stored_entry["amount"] <= 0.001)
				microscope_reagent_storage.Cut(stored_index, stored_index + 1)
			balloon_alert(usr, "реагент добавлен в кровь")
			SStgui.update_uis(src)
			return TRUE

		if("synthesizeMicroscopeVaccine")
			if(wait)
				return TRUE
			var/list/selected_ids = params["reagents"]
			if(!islist(selected_ids) || !length(selected_ids) || length(selected_ids) > 2)
				balloon_alert(usr, "выберите один или два компонента")
				return TRUE
			var/sample_is_installed = FALSE
			if(beaker?.reagents && microscope_sample_reagent)
				for(var/datum/reagent/sample_reagent as anything in beaker.reagents.reagent_list)
					if(sample_reagent == microscope_sample_reagent)
						sample_is_installed = TRUE
						break
			var/has_virus_sample = sample_is_installed && islist(microscope_sample_reagent.data) && length(microscope_virus_seeds)

			var/list/selected_entries = list()
			var/list/validated_ids = list()
			for(var/reagent_id as anything in selected_ids)
				if(!istext(reagent_id) || reagent_id in validated_ids)
					return TRUE
				validated_ids += reagent_id
				var/list/selected_entry
				for(var/list/stored_reagent as anything in microscope_reagent_storage)
					if(stored_reagent["id"] == reagent_id && stored_reagent["amount"] >= 1)
						selected_entry = stored_reagent
						break
				if(!selected_entry)
					balloon_alert(usr, "компонент отсутствует в хранилище")
					return TRUE
				selected_entries += list(selected_entry)

			var/vaccine_type
			var/list/vaccine_targets = list()
			var/vaccine_name = null
			var/vaccine_label = null

			if(length(selected_entries) == 1 && has_virus_sample)
				var/reagent_id = validated_ids[1]
				var/list/applied_reagents = microscope_sample_reagent.data["microscope_protective_reagents"]
				if(!islist(applied_reagents) || !(reagent_id in applied_reagents))
					balloon_alert(usr, "сначала проверьте реагент на клетках крови")
					return TRUE
				for(var/list/seed as anything in microscope_virus_seeds)
					if(!seed["vaccine_allowed"] || !seed["immunity_allowed"])
						continue
					if(seed["protective_reagent_id"] != reagent_id)
						continue
					var/rejected_cell_found = FALSE
					for(var/list/blood_cell as anything in microscope_simulation_blood_cells)
						if(blood_cell["virusName"] == seed["name"] && blood_cell["rejectionTicks"] >= 60)
							rejected_cell_found = TRUE
							break
					if(!rejected_cell_found)
						continue
					vaccine_type = /datum/reagent/vaccine/immunity
					vaccine_targets += seed["disease_id"]
					vaccine_name = seed["name"]
					vaccine_label = "иммунная"
					break

			if(length(selected_entries) == 2 && !vaccine_type && has_virus_sample)
				var/first_id = validated_ids[1]
				var/second_id = validated_ids[2]
				for(var/list/seed as anything in microscope_virus_seeds)
					if(!seed["vaccine_allowed"])
						continue
					var/list/virus_reagents = seed["microscope_reagents"]
					if(length(virus_reagents) < 2)
						continue
					if((first_id == virus_reagents[1] && second_id == virus_reagents[2]) || (first_id == virus_reagents[2] && second_id == virus_reagents[1]))
						vaccine_type = /datum/reagent/vaccine/antiviral
						vaccine_targets += seed["disease_id"]
						vaccine_name = seed["name"]
						vaccine_label = "вирусоцидная"
						break

			if(length(selected_entries) == 2 && !vaccine_type)
				var/list/first_entry = selected_entries[1]
				var/list/second_entry = selected_entries[2]
				var/first_type = first_entry["type"]
				var/second_type = second_entry["type"]
				var/list/first_targets = first_entry["data"]
				var/list/second_targets = second_entry["data"]
				if(islist(first_targets) && islist(second_targets) && ((first_type == /datum/reagent/vaccine/antiviral && second_type == /datum/reagent/vaccine/immunity) || (second_type == /datum/reagent/vaccine/antiviral && first_type == /datum/reagent/vaccine/immunity)))
					for(var/target_id in first_targets)
						if(target_id in second_targets)
							vaccine_targets += target_id
				if(length(vaccine_targets))
					vaccine_type = /datum/reagent/vaccine/combined
					for(var/list/seed as anything in microscope_virus_seeds)
						if(seed["disease_id"] in vaccine_targets)
							vaccine_name = seed["name"]
							break
					if(!vaccine_name)
						vaccine_name = "смешанный штамм"
					vaccine_label = "комплексная"

			if(!vaccine_type || !length(vaccine_targets))
				balloon_alert(usr, "состав не соответствует ни одной известной формуле")
				return TRUE

			var/obj/item/reagent_containers/cup/bottle/vaccine_bottle = new(loc)
			if(!vaccine_bottle)
				return TRUE
			vaccine_bottle.pixel_x = rand(-3, 3)
			vaccine_bottle.pixel_y = rand(-3, 3)
			vaccine_bottle.name = "[capitalize(vaccine_label)] вакцина [vaccine_name]"
			vaccine_bottle.desc = "Синтезированная [vaccine_label] вакцина против [vaccine_name]."
			vaccine_bottle.reagents.add_reagent(vaccine_type, 15, vaccine_targets)

			for(var/reagent_id as anything in validated_ids)
				for(var/index = length(microscope_reagent_storage), index >= 1, index--)
					var/list/entry = microscope_reagent_storage[index]
					if(entry["id"] == reagent_id)
						entry["amount"] = max(0, entry["amount"] - 1)
						if(entry["amount"] <= 0.001)
							microscope_reagent_storage.Cut(index, index + 1)
						break

			replicator_cooldown(20 SECONDS)
			SStgui.update_uis(src)
			return TRUE

		if("setMicroscopeTemperature")
			var/new_temperature = params["temperature"]
			if(isnum(new_temperature))
				microscope_temperature = max(0, min(30, new_temperature))
			return TRUE

		if("saveMicroscopeState")
			var/saved_temperature = params["temperature"]
			if(isnum(saved_temperature))
				microscope_temperature = max(0, min(30, saved_temperature))

			var/save_generation = params["generation"]
			if(save_generation != microscope_culture_generation || !beaker || !microscope_sample_reagent)
				return TRUE

			var/sample_present = FALSE
			if(beaker?.reagents)
				for(var/datum/reagent/sample_reagent as anything in beaker.reagents.reagent_list)
					if(sample_reagent == microscope_sample_reagent)
						sample_present = TRUE
						break
			if(!sample_present)
				return TRUE

			var/list/incoming_cells = params["cells"]
			var/list/incoming_particles = params["particles"]
			var/list/incoming_blood_cells = params["bloodCells"]
			if(!islist(incoming_cells) || !islist(incoming_particles))
				return TRUE
			if(!islist(incoming_blood_cells))
				incoming_blood_cells = list()
			if(length(incoming_cells) > 10 || length(incoming_particles) > 80 || length(incoming_blood_cells) > 40)
				return TRUE

			var/list/saved_cells = list()
			for(var/list/cell_data as anything in incoming_cells)
				if(!islist(cell_data))
					return TRUE
				var/cell_stage = cell_data["stage"]
				if(!isnum(cell_data["id"]) || !istext(cell_data["name"]) || !istext(cell_stage))
					return TRUE
				if(!(cell_stage in list("normal", "growing", "stretching", "splitting", "dying")))
					return TRUE
				if(!isnum(cell_data["x"]) || !isnum(cell_data["y"]) || !isnum(cell_data["vx"]) || !isnum(cell_data["vy"]))
					return TRUE
				if(!isnum(cell_data["age"]) || !isnum(cell_data["size"]) || !isnum(cell_data["food"]) || !isnum(cell_data["comfortTemperature"]))
					return TRUE
				if(!isnum(cell_data["outerStrength"]) || !isnum(cell_data["innerStrength"]) || !isnum(cell_data["nucleusStrength"]) || !isnum(cell_data["stageTicks"]))
					return TRUE
				var/visual_pulse_type = cell_data["visualPulseType"]
				if(!isnull(visual_pulse_type) && !(visual_pulse_type in list("impact", "food", "damage")))
					return TRUE
				if(!isnull(cell_data["visualPulse"]) && !isnum(cell_data["visualPulse"]))
					return TRUE
				if(!isnull(cell_data["visualPulseAngle"]) && !isnum(cell_data["visualPulseAngle"]))
					return TRUE
				if(!isnull(cell_data["divisionAngle"]) && !isnum(cell_data["divisionAngle"]))
					return TRUE
				if(!isnull(cell_data["membraneVelocity"]) && !islist(cell_data["membraneVelocity"]))
					return TRUE

				var/list/saved_cell = list(
					"id" = round(cell_data["id"]),
					"name" = copytext(cell_data["name"], 1, 64),
					"x" = max(0, min(800, cell_data["x"])),
					"y" = max(0, min(460, cell_data["y"])),
					"vx" = max(-12, min(12, cell_data["vx"])),
					"vy" = max(-12, min(12, cell_data["vy"])),
					"age" = max(0, round(cell_data["age"])),
					"size" = max(10, min(30, cell_data["size"])),
					"food" = max(0, min(5, cell_data["food"])),
					"comfortTemperature" = max(0, min(30, cell_data["comfortTemperature"])),
					"outerStrength" = max(0, min(100, cell_data["outerStrength"])),
					"innerStrength" = max(0, min(100, cell_data["innerStrength"])),
					"nucleusStrength" = max(0, min(100, cell_data["nucleusStrength"])),
					"stage" = cell_stage,
					"stageTicks" = max(0, min(60, round(cell_data["stageTicks"]))),
					"membrane" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
					"membraneVelocity" = list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
					"visualPulse" = isnum(cell_data["visualPulse"]) ? max(0, min(1, cell_data["visualPulse"])) : 0,
					"visualPulseType" = istext(visual_pulse_type) ? visual_pulse_type : "impact",
					"visualPulseAngle" = isnum(cell_data["visualPulseAngle"]) ? max(-6.3, min(6.3, cell_data["visualPulseAngle"])) : 0,
					"membranePhase" = isnum(cell_data["membranePhase"]) ? cell_data["membranePhase"] : cell_data["id"] * 0.73
				)
				if(!isnum(cell_data["membranePhase"]) && !isnull(cell_data["membranePhase"]))
					return TRUE
				if(islist(cell_data["membrane"]))
					if(length(cell_data["membrane"]) != 24)
						return TRUE
					var/list/saved_membrane = list()
					for(var/membrane_value as anything in cell_data["membrane"])
						if(!isnum(membrane_value))
							return TRUE
						saved_membrane += max(-16, min(5, membrane_value))
					saved_cell["membrane"] = saved_membrane
				if(isnum(cell_data["divisionAngle"]))
					saved_cell["divisionAngle"] = max(-6.3, min(6.3, cell_data["divisionAngle"]))
				if(islist(cell_data["membraneVelocity"]))
					if(length(cell_data["membraneVelocity"]) != 24)
						return TRUE
					var/list/saved_membrane_velocity = list()
					for(var/velocity_value as anything in cell_data["membraneVelocity"])
						if(!isnum(velocity_value))
							return TRUE
						saved_membrane_velocity += max(-20, min(20, velocity_value))
					saved_cell["membraneVelocity"] = saved_membrane_velocity
				if(istext(cell_data["outerReagentId"]))
					saved_cell["outerReagentId"] = copytext(cell_data["outerReagentId"], 1, 64)
				var/nucleus_reagent_id = cell_data["nucleusReagentId"]
				// Migrate saved microscope cultures from the old inner-layer reagent field.
				if(!istext(nucleus_reagent_id))
					nucleus_reagent_id = cell_data["innerReagentId"]
				if(istext(nucleus_reagent_id))
					saved_cell["nucleusReagentId"] = copytext(nucleus_reagent_id, 1, 64)
				saved_cells += list(saved_cell)

			var/list/saved_particles = list()
			for(var/list/particle_data as anything in incoming_particles)
				if(!islist(particle_data))
					return TRUE
				if(!isnum(particle_data["id"]) || !istext(particle_data["reagentId"]) || !istext(particle_data["color"]))
					return TRUE
				if(!isnum(particle_data["foodValue"]) || !isnum(particle_data["x"]) || !isnum(particle_data["y"]))
					return TRUE
				if(!isnum(particle_data["vx"]) || !isnum(particle_data["vy"]) || !isnum(particle_data["radius"]))
					return TRUE

				saved_particles += list(list(
					"id" = round(particle_data["id"]),
					"reagentId" = copytext(particle_data["reagentId"], 1, 64),
					"isVaccine" = particle_data["isVaccine"] ? TRUE : FALSE,
					"foodValue" = max(0, min(1, particle_data["foodValue"])),
					"color" = copytext(particle_data["color"], 1, 16),
					"x" = max(0, min(800, particle_data["x"])),
					"y" = max(0, min(460, particle_data["y"])),
					"vx" = max(-12, min(12, particle_data["vx"])),
					"vy" = max(-12, min(12, particle_data["vy"])),
					"radius" = max(0.5, min(3, particle_data["radius"])),
				))

			var/list/saved_blood_cells = list()
			for(var/list/blood_cell_data as anything in incoming_blood_cells)
				if(!islist(blood_cell_data))
					return TRUE
				if(!isnum(blood_cell_data["id"]) || !istext(blood_cell_data["virusName"]))
					return TRUE
				if(!isnum(blood_cell_data["x"]) || !isnum(blood_cell_data["y"]) || !isnum(blood_cell_data["vx"]) || !isnum(blood_cell_data["vy"]))
					return TRUE
				if(!isnum(blood_cell_data["size"]) || !isnum(blood_cell_data["rejectionTicks"]))
					return TRUE
				var/list/saved_blood_cell = list(
					"id" = round(blood_cell_data["id"]),
					"virusName" = copytext(blood_cell_data["virusName"], 1, 64),
					"x" = max(0, min(800, blood_cell_data["x"])),
					"y" = max(0, min(460, blood_cell_data["y"])),
					"vx" = max(-12, min(12, blood_cell_data["vx"])),
					"vy" = max(-12, min(12, blood_cell_data["vy"])),
					"size" = max(6, min(24, blood_cell_data["size"])),
					"rejectionTicks" = max(0, min(1000, round(blood_cell_data["rejectionTicks"]))),
				)
				if(istext(blood_cell_data["protectiveReagentId"]))
					saved_blood_cell["protectiveReagentId"] = copytext(blood_cell_data["protectiveReagentId"], 1, 64)
				saved_blood_cells += list(saved_blood_cell)

			microscope_simulation_cells = saved_cells
			microscope_simulation_particles = saved_particles
			microscope_simulation_blood_cells = saved_blood_cells
			microscope_simulation_blood_cells_initialized = TRUE
			microscope_simulation_initialized = TRUE
			return TRUE

		if("microscopePopulationExtinct")
			if(params["generation"] != microscope_culture_generation)
				return TRUE
			// Keep the strain recipe and any surviving, protected blood cells:
			// they are still needed to synthesize vaccines after the culture dies.
			// An initialized empty virus list prevents this same sample respawning.
			microscope_simulation_cells = list()
			microscope_simulation_initialized = TRUE
			microscope_simulation_blood_cells_initialized = TRUE
			SStgui.update_uis(src)
			return TRUE

		if("clearAndExtractBeaker")
			beaker.reagents.clear_reagents()
			eject_beaker()

		if("renameDisease")
			var/new_name = tgui_input_text(usr, "Назовите вирус:", "Введите название вируса", max_length = MAX_NAME_LEN)
			if(!new_name)
				return
			var/id = GetDiseaseTypeByIndex(text2num(params["index"]))
			if(GLOB.archive_diseases[id])
				var/datum/disease/virus/advance/advanced_disease = GLOB.archive_diseases[id]
				advanced_disease.AssignName(new_name)
				for(var/datum/disease/virus/advance/adv_disease in GLOB.active_diseases)
					adv_disease.Refresh(update_properties = FALSE)
			SStgui.update_uis(src)

		if("printForm")
			var/datum/disease/disease = GetDiseaseByIndex(text2num(params["index"]))
			disease = GLOB.archive_diseases[disease.GetDiseaseID()]//We know it's advanced no need to check
			print_form(disease, usr)

		if("createExample")
			if(wait)
				return
			var/datum/disease/disease = GetDiseaseByIndex(text2num(params["index"]))
			var/datum/disease/copy
			if(istype(disease, /datum/disease/virus/advance))
				var/datum/disease/virus/advance/adv_disease = GLOB.archive_diseases[disease.GetDiseaseID()]
				if(adv_disease)
					copy = adv_disease.Copy()
			if(!copy)
				copy = disease.Copy()
			if(!copy)
				return
			var/name = tgui_input_text(usr, "Название:", "Введите название культуры", disease.name, MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/cup/bottle/bottle = new(loc)
			bottle.icon_state = "round_bottle"
			bottle.pixel_x = rand(-3, 3)
			bottle.pixel_y = rand(-3, 3)
			replicator_cooldown(5 SECONDS)
			var/list/data = list("diseases"=list(copy))
			bottle.name = "культура [capitalize(name)]"
			bottle.ru_names = alist(
				NOMINATIVE = "культура [capitalize(name)]",
				GENITIVE = "культуры [capitalize(name)]",
				DATIVE = "культуре [capitalize(name)]",
				ACCUSATIVE = "культуру [capitalize(name)]",
				INSTRUMENTAL = "культурой [capitalize(name)]",
				PREPOSITIONAL = "культуре [capitalize(name)]",
			)
			bottle.desc = "Небольшая бутылка. Содержит синтетическую кровь, заражённую культурой [capitalize(copy.agent)]."
			bottle.reagents.add_reagent(/datum/reagent/blood, 20, data)

		if("addSympthom")
			add_random_symptom(text2num(params["index"]))
			SStgui.update_uis(src)

		if("removeSympthom")
			remove_random_symptom(text2num(params["index"]))
			SStgui.update_uis(src)

/obj/machinery/computer/pandemic/proc/ui_act_modal(action, params)
	return FALSE


// MARK: Actions
/obj/machinery/computer/pandemic/proc/eject_beaker()
	if(!beaker)
		return
	beaker.forceMove(drop_location())
	beaker = null
	microscope_reagents = list()
	update_icon(UPDATE_ICON_STATE)
	SStgui.update_uis(src)


//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/computer/pandemic/proc/print_form(datum/disease/virus/advance/disease, mob/living/user)
	disease = GLOB.archive_diseases[disease.GetDiseaseID()]
	if(!(printing) && disease)
		var/reason = tgui_input_text(user,"Укажите причину выпуска", "Указать", multiline = TRUE)
		reason += "<span class=\"paper_field\"></span>"
		var/symptoms_list = list()
		for(var/datum/symptom/symptom in disease.symptoms)
			symptoms_list += symptom.name
		var/symtoms = russian_list(symptoms_list)

		var/signature
		if(tgui_alert(user, "Вы хотите подписать этот документ?", "Подпись", list("Да","Нет")) == "Да")
			signature = "<span style='font-face: \"[SIGNFONT]\";'><i>[user ? user.real_name : UNKNOWN_NAME_RUS]</i></span>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/form = new /obj/item/paper(loc)
		visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] дребезжит, после чего из окна печати выпадает лист бумаги."))
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, TRUE)

		form.info = span_fontsize4("<u><b><center> Выпуск вируса </b></center></u>")
		form.info += "<hr>"
		form.info += "<u>Название вируса:</u> [disease.name] <br>"
		form.info += "<u>Симптомы:</u> [symtoms]<br>"
		form.info += "<u>Путь передачи:</u> [disease.additional_info]<br>"
		form.info += "<u>Лекарство от вируса:</u> [disease.cure_text]<br>"
		form.info += "<br>"
		form.info += "<u>Причина выпуска:</u> [reason]"
		form.info += "<hr>"
		form.info += "Вирусолог, ответственный за любые биологические угрозы, возникшие вследствие выпуска вируса.<br>"
		form.info += "<u>Подпись вирусолога:</u> [signature]<br>"
		form.info += "Печать ответственного лица, разрешившего выпуск вируса:"
		form.populatefields()
		form.updateinfolinks()
		form.name = "Выпуск вируса «[disease.name]»"
		form.update_icon()
		printing = null


// MARK: Utilitary procs
/obj/machinery/computer/pandemic/proc/GetDiseaseByIndex(index)
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["diseases"])
				var/list/diseases = BL.data["diseases"]
				return diseases[index]

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	if(length(beaker?.reagents?.reagent_list))
		for(var/datum/reagent/BL in beaker.reagents.reagent_list)
			if(BL?.data && BL.data["resistances"])
				var/list/resistances = BL.data["resistances"]
				return resistances[index]

/obj/machinery/computer/pandemic/proc/GetDiseaseTypeByIndex(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(disease)
		return disease.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, TRUE)

/obj/machinery/computer/pandemic/proc/add_random_symptom(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(!istype(disease, /datum/disease/virus/advance))
		balloon_alert(usr, "ошибка!")
		return

	var/datum/disease/virus/advance/advance_virus = disease
	GET_SKILL_LEVEL(usr, /datum/skill/medical/virusology, virusology_skill_level)
	var/random_symptom = null
	if(virusology_skill_level > SKILL_LEVEL_BASIC)
		var/list/random_symptoms = advance_virus.GenerateSymptoms(level_max = virusology_skill_level, count_of_symptoms = (2 + (virusology_skill_level-SKILL_LEVEL_BASIC)))
		random_symptom = tgui_input_list(usr, "Выберите симптом для добавления", "Добавление симптома", random_symptoms)
	else
		random_symptom = safepick(advance_virus.GenerateSymptoms(level_max = virusology_skill_level))

	if(random_symptom)
		advance_virus.AddSymptom(random_symptom)
		advance_virus.Refresh(reset_name = TRUE)


/obj/machinery/computer/pandemic/proc/remove_random_symptom(index)
	var/datum/disease/disease = GetDiseaseByIndex(index)
	if(!istype(disease, /datum/disease/virus/advance))
		balloon_alert(usr, "ошибка!")
		return

	var/datum/disease/virus/advance/advance_virus = disease
	GET_SKILL_LEVEL(usr, /datum/skill/medical/virusology, virusology_skill_level)
	var/random_symptom = null
	if(virusology_skill_level > SKILL_LEVEL_BASIC)
		random_symptom = tgui_input_list(usr, "Выберите симптом для удаления", "Удаление симптома", advance_virus.symptoms)
	else
		random_symptom = safepick(advance_virus.symptoms)

	if(random_symptom)
		advance_virus.RemoveSymptom(random_symptom)
		advance_virus.Refresh(reset_name = TRUE)
