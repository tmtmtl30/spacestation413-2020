/obj/effect/proc_holder/spell
	var/gain_desc
	var/blood_used = 0
	var/vamp_req = FALSE

/obj/effect/proc_holder/spell/cast_check(skipcharge = 0, mob/user = usr)
	. = ..(skipcharge, user)
	if(vamp_req)
		if(!is_vampire_antag(user))
			return FALSE
		var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V)
			return FALSE
		if(V.usable_blood < blood_used)
			to_chat(user, "<span class='warning'>You do not have enough blood to cast this!</span>")
			return FALSE

/obj/effect/proc_holder/spell/Initialize()
	if(vamp_req)
		clothes_req = FALSE
		range = 1
		human_req = FALSE //so we can cast stuff while a bat, too
	.=..()


/obj/effect/proc_holder/spell/before_cast(list/targets)
	. = ..()
	if(vamp_req)
		// sanity check before we cast
		if(!is_vampire_antag(usr))
			targets.Cut()
			return

		if(!blood_used)
			return

		// enforce blood
		var/datum/antagonist/vampire/vampire = usr.mind.has_antag_datum(/datum/antagonist/vampire)

		if(blood_used <= vampire.usable_blood)
			vampire.usable_blood -= blood_used
		else
			// stop!!
			targets.Cut()

		if(LAZYLEN(targets))
			to_chat(usr, "<span class='notice'><b>You have [vampire.usable_blood] left to use.</b></span>")


/obj/effect/proc_holder/spell/can_target(mob/living/target)
	. = ..()
	if(vamp_req && is_vampire_antag(target))
		return FALSE

/datum/vampire_passive
	var/gain_desc

/datum/vampire_passive/New()
	..()
	if(!gain_desc)
		gain_desc = "You have gained \the [src] ability."


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/vampire_passive/regen
	gain_desc = "Your rejuvination abilities have improved and will now heal you over time when used."

/datum/vampire_passive/vision
	gain_desc = "Your vampiric vision has improved."

/datum/vampire_passive/full
	gain_desc = "You have reached your full potential and are no longer weak to the effects of anything holy and your vision has been improved greatly."

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/effect/proc_holder/spell/self/rejuvenate
	name = "Rejuvenate"
	desc = "Flush your system with spare blood to regain your strength. Will restore missing blood in your bloodstream, at the cost of 10 blood points, if blood volume is sufficiently low."
	action_icon_state = "rejuv"
	charge_max = 200
	stat_allowed = 1
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/rejuvenate/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/U = user
	var/datum/antagonist/vampire/V = U.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V) //sanity check
		return
	to_chat(user, "<span class='notice'>You flush your system with blood, and energy surges through you.</span>")
	U.stuttering = 0

	var/restore_blood = 0 // how many units of blood we should restore per tick. default: do not restore any blood
	if(U.blood_volume < BLOOD_VOLUME_SAFE) // we are low enough on blood to start taking damage from it
		if(V.usable_blood >= 2) // we have usable_blood to spend
			to_chat(user, "<span class='notice'>You channel stored blood into your thinned bloodstream, the foreign liquid pumping through your veins.</span>")
			if(V.get_ability(/datum/vampire_passive/regen))
				restore_blood = 4 // restore four units of blood per rejuvenate tick if we are strong
			else
				restore_blood = 2 // without the passive upgrade to regen amount, only restore 2 units per rejuvenate tick. 2 units * 5 ticks = 10 units total
		else // we have no usable_blood to spend
			to_chat(user,"<span class='warning'>You don't have enough blood in reserve to refill your bloodstream!")

	for(var/i = 1 to 5) // 5 ticks total
		U.adjustStaminaLoss(-10)
		if(restore_blood)
			if(V.usable_blood >= 2)
				if(U.blood_volume >= BLOOD_VOLUME_SAFE) // you're in the clear, no need to regenerate any more
					restore_blood = 0
				else
					U.blood_volume = min(U.blood_volume + restore_blood,BLOOD_VOLUME_NORMAL) // don't overfill. also, no blood duplication
					V.usable_blood -= 2
			else
				to_chat(user,"<span class='warning'>You don't have enough blood in reserve to refill your bloodstream!")
				restore_blood = 0 // you're out of usable blood, can't regenerate any more
		if(V.get_ability(/datum/vampire_passive/regen))
			U.adjustBruteLoss(-1)
			U.adjustOxyLoss(-2.5)
			U.adjustToxLoss(-1)
			U.adjustFireLoss(-1)
		sleep(7.5)


