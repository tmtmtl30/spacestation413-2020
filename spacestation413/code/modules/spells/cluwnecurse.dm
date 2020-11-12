// this entire thing is mostly copied from the barnyard curse
/obj/effect/proc_holder/spell/pointed/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 600
	charge_counter = 0
	clothes_req = TRUE
	stat_allowed = FALSE
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT
	range = 3
	cooldown_min = 75
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi' // too lazy to make a new icon
	action_icon = 'spacestation413/icons/mob/actions.dmi'
	action_icon_state = "cluwne"
	active_msg = "You prepare to curse a target..."
	deactive_msg = "You dispel the curse..."
	/// List of mobs which are allowed to be a target of the spell
	var/static/list/compatible_mobs_typecache = typecacheof(list(/mob/living/carbon/human))

// also mostly copied from barnyard curse
/obj/effect/proc_holder/spell/pointed/cluwnecurse/cast(list/targets, mob/user)
	if(!targets.len)
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/carbon/target = targets[1]
	if(target.anti_magic_check())
		to_chat(user, "<span class='warning'>The curse had no effect!</span>")
		target.visible_message("<span class='danger'>A horrible mask begins to appear upon [target]'s face, but it is dispelled in a flash of light!</span>", \
						"<span class='danger'>Your thoughts are clouded by a terrible green fog, but your mind quickly snaps back into focus!</span>")
		return FALSE

	var/mob/living/carbon/human/H = target
	H.cluwneify()

// also mostly copied from barnyard curse
/obj/effect/proc_holder/spell/pointed/cluwnecurse/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!is_type_in_typecache(target, compatible_mobs_typecache))
		if(!silent)
			to_chat(user, "<span class='warning'>You are unable to curse [target]!</span>")
		return FALSE
	return TRUE

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /obj/effect/proc_holder/spell/pointed/cluwnecurse

/datum/action/spell_action/New(Target) // we have to do this to jack in our own spell icon. dumb as hell
	..()
	var/obj/effect/proc_holder/spell/S = Target
	icon_icon = S.action_icon
