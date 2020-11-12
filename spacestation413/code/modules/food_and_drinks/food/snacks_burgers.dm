/obj/item/food/burger/assburger // butts
	name = "assburger"
	desc = "What the hell, that's not domesticated donkey meat, it's a literal buttburger!"
	icon = 'spacestation413/icons/obj/food/burgerbread2.dmi'
	icon_state = "assburger"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 3, /datum/reagent/drug/fartium = 10)
	tastes = list("butt" = 4)
	foodtypes = MEAT | GRAIN | GROSS

/obj/item/food/burger/cluwneburger
	name = "cluwne burger"
	desc = "A old burger with a cluwne mask on it. It seems to be staring into your soul..."
	icon = 'spacestation413/icons/obj/food/burgerbread.dmi'
	icon_state = "cluwneburger"
	food_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/nutriment/protein = 6, /datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/cluwnification = 6)
	tastes = list("bun" = 4, "regret" = 2, "something funny" = 1)
	foodtypes = GRAIN | TOXIC