/obj/effect/proc_holder/spell/targeted/hypnotise
	name = "Hypnotize (20)"
	desc = "A piercing stare that incapacitates your victim for a good length of time."
	action_icon_state = "hypnotize"
	blood_used = 20
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/hypnotise/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user]'s eyes flash briefly as he stares into [target]'s eyes</span>")
		if(do_mob(user, target, 20))
			to_chat(user, "<span class='warning'>Your piercing gaze knocks out [target].</span>")
			to_chat(target, "<span class='userdanger'>You find yourself unable to move and barely able to speak.</span>")
			target.Paralyze(150)
			target.stuttering = 10
		else
			revert_cast(usr)
			to_chat(usr, "<span class='warning'>You broke your gaze.</span>")

/obj/effect/proc_holder/spell/self/shapeshift
	name = "Shapeshift (50)"
	desc = "Changes your name and appearance at the cost of 50 blood and has a cooldown of 3 minutes."
	gain_desc = "You have gained the shapeshifting ability, at the cost of stored blood you can change your form permanently."
	action_icon_state = "genetic_poly"
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 50
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/shapeshift/cast(list/targets, mob/user = usr)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		user.visible_message("<span class='danger'>[H] transforms!</span>")
		randomize_human(H)
	user.regenerate_icons()

/obj/effect/proc_holder/spell/self/cloak
	name = "Cloak of Darkness"
	desc = "Toggles whether you are currently cloaking yourself in darkness. You'll be noticeably transparent in full light, however."
	gain_desc = "You have gained the Cloak of Darkness ability which when toggled makes you near invisible in the shroud of darkness."
	action_icon_state = "cloak"
	charge_max = 10
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/cloak/Initialize()
	update_name()
	.=..()

/obj/effect/proc_holder/spell/self/cloak/proc/update_name()
	var/mob/living/user = loc
	if(!ishuman(user) || !is_vampire_antag(user))
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	name = "[initial(name)] ([V.iscloaking ? "Deactivate" : "Activate"])"

/obj/effect/proc_holder/spell/self/cloak/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	V.iscloaking = !V.iscloaking
	update_name()
	to_chat(user, "<span class='notice'>You will now be [V.iscloaking ? "hidden" : "seen"] in darkness.</span>")

/obj/effect/proc_holder/spell/targeted/disease
	name = "Diseased Touch (45)"
	desc = "Touches your victim with infected blood giving them Grave Fever, which will, left untreated, causes toxic building and frequent collapsing."
	gain_desc = "You have gained the Diseased Touch ability which causes those you touch to become weak unless treated medically."
	action_icon_state = "disease"
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 45
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/disease/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/target in targets)
		to_chat(user, "<span class='warning'>You stealthily infect [target] with your diseased touch.</span>")
		target.help_shake_act(user)
		if(is_vampire_antag(target))
			to_chat(user, "<span class='warning'>They seem to be unaffected.</span>")
			continue
		var/datum/disease/D = new /datum/disease/vampire
		target.ForceContractDisease(D)

/obj/effect/proc_holder/spell/self/screech
	name = "Chiropteran Screech (25)"
	desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	gain_desc = "You have gained the Chiropteran Screech ability, which stuns anything with ears (and shatters glass) in a 4-tile radius."
	action_icon_state = "reeee"
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	blood_used = 25
	vamp_req = TRUE

	// These vars are for breaking glass things. If only the materials system was ever actually used by anything.
	// list of machinery types to damage, with values equal to the amount of damage to deal to that machine
	var/list/machinery_types_to_damage = list(
		/obj/machinery/light=6,
		/obj/machinery/door/window=150,
		/obj/machinery/computer=100
	)
	// list of structure types to damage, with values equal to the amount of damage to deal to that structure
	var/list/structure_types_to_damage = list(
		/obj/structure/window=75,
		/obj/structure/table/glass=70,
		/obj/structure/mirror=120,
		/obj/structure/fireaxecabinet = 110
	)

/obj/effect/proc_holder/spell/self/screech/cast(list/targets, mob/user = usr)
	user.visible_message("<span class='danger'>[user] lets out an ear piercing shriek!</span>", "<span class='danger'>You let out a loud shriek.</span>", "<span class='danger'>You hear a loud painful shriek!</span>")
	for(var/mob/living/carbon/C in hearers(4))
		if(C == user || (HAS_TRAIT(C, TRAIT_DEAF)) || is_vampire_antag(C))
			continue
		to_chat(C, "<span class='userdanger'>You hear a ear piercing shriek and your senses dull!</span>")
		C.Knockdown(4)
		var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
		if(ears)
			ears.adjustEarDamage(0, 30)
		C.stuttering = 250
		C.Stun(4)
		C.Jitter(150)
	for(var/obj/O in view(4))
		if(istype(O, /obj/item)) // might as well filter these out early
			if(istype(O, /obj/item/reagent_containers/food/drinks))
				var/obj/item/reagent_containers/food/drinks/D = O
				D.smash(D.loc)
			continue // we won't be any of the other types
		if(istype(O, /obj/machinery))
			for(var/machinery_type in machinery_types_to_damage) // not sure if there's a better way of doing this
				if(istype(O, machinery_type))
					O.take_damage(machinery_types_to_damage[machinery_type])
					break // no need to keep testing
			continue
		if(istype(O, /obj/structure))
			for(var/structure_type in structure_types_to_damage)
				if(istype(O, structure_type))
					O.take_damage(structure_types_to_damage[structure_type])
					break
			continue
	playsound(user.loc, 'sound/effects/screech.ogg', 100, 1)

