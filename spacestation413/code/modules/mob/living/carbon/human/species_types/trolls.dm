/datum/species/troll
	name = "troll"
	id = "troll"
	default_color = "c4c4c4"
	species_traits = list(HAIR,FACEHAIR,LIPS,HAS_FLESH,HAS_BONE,TROLLHORNS)
	mutant_bodyparts = list("tail_human" = "None", "wings" = "None")
	use_skintones = 0
	hair_color="222222"
	limbs_id = "troll"
	exotic_bloodtype = "T"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = GROSS | DAIRY
	liked_food = JUNKFOOD | MEAT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/troll/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	if(H.dna.features["ears"] == "Cat")
		mutantears = /obj/item/organ/ears/cat
	if(H.dna.features["tail_human"] == "Cat")
		var/tail = /obj/item/organ/tail/cat
		mutant_organs += tail
	H.blood_color = get_color_from_caste(H.dna.features["troll_caste"])
	..()

/datum/species/troll/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_troll_name()

	return troll_name()
