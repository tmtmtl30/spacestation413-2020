/obj/item/melee/transforming/butterfly
	name = "butterfly knife"
	desc = "A stealthy knife famously used by spy organisations. Capable of piercing armour and causing massive backstab damage when used with harm intent."
	flags_1 = CONDUCT_1
	icon = 'spacestation413/icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "butterflyknife0"
	icon_state_on = "butterflyknife1"
	hitsound_on = 'spacestation413/sound/weapons/knife.ogg'
	lefthand_file = 'spacestation413/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'spacestation413/icons/mob/inhands/righthand.dmi'
	force_on = 10
	wound_bonus = 5
	bare_wound_bonus = 5
	throwforce_on = 10
	armour_penetration = 20
	attack_verb_on = list("pokes", "slashes", "stabs", "slices", "tears", "pierces", "dices", "cuts")
	attack_verb_off = list("taps", "prods")
	sharpness = SHARP_NONE
	w_class_on = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=12000)
	var/sharpness_on = SHARP_POINTY
	var/extra_backstab_force = 20
	var/has_been_sharpened = FALSE
	var/onsound = 'spacestation413/sound/weapons/batonextend.ogg'
	var/offsound = 'spacestation413/sound/weapons/batonextend.ogg'

/obj/item/melee/transforming/butterfly/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen) // lets us use whetstones properly

// annoyingly, we have to implement this ourselves. pseudo-copied from /datum/component/two_handed
/obj/item/melee/transforming/butterfly/proc/on_sharpen(obj/item/item, amount, max_amount) // 80% sure the "item" arg here is just ourselves
	SIGNAL_HANDLER

	if(has_been_sharpened) // can't sharpen twice
		return COMPONENT_BLOCK_SHARPEN_ALREADY
	if(!active) // it needs to be open, dumbass
		return COMPONENT_BLOCK_SHARPEN_BLOCKED
	if(force_on > max_amount) // can't sharpen if it's been enhanced somehow else
		return COMPONENT_BLOCK_SHARPEN_MAXED
	has_been_sharpened = TRUE
	force_on = clamp(force_on + amount, 0, max_amount)
	throwforce_on = clamp(throwforce_on + amount, 0, max_amount)
	wound_bonus += amount
	force = force_on // we have to set our current force too
	// bizarrely, we don't need to change our current throwforce. whetstone does that for us automatically
	return COMPONENT_BLOCK_SHARPEN_APPLIED

/obj/item/melee/transforming/butterfly/transform_weapon(mob/living/user, supress_message_text) // we need to change our exclusive variables correctly
	. = ..()
	if(active)
		icon_state = icon_state_on
		sharpness = sharpness_on
		item_flags |= EYE_STAB // lets you stab people
	else
		icon_state = initial(icon_state)
		sharpness = initial(sharpness)
		item_flags &= ~EYE_STAB // no more stabbing

// this is where the backstabbing happens. can't shove it in its own proc, because we need to call ..() and remember some state
/obj/item/melee/transforming/butterfly/attack(mob/living/carbon/M, mob/living/carbon/user)
	var/mob/living/carbon/human/H = M
	if(M != user && check_target_facings(user, H) == FACING_SAME_DIR && istype(H) && \
		active && user.a_intent != INTENT_HELP && M.stat != DEAD && H.get_bodypart(BODY_ZONE_CHEST))

		// change things around in preparation for backstab
		var/user_old_zone_selected = user.zone_selected
		user.zone_selected = BODY_ZONE_CHEST // annoying that we have to do this, but you can only backstab their back
		attack_verb_continuous = list("backstabs")
		hitsound = null // we have to do this, because the sound calculated using our force ends up being wayyy too loud
		force += extra_backstab_force

		. = ..() // actually do the stab
		playsound(loc,'spacestation413/sound/weapons/knifecrit.ogg', 40, 1, -1) // play our sound

		// reset everything
		force -= extra_backstab_force
		hitsound = hitsound_on
		user.zone_selected = user_old_zone_selected
		H.dropItemToGround(H.get_active_held_item())
	else
		return ..()

/obj/item/melee/transforming/butterfly/transform_messages(mob/living/user, supress_message_text)//no fucking esword on sound
	playsound(user, active ? onsound  : offsound , 50, 1)
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "is now active":"can now be concealed"].</span>")

/obj/item/melee/transforming/butterfly/energy
	name = "energy balisong"
	desc = "A vicious carbon fibre blade and plasma tip allow for unparelled precision strikes against fat Nanotrasen backsides."
	force_on = 20
	throwforce_on = 20
	extra_backstab_force = 60
	bare_wound_bonus = 10 // that's an energy weapon, baby!
	icon_state_on = "butterflyknife_syndie"
	onsound = 'spacestation413/sound/weapons/knifeopen.ogg'
	offsound = 'spacestation413/sound/weapons/knifeclose.ogg'

/obj/item/melee/transforming/butterfly/energy/on_sharpen(obj/item/item, amount, max_amount)
	return COMPONENT_BLOCK_SHARPEN_MAXED // this thing is already insane, no sharpening further -- backstab is just too much