/obj/effect/proc_holder/spell/bats
	name = "Summon Bats (55)"
	desc = "You summon a pair of space bats who attack nearby targets until they or their target is dead."
	gain_desc = "You have gained the Summon Bats ability."
	action_icon_state = "bats"
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	charge_max = 1200
	vamp_req = TRUE
	blood_used = 55
	var/num_bats = 2

/obj/effect/proc_holder/spell/bats/choose_targets(mob/user = usr)
	var/list/turf/locs = new
	for(var/direction in GLOB.alldirs) //looking for bat spawns
		if(locs.len == num_bats) //we found 2 locations and thats all we need
			break
		var/turf/T = get_step(usr, direction) //getting a loc in that direction
		if(AStar(user, T, /turf/proc/Distance, 1, simulated_only = 0)) // if a path exists, so no dense objects in the way its valid salid
			locs += T

	// pad with player location
	for(var/i = locs.len + 1 to num_bats)
		locs += user.loc

	perform(locs, user = user)

/obj/effect/proc_holder/spell/bats/cast(list/targets, mob/user = usr)
	for(var/T in targets)
		new /mob/living/simple_animal/hostile/retaliate/bat/vampire_bat(T)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform
	name = "Mist Form (20)"
	gain_desc = "You have gained the Mist Form ability which allows you to take on the form of mist for a short period and pass over any obstacle in your path."
	blood_used = 20
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform/Initialize()
	. = ..()
	range = -1
	addtimer(VARSET_CALLBACK(src, range, -1), 10) //Avoid fuckery

/obj/effect/proc_holder/spell/targeted/vampirize
	name = "Lilith's Pact (500)"
	desc = "You drain a victim's blood, and fill them with new blood, blessed by Lilith, turning them into a new vampire."
	gain_desc = "You have gained the ability to force someone, given time, to become a vampire."
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	action_icon_state = "oath"
	blood_used = 500
	vamp_req = TRUE

/obj/effect/proc_holder/spell/targeted/vampirize/cast(list/targets, mob/user = usr)
	for(var/mob/living/carbon/target in targets)
		if(is_vampire_antag(target))
			to_chat(user, "<span class='warning'>They're already a vampire!</span>")
			continue
		user.visible_message("<span class='danger'>[user] latches onto [target]'s neck, and a pure dread emanates from them.</span>", "<span class='warning'>You latch onto [target]'s neck, preparing to transfer your unholy blood to them.</span>", "<span class='warning'>A dreadful feeling overcomes you.</span>")
		target.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 10) //incase you're choking the victim
		for(var/progress = 0, progress <= 3, progress++)
			switch(progress)
				if(1)
					to_chat(target, "<span class='warning'>Visions of dread flood your vision...</span>")
					to_chat(user, "<span class='notice'>We begin to drain [target]'s blood in, so Lilith can bless it.</span>")
				if(2)
					to_chat(target, "<span class='danger'>Demonic whispers fill your mind, and they become irressistible...</span>")
				if(3)
					to_chat(target, "<span class='userdanger'>The world blanks out, and you see a demo- no ange- demon- lil- glory- blessing... Lilith.</span>")
					to_chat(user, "<span class='notice'>Excitement builds up in you as [target] sees the blessing of Lilith.</span>")
			if(!do_mob(user, target, 70))
				to_chat(user, "<span class='userdanger'>The pact has failed! [target] has not became a vampire.</span>")
				to_chat(target, "<span class='notice'>The visions stop, and you relax.</span>")
				return
		if(!QDELETED(user) && !QDELETED(target))
			to_chat(user, "<span class='notice'>. . .</span>")
			to_chat(target, "<span class='italics'>Come to me, child.</span>")
			sleep(10)
			to_chat(target, "<span class='italics'>The world hasn't treated you well, has it?</span>")
			sleep(15)
			to_chat(target, "<span class='italics'>Strike fear into their hearts...</span>")
			to_chat(user, "<span class='notice italics bold'>They have signed the pact!</span>")
			to_chat(target, "<span class='userdanger'>You sign Lilith's Pact.</span>")
			target.mind.store_memory("<B>[user] showed you the glory of Lilith. <I>You are not required to respect or obey [user] in any way</I></B>")
			add_vampire(target)


