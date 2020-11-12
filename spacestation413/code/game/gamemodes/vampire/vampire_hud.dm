/datum/hud
	var/atom/movable/screen/vampire/vamp_blood_display

// i hate proc redefinitions i hate proc redefinitions i hate proc redefinitions i hate-
/datum/hud/New(mob/owner)
	. = ..()
	vamp_blood_display = new /atom/movable/screen/vampire()
	vamp_blood_display.hud = src

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	vamp_blood_display = new /atom/movable/screen/vampire()
	vamp_blood_display.hud = src
	infodisplay += vamp_blood_display

/datum/hud/Destroy()
	. = ..()
	vamp_blood_display = null
