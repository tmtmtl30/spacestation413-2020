/obj/item/clothing/mask/spacestation413/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	inhand_icon_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT | DROPDEL
	flags_inv = HIDEEARS|HIDEEYES
	clothing_flags = DANGEROUS_OBJECT
	modifies_speech = TRUE
	var/last_sound = 0
	var/delay = 15

	// list of cluwne laughs, to be used for laughing / screaming from the cluwne mask
	var/list/cluwne_laughs = list('spacestation413/sound/voice/cluwnelaugh1.ogg','spacestation413/sound/voice/cluwnelaugh2.ogg','spacestation413/sound/voice/cluwnelaugh3.ogg')

/obj/item/clothing/mask/spacestation413/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/mask/spacestation413/cluwne/equipped(mob/user, slot, cluwne_transform_override = FALSE) //when you put it on
	var/mob/living/carbon/C = user
	if((C.wear_mask == src) && (~clothing_flags & VOICEBOX_DISABLED)) // they're wearing us and the voicebox is on (for turned-off versions of the happy mask)
		play_random_cluwnelaugh()
	if((slot == ITEM_SLOT_MASK) && ishuman(user) && !cluwne_transform_override) // the happy mask calls with cluwne_transform_override, so it doesn't run this code
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return ..()

/////////////////////////
// SPEECH MODIFICATION //
/////////////////////////

/obj/item/clothing/mask/spacestation413/cluwne/proc/play_cluwnelaugh(laugh_index)
	if(world.time - delay > last_sound)
		playsound(src, cluwne_laughs[laugh_index], 30, 1)
		last_sound = world.time

/obj/item/clothing/mask/spacestation413/cluwne/proc/play_random_cluwnelaugh(laugh_index)
	play_cluwnelaugh(rand(1, cluwne_laughs.len))

/obj/item/clothing/mask/spacestation413/cluwne/handle_speech(datum/source, list/speech_args) //whenever you speak
	. = ..()
	var/message = speech_args[SPEECH_MESSAGE]
	if(~clothing_flags & VOICEBOX_DISABLED) // our voicebox isn't disabled
		var/mob/living/carbon/human/H = source // need this to see if they're a cluwne so they can scream in pain; if they have the happy mask on, they shouldn't scream
		if(prob(5) && ishuman(source) && !(H.dna?.check_mutation(CLUWNEMUT))) //the brain isnt fully gone yet...
			message = pick("HELP ME!!","PLEASE KILL ME!!","I WANT TO DIE!!", "END MY SUFFERING", "I CANT TAKE THIS ANYMORE!!" ,"SOMEBODY STOP ME!!")
			play_cluwnelaugh(2)
		else if(prob(3))
			message = pick("HOOOOINKKKKKKK!!", "HOINK HOINK HOINK HOINK!!","HOINK HOINK!!","HOOOOOOIIINKKKK!!") //but most of the time they cant speak,
			play_cluwnelaugh(3)
		else
			message = pick("HEEEENKKKKKK!!", "HONK HONK HONK HONK!!","HONK HONK!!","HOOOOOONKKKK!!") //More sounds,
			play_cluwnelaugh(1)
	speech_args[SPEECH_MESSAGE] = trim(message)

// forgive me, for i must proc override. this makes cluwne mask wearers use cluwne laughs for the laugh emote
/datum/emote/living/laugh/get_sound(mob/living/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/clothing/mask/spacestation413/cluwne/c_mask = C.wear_mask
		if(istype(c_mask) && (~(c_mask.clothing_flags) & VOICEBOX_DISABLED)) // are they wearing a cluwne mask with enabled voicebox?
			return pick(c_mask.cluwne_laughs)
	return ..() // go as normal

// another emote proc override, same purpose as the laugh get_sound override above, but for screams
/datum/emote/living/carbon/human/scream/get_sound(mob/living/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/obj/item/clothing/mask/spacestation413/cluwne/c_mask = C.wear_mask
		if(istype(c_mask) && (~(c_mask.clothing_flags) & VOICEBOX_DISABLED)) // are they wearing a cluwne mask with enabled voicebox?
			return pick(c_mask.cluwne_laughs)
	return ..() // go as normal

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be %99 curse free and %99.9 not haunted. "
	flags_1 = MASKINTERNALS
	item_flags = ABSTRACT
	clothing_flags = DANGEROUS_OBJECT | VOICEBOX_TOGGLABLE
	var/can_cluwne = TRUE // not sure why this is here, defaulting it to true
	var/is_cursed = FALSE //i don't care that this is *slightly* memory wasteful, it's just one more byte and it's not like some madman is going to spawn thousands of these
	var/is_very_cursed = FALSE

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/Initialize()
	.=..()
	REMOVE_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	if(prob(1)) //this function pre-determines the logic of the cluwne mask. applying and reapplying the mask does not alter or change anything
		is_cursed = TRUE
		is_very_cursed = FALSE
	else if(prob(0.1))
		is_cursed = FALSE
		is_very_cursed = TRUE

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/attack_self(mob/user)
	. = ..()
	if(~clothing_flags & VOICEBOX_DISABLED) // if we have an enabled voicebox
		play_random_cluwnelaugh()

/obj/item/clothing/mask/spacestation413/cluwne/happy_cluwne/equipped(mob/user, slot, cluwne_transform_override = TRUE)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == ITEM_SLOT_MASK && can_cluwne)
		if(is_cursed) //logic predetermined
			log_admin("[key_name(H)] was made into a cluwne by [src]")
			message_admins("[key_name(H)] got cluwned by [src]")
			to_chat(H, "<span class='userdanger'>The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!</span>")
			H.dropItemToGround(src)
			H.cluwneify()
			qdel(src)
			return
		else if(is_very_cursed)
			var/turf/T = get_turf(src)
			var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
			S.Acquire_Victim(user)
			log_admin("[key_name(user)] summoned a floor cluwne using the [src]")
			message_admins("[key_name(user)] summoned a floor cluwne using the [src]")
			to_chat(H, "<span class='warning'>The mask suddenly slips off your face and... slides under the floor?</span>")
			to_chat(H, "<i>...dneirf uoy ot gnoleb ton seod tahT</i>")
			qdel(src)
			return
	. = ..()
