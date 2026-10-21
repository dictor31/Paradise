
/*
* /datum/recipe/candy/
*	reagents = list()
*	items = list()
*	result = /obj/item/reagent_containers/food/snacks/
*	byproduct = /obj/item/		// only set this if the recipe has a byproduct, like returning it's mould
*
* NOTE: If using a mould, make sure to list it in *BOTH* the items and byproduct lists if it is to be returned.
* Failure to list in both places will result in either consumption of the mould, or spontaneous generation of a mould.
*
*/

// ***********************************************************
// Candy Ingredients / Flavorings Recipes
// ***********************************************************

/datum/recipe/candy/New()
	. = ..()

	if(!reagents)
		return

	var/list/randomized_reagents = list()

	for(var/reagent in reagents)
		var/amount = reagents[reagent]
		randomized_reagents[reagent] = rand(max(1, amount - 5), amount + 5)

	reagents = randomized_reagents

/datum/recipe/candy/chocolate_bar
	name = "Шоколадная плитка на соевом молоке"
	reagents = list("soymilk" = 2, "cocoa" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/reagent_containers/food/snacks/chocolatebar

/datum/recipe/candy/chocolate_bar2
	name = "Шоколадная плитка на молоке"
	reagents = list("milk" = 2, "cocoa" = 2, "sugar" = 2)
	items = list()
	result = /obj/item/reagent_containers/food/snacks/chocolatebar

/datum/recipe/candy/fudge_peanut
	name = "Шоколадная долька с арахисом"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/chocolatebar, /obj/item/reagent_containers/food/snacks/grown/peanuts,
		/obj/item/reagent_containers/food/snacks/grown/peanuts, /obj/item/reagent_containers/food/snacks/grown/peanuts,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/fudge/peanut

/datum/recipe/candy/fudge_cherry
	name = "Шоколадная долька с вишней"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/chocolatebar, /obj/item/reagent_containers/food/snacks/grown/cherries,
		/obj/item/reagent_containers/food/snacks/grown/cherries, /obj/item/reagent_containers/food/snacks/grown/cherries,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/fudge/cherry

/datum/recipe/candy/fudge_cookies_n_cream
	name = "Шоколадная долька с печеньем и сливками"
	reagents = list("sugar" = 5, "milk" = 5, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/cookie,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/fudge/cookies_n_cream

/datum/recipe/candy/fudge_turtle
	name = "Шоколадная долька «Черепашка»"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/candy/caramel,
		/obj/item/reagent_containers/food/snacks/grown/peanuts,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/fudge/turtle

/datum/recipe/candy/fudge
	name = "Шоколадная долька"
	reagents = list("sugar" = 5, "milk" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/chocolatebar)
	result = /obj/item/reagent_containers/food/snacks/candy/fudge

/datum/recipe/candy/caramel
	name = "Карамель"
	reagents = list("sugar" = 5, "cream" = 5)
	items = list()
	result = /obj/item/reagent_containers/food/snacks/candy/caramel

/datum/recipe/candy/toffee
	name = "Ириска"
	reagents = list("sugar" = 5, "flour" = 10)
	result = /obj/item/reagent_containers/food/snacks/candy/toffee

/datum/recipe/candy/taffy
	name = "Тянучка"
	reagents = list("salglu_solution" = 15)
	items = list()
	result = /obj/item/reagent_containers/food/snacks/candy/taffy

/datum/recipe/candy/nougat
	name = "Нуга"
	reagents = list("sugar" = 5, "cornoil" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/egg)
	result = /obj/item/reagent_containers/food/snacks/candy/nougat

/datum/recipe/candy/nougat/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/candy/nougat/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

// ***********************************************************
// Base Candy Recipes (unflavored / plain)
// ***********************************************************

/datum/recipe/candy/cottoncandy
	name = "Сахарная вата"
	reagents = list("sugar" = 15)
	items = list(
		/obj/item/c_tube,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton

/datum/recipe/candy/gummybear
	name = "Жевательный мишка"
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/bear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear
	byproduct = /obj/item/kitchen/mould/bear

/datum/recipe/candy/gummyworm
	name = "Жевательный червячок"
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/worm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm
	byproduct = /obj/item/kitchen/mould/worm

/datum/recipe/candy/jellybean
	name = "Мармеладный боб"
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/bean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean
	byproduct = /obj/item/kitchen/mould/bean

/datum/recipe/candy/jawbreaker
	name = "Зубодробитель"
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/ball,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jawbreaker
	byproduct = /obj/item/kitchen/mould/ball

/datum/recipe/candy/candycane
	name = "Леденец-трость"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/kitchen/mould/cane,
		/obj/item/reagent_containers/food/snacks/mint,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/candycane
	byproduct = /obj/item/kitchen/mould/cane

/datum/recipe/candy/gum
	name = "Жевательная резинка"
	reagents = list("sugar" = 5, "water" = 5, "cornoil" = 5)
	items = list()
	result = /obj/item/reagent_containers/food/snacks/candy/gum

/datum/recipe/candy/candybar
	name = "Шоколадный батончик"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/candybar

/datum/recipe/candy/cash
	name = "Шоколадная купюра"
	items = list(
		/obj/item/kitchen/mould/cash,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cash
	byproduct = /obj/item/kitchen/mould/cash

/datum/recipe/candy/coin
	name = "Шоколадная монета"
	items = list(
		/obj/item/kitchen/mould/coin,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/coin
	byproduct = /obj/item/kitchen/mould/coin

/datum/recipe/candy/sucker
	name = "Леденец на палочке"
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/kitchen/mould/loli,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/sucker
	byproduct = /obj/item/kitchen/mould/loli

// ***********************************************************
// Cotton Candy Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/cottoncandy_red
	name = "Красная сахарная вата"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/red

/datum/recipe/candy/cottoncandy_blue
	name = "Голубая сахарная вата"
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/blue

/datum/recipe/candy/cottoncandy_poison
	name = "Ядовитая сахарная вата"
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/poison

/datum/recipe/candy/cottoncandy_green
	name = "Зелёная сахарная вата"
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/green

/datum/recipe/candy/cottoncandy_yellow
	name = "Жёлтая сахарная вата"
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/yellow

/datum/recipe/candy/cottoncandy_orange
	name = "Оранжевая сахарная вата"
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/orange

/datum/recipe/candy/cottoncandy_purple
	name = "Фиолетовая сахарная вата"
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/purple

/datum/recipe/candy/cottoncandy_pink
	name = "Розовая сахарная вата"
	reagents = list("watermelonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/pink

/datum/recipe/candy/cottoncandy_rainbow
	name = "Радужная сахарная вата"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton/red,
		/obj/item/reagent_containers/food/snacks/candy/cotton/blue,
		/obj/item/reagent_containers/food/snacks/candy/cotton/green,
		/obj/item/reagent_containers/food/snacks/candy/cotton/yellow,
		/obj/item/reagent_containers/food/snacks/candy/cotton/orange,
		/obj/item/reagent_containers/food/snacks/candy/cotton/purple,
		/obj/item/reagent_containers/food/snacks/candy/cotton/pink,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/rainbow

/datum/recipe/candy/cottoncandy_rainbow2
	name = "Не Радужная сахарная вата"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/cotton/red,
		/obj/item/reagent_containers/food/snacks/candy/cotton/poison,
		/obj/item/reagent_containers/food/snacks/candy/cotton/green,
		/obj/item/reagent_containers/food/snacks/candy/cotton/yellow,
		/obj/item/reagent_containers/food/snacks/candy/cotton/orange,
		/obj/item/reagent_containers/food/snacks/candy/cotton/purple,
		/obj/item/reagent_containers/food/snacks/candy/cotton/pink,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow

// ***********************************************************
// Gummy Bear Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummybear_red
	name = "Красный жевательный мишка"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/red

/datum/recipe/candy/gummybear_blue
	name = "Голубой жевательный мишка"
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/blue

/datum/recipe/candy/gummybear_poison
	name = "Ядовитый жевательный мишка"
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/poison

/datum/recipe/candy/gummybear_green
	name = "Зелёный жевательный мишка"
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/green

/datum/recipe/candy/gummybear_yellow
	name = "Жёлтый жевательный мишка"
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/yellow

/datum/recipe/candy/gummybear_orange
	name = "Оранжевый жевательный мишка"
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/orange

/datum/recipe/candy/gummybear_purple
	name = "Фиолетовый жевательный мишка"
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/purple

/datum/recipe/candy/gummybear_wtf
	name = "Странный жевательный мишка"
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummybear,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/wtf

/datum/recipe/candy/gummybear_wtf2
	name = "Странный жевательный мишка с амброзией"
	reagents = list()
	items = list(/obj/item/reagent_containers/food/snacks/candy/gummybear, /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris)
	result = /obj/item/reagent_containers/food/snacks/candy/gummybear/wtf

// ***********************************************************
// Gummy Worm Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/gummyworm_red
	name = "Красный жевательный червячок"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/red

/datum/recipe/candy/gummyworm_blue
	name = "Голубой жевательный червячок"
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/blue

/datum/recipe/candy/gummyworm_poison
	name = "Ядовитый жевательный червячок"
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/poison

/datum/recipe/candy/gummyworm_green
	name = "Зелёный жевательный червячок"
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/green

/datum/recipe/candy/gummyworm_yellow
	name = "Жёлтый жевательный червячок"
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/yellow

/datum/recipe/candy/gummyworm_orange
	name = "Оранжевый жевательный червячок"
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/orange

/datum/recipe/candy/gummyworm_purple
	name = "Фиолетовый жевательный червячок"
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/purple

/datum/recipe/candy/gummyworm_wtf
	name = "Странный жевательный червячок"
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/gummyworm,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/wtf

/datum/recipe/candy/gummyworm_wtf2
	name = "Странный жевательный червячок с амброзией"
	items = list(/obj/item/reagent_containers/food/snacks/candy/gummyworm, /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris)
	result = /obj/item/reagent_containers/food/snacks/candy/gummyworm/wtf

// ***********************************************************
// Jelly Bean Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/jellybean_red
	name = "Красный мармеладный боб"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/red

/datum/recipe/candy/jellybean_blue
	name = "Голубой мармеладный боб"
	reagents = list("berryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/blue

/datum/recipe/candy/jellybean_poison
	name = "Ядовитый мармеладный боб"
	reagents = list("poisonberryjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/poison

/datum/recipe/candy/jellybean_green
	name = "Зелёный мармеладный боб"
	reagents = list("limejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/green

/datum/recipe/candy/jellybean_yellow
	name = "Жёлтый мармеладный боб"
	reagents = list("lemonjuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/yellow

/datum/recipe/candy/jellybean_orange
	name = "Оранжевый мармеладный боб"
	reagents = list("orangejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/orange

/datum/recipe/candy/jellybean_purple
	name = "Фиолетовый мармеладный боб"
	reagents = list("grapejuice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/purple

/datum/recipe/candy/jellybean_chocolate
	name = "Шоколадный мармеладный боб"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/chocolate

/datum/recipe/candy/jellybean_cola
	name = "Мармеладный боб со вкусом колы"
	reagents = list("cola" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/cola

/datum/recipe/candy/jellybean_popcorn
	name = "Мармеладный боб с попкорном"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/popcorn,
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/popcorn

/datum/recipe/candy/jellybean_coffee
	name = "Мармеладный боб со вкусом кофе"
	reagents = list("coffee" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/cola

/datum/recipe/candy/jellybean_drgibb
	name = "Мармеладный боб со вкусом Dr. Gibb"
	reagents = list("dr_gibb" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/cola

/datum/recipe/candy/jellybean_wtf
	name = "Странный мармеладный боб"
	reagents = list("space_drugs" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/jellybean,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/wtf

/datum/recipe/candy/jellybean_wtf2
	name = "Странный мармеладный боб с амброзией"
	items = list(/obj/item/reagent_containers/food/snacks/candy/jellybean, /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris)
	result = /obj/item/reagent_containers/food/snacks/candy/jellybean/wtf

// ***********************************************************
// Candybar Recipes (flavored)
// ***********************************************************

/datum/recipe/candy/malper
	name = "Карамельный батончик"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/candybar,
		/obj/item/reagent_containers/food/snacks/candy/caramel,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/confectionery/caramel

/datum/recipe/candy/toolerone
	name = "Нуга в шоколаде"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/candybar,
		/obj/item/reagent_containers/food/snacks/candy/nougat,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/confectionery/nougat

/datum/recipe/candy/yumbaton
	name = "Ирисовый батончик"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/candybar,
		/obj/item/reagent_containers/food/snacks/candy/toffee,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/confectionery/toffee

/datum/recipe/candy/crunch
	name = "Хрустящий рисовый батончик"
	reagents = list("rice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/candybar,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/confectionery/rice

/datum/recipe/candy/toxinstest
	name = "Токсичная бомба"
	reagents = list()
	items = list(
		/obj/item/reagent_containers/food/snacks/candy/candybar,
		/obj/item/reagent_containers/food/snacks/candy/caramel,
		/obj/item/reagent_containers/food/snacks/candy/nougat,
	)
	result = /obj/item/reagent_containers/food/snacks/candy/confectionery/caramel_nougat
