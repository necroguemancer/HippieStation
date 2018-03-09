/obj/item/weapon/stopwatch
	name = "antique stopwatch"
	desc = "Can the omniscient be patronized?"
	icon = 'icons/obj/anomalous/stopwatch.dmi'
	icon_state = "stopwatch"
	w_class = WEIGHT_CLASS_TINY
	var/broken = 0
	var/timer = 0
	var/activated = 0
	var/mob/living/carbon/human/watchowner = null
	slot_flags = SLOT_ID | SLOT_BELT | SLOT_GLOVES


/obj/item/weapon/stopwatch/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/weapon/stopwatch/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/stopwatch/verb/lifesaver()
	set name = "Synchronize the watch"
	set category = "Object"
	var/mob/living/carbon/human/H = usr
	if (!istype(H, /mob/living/carbon/human))
		to_chat(H, "<span class='warning'>You have no clue what to do with this thing.</span>")
		return
	if(!watchowner)
		to_chat(H, "<span class='notice'>You wind up the [src]. It starts ticking synchronously with your heartbeat.</span>")
		watchowner = H
		return
	else
		to_chat(H, "<span class='notice'>You wind up the [src]. Nothing changes.</span>")
		H << "<font color='blue'>You wind up the [src]. Nothing changes.</font>"
		return


/obj/item/weapon/stopwatch/attack_self(var/mob/living/user as mob)
	if(timer == 0 && !broken)
		timer = 10
		icon_state = "stopwatch_on"
		var/obj/effect/timestop/T = new /obj/effect/timestop(user.loc)
		T.forceMove(get_turf(user.loc))
		T.immune += user
		T.timestop()
		activated = 1
		return
	else if(broken)
		to_chat(user, "<span class='notice'>It completely stopped.</span>")
		return

	else
		to_chat(user, "<span class='notice'>The stopwatch is recharging...</span>")


/obj/item/weapon/stopwatch/process()
	if(watchowner && !broken)
		if(watchowner.health < (watchowner.maxHealth - watchowner.maxHealth/2))
			watchowner.adjustBruteLoss(-7)
			watchowner.adjustFireLoss(-7)
			watchowner.adjustToxLoss(-7)
			watchowner.adjustOxyLoss(-7)
			timer = 0
			attack_self(watchowner)
			broken = 1
			icon_state = "stopwatch_cd"
			to_chat(watchowner, "<span class='warning'>The stopwatch stopped ticking...</span>")
			STOP_PROCESSING(SSobj, src)
	if(timer > 0)
		timer--
	else if (timer == 0)
		if(activated == 1)
			icon_state = "stopwatch_cd"
			activated = 0
			timer = 15
		else
			icon_state = "stopwatch"


