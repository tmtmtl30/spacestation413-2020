/mob/living/carbon/human/proc/handle_vamp_biting(mob/living/carbon/human/M)
	if(!is_vampire_antag(M) || M == src || M.zone_selected != "head")
		return FALSE
	var/datum/antagonist/vampire/V = M.mind.has_antag_datum(/datum/antagonist/vampire)
	if(dna.species.id == "skeleton") // this would be ruled out by NOBLOOD, so we have to put it above
		to_chat(M, "<span class='warning'>There is no blood in a skeleton!</span>")
		return FALSE
	if((NOBLOOD in dna.species.species_traits) || dna.species.exotic_blood || !blood_volume)
		to_chat(M, "<span class='warning'>They have no blood!</span>")
		return FALSE
	if(is_vampire_antag(src))
		to_chat(M, "<span class='warning'>Your fangs fail to pierce [name]'s cold flesh</span>")
		return FALSE
	if(!ckey)
		to_chat(M, "<span class='warning'>[src]'s blood is stale and useless.</span>")
		return FALSE
	if(V.draining) // if you're blood-sucking somebody, V.draining is set to something, so checking if it's set = checking if you're already succing
		return FALSE
	V.handle_bloodsucking(src) // sets V.draining; might not reset it due to runtime, so...
	V.draining = null // we reset it HERE, so it won't leave us high and dry
	return TRUE
