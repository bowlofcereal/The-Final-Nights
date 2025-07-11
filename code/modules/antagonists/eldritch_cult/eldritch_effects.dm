/obj/effect/heretic_rune
	name = "Generic rune"
	desc = "A flowing circle of shapes and runes is etched into the floor, filled with a thick black tar-like fluid."
	anchored = TRUE
	icon_state = ""
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER

/obj/effect/heretic_rune/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	try_activate(user)

/obj/effect/heretic_rune/proc/try_activate(mob/living/user)
	if(!IS_HERETIC(user))
		return
	INVOKE_ASYNC(src, PROC_REF(activate) , user)

/obj/effect/heretic_rune/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(istype(I,/obj/item/nullrod))
		qdel(src)

/obj/effect/heretic_rune/proc/activate(mob/living/user)
	flick("[icon_state]_active",src)
	playsound(user, 'sound/magic/castsummon.ogg', 75, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_exponent = 10)


/// A 3x3 heretic rune. The kind heretics actually draw in game.
/obj/effect/heretic_rune/big
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = 18
	pixel_z = -48
	greyscale_config = /datum/greyscale_config/heretic_rune

/obj/effect/heretic_rune/big/Initialize(mapload, path_colour)
	. = ..()
	if (path_colour)
		set_greyscale(colors = list(path_colour))

/obj/effect/temp_visual/drawing_heretic_rune
	duration = 30 SECONDS
	icon = 'icons/effects/96x96.dmi'
	icon_state = "transmutation_rune"
	pixel_x = -30
	pixel_y = 18
	pixel_z = -48
	plane = FLOOR_PLANE
	layer = FLOOR_PLANE
	greyscale_config = /datum/greyscale_config/heretic_rune
	/// We only set this state after setting the colour, otherwise the animation doesn't colour correctly
	var/animation_state = "transmutation_rune_draw"

/obj/effect/temp_visual/drawing_heretic_rune/Initialize(mapload, path_colour = COLOR_RED)
	. = ..()
	set_greyscale(colors = list(path_colour))
	icon_state = animation_state

/obj/effect/temp_visual/drawing_heretic_rune/fast
	duration = 12 SECONDS
	animation_state = "transmutation_rune_fast"

/obj/effect/temp_visual/drawing_heretic_rune/fail
	duration = 0.25 SECONDS
	animation_state = "transmutation_rune_fail"


/**
 * #Reality smash tracker
 *
 * Stupid fucking list holder, DONT create new ones, it will break the game, this is automnatically created whenever eldritch cultists are created.
 *
 * Tracks relevant data, generates relevant data, useful tool
 */
/datum/reality_smash_tracker
	///list of tracked reality smashes
	var/list/smashes = list()
	///List of mobs with ability to see the smashes
	var/list/targets = list()

/datum/reality_smash_tracker/Destroy(force, ...)
	if(GLOB.reality_smash_track == src)
		stack_trace("/datum/reality_smash_tracker was deleted. Heretics may no longer access any influences. Fix it or call coder support")
	QDEL_LIST(smashes)
	targets.Cut()
	return ..()
/**
 * Automatically fixes the target and smash network
 *
 * Fixes any bugs that are caused by late Generate() or exchanging clients
 */
/datum/reality_smash_tracker/proc/ReworkNetwork()
	listclearnulls(smashes)
	for(var/mind in targets)
		if(isnull(mind))
			stack_trace("A null somehow landed in a list of minds")
			continue
		for(var/X in smashes)
			var/obj/effect/reality_smash/reality_smash = X
			reality_smash.AddMind(mind)

/**
 * Generates a set amount of reality smashes based on the N value
 *
 * Automatically creates more reality smashes
 */
/datum/reality_smash_tracker/proc/Generate(mob/clicker)
	if(istype(clicker))
		targets += clicker
	var/targ_len = length(targets)
	var/smash_len = length(smashes)
	var/number = max(targ_len * (4-(targ_len-1)) - smash_len,1)

	for(var/i in 0 to number)
		var/turf/chosen_location = get_safe_random_station_turf()
		//we also dont want them close to each other, at least 1 tile of seperation
		var/obj/effect/reality_smash/what_if_i_have_one = locate() in range(1, chosen_location)
		var/obj/effect/broken_illusion/what_if_i_had_one_but_got_used = locate() in range(1, chosen_location)
		if(what_if_i_have_one || what_if_i_had_one_but_got_used) //we dont want to spawn
			continue
		new /obj/effect/reality_smash(chosen_location)
	ReworkNetwork()

/**
 * Adds a mind to the list of people that can see the reality smashes
 *
 * Use this whenever you want to add someone to the list
 */
/datum/reality_smash_tracker/proc/AddMind(datum/mind/e_cultists)
	RegisterSignal(e_cultists.current,COMSIG_MOB_LOGIN, PROC_REF(ReworkNetwork))
	targets |= e_cultists
	Generate()
	for(var/obj/effect/reality_smash/reality_smash in smashes)
		reality_smash.AddMind(e_cultists)


