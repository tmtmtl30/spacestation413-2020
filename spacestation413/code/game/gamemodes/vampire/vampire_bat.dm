/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat // a special vampire bat for REAL (i.e. gamemode-spawned) vampires ONLY.
	name = "vampire bat"
	desc = "A bat that sucks blood. Keep away from medical bays."
	maxHealth = 20
	health = 20
	harm_intent_damage = 7
	melee_damage_lower = 5
	melee_damage_upper = 7
	faction = list("hostile", "vampire")

	var/mob/living/controller

/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat/CanAttack(atom/the_target)
	. = ..()
	if(isliving(the_target) && is_vampire_antag(the_target))
		return FALSE

/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat/Initialize()
	. = ..()
	// a bit hacky; we have to override the spacewalking of the mob we inherit from
	// because vamps are supposed to HATE space
	REMOVE_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

// copied from /mob/living/simple_animal/hostile, since /mob/living/simple_animal/hostile/retaliate
// doesn't autoattack and checks its enemies list first, which we don't want. so we have to override it
// with the proc of its parent type. dumb dumb dumb
/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat/ListTargets()
	if(!search_objects)
		. = hearers(vision_range, targets_from) - src //Remove self, so we don't suicide

		var/static/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))

		for(var/HM in typecache_filter_list(range(vision_range, targets_from), hostile_machines))
			if(can_see(targets_from, HM, vision_range))
				. += HM
	else
		. = oview(vision_range, targets_from)

/mob/living/simple_animal/hostile/retaliate/bat/vampire_bat/death()
	if(isliving(controller))
		controller.forceMove(loc)
		mind.transfer_to(controller)
		controller.status_flags &= ~GODMODE
		controller.Knockdown(120)
		to_chat(controller, "<span class='userdanger'>The force of being exiled from your bat form knocks you down!</span>")
	. = ..()
