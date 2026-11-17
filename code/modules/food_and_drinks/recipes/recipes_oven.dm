// /datum/recipe/oven

/datum/recipe/oven/New()
	. = ..()

	if(!reagents)
		return

	var/list/randomized_reagents = list()

	for(var/reagent in reagents)
		var/amount = reagents[reagent]
		randomized_reagents[reagent] = rand(max(1, amount - 5), amount + 5)

	reagents = randomized_reagents

/datum/recipe/oven/bun
	name = "Булка"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/bun
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/oven/meatbread
	name = "Мясной хлеб"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/meat
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/syntibread
	name = "Хлеб из синт-мяса"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/meat
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/xenomeatbread
	name = "Хлеб с мясом ксеносов"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/xeno
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/bananabread
	name = "Банановый хлеб"
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/banana
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/muffin
	name = "Маффин"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/muffin
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/carrotcake
	name = "Морковный торт"
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/carrotcake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/cheesecake
	name = "Чизкейк"
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/cheesecake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/plaincake
	name = "Торт"
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/plaincake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie
	name = "Мясной пирог"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_human
	name = "Пирог с человеческим мясом"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/organ/internal/liver,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/human
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_vulpkanin
	name = "Пирог с мясом вульпканина"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin,
		/obj/item/organ/internal/liver/vulpkanin,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/vulpkanin
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_tajaran
	name = "Пирог с мясом таярана"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran,
		/obj/item/organ/internal/liver/tajaran,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/tajaran
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_unathi
	name = "Пирог с мясом унатха"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/unathi,
		/obj/item/organ/internal/liver/unathi,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/unathi
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_drask
	name = "Пирог с мясом драска"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/drask,
		/obj/item/organ/internal/liver/drask,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/drask
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_grey
	name = "Пирог с мясом грея"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/grey,
		/obj/item/organ/internal/liver/grey,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/grey
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_skrell
	name = "Пирог с мясом скрелла"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/skrell,
		/obj/item/organ/internal/liver/skrell,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/skrell
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_vox
	name = "Пирог с мясом вокса"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vox,
		/obj/item/organ/internal/liver/vox,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/vox
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_slime
	name = "Пирог со слизью"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/slime,
		/obj/item/organ/internal/heart/slime,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/slime
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_wryn
	name = "Пирог с мясом вринов"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wryn,
		/obj/item/organ/internal/wryn/glands,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/wryn
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_kidan
	name = "Пирог с мясом кидана"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/kidan,
		/obj/item/organ/internal/liver/kidan,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/kidan
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_nian
	name = "Пирог с мясом ниана"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/nian,
		/obj/item/organ/internal/liver/nian,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/nian
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_diona
	name = "Пирог с мясом дионы"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/organ/internal/liver/diona,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/diona
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_monkey
	name = "Пирог с обезьяньим мясом"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/organ/internal/heart,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/monkey
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_farwa
	name = "Пирог с мясом фарвы"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/farwa,
		/obj/item/organ/internal/heart/tajaran,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/farwa
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_wolpin
	name = "Пирог с мясом вульпы"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wolpin,
		/obj/item/organ/internal/heart/vulpkanin,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/wolpin
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_neara
	name = "Пирог с мясом неары"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/neara,
		/obj/item/organ/internal/heart/skrell,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/neara
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpie_stok
	name = "Пирог с мясом стока"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/stok,
		/obj/item/organ/internal/heart/unathi,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/stok
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/tofupie
	name = "Пирог с тофу"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofupie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/xemeatpie
	name = "Пирог с мясом ксеносов"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/xemeatpie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/pie
	name = "Пирог"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/pie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/cherrypie
	name = "Вишнёвый пирог"
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/cherries,
	)
	result = /obj/item/reagent_containers/food/snacks/cherrypie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/berryclafoutis
	name = "Ягодный клафути"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/berryclafoutis
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/tofubread
	name = "Хлеб с тофу"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/tofu
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/loadedbakedpotato
	name = "Фаршированный запечённый картофель"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/yakiimo
	name = "Якиимо"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet,
	)
	result = /obj/item/reagent_containers/food/snacks/yakiimo
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

