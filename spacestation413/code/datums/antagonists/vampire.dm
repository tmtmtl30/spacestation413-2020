#define ALL_POWERS_UNLOCKED 800
#define VAMPIRE_SUN_OCCLUSION_DISTANCE 20

/datum/antagonist/vampire

	name = "Vampire"
	antagpanel_category = "Vampire"
	roundend_category = "vampires"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_VAMPIRE

	// this isn't vampire-specific, but nothing else in the code uses this icon at the moment, and i'm
	// not patching in some dumb workaround so we can get our own unique vampire antag icon. this variable represents
	// an icon_state in "icons/mob/hud.dmi", by the way. would love if that were documented literally anywhere
	antag_hud_name = "huddeathsquad"

	var/usable_blood = 0
	var/total_blood = 0
	var/fullpower = FALSE
	var/draining

	var/iscloaking = FALSE

	var/list/powers = list() // list of current powers

	var/obj/item/clothing/suit/draculacoat/coat

	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/self/revive = 0,
		/obj/effect/proc_holder/spell/targeted/hypnotise = 0,
		/datum/vampire_passive/vision = 175,
		/obj/effect/proc_holder/spell/self/shapeshift = 175,
		/obj/effect/proc_holder/spell/self/cloak = 225,
		/obj/effect/proc_holder/spell/targeted/disease = 275,
		/obj/effect/proc_holder/spell/bats = 350,
		/obj/effect/proc_holder/spell/self/batform = 350,
		/obj/effect/proc_holder/spell/self/screech = 315,
		/datum/vampire_passive/regen = 425,
		/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/mistform = 500,
		/datum/vampire_passive/full = 666,
		/obj/effect/proc_holder/spell/self/summon_coat = 666,
		/obj/effect/proc_holder/spell/targeted/vampirize = 666)

/datum/antagonist/vampire/get_admin_commands()
	. = ..()
	.["Full Power"] = CALLBACK(src,.proc/admin_set_full_power)
	.["Set Blood Amount"] = CALLBACK(src,.proc/admin_set_blood)

/datum/antagonist/vampire/proc/admin_set_full_power(mob/admin)
	set_blood_values(total_blood_val=ALL_POWERS_UNLOCKED,usable_blood_val=ALL_POWERS_UNLOCKED)
	message_admins("[key_name_admin(admin)] made [owner.current] a full power vampire.")
	log_admin("[key_name(admin)] made [owner.current] a full power vampire.")

/datum/antagonist/vampire/proc/admin_set_blood(mob/admin)
	var/new_total_blood = input(admin, "Set Vampire Total Blood", "Total Blood", total_blood) as null|num
	var/new_usable_blood = input(admin, "Set Vampire Usable Blood", "Usable Blood", usable_blood) as null|num
	set_blood_values(total_blood_val=new_total_blood,usable_blood_val=new_usable_blood)
	message_admins("[key_name_admin(admin)] set [owner.current]'s total blood to [total_blood], and usable blood to [usable_blood].")
	log_admin("[key_name(admin)] set [owner.current]'s total blood to [total_blood], and usable blood to [usable_blood].")

// sets the vampire's blood amounts to the passed-in values, and runs check_vampire_upgrade.
// the new usable_blood (if applicable) is capped to the updated total_blood value.
// null values result in no change.
/datum/antagonist/vampire/proc/set_blood_values(total_blood_val=null, usable_blood_val=null)
	if(!isnull(total_blood_val))
		total_blood = total_blood_val
	if(!isnull(usable_blood_val))
		usable_blood = min(usable_blood_val, total_blood) // usable blood should not exceed total blood
	check_vampire_upgrade()

/datum/antagonist/vampire/on_gain() // proc for applying self to a mind (i think)
	give_objectives()
	check_vampire_upgrade()
	owner.special_role = "vampire"
	SSticker.mode.vampires |= owner
	..()

/datum/antagonist/vampire/on_removal() // proc for removing self from a mind (i think)
	remove_vampire_powers()
	owner.special_role = null
	SSticker.mode.vampires -= owner
	..()

/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override) // proc for applying self to a mob (i think)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	add_antag_hud(antag_hud_type, antag_hud_name, current)
	current.faction |= "vampire"
	var/mob/living/carbon/human/C = current
	if(istype(C))
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B)
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE

