// /datum/recipe/grill

/datum/recipe/grill
		required_skill_level = 5

/datum/recipe/grill/New()
	. = ..()

	if(!reagents)
		return

	var/list/randomized_reagents = list()

	for(var/reagent in reagents)
		var/amount = reagents[reagent]
		randomized_reagents[reagent] = rand(max(1, amount - 5), amount + 5)

	reagents = randomized_reagents

/datum/recipe/grill/bacon
	name = "Бекон"
	items = list(
		/obj/item/reagent_containers/food/snacks/raw_bacon,
	)
	result = /obj/item/reagent_containers/food/snacks/bacon

/datum/recipe/grill/telebacon
	name = "Теле-Бекон"
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/assembly/signaler,
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon

/datum/recipe/grill/syntitelebacon
	name = "Синтетический Теле-Бекон"
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/assembly/signaler,
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon

/datum/recipe/grill/friedegg
	name = "Яичница"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg

/datum/recipe/grill/birdsteak
	name = "Куринный стейк"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/bird,
	)
	result = /obj/item/reagent_containers/food/snacks/birdsteak

/datum/recipe/grill/meatsteak
	name = "Мясной стейк"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/salmonsteak
	name = "Рыбный стейк"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/salmonsteak

/datum/recipe/grill/syntisteak
	name = "Синтетический стейк"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/meatsteak_human
	name = "Стейк из человечины"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/human

/datum/recipe/grill/meatsteak_vulpkanin
	name = "Стейк из вульпканина"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/vulpkanin

/datum/recipe/grill/meatsteak_tajaran
	name = "Стейк из таяры"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "sodawater" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran,
		/obj/item/grown/nettle/basic,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/tajaran

/datum/recipe/grill/meatsteak_unathi
	name = "Стейк из унати"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "tomatojuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/unathi,
		/obj/item/reagent_containers/food/snacks/grown/harebell,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/unathi

/datum/recipe/grill/meatsteak_drask
	name = "Стейк из драска"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "capsaicin" = 10, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/drask,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/drask

/datum/recipe/grill/meatsteak_grey
	name = "Стейк из грея"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "tomatojuice" = 10, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/grey,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/grey

/datum/recipe/grill/meatsteak_skrell
	name = "Стейк из скрелла"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 5, "tomatojuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/skrell,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/skrell

/datum/recipe/grill/meatsteak_vox
	name = "Стейк из вокса"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vox,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/vox

