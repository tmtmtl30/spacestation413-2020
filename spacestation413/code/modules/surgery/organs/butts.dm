/obj/item/organ/butt // butts
	name = "butt"
	desc = "extremely treasured body part"
	worn_icon = 'spacestation413/icons/mob/head.dmi'
	icon = 'spacestation413/icons/obj/butts.dmi'
	icon_state = "butt"
	inhand_icon_state = "butt"
	zone = "groin"
	slot = ORGAN_SLOT_BUTT
	throwforce = 5
	throw_speed = 4
	force = 5
	hitsound = 'spacestation413/sound/effects/fart.ogg'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	embedding = list("embedded_pain_multiplier" = 1, "embed_chance" = 4, "embedded_fall_chance" = 10, "embedded_ignore_throwspeed_threshold" = FALSE) //This is a joke
	juice_results = list(/datum/reagent/drug/fartium = 20)

	// current value is if we should take damage from sharp items right now, initial(protected) is the "default" for this butt
	var/protected = FALSE

	// used to prevent superfart spam
	var/loose = FALSE

	// these are used for storage
	var/component_type = /datum/component/storage/concrete/butt
	var/max_combined_w_class = 3
	var/max_w_class = WEIGHT_CLASS_SMALL
	var/max_items = 2

/////////////////////////////////////////////////////
// begin code mostly copied from /obj/item/storage //
/////////////////////////////////////////////////////
/obj/item/organ/butt/ComponentInitialize()
	. = ..()
	var/datum/component/storage/inv_component = AddComponent(component_type)
	inv_component.max_combined_w_class = max_combined_w_class // this code is taken from backpacks
	inv_component.max_w_class = max_w_class
	inv_component.max_items = max_items // backpack code ends here

/obj/item/organ/butt/contents_explosion(severity, target) // because your ass is not a blast shelter
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing
	return ..()

/obj/item/organ/butt/Destroy() // the nuke disk will just slip right out of your bunghole, sorry folks
	for(var/obj/important_thing in contents)
		if(!(important_thing.resistance_flags & INDESTRUCTIBLE))
			continue
		important_thing.forceMove(drop_location())
	return ..()

/////////////////////////////////////////////////////
//  end code mostly copied from /obj/item/storage  //
/////////////////////////////////////////////////////

/obj/item/organ/butt/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!(organ_flags & ORGAN_SYNTHETIC_EMP))
		// this technically means you can unlock an EMPed butt early as long as it isn't permanently fucked, but who cares
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)

/obj/item/organ/butt/Remove(mob/living/carbon/M, special = 0)
	var/turf/T = get_turf(M)
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	for(var/i in contents)
		var/obj/item/I = i
		STR.remove_from_storage(I, T)
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE) // you can't put things in an ass when it is not on a person
	. = ..()

/obj/item/organ/butt/on_life()
	// not calling ..() is intentional -- we have no use for organ health
	if(protected)
		return
	for(var/obj/item/I in contents)
		if(I.get_sharpness() && prob(50))
			to_chat(owner, "<span class='danger'>You feel a stinging pain inside your butt!</span>")
			owner.bleed(4)
			owner.apply_damage(damage=2,damagetype=BRUTE,def_zone=BODY_ZONE_CHEST)

/obj/item/organ/butt/attackby(obj/item/W, mob/user as mob, params) // copypasting bot manufucturing process, im a lazy fuck
	if(istype(W, /obj/item/bodypart/r_arm/robot)) // can't make using left arms, for consistency
		if(istype(src, /obj/item/organ/butt/cybernetic)) //nobody sprited a cyber/blue butt buttbot
			to_chat(user, "<span class='warning'>Why the heck would you want to make a robot out of this?</span>")
			return
		user.dropItemToGround(W)
		qdel(W)
		var/turf/T = get_turf(src.loc)
		var/mob/living/simple_animal/bot/buttbot/B = new /mob/living/simple_animal/bot/buttbot(T)
		if(istype(src, /obj/item/organ/butt/xeno))
			B.xeno = TRUE
			B.icon_state = "buttbot_xeno"
			B.speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")
		to_chat(user, "<span class='notice'>You add the robot arm to the butt and... What?</span>")
		user.dropItemToGround(src)
		qdel(src)

/obj/item/organ/butt/throw_impact(atom/hit_atom)
	..()
	playsound(src, 'spacestation413/sound/effects/fart.ogg', 50, TRUE, 5)

// alternate butts:
/obj/item/organ/butt/xeno //XENOMORPH BUTTS ARE BEST BUTTS yes i agree
	name = "alien butt"
	desc = "best trophy ever"
	icon_state = "xenobutt"
	inhand_icon_state = "xenobutt"
	max_items = 3
	max_combined_w_class = 5

/obj/item/organ/butt/cybernetic // unused, currently, but makes more sense as a base subtype considering the other cybernetic organs
	name = "robobutt"
	desc = "A robotic butt. More durable than a normal one, allowing you to store sharp objects safely as long as it's functional."
	status = ORGAN_ROBOTIC
	protected = TRUE

	// used for EMPs
	var/emp_vulnerability = 20

/obj/item/organ/butt/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	lockdown_malfunction() // start being locked, stop being protected
	if(COOLDOWN_FINISHED(src, severe_cooldown))
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)
		addtimer(CALLBACK(src, .proc/regain_functionality), 10 SECONDS, TIMER_UNIQUE) // we come back online eventually
	if(prob(emp_vulnerability/severity))	//Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP // stops us from recovering

/obj/item/organ/butt/cybernetic/proc/lockdown_malfunction()
	protected = FALSE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/organ/butt/cybernetic/proc/regain_functionality()
	if(organ_flags & ORGAN_SYNTHETIC_EMP) // shit's broke, can't fix it
		return
	protected = initial(protected)
	if(owner)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)

/obj/item/organ/butt/cybernetic/bluebutt // bluespace butts, science
	name = "butt of holding"
	desc = "This butt has bluespace properties, letting you store more items in it. More durable than a normal one, allowing you to store sharp objects safely as long as it's functional."
	icon_state = "bluebutt"
	inhand_icon_state = "bluebutt"
	max_combined_w_class = 12
	max_w_class = WEIGHT_CLASS_NORMAL
	max_items = 4