/obj/effect/proc_holder/spell/self/revive
	name = "Revive"
	gain_desc = "You have gained the ability to revive after death... However you can still be cremated/gibbed, and you will disintergrate if you're in the chapel!"
	desc = "Revives you, provided you are not in the chapel!"
	blood_used = 0
	stat_allowed = TRUE
	charge_max = 1000
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_icon_state = "coffin"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/revive/cast(list/targets, mob/user = usr)
	if(!is_vampire_antag(user) || !isliving(user))
		revert_cast()
		return
	if(user.stat != DEAD)
		to_chat(user, "<span class='notice'>We aren't dead enough to do that yet!</span>")
		revert_cast()
		return
	if(user.reagents.has_reagent(/datum/reagent/water/holywater))
		to_chat(user, "<span class='danger'>We cannot revive, holy water is in our system!</span>")
		return
	var/mob/living/L = user
	if(istype(get_area(L.loc), /area/chapel))
		L.visible_message("<span class='warning'>[L] disintergrates into dust!</span>", "<span class='userdanger'>Holy energy seeps into our very being, disintergrating us instantly!</span>", "You hear sizzling.")
		new /obj/effect/decal/remains/human(L.loc)
		L.dust()
	to_chat(L, "<span class='notice'>We begin to reanimate... this will take a minute.</span>")
	addtimer(CALLBACK(src, /obj/effect/proc_holder/spell/self/revive.proc/revive, L), 600)

/obj/effect/proc_holder/spell/self/revive/proc/revive(mob/living/user)
	user.revive(full_heal = TRUE)
	user.visible_message("<span class='danger'>[user] reanimates from death!</span>", "<span class='notice'>We get back up.</span>")
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
	var/list/missing = user.get_missing_limbs()
	if(missing.len)
		user.visible_message("<span class='danger'>Shadowy matter takes the place of [user]'s missing limbs as they reform!</span>")
		user.regenerate_limbs(0, list(BODY_ZONE_HEAD)) // intentionally doesn't regenerate the head, for coolness points, i guess
	user.regenerate_organs()
	user.Paralyze(100)

/obj/effect/proc_holder/spell/self/summon_coat
	name = "Summon Dracula Coat (5)"
	desc = "Summons your vampiric coat."
	gain_desc = "Now that you have reached full power, you can now pull a vampiric coat out of thin air!"
	blood_used = 5
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_icon_state = "coat"
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE

/obj/effect/proc_holder/spell/self/summon_coat/cast(list/targets, mob/user = usr)
	if(!is_vampire_antag(user) || !isliving(user))
		revert_cast()
		return
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return
	if(QDELETED(V.coat) || !V.coat)
		V.coat = new /obj/item/clothing/suit/draculacoat(user.loc)
	else if(get_dist(V.coat, user) > 1 || !(V.coat in user.GetAllContents()))
		V.coat.forceMove(user.loc)
	user.put_in_hands(V.coat)
	to_chat(user, "<span class='notice'>You summon your dracula coat.</span>")


/obj/effect/proc_holder/spell/self/batform
	name = "Bat Form (15)"
	gain_desc = "You now have the Bat Form ability, which allows you to turn into a bat (and back!)"
	desc = "Transform into a bat!"
	action_icon_state = "bat"
	charge_max = 200
	blood_used = 0 //this is only 0 so we can do our own custom checks
	action_icon = 'hippiestation/icons/mob/vampire.dmi'
	action_background_icon_state = "bg_demon"
	vamp_req = TRUE
	var/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat/bat

/obj/effect/proc_holder/spell/self/batform/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return FALSE
	if(!bat || bat.stat == DEAD)
		if(V.usable_blood < 15)
			to_chat(user, "<span class='warning'>You do not have enough blood to cast this!</span>")
			return FALSE
		bat = new /mob/living/simple_animal/hostile/retaliate/bat/vampire_bat(user.loc)
		user.forceMove(bat)
		bat.controller = user
		user.status_flags |= GODMODE
		user.mind.transfer_to(bat)
		charge_counter = charge_max //so you don't need to wait 20 seconds to turn BACK.
		recharging = FALSE
		action.UpdateButtonIcon()
	else
		bat.controller.forceMove(bat.loc)
		bat.controller.status_flags &= ~GODMODE
		bat.mind.transfer_to(bat.controller)
		bat.controller = null //just so we don't accidently trigger the death() thing
		QDEL_NULL(bat)