/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override) // proc for removing self from a mob (i think)
	. = ..()
	var/mob/living/current = owner.current
	if(mob_override)
		current = mob_override
	remove_antag_hud(antag_hud_type, current)
	current.faction -= "vampire"
	var/mob/living/carbon/human/C = current
	if(istype(C))
		if(C.hud_used && C.hud_used.vamp_blood_display) // when vampire_life procs, it makes this ui element visible, so here, we re-invisible it
			C.hud_used.vamp_blood_display.invisibility = INVISIBILITY_ABSTRACT
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(B && (B.decoy_override != initial(B.decoy_override)))
			B.organ_flags |= ORGAN_VITAL
			B.decoy_override = FALSE

/datum/antagonist/vampire/greet()
	to_chat(owner, "<span class='userdanger'>You are a Vampire!</span>")
	to_chat(owner, "<span class='danger bold'>You are a creature of the night -- holy water, the chapel, and space will cause you to burn.</span>")
	to_chat(owner, "<span class='notice bold'>Hit someone in the head with harm intent to start sucking their blood. However, only blood from living creatures is usable!</span>")
	to_chat(owner, "<span class='notice bold'>Coffins will heal you.</span>")
	if(LAZYLEN(objectives))
		owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'hippiestation/sound/ambience/antag/vampire.ogg',80,0)

/datum/antagonist/vampire/proc/give_objectives()
	var/datum/objective/blood/blood_objective = new
	blood_objective.owner = owner
	blood_objective.gen_amount_goal()
	add_objective(blood_objective)

	for(var/i = 1, i < CONFIG_GET(number/traitor_objectives_amount), i++)
		forge_single_objective()

	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/vampire/proc/add_objective(datum/objective/O)
	objectives |= O

/datum/antagonist/vampire/proc/forge_single_objective() //Returns how many objectives are added
	var/datum/objective/objective_type
	if(prob(50))
		objective_type = /datum/objective/steal
	else
		var/list/active_ais_list = active_ais() // have to typecast this proc's return value because we don't use type hints
		if(active_ais_list.len && prob(100/GLOB.joined_player_list.len))
			objective_type = /datum/objective/destroy
		else if(prob(30))
			objective_type = /datum/objective/maroon
		else
			objective_type = /datum/objective/assassinate
	var/datum/objective/new_objective = new objective_type
	new_objective.owner = owner
	new_objective.find_target()
	add_objective(new_objective)
	return 1

/datum/antagonist/vampire/proc/check_sun() // this code copied from solar panels. does it work? who knows
	var/mob/living/carbon/C = owner.current
	if(!C)
		return

	var/azimuth = SSsun.azimuth
	var/target_x = round(sin(azimuth), 0.01)
	var/target_y = round(cos(azimuth), 0.01)
	var/x_hit = C.x
	var/y_hit = C.y
	var/our_z = C.z
	var/turf/hit

	for(var/run in 1 to VAMPIRE_SUN_OCCLUSION_DISTANCE)
		x_hit += target_x
		y_hit += target_y
		hit = locate(round(x_hit, 1), round(y_hit, 1), our_z)
		if(IS_OPAQUE_TURF(hit))
			return
		if(hit.x == 1 || hit.x == world.maxx || hit.y == 1 || hit.y == world.maxy) //edge of the map
			break
	vamp_burn(TRUE)

/datum/antagonist/vampire/proc/vamp_burn(severe_burn = FALSE)
	var/mob/living/L = owner.current
	if(!L)
		return
	var/burn_chance = severe_burn ? 35 : 8
	if(prob(burn_chance) && L.health >= 50)
		switch(L.health)
			if(75 to 100)
				L.visible_message("<span class='warning'>[L]'s skin begins to flake!</span>", "<span class='danger'>Your skin flakes away...</span>")
			if(50 to 75)
				L.visible_message("<span class='warning'>[L]'s skin sizzles loudly!</span>", "<span class='danger'>Your skin sizzles!</span>", "You hear sizzling.")
		L.adjustFireLoss(3)
	else if(L.health < 50)
		if(!L.on_fire)
			L.visible_message("<span class='warning'>[L] catches fire!</span>", "<span class='danger'>Your skin catches fire!</span>")
			L.emote("scream")
		else
			L.visible_message("<span class='warning'>[L] continues to burn!</span>", "<span class='danger'>Your continue to burn!</span>")
		L.adjust_fire_stacks(5)
		L.IgniteMob()
	return

