/datum/dynamic_ruleset/latejoin/vampire_stowaway
	name = "Vampire Stowaway"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	minimum_required_age = 0
	protected_roles = list("Chaplain", "Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI","Cyborg")
	required_candidates = 1
	weight = 3
	cost = 10
	requirements = list(40,30,20,10,10,10,10,10,10,10)
	repeatable = TRUE
	flags = TRAITOR_RULESET
