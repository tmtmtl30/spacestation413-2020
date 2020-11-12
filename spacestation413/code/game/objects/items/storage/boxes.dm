/obj/item/storage/box/survival/PopulateContents()
	. = ..()
	new /obj/item/poster/random_contraband(src) // 413 -- posters in boxes
	new /obj/item/poster/random_official(src) // 413 -- posters in boxes
