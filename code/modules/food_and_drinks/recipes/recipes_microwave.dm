// see code/datums/recipe.dm

/datum/recipe/microwave/New()
	. = ..()

	if(!reagents)
		return

	var/list/randomized_reagents = list()

	for(var/reagent in reagents)
		var/amount = reagents[reagent]
		randomized_reagents[reagent] = rand(max(1, amount - 5), amount + 5)

	reagents = randomized_reagents

/datum/recipe/microwave/boiledegg
	name = "Варённое яйцо"
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledegg
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/microwave/dionaroast
	name = "Диона-жаркое"
	reagents = list("facid" = 5) //It dissolves the carapace. Still poisonous, though.
	items = list(
		/obj/item/holder/diona,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/dionaroast
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/jellydonut
	name = "Желейный пончик"
	reagents = list("berryjuice" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/jellydonut/slime
	name = "Желейный пончик со слизью"
	reagents = list("slimejelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/jellydonut/cherry
	name = "Желейный пончик с вишней"
	reagents = list("cherryjelly" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/jelly/cherryjelly
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/donut
	name = "Пончик"
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/donut/sprinkles
	name = "Пончик с глазурью"
	reagents = list("sugar" = 5, "sprinkles" = 2)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/sprinkles
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/human/burger
	name = "Бургер..."
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/human_burger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/plainburger
	name = "Бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat, //do not place this recipe before /datum/recipe/microwave/human_burger
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/syntiburger
	name = "Бургер из синтетического мяса"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeyburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/xenoburger
	name = "Ксенобургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/organ/internal/brain/xeno,
	)
	result = /obj/item/reagent_containers/food/snacks/xenoburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/brainburger
	name = "Мозговой бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/organ/internal/brain,
	)
	result = /obj/item/reagent_containers/food/snacks/brainburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/roburger
	name = "Робургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/robot_parts/head,
	)
	result = /obj/item/reagent_containers/food/snacks/roburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/fishburger
	name = "Рыбный бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/tofuburger
	name = "Тофу-бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofuburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/ghostburger
	name = "Призрачный бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/ectoplasm, //where do you even find this stuff
	)
	result = /obj/item/reagent_containers/food/snacks/ghostburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/clownburger
	name = "Клоунский бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/mask/gas/clown_hat,
	)
	result = /obj/item/reagent_containers/food/snacks/clownburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mimeburger
	name = "Мимский бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/beret,
	)
	result = /obj/item/reagent_containers/food/snacks/mimeburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/baseballburger
	name = "Бейсбольный бургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/melee/baseball_bat,
	)
	result = /obj/item/reagent_containers/food/snacks/baseballburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cheeseburger
	name = "Чизбургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheeseburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/hotdog
	name = "Хот-дог"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/sausage,
	)
	result = /obj/item/reagent_containers/food/snacks/hotdog
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/donkpocket
	name = "Донк-пакет"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/donkpocket
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/warmdonkpocket
	name = "Тёплый донк-пакет"
	items = list(
		/obj/item/reagent_containers/food/snacks/donkpocket,
	)
	result = /obj/item/reagent_containers/food/snacks/warmdonkpocket
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/eggplantparm
	name = "Пармиджана из баклажанов"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
	)
	result = /obj/item/reagent_containers/food/snacks/eggplantparm
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/soylentviridians
	name = "Сойлент Виридиан"
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
	)
	result = /obj/item/reagent_containers/food/snacks/soylentviridians
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/soylentgreen
	name = "Зеленый Сойлент"
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
	)
	result = /obj/item/reagent_containers/food/snacks/soylentgreen
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/chaosdonut
	name = "Хаотичный пончик"
	reagents = list("frostoil" = 5, "capsaicin" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/donut/chaos
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cheesyfries
	name = "Картофель фри с сыром"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheesyfries
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cubancarp
	name = "Кубинский карп"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/carpmeat,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/food/snacks/cubancarp
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/popcorn
	name = "Попкорн"
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/popcorn
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/microwave/spacylibertyduff
	name = "Расширитель сознания"
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap,
	)
	result = /obj/item/reagent_containers/food/snacks/spacylibertyduff
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/amanitajelly
	name = "Желе из мухомора"
	reagents = list("water" = 5, "vodka" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita,
	)
	result = /obj/item/reagent_containers/food/snacks/amanitajelly
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/amanitajelly/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/amanitajelly/being_cooked = ..()
	being_cooked.reagents.del_reagent("amanitin")
	return being_cooked

