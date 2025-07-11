/mob/living/simple_animal/werewolf/update_damage_overlays() //aliens don't have damage overlays.
	return

/mob/living/simple_animal/werewolf/update_body() // we don't use the bodyparts or body layers for aliens.
	return

/mob/living/simple_animal/werewolf/crinos/update_icons()
	cut_overlays()

	var/laid_down = FALSE

	if(stat == UNCONSCIOUS || IsSleeping() || stat == HARD_CRIT || stat == SOFT_CRIT || IsParalyzed() || stat == DEAD || body_position == LYING_DOWN)
		if(wyrm_tainted)
			icon_state = "spiral[sprite_color]_rest"
		else
			icon_state = "[sprite_color]_rest"
		laid_down = TRUE
	else
		if(wyrm_tainted)
			icon_state = "spiral[sprite_color]"
		else
			icon_state = "[sprite_color]"
		var/mutable_appearance/shadow_overlay = mutable_appearance(icon, "undershadow")
		shadow_overlay.pixel_z = -4
		shadow_overlay.alpha = 64
		shadow_overlay.layer = layer-1
		add_overlay(shadow_overlay)

	if(sprite_scar)
		var/mutable_appearance/scar_overlay = mutable_appearance(icon, "scar[sprite_scar][laid_down ? "_rest" : ""]")
		add_overlay(scar_overlay)

	switch(getFireLoss()+getBruteLoss())
		if(25 to 100)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage1[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)
		if(100 to 250)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage2[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)
		if(250 to INFINITY)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage3[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)

	if(sprite_apparel)
		var/mutable_appearance/clothing_overlay = mutable_appearance(icon, "[sprite_apparel][laid_down ? "_rest" : ""]")
		add_overlay(clothing_overlay)

	if(sprite_hair)
		var/mutable_appearance/hair_overlay = mutable_appearance(icon, "hair[sprite_hair][laid_down ? "_rest" : ""]")
		hair_overlay.color = sprite_hair_color
		add_overlay(hair_overlay)

	var/mutable_appearance/eye_overlay = mutable_appearance(icon, "eyes[laid_down ? "_rest" : ""]")
	eye_overlay.color = sprite_eye_color
	eye_overlay.plane = ABOVE_LIGHTING_PLANE
	eye_overlay.layer = ABOVE_LIGHTING_LAYER
	add_overlay(eye_overlay)

	update_inv_hands()
	..()

/mob/living/simple_animal/werewolf/crinos/regenerate_icons()
	if(!..())
	//	update_icons() //Handled in update_transform(), leaving this here as a reminder
		update_transform()

/mob/living/simple_animal/werewolf/crinos/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	. = ..()
	update_icons()


/mob/living/simple_animal/werewolf/corax/corax_crinos/update_icons()
	cut_overlays()

	var/laid_down = FALSE

	if(stat == UNCONSCIOUS || IsSleeping() || stat == HARD_CRIT || stat == SOFT_CRIT || IsParalyzed() || stat == DEAD || body_position == LYING_DOWN)
		icon_state = "[sprite_color]_rest"
		laid_down = TRUE
	else
		icon_state = "[sprite_color]"
		var/mutable_appearance/shadow_overlay = mutable_appearance(icon, "undershadow")
		shadow_overlay.pixel_z = -4
		shadow_overlay.alpha = 64
		shadow_overlay.layer = layer-1
		add_overlay(shadow_overlay)

	if(sprite_scar)
		var/mutable_appearance/scar_overlay = mutable_appearance(icon, "scar[sprite_scar][laid_down ? "_rest" : ""]")
		add_overlay(scar_overlay)

	switch(getFireLoss()+getBruteLoss())
		if(25 to 100)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage1[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)
		if(100 to 250)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage2[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)
		if(250 to INFINITY)
			var/mutable_appearance/damage_overlay = mutable_appearance(icon, "damage3[laid_down ? "_rest" : ""]")
			add_overlay(damage_overlay)

	if(sprite_apparel)
		var/mutable_appearance/clothing_overlay = mutable_appearance(icon, "[auspice.tribe.name][sprite_apparel][laid_down ? "_rest" : ""]")
		add_overlay(clothing_overlay)

	if(sprite_hair)
		var/mutable_appearance/hair_overlay = mutable_appearance(icon, "hair[sprite_hair][laid_down ? "_rest" : ""]")
		hair_overlay.color = sprite_hair_color
		add_overlay(hair_overlay)

	var/mutable_appearance/eye_overlay = mutable_appearance(icon, "eyes[laid_down ? "_rest" : ""]")
	eye_overlay.color = sprite_eye_color
	eye_overlay.plane = ABOVE_LIGHTING_PLANE
	eye_overlay.layer = ABOVE_LIGHTING_LAYER
	add_overlay(eye_overlay)

	update_inv_hands()
	..()

/mob/living/simple_animal/werewolf/corax/corax_crinos/regenerate_icons()
	if(!..())
	//	update_icons() //Handled in update_transform(), leaving this here as a reminder
		update_transform()

/mob/living/simple_animal/werewolf/corax/corax_crinos/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	. = ..()
	update_icons()