//cookies by Ume
/datum/recipe/oven/cookies
	name = "Шоколадное печенье"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies/chocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/sugarcookies
	name = "Сахарное печенье"
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/sugarcookie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/fortunecookie
	name = "Печенье с предсказанием"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/snacks/fortunecookie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/fortunecookie/make_food(obj/container)
	var/obj/item/paper/P = locate() in container
	P.loc = null //So we don't delete the paper while cooking the cookie
	var/obj/item/reagent_containers/food/snacks/fortunecookie/being_cooked = ..()
	if(P.info) //If there's anything written on the paper, just move it into the fortune cookie
		P.forceMove(being_cooked) //Prevents the oven deleting our paper
		being_cooked.trash = P //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	else
		qdel(P)
	return being_cooked

/datum/recipe/oven/pizzamargherita
	name = "Пицца «Маргарита»"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/meatpizza
	name = "Мясная пицца"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/syntipizza
	name = "Пицца с синт-мясом"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/mushroompizza
	name = "Грибная пицца"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/vegetablepizza
	name = "Овощная пицца"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/hawaiianpizza
	name = "Гавайская пицца"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/macncheesepizza
	name = "Пицца с макаронами и сыром"
	reagents = list("tsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/macncheese,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/macpizza
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/seapizza
	name = "Пицца с морепродуктами"
	reagents = list("herbsmix" = 1, "gsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/seafood
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/tajarpizza
	name = "Пицца по-таярански"
	reagents = list("herbsmix" = 1, "tsauce" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/tajaroni,
		/obj/item/reagent_containers/food/snacks/grown/olive,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/tajaroni
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/baconpizza
	name = "Пицца с беконом"
	reagents = list("msauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/raw_bacon,
		/obj/item/reagent_containers/food/snacks/raw_bacon,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/bacon
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/diablopizza
	name = "Пицца «Дьябло»"
	reagents = list("herbsmix" = 1, "dsauce" = 1, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/diablo
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/amanita_pie
	name = "Пирог с мухомором"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/amanita_pie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/plump_pie
	name = "Пышный пирог"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
	)
	result = /obj/item/reagent_containers/food/snacks/plump_pie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/plumphelmetbiscuit
	name = "Бисквит из толстошлемника"
	reagents = list("water" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/creamcheesebread
	name = "Хлеб со сливочным сыром"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/baguette
	name = "Багет"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/baguette
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/birthdaycake
	name = "Именинный торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/clothing/head/cakehat,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/bread
	name = "Хлеб"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/oven/bread/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sliceable/bread/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/applepie
	name = "Яблочный пирог"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/applepie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/applecake
	name = "Яблочный торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/applecake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/orangecake
	name = "Апельсиновый торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/orangecake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/bananacake
	name = "Банановый торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bananacake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/limecake
	name = "Лаймовый торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/limecake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/lemoncake
	name = "Лимонный торт"
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lemoncake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL


/datum/recipe/oven/chocolatecake
	name = "Шоколадный торт"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/chocolatecake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/braincake
	name = "Торт с мозгом"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/organ/internal/brain,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/braincake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/pumpkinpie
	name = "Тыквенный пирог"
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/appletart
	name = "Шарлотка"
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold,
	)
	result = /obj/item/reagent_containers/food/snacks/appletart
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/appletart/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/appletart/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/cracker
	name = "Крекер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
	)
	result = /obj/item/reagent_containers/food/snacks/cracker
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/oven/sugarcookie/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sugarcookie/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/flatbread
	name = "Лепёшка"
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/flatbread
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/oven/toastedsandwich
	name = "Поджаренный сэндвич"
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwich,
	)
	result = /obj/item/reagent_containers/food/snacks/toastedsandwich
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/oven/turkey  // Magic
	name = "Запечённая индейка"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/stuffing,
		/obj/item/reagent_containers/food/snacks/stuffing,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/turkey
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/tofurkey
	name = "Индейка из тофу"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/stuffing,
	)
	result = /obj/item/reagent_containers/food/snacks/tofurkey
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/lasagna
	name = "Лазанья"
	reagents = list("sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/lasagna
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/tajaroni
	name = "Таярони"
	reagents = list("blackpepper" = 1)
	items = list(
		/obj/item/organ/external/tail/tajaran,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/tajaroni
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/vuplix
	name = "Вульпикс"
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "tsauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/vulpixchilli
	name = "Вульпикс с чили"
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "dsauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/chilli
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/vulpixcheese
	name = "Вульпикс с сыром"
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "csauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/cheese
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/vulpixbacon
	name = "Вульпикс с беконом"
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "msauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/raw_bacon,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/bacon
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/slimepie
	name = "Пирог со слизью"
	reagents = list("custard" = 1, "milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/organ/internal/heart/slime,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/slimepie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

//////////////////////////////////////////
//onyx bay food
//////////////////////////////////////////

/datum/recipe/oven/bunbun
	name = "Бан-бан"
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/bunbun
	required_skill_level = SKILL_LEVEL_BEGINNER
/datum/recipe/oven/choccherrycake
	name = "Шоколадно-вишнёвый торт"
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/grown/cherries,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/choccherrycake
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/smokedsausage
	name = "Копчёная колбаса"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sausage,
	)
	result = /obj/item/reagent_containers/food/snacks/smokedsausage
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/salami
	name = "Салями"
	reagents = list("gsauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/smokedsausage,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/salami
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/sundae
	name = "Сандей"
	reagents = list("cream" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cherries,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/doughslice,
	)
	result = /obj/item/reagent_containers/food/snacks/sundae
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/noel
	name = "Ноэль"
	reagents = list("flour" = 15, "cream" = 10, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/noel
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

//////////////////////////////////////////
//Reinforced cheese
//////////////////////////////////////////
/datum/recipe/oven/reinforcedcheese
	name = "Лист сыра"
	reagents = list("sodiumchloride" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel,
	)
	result = /obj/item/stack/sheet/cheese
	required_skill_level = SKILL_LEVEL_LEGEND

/datum/recipe/oven/bakedvulp
	name = "Запечённый вульпканин"
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/external/head/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/bakedvulp
	required_skill_level = SKILL_LEVEL_PROFESSIONAL
//////////////////////////////////////////
//Reinforced gingerbread
//////////////////////////////////////////
/datum/recipe/oven/reinforcedgingerbread
	name = "Твёрдый пряник"
	reagents = list("sodiumchloride" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/gingercookie,
		/obj/item/reagent_containers/food/snacks/gingercookie,
	)
	result = /obj/item/stack/sheet/gingerbread/five
	required_skill_level = SKILL_LEVEL_LEGEND

//////////////////////////////////////////
//Ginger cookies
//////////////////////////////////////////

/datum/recipe/oven/gingercokie
	name = "Имбирное печенье"
	reagents = list("sugar" = 1, "milk" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/ball
	name = "Имбирное печенье (шарик)"
	reagents = list("sugar" = 2, "milk" = 2)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough, /obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/ball
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/cane
	name = "Имбирное печенье (трость)"
	reagents = list("sugar" = 3, "milk" = 3)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/cane
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/heart
	name = "Имбирное печенье (сердце)"
	reagents = list("sugar" = 4, "milk" = 4)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/heart
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/home
	name = "Имбирное печенье (домик)"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/home
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/mitten
	name = "Имбирное печенье (варежка)"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/mitten
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/gingercokie/tree
	name = "Имбирное печенье (ёлка)"
	reagents = list("sugar" = 10, "milk" = 10)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough, /obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/tree
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

//////////////////////////////////////////
//Carbon dulce Feliz Navidad
//////////////////////////////////////////

/datum/recipe/oven/sugar_coal
	name = "Сахарный уголь"
	reagents = list("charcoal" = 5, "sugar" = 5, "egg" = 5)
	result = /obj/item/reagent_containers/food/snacks/sugar_coal
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/oven/croissant
	name = "Круассан"
	reagents = list("milk" = 5, "sugar" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/croissant
	required_skill_level = SKILL_LEVEL_PROFESSIONAL
