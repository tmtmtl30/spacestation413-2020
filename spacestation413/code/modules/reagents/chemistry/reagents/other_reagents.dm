/datum/reagent/water/holywater/on_mob_life(mob/living/M)
	. = ..()
	if(ishuman(M) && is_vampire_antag(M) && prob(80))
		var/datum/antagonist/vampire/V = M.mind.has_antag_datum(/datum/antagonist/vampire)
		if(!V.get_ability(/datum/vampire_passive/full))
			switch(data["misc"]) // current_cycle doesn't work, because holywater overrides default on_mob_life for some fucking reason, which is what updates current_cycle? why does it override that? why is THAT what increments current_cycle? ugh
				if(1 to 4)
					to_chat(M, "<span class='warning'>Something sizzles in your veins!</span>")
					M.adjustFireLoss(0.5)
				if(5 to 12)
					to_chat(M, "<span class='danger'>You feel an intense burning inside of you!</span>")
					M.adjustFireLoss(1)
				if(13 to INFINITY)
					M.visible_message("<span class='danger'>[M] suddenly bursts into flames!<span>", "<span class='userdanger'>You suddenly ignite in a holy fire!</span>")
					M.adjust_fire_stacks(3)
					M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
					M.adjustFireLoss(3)		//Hence the other damages... ain't I a bastard? // sigh

/datum/reagent/cluwnification
	name = "Cluwne Tears"
	description = "Tears from thousands of cluwnes compressed into a dangerous cluwnification virus."
	color = "#535E66" // rgb: 62, 224, 33
	can_synth = FALSE
	taste_description = "something funny"

/datum/reagent/cluwnification/expose_mob(mob/living/L, method=TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		// this proc only works during testing if you spawn humans that are JUST /mob/living/carbon/human , not a subtype
		// because that breaks a check later down the line. ugh
		L.ForceContractDisease(new /datum/disease/cluwnification(), FALSE, TRUE)