/datum/recipe/grill/meatsteak_slime
	name = "Стейк из слизи"
	reagents = list("sodiumchloride" = 10, "sugar" = 5, "herbsmix" = 5, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/slime,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/slime

/datum/recipe/grill/meatsteak_wryn
	name = "Стейк из врина"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "orangejuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wryn,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/wryn

/datum/recipe/grill/meatsteak_kidan
	name = "Стейк из кидана"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/kidan,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/olive,
		/obj/item/reagent_containers/food/snacks/grown/olive,
		/obj/item/reagent_containers/food/snacks/grown/olive,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/kidan

/datum/recipe/grill/meatsteak_nian
	name = "Стейк из ниана"
	reagents = list("sodiumchloride" = 5, "sugar" = 5, "herbsmix" = 5, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/nian,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/nian

/datum/recipe/grill/meatsteak_diona
	name = "Стейк из дионы"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/diona

/datum/recipe/grill/meatsteak_monkey
	name = "Стейк из обезьяны"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/monkey

/datum/recipe/grill/meatsteak_farwa
	name = "Стейк из фарвы"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "grapejuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/farwa,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/farwa

/datum/recipe/grill/meatsteak_wolpin
	name = "Стейк из вульпы"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "potato" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wolpin,
		/obj/item/reagent_containers/food/snacks/onion_slice/red,
		/obj/item/reagent_containers/food/snacks/onion_slice/red,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/wolpin

/datum/recipe/grill/meatsteak_neara
	name = "Стейк из неары"
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2, "lemonjuice" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/neara,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/neara

/datum/recipe/grill/meatsteak_stok
	name = "Стейк из стока"
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2, "orangejuice" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/stok,
		/obj/item/reagent_containers/food/snacks/cucumberslice,
		/obj/item/reagent_containers/food/snacks/cucumberslice,
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/stok

/datum/recipe/grill/waffles
	name = "Вафли"
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/grill/rofflewaffles
	name = "Рофл-вафли"
	reagents = list("psilocybin" = 5, "sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/grill/grilledcheese
	name = "Грильд-чиз"
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/grilledcheese

/datum/recipe/grill/sausage
	name = "Сосиска"
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/sausage

/datum/recipe/grill/fishfingers
	name = "Рыбные палочки"
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishfingers

/datum/recipe/grill/fishfingers/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/fishfingers/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/grill/cutlet
	name = "Котлета"
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/cutlet

/datum/recipe/grill/omelette
	name = "Омлет"
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/omelette

/datum/recipe/grill/wingfangchu
	name = "Крыло Фенг-Чу"
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
	)
	result = /obj/item/reagent_containers/food/snacks/wingfangchu

/datum/recipe/grill/human/kabob
	name = "Мясной кебаб"
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
	)
	result = /obj/item/reagent_containers/food/snacks/kabob

/datum/recipe/grill/monkeykabob
	name = "Обезьянский кебаб"
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/syntikabob
	name = "Синтетический кебаб"
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/tofukabob
	name = "Тофу-кебаб"
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofukabob

/datum/recipe/grill/sushi_Tamago
	name = "Суши Тамаго"
	reagents = list("sake" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tamago

/datum/recipe/grill/sushi_Unagi
	name = "Суши Унаги"
	reagents = list("sake" = 5)
	items = list(
		/obj/item/fish/electric_eel,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Unagi

/datum/recipe/grill/sushi_Ebi
	name = "Суши Эби"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ebi

/datum/recipe/grill/sushi_Ikura
	name =  "Суши Икура"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/salmon,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ikura

/datum/recipe/grill/sushi_Inari
	name = "Суши Инара"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/fried_tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Inari

/datum/recipe/grill/sushi_Sake
	name = "Суши Саке"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Sake

/datum/recipe/grill/sushi_SmokedSalmon
	name = "Суши с копченым лососем"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonsteak,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon

/datum/recipe/grill/sushi_Masago
	name = "Суши Масаго"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/goldfish,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Masago

/datum/recipe/grill/sushi_Tobiko
	name = "Суши Тобико"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/shark,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tobiko

/datum/recipe/grill/sushi_TobikoEgg
	name = "Суши Тобико с яйцом"
	items = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg

/datum/recipe/grill/sushi_Tai
	name = "Суши Тай"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/catfishmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tai

/datum/recipe/grill/goliath
	name = "Стейк из голиафа"
	items = list(/obj/item/reagent_containers/food/snacks/monstermeat/goliath)
	result = /obj/item/reagent_containers/food/snacks/goliath_steak

/datum/recipe/grill/shrimp_skewer
	name = "Креветочный шашлык"
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/shrimp_skewer

/datum/recipe/grill/fish_skewer
	name = "Рыбный шашлык"
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/fish_skewer

/datum/recipe/grill/pancake
	name = "Блины"
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
	)
	result = /obj/item/reagent_containers/food/snacks/pancake

/datum/recipe/grill/berry_pancake
	name = "Блины с ягодами"
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/grown/berries,
	)
	result = /obj/item/reagent_containers/food/snacks/pancake/berry_pancake

/datum/recipe/grill/choc_chip_pancake
	name = "Блины с шоколадной крошкой"
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/choc_pile,
	)
	result = /obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake

/datum/recipe/grill/unathi
	name = "Жаренный хвост унати"
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "tsauce" = 1)
	items = list(
		/obj/item/organ/external/tail/unathi,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lizard

/datum/recipe/grill/plov
	name = "Плов"
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/rawcutlet,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
	)
	result = /obj/item/reagent_containers/food/snacks/plov
