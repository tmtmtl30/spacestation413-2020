/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	minimum_required_age = 0
	protected_roles = list("Chaplain", "Prisoner", "Security Officer", "Warden", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI","Cyborg")
	required_candidates = 1
	weight = 3
	cost = 20
	scaling_cost = 15
	requirements = list(50,45,45,40,35,20,20,15,10,10)
	antag_cap = list(1,1,1,1,2,2,2,2,3,3)

/datum/dynamic_ruleset/roundstart/vampire/pre_execute()
	. = ..()
	var/num_vampires = antag_cap[indice_pop] * (scaled_times + 1)
	for (var/i = 1 to num_vampires)
		var/mob/M = pick_n_take(candidates)
		assigned += M.mind
		M.mind.special_role = ROLE_VAMPIRE
		M.mind.restricted_roles = restricted_roles
		GLOB.pre_setup_antags += M.mind
	return TRUE

