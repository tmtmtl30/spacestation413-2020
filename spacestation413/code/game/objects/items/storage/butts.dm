// butts
#define BUTT_LOCKED_MESSAGE "<span class='warning'>You can't access that butt's contents; it's too tight!</span>"
#define BUTT_JUMPSUIT_MESSAGE "<span class='danger'>You'll need to remove the clothes first!</span>"

/datum/component/storage/concrete/butt // no unique vars, but i'm putting this line here so you know this is where it's defined

/datum/component/storage/concrete/butt/handle_item_insertion(obj/item/W, prevent_warning = 1, mob/user)
	if(locked)
		to_chat(user, BUTT_LOCKED_MESSAGE)
		return
	var/obj/item/organ/butt/B = real_location()
	if(B.owner && ishuman(B.owner))
		var/mob/living/carbon/human/H = B.owner
		if(H.w_uniform)
			to_chat(user, BUTT_JUMPSUIT_MESSAGE)
			return
	. = ..()

// this is used to let people remove items from other people's asses if they
// have their ass's contents open, since it doesn't work otherwise.
// i think that's normally stopped by one of the safeguards against taking things
// out of other people's backpacks, but i'm not 100% sure.
/datum/component/storage/concrete/butt/canreach_react(datum/source, list/next)
	var/obj/item/organ/butt/B = parent
	next += B.owner
	. = ..()

/mob/living/carbon/proc/is_on_butt_intent(mob/living/carbon/user)
	return (user.zone_selected == BODY_ZONE_PRECISE_GROIN && user.a_intent == INTENT_GRAB)

/mob/living/carbon/proc/checkbuttinsert(obj/item/I, mob/living/carbon/user)
	if(!is_on_butt_intent(user))
		return FALSE
	var/mob/living/carbon/human/buttowner = src
	if(buttowner.w_uniform)
		return FALSE

	var/obj/item/organ/butt/B = buttowner.getorgan(/obj/item/organ/butt)
	if(!B)
		to_chat(user, "<span class='warning'>There's no butt to insert anything into!</span>")
		return TRUE
	var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
	if(STR.locked)
		to_chat(user, BUTT_LOCKED_MESSAGE)
		return TRUE
	user.visible_message("<span class='warning'>[user] starts hiding [I] inside [src == user ? "[p_their()] own" : "[user]'s"] butt.</span>", "<span class='warning'>You start hiding [I] inside [user == src ? "your" : "[user]'s"] butt.</span>")
	if(do_mob(user, src, 20) && STR.can_be_inserted(I, 0, user))
		STR.handle_item_insertion(I, 0, user)
		user.visible_message("<span class='warning'>[user] hides [I] inside [src == user ? "[p_their()] own" : "[user]'s"] butt.</span>", "<span class='warning'>You hide [I] inside [user == src ? "your" : "[user]'s"] butt.</span>")
	return TRUE

/mob/living/carbon/human/proc/checkbuttinspect(mob/living/carbon/user)
	if(!is_on_butt_intent(user))
		return FALSE

	if(w_uniform) // if they're wearing a jumpsuit, we do not view its contents
		to_chat(user,  BUTT_JUMPSUIT_MESSAGE)
		if(user == src)
			user.visible_message("<span class='warning'>[user] grabs [p_their()] own butt!</span>", "<span class='warning'>You grab your own butt!</span>")
		else
			user.visible_message("<span class='warning'>[user] grabs [src]'s butt!</span>", "<span class='warning'>You grab [src]'s butt!</span>")
			to_chat(src, "<span class='userdanger'>You feel your butt being grabbed!</span>")
		return FALSE

	var/obj/item/organ/butt/B = getorgan(/obj/item/organ/butt)
	if(!B) // if they have no butt, we cannot inspect it
		to_chat(user, "<span class='warning'>There's nothing to inspect!</span>")
		return TRUE
	user.visible_message("<span class='warning'>[user] starts inspecting [user == src ? "[p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You start inspecting [user == src ? "your" : "[src]'s"] ass!</span>")
	if(do_mob(user, src, 40)) // start inspecting
		var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
		if(!STR.locked) // if the butt isn't locked, we succeed
			user.visible_message("<span class='warning'>[user] inspects [user == src ? "[p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You inspect [user == src ? "your" : "[src]'s"] ass!</span>")
			STR.show_to(user)
			return TRUE
		to_chat(user, BUTT_LOCKED_MESSAGE) // if the butt is locked, we fail
	// by this point we have either failed the do_mob or the butt is locked; either way, the inspection has failed
	user.visible_message("<span class='warning'>[user] fails to inspect [user == src ? "[p_their()] own" : "[src]'s"] ass!</span>", "<span class='warning'>You fail to inspect [user == src ? "your" : "[src]'s"] ass!</span>")
	return TRUE

/obj/item/clothing/proc/checkbuttuniform(mob/user)
	var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
	if(B)
		var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
		STR.close_all()
