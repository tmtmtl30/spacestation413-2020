/datum/dynamic_ruleset/latejoin/vampire_stowaway
	name = "Vampire Stowaway"
	antag_flag = ROLE_VAMPIRE
	antag_datum = /datum/antagonist/vampire
	protected_roles = list("Chaplain", "Security Officer", "Warden", "Head of Personnel", "Detective", "Head of Security", "Captain")
	restricted_roles = list("AI","Cyborg")
	required_candidates = 1
	weight = 5
	cost = 15
	requirements = list(101,70,60,50,40,20,20,10,10,10)
	repeatable = TRUE
	flags = TRAITOR_RULESET
