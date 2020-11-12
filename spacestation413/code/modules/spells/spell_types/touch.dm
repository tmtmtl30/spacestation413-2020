/obj/item/melee/touch_attack/rathens
	name = "\improper ass-blasting touch"
	desc = "This hand of mine glows with an awesome power!"
	catchphrase = "ARSE NATH!!"
	on_use_sound = 'spacestation413/sound/effects/superfart.ogg'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"

/obj/item/melee/touch_attack/rathens/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity || target == user || !ismob(target) || !iscarbon(user) || !(user.mobility_flags & MOBILITY_USE)) //exploding after touching yourself would be bad
		return
	if(!user.can_speak_vocal())
		to_chat(user, "<span class='notice'>You can't get the words out!</span>")
		return
	var/mob/living/M = target
	for(var/mob/living/L in view(src, 7))
		if(L != user)
			L.flash_act(affect_silicon = FALSE)
	var/atom/A = M.anti_magic_check()
	if(A) // they are IMMUNE, it is REFLECTED
		if(isitem(A))
			target.visible_message("<span class='warning'>[target]'s [A] glows brightly as it wards off the spell!</span>")
		user.visible_message("<span class='warning'>The feedback blows [user]'s ass off!</span>","<span class='userdanger'>The spell bounces from [M]'s skin back into your ass!</span>")
		user.flash_act()
		var/ass_explode = blow_off_ass(user)
		if(!ass_explode)
			to_chat(user, "<span class='danger'>You don't have a butt!</span>")
		return ..()

	M.visible_message("<span class='warning'><b>[M] begins glowing suspiciously...</span>","<span class='warning'>You feel the effects of the spell try to find your ass, but you don't have one! You can feel it start to fill the rest of your body!</span>")
	// check to see if they are wearing bloated human suit
	var/obj/item/clothing/suit/hooded/bloated_human/suit = M.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		M.visible_message("<span class='danger'>[M]'s [suit] explodes off of [M.p_them()] into a puddle of gore!</span>")
		M.dropItemToGround(suit, force=TRUE)
		qdel(suit)
		new /obj/effect/gibspawner/human(M.loc)
		return ..()
	var/ass_explode = blow_off_ass(target)
	if(!ass_explode)
		M.gib()
	return ..()

// returns FALSE if the target has no ass, and TRUE if the ass is blown off successfully.
/obj/item/melee/touch_attack/rathens/proc/blow_off_ass(mob/living/target)
	var/obj/item/organ/butt/B = target.getorganslot(ORGAN_SLOT_BUTT)
	if(!B)
		return FALSE
	B.Remove(target)
	B.forceMove(get_turf(target))
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!(NOBLOOD in H.dna?.species.species_traits)) // need to make sure they have blood to spawn it on the floor
			var/obj/effect/decal/cleanable/blood/blood = new /obj/effect/decal/cleanable/blood(target.loc)
			blood.set_blood_color(H.blood_color)
	target.nutrition = max(target.nutrition - 500, NUTRITION_LEVEL_STARVING)
	target.apply_damage(50,BRUTE,BODY_ZONE_PRECISE_GROIN,wound_bonus=CANT_WOUND) // don't want them getting a broken leg if they're already half-dead and assless
	target.visible_message("<span class='warning'><b>[target]'s</b> ass blows clean off!</span>", "<span class='warning'>Holy shit, your butt flies off in an arc!</span>")
	return TRUE

/obj/effect/proc_holder/spell/targeted/touch/rathens
	name = "Rathen's Secret"
	desc = "Summons a powerful shockwave around you that tears the arses and limbs off of enemies."
	hand_path = /obj/item/melee/touch_attack/rathens

	school = "evocation"
	charge_max = 400
	clothes_req = TRUE
	cooldown_min = 40 //90 deciseconds reduction per rank

	action_icon_state = "gib"

/datum/spellbook_entry/disintegrate //THIS IS INTENTIONAL -- REPLACING EI NATH WITH ARSE NATH (also makes it easy to fix later by just renaming)
	name = "Rathen's Secret"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/rathens
