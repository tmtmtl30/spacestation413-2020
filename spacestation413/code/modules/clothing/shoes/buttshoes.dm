/obj/item/clothing/shoes/buttshoes // butts
	desc = "Why?"
	name = "butt shoes"
	worn_icon = 'spacestation413/icons/mob/feet.dmi'
	icon = 'spacestation413/icons/obj/clothing/shoes.dmi'
	icon_state = "buttshoes"
	inhand_icon_state = "buttshoes"

/obj/item/clothing/shoes/buttshoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('spacestation413/sound/effects/fart.ogg'=1), 50)
