/*
Hey.
Don't touch this. Please?
As in, don't touch this if you don't actually understand what it does.

What do they do? They prevent safe movement if you do not have:
- Enough swimming skill.
- A boat.
- Like two other edge cases.
Otherwise, you CAN move through them, but...

Cheers! - Carl
*/
/turf/open/water
	//Is this going to prevent entering AT ALL when below the skill requirement?
	var/swichek_prot = FALSE
	//Minimal required skill to actually swim? We start at 4(Expert), for the check. Use define for clarity.
	var/swichek_req = SKILL_LEVEL_EXPERT

//The sort spawned by the hazard spawner, for mapping use.
/turf/open/water/default_hazard
	icon_state = "ash"
	slowdown = 8
	swichek_prot = TRUE

//This will probably be ABUSED TO SHIT by a gamer but, y'know, later me issue. I'll gib them.
/turf/open/water/proc/swichek_able(mob/living/swimmer)
	if(!isliving(swimmer))//If you're not a living mob we don't care. You don't get here but whatever.
		return TRUE
	if(swimmer.is_floor_hazard_immune())//Flight? Sure, bud.
		return TRUE
	if(ishuman(swimmer.buckled))//Buckled? Boat? Whatever. Pass.
		return TRUE
	if(!ishuman(swimmer))//All non-humans auto travel. Pass.
		return TRUE

	//Finally, we check the moron's skill. If it gets this far.
	var/mob/living/carbon/human/human_swimmer = swimmer
	if(human_swimmer.get_skill_level(/datum/skill/misc/swimming) >= swichek_req)
		return TRUE
	else//If you DO get to this part... you little idiot...
		to_chat(swimmer, span_danger("I'm not skilled enough to swim here!"))
		swimmer.Immobilize(4 SECONDS)//DROWN!!! Unless you, like... breath water or something...
		swimmer.Knockdown(6 SECONDS)//A bit extra to climb out as if in cinema. Teeheee...

/turf/open/water/CanPass(atom/movable/mover)
	if(isliving(mover) && src.swichek_prot)
		var/mob/mover_mob = mover
		if(mover_mob.mind)
			swichek_able(mover)
	. = ..()

//Mapping marker, for the above.
//Really shouldn't be using this, as it defaults to expert, but, whatever...
/obj/structure/water_hazard
	name = "water hazard marker"
	desc = "This is used to spawn water hazard tiles. For MAPPING. How are you seeing this? Yell at Carl."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "trap-cult"

//This is awful oh my god Carl why are you like this????
//WHY DO I DO THIS TO MYSELF?
/obj/structure/water_hazard/Initialize(mapload)
	. = ..()
	new /turf/open/water/default_hazard(get_turf(src))
	qdel(src)
