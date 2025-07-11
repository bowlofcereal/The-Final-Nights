/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */


/obj/structure/windoor_assembly
	icon = 'icons/obj/doors/windoor.dmi'

	name = "windoor Assembly"
	icon_state = "l_windoor_assembly01"
	desc = "A small glass and wire assembly for windoors."
	anchored = FALSE
	density = FALSE
	dir = NORTH
	set_dir_on_move = FALSE

	var/obj/item/electronics/airlock/electronics = null
	var/created_name = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = FALSE		//Whether or not this creates a secure windoor
	var/state = "01"	//How far the door assembly has progressed

/obj/structure/windoor_assembly/New(loc, set_dir)
	..()
	if(set_dir)
		setDir(set_dir)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM)

/obj/structure/windoor_assembly/Destroy()
	density = FALSE
	return ..()

/obj/structure/windoor_assembly/update_icon_state()
	icon_state = "[facing]_[secure ? "secure_" : ""]windoor_assembly[state]"
	return ..()

/obj/structure/windoor_assembly/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()

	if(get_dir(loc, target) == dir)
		return

	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_window_location(loc, moved_window.dir, is_fulltile = moved_window.fulltile)

	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_window_location(loc, mover.dir, is_fulltile = FALSE)

/obj/structure/windoor_assembly/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return // Let's not block ourselves.

	if (leaving.pass_flags & pass_flags_self)
		return

	if (direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/windoor_assembly/attackby(obj/item/W, mob/user, params)
	//I really should have spread this out across more states but thin little windoors are hard to sprite.
	add_fingerprint(user)
	switch(state)
		if("01")
			if(W.tool_behaviour == TOOL_WELDER && !anchored)
				if(!W.tool_start_check(user, amount=0))
					return

				user.visible_message("<span class='notice'>[user] disassembles the windoor assembly.</span>",
					"<span class='notice'>You start to disassemble the windoor assembly...</span>")

				if(W.use_tool(src, user, 40, volume=50))
					to_chat(user, "<span class='notice'>You disassemble the windoor assembly.</span>")
					var/obj/item/stack/sheet/rglass/RG = new (get_turf(src), 5)
					RG.add_fingerprint(user)
					if(secure)
						var/obj/item/stack/rods/R = new (get_turf(src), 4)
						R.add_fingerprint(user)
					qdel(src)
				return

			//Wrenching an unsecure assembly anchors it in place. Step 4 complete
			if(W.tool_behaviour == TOOL_WRENCH && !anchored)
				for(var/obj/machinery/door/window/WD in loc)
					if(WD.dir == dir)
						to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
						return
				user.visible_message("<span class='notice'>[user] secures the windoor assembly to the floor.</span>",
					"<span class='notice'>You start to secure the windoor assembly to the floor...</span>")

				if(W.use_tool(src, user, 40, volume=100))
					if(anchored)
						return
					for(var/obj/machinery/door/window/WD in loc)
						if(WD.dir == dir)
							to_chat(user, "<span class='warning'>There is already a windoor in that location!</span>")
							return
					to_chat(user, "<span class='notice'>You secure the windoor assembly.</span>")
					set_anchored(TRUE)
					if(secure)
						name = "secure anchored windoor assembly"
					else
						name = "anchored windoor assembly"

			//Unwrenching an unsecure assembly un-anchors it. Step 4 undone
			else if(W.tool_behaviour == TOOL_WRENCH && anchored)
				user.visible_message("<span class='notice'>[user] unsecures the windoor assembly to the floor.</span>",
					"<span class='notice'>You start to unsecure the windoor assembly to the floor...</span>")

				if(W.use_tool(src, user, 40, volume=100))
					if(!anchored)
						return
					to_chat(user, "<span class='notice'>You unsecure the windoor assembly.</span>")
					set_anchored(FALSE)
					if(secure)
						name = "secure windoor assembly"
					else
						name = "windoor assembly"

			//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
			else if(istype(W, /obj/item/stack/sheet/plasteel) && !secure)
				var/obj/item/stack/sheet/plasteel/P = W
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to do this!</span>")
					return
				to_chat(user, "<span class='notice'>You start to reinforce the windoor with plasteel...</span>")

				if(do_after(user,40, target = src))
					if(!src || secure || P.get_amount() < 2)
						return

					P.use(2)
					to_chat(user, "<span class='notice'>You reinforce the windoor.</span>")
					secure = TRUE
					if(anchored)
						name = "secure anchored windoor assembly"
					else
						name = "secure windoor assembly"

			//Adding cable to the assembly. Step 5 complete.
			else if(istype(W, /obj/item/stack/cable_coil) && anchored)
				user.visible_message("<span class='notice'>[user] wires the windoor assembly.</span>", "<span class='notice'>You start to wire the windoor assembly...</span>")

				if(do_after(user, 40, target = src))
					if(!src || !anchored || src.state != "01")
						return
					var/obj/item/stack/cable_coil/CC = W
					if(!CC.use(1))
						to_chat(user, "<span class='warning'>You need more cable to do this!</span>")
						return
					to_chat(user, "<span class='notice'>You wire the windoor.</span>")
					state = "02"
					if(secure)
						name = "secure wired windoor assembly"
					else
						name = "wired windoor assembly"
			else
				return ..()

		if("02")

			//Removing wire from the assembly. Step 5 undone.
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message("<span class='notice'>[user] cuts the wires from the airlock assembly.</span>", "<span class='notice'>You start to cut the wires from airlock assembly...</span>")

				if(W.use_tool(src, user, 40, volume=100))
					if(state != "02")
						return

					to_chat(user, "<span class='notice'>You cut the windoor wires.</span>")
					new/obj/item/stack/cable_coil(get_turf(user), 1)
					state = "01"
					if(secure)
						name = "secure anchored windoor assembly"
					else
						name = "anchored windoor assembly"

			//Adding airlock electronics for access. Step 6 complete.
			else if(istype(W, /obj/item/electronics/airlock))
				if(!user.transferItemToLoc(W, src))
					return
				W.play_tool_sound(src, 100)
				user.visible_message("<span class='notice'>[user] installs the electronics into the airlock assembly.</span>",
					"<span class='notice'>You start to install electronics into the airlock assembly...</span>")

				if(do_after(user, 40, target = src))
					if(!src || electronics)
						W.forceMove(drop_location())
						return
					to_chat(user, "<span class='notice'>You install the airlock electronics.</span>")
					name = "near finished windoor assembly"
					electronics = W
				else
					W.forceMove(drop_location())

			//Screwdriver to remove airlock electronics. Step 6 undone.
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)
				if(!electronics)
					return

				user.visible_message("<span class='notice'>[user] removes the electronics from the airlock assembly.</span>",
					"<span class='notice'>You start to uninstall electronics from the airlock assembly...</span>")

				if(W.use_tool(src, user, 40, volume=100) && electronics)
					to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")
					name = "wired windoor assembly"
					var/obj/item/electronics/airlock/ae
					ae = electronics
					electronics = null
					ae.forceMove(drop_location())

			else if(IS_WRITING_UTENSIL(W))
				var/t = tgui_input_text(user, "Enter the name for the door", "Windoor Renaming", created_name, MAX_NAME_LEN)
				if(!t)
					return
				if(!in_range(src, usr) && loc != usr)
					return
				created_name = t
				return



			//Crowbar to complete the assembly, Step 7 complete.
			else if(W.tool_behaviour == TOOL_CROWBAR)
				if(!electronics)
					to_chat(usr, "<span class='warning'>The assembly is missing electronics!</span>")
					return
				user << browse(null, "window=windoor_access")
				user.visible_message("<span class='notice'>[user] pries the windoor into the frame.</span>",
					"<span class='notice'>You start prying the windoor into the frame...</span>")

				if(W.use_tool(src, user, 40, volume=100) && electronics)

					density = TRUE //Shouldn't matter but just incase
					to_chat(user, "<span class='notice'>You finish the windoor.</span>")

					if(secure)
						var/obj/machinery/door/window/brigdoor/windoor = new /obj/machinery/door/window/brigdoor(loc)
						if(facing == "l")
							windoor.icon_state = "leftsecureopen"
							windoor.base_state = "leftsecure"
						else
							windoor.icon_state = "rightsecureopen"
							windoor.base_state = "rightsecure"
						windoor.setDir(dir)
						windoor.density = FALSE

						if(electronics.one_access)
							windoor.req_one_access = electronics.accesses
						else
							windoor.req_access = electronics.accesses
						windoor.electronics = electronics
						electronics.forceMove(windoor)
						if(created_name)
							windoor.name = created_name
						qdel(src)
						windoor.close()


					else
						var/obj/machinery/door/window/windoor = new /obj/machinery/door/window(loc)
						if(facing == "l")
							windoor.icon_state = "leftopen"
							windoor.base_state = "left"
						else
							windoor.icon_state = "rightopen"
							windoor.base_state = "right"
						windoor.setDir(dir)
						windoor.density = FALSE

						if(electronics.one_access)
							windoor.req_one_access = electronics.accesses
						else
							windoor.req_access = electronics.accesses
						windoor.electronics = electronics
						electronics.loc = windoor
						if(created_name)
							windoor.name = created_name
						qdel(src)
						windoor.close()


			else
				return ..()

	//Update to reflect changes(if applicable)
	update_appearance()

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_USE))
			return

	if(facing == "l")
		to_chat(usr, "<span class='notice'>The windoor will now slide to the right.</span>")
		facing = "r"
	else
		facing = "l"
		to_chat(usr, "<span class='notice'>The windoor will now slide to the left.</span>")

	update_appearance()
	return
