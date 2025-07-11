
/mob/living/silicon/ai/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/ai_module))
		var/obj/item/ai_module/MOD = W
		if(!mind) //A player mind is required for law procs to run antag checks.
			to_chat(user, "<span class='warning'>[src] is entirely unresponsive!</span>")
			return
		MOD.install(laws, user) //Proc includes a success mesage so we don't need another one
		return

	return ..()

/mob/living/silicon/ai/attack_slime(mob/living/simple_animal/slime/user, list/modifiers)
	return //immune to slimes

/mob/living/silicon/ai/blob_act(obj/structure/blob/B)
	if (stat != DEAD)
		adjustBruteLoss(60)
		updatehealth()
		return TRUE
	return FALSE

/mob/living/silicon/ai/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	disconnect_shell()
	if (prob(30))
		switch(pick(1,2))
			if(1)
				view_core()
			if(2)
				SSshuttle.requestEvac(src,"ALERT: Energy surge detected in AI core! Station integrity may be compromised! Initiati--%m091#ar-BZZT")

/mob/living/silicon/ai/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(30)



/mob/living/silicon/ai/bullet_act(obj/projectile/Proj)
	. = ..(Proj)
	updatehealth()

/mob/living/silicon/ai/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	return // no eyes, no flashing
