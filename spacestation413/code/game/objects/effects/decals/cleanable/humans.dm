/obj/effect/decal/cleanable/blood
	desc = "It's gooey. Perhaps it's the chef's cooking?"

/obj/effect/decal/cleanable/blood/proc/set_blood_color(new_color)
	if(blood_color != new_color)
		blood_color = new_color
		update_icon()

/obj/effect/decal/cleanable/trail_holder/proc/set_blood_color(new_color)
	if(blood_color != new_color)
		blood_color = new_color
		update_icon()

/obj/effect/decal/cleanable/blood/update_icon()
	if(is_abnormal_blood_color(blood_color))
		var/icon/newIcon = icon("spacestation413/icons/effects/blood.dmi")
		newIcon.Blend(blood_color,ICON_MULTIPLY)
		icon = newIcon
	. = ..()

/obj/effect/decal/cleanable/trail_holder/update_icon()
	if(is_abnormal_blood_color(blood_color))
		var/icon/newIcon = icon("spacestation413/icons/effects/blood.dmi")
		newIcon.Blend(blood_color,ICON_MULTIPLY)
		icon = newIcon
	. = ..()
