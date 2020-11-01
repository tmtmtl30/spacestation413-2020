/obj/effect/decal/cleanable/blood
	desc = "It's gooey. Perhaps it's the chef's cooking?"

/obj/effect/decal/cleanable/blood/proc/set_blood_color(new_color)
	if((color != new_color) && (blood_state == BLOOD_STATE_HUMAN))
		color = new_color