/**
 * Removes a mind from the list of people that can see the reality smashes
 *
 * Use this whenever you want to remove someone from the list
 */
/datum/reality_smash_tracker/proc/RemoveMind(datum/mind/e_cultists)
	UnregisterSignal(e_cultists.current,COMSIG_MOB_LOGIN)
	targets -= e_cultists
	for(var/obj/effect/reality_smash/reality_smash in smashes)
		reality_smash.RemoveMind(e_cultists)

/obj/effect/broken_illusion
	name = "pierced reality"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "pierced_illusion"
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	alpha = 0

/obj/effect/broken_illusion/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(show_presence)),15 SECONDS)

	var/image/I = image('icons/effects/eldritch.dmi',src,null,OBJ_LAYER)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "pierced_reality", I)

///Makes this obj appear out of nothing
/obj/effect/broken_illusion/proc/show_presence()
	animate(src,alpha = 255,time = 15 SECONDS)

/obj/effect/broken_illusion/attack_hand(mob/living/user, list/modifiers)
	if(!ishuman(user))
		return ..()
	var/mob/living/carbon/human/human_user = user
	if(IS_HERETIC(human_user))
		to_chat(human_user,"<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
	else
		var/obj/item/bodypart/arm = human_user.get_active_hand()
		if(prob(25))
			to_chat(human_user,"<span class='userdanger'>An otherwordly presence tears and atomizes your arm as you try to touch the hole in the very fabric of reality!</span>")
			arm.dismember()
			qdel(arm)
		else
			to_chat(human_user,"<span class='danger'>You pull your hand away from the hole as the eldritch energy flails trying to latch onto existance itself!</span>")


/obj/effect/broken_illusion/attack_tk(mob/user)
	if(!ishuman(user))
		return
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/human/human_user = user
	if(IS_HERETIC(human_user))
		to_chat(human_user,"<span class='boldwarning'>You know better than to tempt forces out of your control!</span>")
		return
	//a very elaborate way to suicide
	to_chat(human_user,"<span class='userdanger'>Eldritch energy lashes out, piercing your fragile mind, tearing it to pieces!</span>")
	human_user.ghostize()
	var/obj/item/bodypart/head/head = locate() in human_user.bodyparts
	if(head)
		head.dismember()
		qdel(head)
	else
		human_user.gib()

	var/datum/effect_system/reagents_explosion/explosion = new()
	explosion.set_up(1, get_turf(human_user), TRUE, 0)
	explosion.start()


/obj/effect/broken_illusion/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user) && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		to_chat(human_user,"<span class='warning'>Your mind burns as you stare at the tear!</span>")
		human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN,10,190)
		SEND_SIGNAL(human_user, COMSIG_ADD_MOOD_EVENT, "gates_of_mansus", /datum/mood_event/gates_of_mansus)

/obj/effect/reality_smash
	name = "reality smash"
	icon = 'icons/effects/eldritch.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	///We cannot use icon_state since this is invisible, functions the same way but with custom behaviour.
	var/image_state = "reality_smash"
	///Who can see us?
	var/list/minds = list()
	///Tracked image
	var/image/img

/obj/effect/reality_smash/Initialize()
	. = ..()
	GLOB.reality_smash_track.smashes += src
	img = image(icon, src, image_state, OBJ_LAYER)
	generate_name()

/obj/effect/reality_smash/Destroy()
	GLOB.reality_smash_track.smashes -= src
	on_destroy()
	return ..()

/obj/effect/reality_smash/proc/on_destroy()
	for(var/e_cultists in minds)
		var/datum/mind/e_cultie = e_cultists
		if(e_cultie.current?.client)
			e_cultie.current.client.images -= img
		//clear the list
		minds -= e_cultie
	img = null
	var/obj/effect/broken_illusion/illusion = new /obj/effect/broken_illusion(drop_location())
	illusion.name = pick("Researched","Siphoned","Analyzed","Emptied","Drained") + " " + name

///Makes the mind able to see this effect
/obj/effect/reality_smash/proc/AddMind(datum/mind/e_cultie)
	minds |= e_cultie
	if(e_cultie.current.client)
		e_cultie.current.client.images |= img

///Makes the mind not able to see this effect
/obj/effect/reality_smash/proc/RemoveMind(datum/mind/e_cultie)
	minds -= e_cultie
	if(e_cultie.current.client)
		e_cultie.current.client.images -= img

///Generates random name
/obj/effect/reality_smash/proc/generate_name()
	var/static/list/prefix = list("Omniscient","Thundering","Enlightening","Intrusive","Rejectful","Atomized","Subtle","Rising","Lowering","Fleeting","Towering","Blissful","Arrogant","Threatening","Peaceful","Aggressive")
	var/static/list/postfix = list("Flaw","Presence","Crack","Heat","Cold","Memory","Reminder","Breeze","Grasp","Sight","Whisper","Flow","Touch","Veil","Thought","Imperfection","Blemish","Blush")

	name = "\improper" + pick(prefix) + " " + pick(postfix)