/datum/antagonist/vampire/proc/vampire_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(owner && C.hud_used && C.hud_used.vamp_blood_display)
		C.hud_used.vamp_blood_display.invisibility = FALSE
		C.hud_used.vamp_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(usable_blood, 1)]</font></div>"
	handle_vampire_cloak()
	if(istype(C.loc, /obj/structure/closet/crate/coffin))
		C.adjustBruteLoss(-4)
		C.adjustFireLoss(-4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		return
	if(!get_ability(/datum/vampire_passive/full) && istype(get_area(C.loc), /area/chapel))
		vamp_burn()
	if(isspaceturf(C.loc))
		check_sun()


/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	// if "draining" is set, this proc doesn't get called; "draining" is only set within this proc
	// it gets reset to null in /mob/living/carbon/human/proc/handle_vamp_biting, the only proc to call
	// this one. it's reset to null there, as well as here, to prevent us from having a stale "draining"
	// value if we runtime, which would make further bloodsucking impossible.
	draining = H
	var/mob/living/carbon/human/O = owner.current
	var/old_total_blood = total_blood //used to see if we increased our blood total
	var/old_usable_blood = usable_blood //used to see if we increased our blood usable
	log_attack("[O] ([O.ckey]) bit [H] ([H.ckey]) in the neck")
	O.visible_message("<span class='danger'>[O] grabs [H]'s neck harshly and sinks in their fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain their blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	if(!iscarbon(owner))
		H.LAssailant = null
	else
		H.LAssailant = O
	playsound(O.loc, 'sound/weapons/bite.ogg', 40, 1)

	while(do_mob(O, H, 22))
		if(!is_vampire_antag(O))
			to_chat(O, "<span class='warning'>Your fangs have disappeared!</span>")
			draining = null
			return
		if(!H.blood_volume)
			to_chat(O, "<span class='warning'>They've got no blood left to give.</span>")
			break
		var/new_blood = 0
		if(H.stat != DEAD)
			// if they have less than 10 blood, give them the remnant else they get 10 blood
			new_blood = min(10, H.blood_volume)
			set_blood_values(total_blood_val=total_blood+new_blood,usable_blood_val=usable_blood+new_blood)
		else
			// The dead only give 2 blood points, but are still drained by 10 blood units -- 1/5th efficiency
			new_blood = min(2, H.blood_volume)
			set_blood_values(usable_blood_val=usable_blood+new_blood)
		H.blood_volume = max(H.blood_volume - 10, 0)
		if(ishuman(O)) // yum
			O.nutrition = min(O.nutrition + (new_blood / 2), NUTRITION_LEVEL_WELL_FED)
		playsound(O.loc, 'hippiestation/sound/effects/vampsip.ogg', 25, 1)

	to_chat(owner, "<span class='notice'>You stop draining [H.name] of blood.</span>")
	if(old_total_blood != total_blood)
		to_chat(O, "<span class='notice'><b>You have accumulated [total_blood] [total_blood > 1 ? "units" : "unit"] of blood[usable_blood != old_usable_blood ? ", and have [usable_blood] left to use" : ""].</b></span>")
	draining = null

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)
	powers += spell

/datum/antagonist/vampire/proc/get_ability(path)
	for(var/P in powers)
		var/datum/power = P
		if(power.type == path)
			return power
	return null

/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)

/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)


/datum/antagonist/vampire/proc/remove_vampire_powers()
	for(var/P in powers)
		remove_ability(P)
	owner.current.alpha = 255

/datum/antagonist/vampire/proc/check_vampire_upgrade()
	var/list/old_powers = powers.Copy()
	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(total_blood >= level)
			add_ability(ptype)
	announce_new_power(old_powers)
	owner.current.update_sight() //deal with sight abilities

/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell))
				var/obj/effect/proc_holder/spell/power = p
				to_chat(owner.current, "<span class='notice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner, "<span class='notice'>[power.gain_desc]</span>")

/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		owner.current.alpha = 255
		return
	var/mob/living/carbon/human/H = owner.current
	var/turf/T = get_turf(H)
	var/light_available = T.get_lumcount()

	if(!istype(T))
		return 0

	if(!iscloaking)
		H.alpha = 255
		return 0

	if(light_available <= 0.25)
		H.alpha = round((255 * 0.15))
		return 1
	else
		H.alpha = round((255 * 0.80))

/datum/antagonist/vampire/roundend_report()
	var/list/result = list()

	var/vampwin = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(LAZYLEN(objectives))//If the vampire had no objectives, don't need to process this.
		var/count = 1
		for(var/datum/objective/objective in objectives)
			if(objective.check_completion())
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='greentext'>Success!</span>"
			else
				objectives_text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <span class='redtext'>Fail.</span>"
				vampwin = FALSE
			count++

	result += objectives_text

	if(vampwin)
		result += "<span class='greentext'>The vampire was successful!</span>"
	else
		result += "<span class='redtext'>The vampire has failed!</span>"
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")

#undef ALL_POWERS_UNLOCKED
#undef VAMPIRE_SUN_OCCLUSION_DISTANCE