//Soup
/datum/recipe/microwave/meatballsoup
	name = "Суп с фрикадельками"
	reagents = list("water" = 10, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/meatballsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/slimesoup
	name = "Суп из слизи"
	reagents = list("water" = 10, "slimejelly" = 5, "sodiumchloride" = 1)
	result = /obj/item/reagent_containers/food/snacks/soup/slimesoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/bloodsoup
	name = "Кровяной суп"
	reagents = list("blood" = 10, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato/blood,
		/obj/item/reagent_containers/food/snacks/grown/tomato/blood,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/bloodsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/clownstears
	name = "Слёзы Клоуна"
	reagents = list("water" = 10)
	items = list(
		/obj/item/stack/ore/bananium,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/clownstears
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/vegetablesoup
	name = "Овощной суп"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/vegetablesoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/nettlesoup
	name = "Крапивный суп"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/grown/nettle/basic,
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/nettlesoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mysterysoup
	name = "Загадочный суп"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/badrecipe,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mysterysoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/sawdustsoup
	name = "Суп из опилок"
	reagents = list("water" = 20)
	items = list(
		/obj/item/stack/sheet/wood,
		/obj/item/stack/sheet/wood,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/sawdustsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/tomatosoup
	name = "Томатный суп"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/tomatosoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/rassolnik
	name = "Рассольник"
	reagents = list("water" = 10, "rice" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/cucumber,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/rassolnik
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/wishsoup
	name = "Суп желаний"
	reagents = list("water" = 20)
	result = /obj/item/reagent_containers/food/snacks/soup/wishsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/misosoup
	name = "Мисосиру"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/misosoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mushroomsoup
	name = "Грибной суп"
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/mushroomsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/beetsoup
	name = "Свекольный суп"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/whitebeet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/beetsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/stew
	name = "Рагу"
	reagents = list("water" = 10)
	items= list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/stew
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/stewedsoymeat
	name = "Тушенное соевое мясо"
	reagents = list("water" = 10, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/soydope,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/stewedsoymeat
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/hotchili
	name = "Острый чили"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/hotchili
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/coldchili
	name = "Холодный чили"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/grown/icepepper,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/coldchili
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/shavelsoup
	name = "Щавелевый суп"
	reagents = list("water" = 10, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/shavel,
	)
	result = /obj/item/reagent_containers/food/snacks/soup/shavelsoup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/spellburger
	name = "Спеллбургер"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/clothing/head/wizard,
	)
	result = /obj/item/reagent_containers/food/snacks/spellburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/bigbiteburger
	name = "Большой бургер"
	reagents = list("sodiumchloride" = 3)
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeyburger,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/bigbiteburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/enchiladas
	name = "Энчилада"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/enchiladas
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/burrito
	name = "Буррито"
	reagents = list("capsaicin" = 5, "rice" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/beans,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/burrito
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/monkeysdelight
	name = "Обезьяний восторг"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/monkeycube,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeysdelight
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/fishandchips
	name = "Рыба с жареной картошкой"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/fries,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishandchips
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/sandwich
	name = "Сэндвич"
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sandwich
	required_skill_level = SKILL_LEVEL_BEGINNER

/datum/recipe/microwave/slimetoast
	name = "Тост со слаймовым желе"
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/slime
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/jelliedtoast
	name = "Тост с вишневым желе"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jelliedtoast/cherry
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/boiledspaghetti
	name = "Варённые спагетти"
	reagents = list("water" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledspaghetti
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/boiledrice
	name = "Варённый рис"
	reagents = list("water" = 5, "rice" = 10)
	result = /obj/item/reagent_containers/food/snacks/boiledrice
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/ricepudding
	name = "Рисовый пудинг"
	reagents = list("milk" = 5, "rice" = 10)
	result = /obj/item/reagent_containers/food/snacks/ricepudding
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/boiledbuckwheat
	name = "Варённая гречка"
	reagents = list("water" = 5, "buckwheat" = 10)
	result = /obj/item/reagent_containers/food/snacks/boiledbuckwheat
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/buckwheat_merchant
	name = "Гречка по-купечески"
	reagents = list("water" = 5, "buckwheat" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/buckwheat_merchant
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/pastatomato
	name = "Паста с помидорами"
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/pastatomato
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/poppypretzel
	name = "Крендель с маком"
	reagents = list("sodiumchloride" = 1, "sugar" = 5)
	items = list(
		/obj/item/seeds/poppy,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/poppypretzel
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/meatballspaggetti
	name = "Спагетти с тефтелями"
	reagents = list("water" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/meatballspaghetti
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/spesslaw
	name = "Спагетти законника"
	reagents = list("water" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/spaghetti,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/spesslaw
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/macncheese
	name = "Макароны с сыром"
	reagents = list("water" = 5, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/macaroni,
	)
	result = /obj/item/reagent_containers/food/snacks/macncheese
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/superbiteburger
	name = "Супербургер"
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bigbiteburger,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/superbiteburger
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/candiedapple
	name = "Яблоко с карамелью"
	reagents = list("water" = 5, "sugar" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/apple)
	result = /obj/item/reagent_containers/food/snacks/candiedapple
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/slimeburger
	name = "Слаймовый бургер"
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/jellyburger/slime
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/jellyburger
	name = "Вишневый бургер"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
	)
	result = /obj/item/reagent_containers/food/snacks/jellyburger/cherry
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/twobread
	name = "Два хлеба"
	reagents = list("wine" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/twobread
	required_skill_level = SKILL_LEVEL_NONE

/datum/recipe/microwave/slimesandwich
	name = "Сэндвич со слаймовым желе"
	reagents = list("slimejelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/slime
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cherrysandwich
	name = "Сэндвич с вишнёвым желе"
	reagents = list("cherryjelly" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/jellysandwich/cherry
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/boiledslimeextract
	name = "Варёный экстракт"
	reagents = list("water" = 5)
	items = list(
		/obj/item/slime_extract,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledslimecore
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mint
	name = "Мятная конфета"
	reagents = list("toxin" = 5)
	result = /obj/item/reagent_containers/food/snacks/mint
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/chocolateegg
	name = "Шоколадное яйцо"
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/chocolateegg
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/chawanmushi
	name = "Омлет на пару"
	reagents = list("water" = 5, "soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/reagent_containers/food/snacks/chawanmushi
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/herbsalad
	name = "Травяной салат"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/herbsalad
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/herbsalad/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/herbsalad/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

/datum/recipe/microwave/aesirsalad
	name = "Эйси-салат"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold,
	)
	result = /obj/item/reagent_containers/food/snacks/aesirsalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/validsalad
	name = "Полезный салат"
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/meatball,
	)
	result = /obj/item/reagent_containers/food/snacks/validsalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/vegisalad
	name = "Овощной салат"
	reagents = list("cream" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cucumber,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/food/snacks/vegisalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/oliviersalad
	name = "Оливье"
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pickles,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sausage,
	)
	result = /obj/item/reagent_containers/food/snacks/oliviersalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/weirdoliviersalad
	name = "Странное оливье"
	reagents = list("cream" = 10, "sodiumchloride" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/pickles,
		/obj/item/reagent_containers/food/snacks/boiledegg,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sausage,
		/obj/item/reagent_containers/food/snacks/grown/apple,
	)
	result = /obj/item/reagent_containers/food/snacks/weirdoliviersalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/validsalad/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/validsalad/being_cooked = ..()
	being_cooked.reagents.del_reagent("toxin")
	return being_cooked

////////////////////////////FOOD ADDITTIONS///////////////////////////////

/datum/recipe/microwave/wrap
	name = "Ёка"
	reagents = list("soysauce" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/friedegg,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/wrap
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/beans
	name = "Бобы"
	reagents = list("ketchup" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
	)
	result = /obj/item/reagent_containers/food/snacks/beans
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/benedict
	name = "Бенедикт"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/friedegg,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/breadslice,
	)
	result = /obj/item/reagent_containers/food/snacks/benedict
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/meatbun
	name = "Мясная булочка"
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/meatbun
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/icecreamsandwich
	name = "Мороженое-сэндвич"
	reagents = list("ice" = 5, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/icecream,
	)
	result = /obj/item/reagent_containers/food/snacks/icecreamsandwich
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/notasandwich
	name = "Не-сэндвич"
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/clothing/mask/fakemoustache,
	)
	result = /obj/item/reagent_containers/food/snacks/notasandwich
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/friedbanana
	name = "Жаренный банан"
	reagents = list("sugar" = 10, "cornoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	result = /obj/item/reagent_containers/food/snacks/friedbanana
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/stuffing
	name = "Хлебная начинка"
	reagents = list("water" = 5, "sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/bread,
	)
	result = /obj/item/reagent_containers/food/snacks/stuffing
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/boiledspiderleg
	name = "Варёная нога паука"
	reagents = list("water" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spiderleg,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledspiderleg
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/spidereggsham
	name = "Паучьи яица и ветчина"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs,
		/obj/item/reagent_containers/food/snacks/monstermeat/spidermeat,
	)
	result = /obj/item/reagent_containers/food/snacks/spidereggsham
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/sashimi
	name = "Сашими"
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/spidereggs,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sashimi
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mashedtaters
	name = "Картофельное пюре"
	reagents = list("gravy" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato,
	)
	result = /obj/item/reagent_containers/food/snacks/mashed_potatoes
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/shawarma
	name = "Шаурма"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/shawarma
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/doner_cheese
	name = "Донер с сыром"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/doner_cheese
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/doner_mushroom
	name = "Донер с грибами"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meatsteak,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/doner_mushroom
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/doner_vegan
	name = "Веганский донер"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
	)
	result = /obj/item/reagent_containers/food/snacks/doner_vegan
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/kidan_ragu
	name = "Киданский рагу"
	reagents = list("water" = 10, "sodiumchloride" = 1)
	items = list(
		/obj/item/organ/external/head/kidan,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/food/snacks/kidanragu
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/tomato_sauce
	name = "Томатный соус"
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
	)
	result = /obj/item/reagent_containers/condiment/tomatosauce
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/diablo_sauce
	name = "Соус Диабло"
	reagents = list("water" = 15, "sodiumchloride" = 1, "blackpepper" = 2, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/condiment/diablosauce
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cheese_sauce
	name = "Сырный соус"
	reagents = list("milk" = 15, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/condiment/cheesesauce
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mushroom_sauce
	name = "Грибной соус"
	reagents = list("milk" = 15, "cream" = 5, "sodiumchloride" = 1,)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/onion,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
	)
	result = /obj/item/reagent_containers/condiment/mushroomsauce
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/garlic_sauce
	name = "Чесночный соус"
	reagents = list("water" = 15, "sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/cucumber,
	)
	result = /obj/item/reagent_containers/condiment/garlicsauce
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/custard
	name = "Крем-брюле"
	reagents = list("sugar" = 10, "milk" = 10, "cream" = 5, "vanilla" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/condiment/custard
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

//////////////////////////////////////////
// bs12 food port stuff
//////////////////////////////////////////

/datum/recipe/microwave/taco
	name = "Тако"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/taco
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/mint_2
	name = "Мятная конфета"
	reagents = list("sugar" = 5, "frostoil" = 5)
	result = /obj/item/reagent_containers/food/snacks/mint
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/boiled_shrimp
	name = "Варёные креветки"
	reagents = list("water" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp,
	)
	result = /obj/item/reagent_containers/food/snacks/boiled_shrimp
	required_skill_level = SKILL_LEVEL_BASIC

//////////////////////////////////////////
//onyx bay food
//////////////////////////////////////////

/datum/recipe/microwave/pelmeni
	name = "Пельмени"
	reagents = list("water" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/pelmeni,
	)
	result = /obj/item/reagent_containers/food/snacks/boiledpelmeni
	required_skill_level = SKILL_LEVEL_BASIC

/datum/recipe/microwave/fruitcup
	name = "Фруктовая миска"
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/watermelon,
	)
	result = /obj/item/reagent_containers/food/snacks/fruitcup
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/junglesalad
	name = "Салат из джунглей"
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/watermelon,
	)
	result = /obj/item/reagent_containers/food/snacks/junglesalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/delightsalad
	name = "Салат восторг"
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
	)
	result = /obj/item/reagent_containers/food/snacks/delightsalad
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/chowmein
	name = "Чоу-мейн"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledspaghetti,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
	)
	result = /obj/item/reagent_containers/food/snacks/chowmein
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/beefnoodles
	name = "Лапша с говядиной"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledspaghetti,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/grown/cabbage,
	)
	result = /obj/item/reagent_containers/food/snacks/beefnoodles
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/tortilla
	name = "Тортилья"
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/corn,
	)
	result = /obj/item/reagent_containers/food/snacks/tortilla
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/nachos
	name = "Начос"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
	)
	result = /obj/item/reagent_containers/food/snacks/nachos
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cheesenachos
	name = "Сырные начос"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheesenachos
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cubannachos
	name = "Кубанские начос"
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/food/snacks/cubannachos
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/carneburrito
	name = "Мясной буррито"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/cutlet,
		/obj/item/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/carneburrito
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/cheeseburrito
	name = "Сырный буррито"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/cheeseburrito
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/plasmaburrito
	name = "Плазменный буррито"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/tortilla,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
	)
	result = /obj/item/reagent_containers/food/snacks/plasmaburrito
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/risotto
	name = "Ризотто"
	reagents = list("wine" = 5, "rice" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/risotto
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/bruschetta
	name = "Брускетта"
	reagents = list("sodiumchloride" = 2, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
	)
	result = /obj/item/reagent_containers/food/snacks/bruschetta
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/quiche
	name = "Киш"
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/quiche
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/crayfish
	name = "Креветки"
	reagents = list("water" = 5, "sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/crayfish_raw,
	)
	result = /obj/item/reagent_containers/food/snacks/crayfish_cooked
	required_skill_level = SKILL_LEVEL_PROFESSIONAL

/datum/recipe/microwave/crayfish_small
	name = "Маленькие креветки"
	reagents = list("water" = 5, "sodiumchloride" = 1, "herbsmix" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/crayfish_raw_small,
	)
	result = /obj/item/reagent_containers/food/snacks/crayfish_cooked_small
	required_skill_level = SKILL_LEVEL_PROFESSIONAL
