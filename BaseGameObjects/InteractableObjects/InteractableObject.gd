class_name InteractableObject extends StaticBody3D

# InteractableObject is a type of object that can have special interactions with 
# actors, such as a computer the actor can interact with. This can be anything 
# from computers to doors. Both the Player and AI actors will be able to 
# interact with these objects. However, interactableObjects aren't the only 
# objects that can be interacted with, just that interacting with them is an 
# Interactable's primary purpose. Additionally, Interactables take time to 
# interact with. For example, an actor interacting with a computer
# would have to interact with it for some time to hack into it.


const INTERACTION_ICON_OFFSET = 10

var is_interactable = true	

## Display Name to be used by prompts and UI elements to reference this object.
## Perfectly fine to be an empty string
@export var display_name : String = ""

@export var camera : Camera3D

@onready var activation_area = $ActivationArea
@onready var interaction_icon : InteractionIcon = $CanvasLayer/InteractionIcon
## interaction_icon_marker is a reference to an optional marker3D node which, if and only if
## added as a direct child of this interactable object will modify where the interaction icon is
## displayed for this object. Otherwise it will be displayed at our global_position
@onready var interaction_icon_marker: Marker3D = $InteractionIconMarker

# Has this object been interacted with. Usually used to stop someone from
# activating with an interactable object twice
var has_been_activated = false : # persist_through_save
	set(value):
		has_been_activated = value
		update_aesthetics() 
# If set to false, the interactable object cannot be activated more than once
@export var allow_if_activated = false

@export var display_text_on_activation : bool = false
@export var text_to_display : String = ""
@export var text_display_time : float = 5.1

## interaction_prompt_text and interaction_prompt_subtext are displayed in the 
## interaction ui. The text is typically used to indicate what will be done with
## the interaction, whereas the subtext is used for things like costs for actions
@export var interaction_prompt_text : String = ""
@export var interaction_prompt_subtext : String = ""

## Spawn Ticket cost for random spawning, usually used with loot objects
@export var spawn_ticket_cost : int = 1
@export var activation_conditions : Array[ConditionEvaluator] = []

@export var hold_use : bool = false
@export var hold_use_time : float = 1.0
@export var hold_use_message : String = "Using..."
var current_use_time : float = 0.0
var is_being_held_to_use : bool = false

# self-explanatory, but, updated every process frame
var should_show_interaction_icon
var should_show_interaction_ghost_icon : bool = false

var debug_enabled = false

# The activated signal is emitted when any interactor completes an interaction
# with this interactable. It emits itself so that objects that watch multiple
# interactables know which interaction was activated, and it also emits the
# interactor that completed the interaction for additional information
signal activated(interactable, interactor)

func _ready():
	pass
	
	
func _process(delta):
	if should_show_interaction_icon:
		update_interaction_icon_location()
		interaction_icon.show_selected_for_interaction()
	elif should_show_interaction_ghost_icon:
		update_interaction_icon_location()
		interaction_icon.show_interaction_ghost()
	else:
		interaction_icon.hide_all()
	should_show_interaction_icon = false
	should_show_interaction_ghost_icon = false


func assign_camera(new_camera: Camera3D):
	camera = new_camera


func on_selected_interaction_object_for_activator(activator : Player):
	if can_activate(activator):
		should_show_interaction_icon = true
		interaction_icon.update_interaction_icon_for_input_string(get_input_button_for_interaction())
		update_interaction_icon_text()


func on_enter_interaction_ghost_area_for_activator(activator : Player):
	if can_activate(activator):
		should_show_interaction_ghost_icon = true


func update_interaction_icon_location():
	if debug_enabled:
		DebugMaster.log_debug("Updating Camera Location")
	if camera:
		var icon_position = global_position
		if interaction_icon_marker != null:
			icon_position = interaction_icon_marker.global_position
		var unprojected_position = camera.unproject_position(icon_position)
		interaction_icon.global_position = Vector2(unprojected_position.x - INTERACTION_ICON_OFFSET,unprojected_position.y)


func update_interaction_icon_text():
	interaction_icon.update_prompt_text(generate_interaction_prompt())
	interaction_icon.update_sub_text(generate_interaction_prompt_subtext())


## Updates All Aesthetics aspects of the interactable object so the player can tell
## Whether or not it can be activated, how much it will cost, etc. This will probably
## be overridden by other interactable objects to implement specific features or aesthetic
## Attributes like lights on 3D meshes etc.
func update_aesthetics():
	pass


func can_activate(activator : Character):
	if not allow_if_activated:
		if has_been_activated:
			return false
	if activation_conditions:
		for activation_condition : ConditionEvaluator in activation_conditions:
			if not activation_condition.evaluate():
				return false
	return true


func activate(activator : Character):
	has_been_activated = true
	update_aesthetics()
	if display_text_on_activation:
		OnScreenMessageMaster.display_message(text_to_display, text_display_time)


func attempt_interaction(activator : Character):
	if can_activate(activator):
		if not hold_use:
			activate(activator)
		else:
			start_hold_use_interaction()



# ---------- Hold Use Functionality --------- #

func start_hold_use_interaction():
	current_use_time = 0.0
	is_being_held_to_use = true


func notify_no_longer_being_held():
	current_use_time = 0.0
	is_being_held_to_use = false


func calculate_hold_use_progress_percentage():
	return (current_use_time/hold_use_time) * 100.0


func handle_held_for_long_enough():
	activate(GameMaster.get_player())
	is_being_held_to_use = false
	current_use_time = 0.0


func notify_has_been_held(delta : float):
	if is_being_held_to_use:
		current_use_time += delta
		OnScreenMessageMaster.display_progress(calculate_hold_use_progress_percentage(), hold_use_message)
		
		if current_use_time >= hold_use_time:
			handle_held_for_long_enough()


# --------- Getters --------- #

func get_spawn_ticket_cost():
	return spawn_ticket_cost


func get_level():
	return GameMaster.get_level()


func generate_interaction_prompt():
	return interaction_prompt_text


func generate_interaction_prompt_subtext():
	return interaction_prompt_subtext


# Returns the button used to interact with this object as a
# string. This is primarily used to update the interaction icon
# to display the proper button input
func get_input_button_for_interaction():
	## TODO - Make this actually return something meaningful
	return 'f'


func get_player():
	return Util.get_player(self)
		

"""
extends Area2D

# returns true if the player attmepting to interact with this should cause the
# player character to interact with the interactable. The alternative is that
# an attempted interaction causes an interaction order to be issued
func attemptedInteractionShouldCausePlayerInteraction():
	var val = isReadyForPlayerInteraction()
	return val
	
# returns true if the player attempting to interact with this should cause a
# command to be issued to a squad mate. This occurs if a squadmate can interact
# with it AND the player can't
func attemptedInteractionShouldCauseInteractionCommand():
	return isUsableByPlayerOrSquadMates() and not attemptedInteractionShouldCausePlayerInteraction()

func stopInteractorMovement():
	if isInteracting() and not isInstant():
		getInteractor().temporarilyDisableMovement()

func overrideInteractorAiming():
	if isInteracting() and not isInstant():
		var forNowDoesNothing = true
		# TODO - reinstate these
		# getInteractor().temporarilyDisableManualAiming()
		# getInteractor().setOverrideFocusPoint(get_global_position())

func checkPlayerInteraction(gameMousePos):
	return getInteractionIcon().checkPlayerInteraction(gameMousePos)

# isAssigned() returns true if a squad member has been issued an order to use this interactable object
func isAssigned():
	return false # We don't have a command manager to handle this yet 
	# TODO: Fix the issu
	# return Util.getModel(self).getCommandManager().commandIssuedForInteractableObject(self)

# getAssignedTo() returns the actor that is assigned an order to interact with this object if there is one, and null
# otherwise
func getAssignedTo():
	return Util.getModel(self).getCommandManager().getActorAssignedTo(self)

# This function checks if it is at all potentially possible for the player or one of the player's squad mates to
# interact with this object. This includes checking for things like the consumable cost of interacting with this
# object
func isUsableByPlayerOrSquadMates():
	return checkPotentialInteraction(Util.getModel(self).getPlayer())
	
# isReadyForPlayerInteraction() returns true if the player is currently able to 
# interact with the given Interactable.
func isReadyForPlayerInteraction():
	return canInteract(Util.getModel(self).getPlayer())

func isInteractingWithPlayer():
	return getInteractor() is Util.getModel(self).getPlayer()

# checkInteractionArea(myObject) checks if myObject is in a valid area to 
# interact with this Interactable
func checkInteractionArea(myObject):
	# if interaction distance is -1, the interactable object can be interacted with from any distance
	if getInteractAnywhere():
		return true
	elif overlaps_body(myObject):
		return true
	return false

# checkInteractionGeometry(actorObject) ensures that the actorObject has line of sight to this interactable object.
# This is not essential for all interactions, but it is for many
func checkInteractionGeometry(actorObject):
	if actorObject.hasLineOfSight(self):
		return true
	else:
		return false

# checkPotentialInteraction(myObject) checks if it will ever be feasible for the actor to interact with this object
# if myObject or the interaction object is moved
func checkPotentialInteraction(myObject):
	if canActivate():
		return true
	return false

# checkOccupiedByAnother(myObject) returns true if the interaction object is currently occupied by another object
# and therefore cannot be interacted with
func checkOccupiedByAnother(myObject):
	if interactor == myObject or interactor == null:
		# We also want to check if we are assigned another interactor, as this is just as good as being occupied
		if isAssigned():
			if getAssignedTo() is myObject:
				return false
		else:
			return false
	return true

# checkPhysicalInteraction returns true if myObject can physically interact with this object, that is that myObject
# is close enough to it and there is no geometry (no other collidable object) impeding the interaction
func checkPhysicalInteraction(myObject):
	if checkInteractionArea(myObject): # and checkInteractionGeometry(myObject):
		return true
	return false

# Returns true if myObject can interact with the object currently
func canInteract(myObject):
	if checkPotentialInteraction(myObject):
		if checkPhysicalInteraction(myObject):
			if not checkOccupiedByAnother(myObject):
				return true
	return false

# Returns true if its possible for this to be activated I.E. if the function that occurs when the object is
# interacted with can occur
func canActivate():
	if activated:
		if allowIfActivated:
			return true
		return false
	return true

# Begins the interaction process
func interact(myObject):
	myObject.getInteractionManager().setInteractingWith(self)
	setInteractor(myObject)
	interacting = true

# _process(elaspedTime) is the function that is run every frame in the game loop. It updates
# various values in an interactable object, such as checking whether or not an actor is
# still interacting with it, and how much time the actor has been interacting with the
# object for
func _process(delta):
	# Increment interaction time if the object is being interacted with
	if interactor != null:
		if interactor.getInteractionManager().isInteracting(self):
			interactionDuration = interactionDuration + delta

			# If we are a type of interactable object you can't move while interacting with, we temporarily stop
			# the interacting actor's movement
			if shouldStopMovement():
				stopInteractorMovement()

			# If we are a type of interactable object that should override the actor's aiming, we stop them from
			# manually aiming and tell them where they should aim here
			if shouldOverrideAiming():
				overrideInteractorAiming()

			# Activate the object if it has been interacted with long enough
			if interactionDuration > getActivationTime():
				if activated != true or canActivateMultipleTimes():
					activate(interactor)
		else:
			interactor = null

	else:
		interacting = false
		interactionDuration = 0

# activate(activator) simply does whatever the interactable object is supposed to do once
# it has been interacted with. If it is a computer, this could be opening up the dialog that
# corresponds to the computer, If it is a door, the door should open or close. This function
# should be overridden for whatever the interactable object needs to do.
func activate(activator=null):
	activator = activator

	# If we don't pass an activator to the activate function, make it the actor who is currently
	# interacting with the object
	if activator == null:
		activator = interactor

	# Set activated so that actors can't try to interact with it again
	activated = true

	emit_signal("activated", self, activator)

	if WarConstants.interactionDebug:
		Util.getModel(self).logDebug("Activated By: " + str(activator) + " Named: " + str(activator.name))

# getActivationPercentage() returns how close to being completed the interaction with this object is. If there is
# no one interaction with this object, this will be 0
func getActivationPercentage():
	if interacting:
		if interactionDuration > activationTime:
			return 1
		return (interactionDuration + 0.0)/(activationTime + 0.0)
	return 0
	
func canActivateMultipleTimes():
	return allowIfActivated

# isInstant returns true if this object is instantly activated upon being interacted with
func isInstant():
	return getActivationTime() == 0

func isBeingInteractedWith():
	return interacting

func isInteracting():
	return interacting

func shouldStopMovement():
	return stopMovement

func shouldOverrideAiming():
	return overrideAiming
	
# returns true if the object passed into the function is an object that could
# possibly complete a squad order to interact with this interactable and false
# otherwise
func objectCanCompleteOrder(actor):
	return checkPotentialInteraction(actor)
	
# sets the state of the AIManager for the actor to the AIState required to 
# complete, or start completing this order. This is abstract for the base
# squad order class
func changeActorAIState(actor):
	actor.getAIManager().setAssignedInteractableObject(self)
	actor.getAIManager().changeAIState(actor.getAIManager().getMoveToInteractableState())
	
func assignToActor(actor):
	setAssignedActor(actor)
	
# Both assigns and sets the AIManager state of the given actor to complete this
# interactable as a squad order
func issueOrderToActor(actor):
	assignToActor(actor)
	changeActorAIState(actor)
	
# Remove any actor that is currently assigned to complete this order from 
# completing it. We do not assign the actor state here, because they should go
# back to doing whatever they were doing before being issued this order, which
# we as a squad order do not know
func cancelOrder():
	setAssignedActor(null)
	
# the completeOrder function takes in an actor and does different things to the
# actor depending on what order was completed. This should be called 
# automatically whenever an actor completes this order
func completeOrder(actor):
	var thisIsAbtract = true

func makeSaveDict():
	var saveDict = {
		SaveLoadConsts.fileNameSaveDictKey : get_filename(),
		"rotation" : rotation,
		"xpos" : position.x,
		"ypos" : position.y,
		"activated" : activated,
	}

	# Custom_Dev_Lines_Start
	# Custom_Dev_Lines_End

	return saveDict

func loadFromSaveDict(saveDict):
	rotation = saveDict["rotation"]
	position.x = saveDict["xpos"]
	position.y = saveDict["ypos"]
	activated = saveDict["activated"]


	# Custom_Dev_Lines_Start
	# Custom_Dev_Lines_End


##### Getters and Setters #####


func getIsInteractable():
	return isInteractable

func setIsInteractable(val):
	isInteractable = val

func getActivated():
	return activated

func setActivated(val):
	activated = val

func getActivationTime():
	return activationTime

func setActivationTime(val):
	activationTime = val

func getActivator():
	return activator

func setActivator(val):
	activator = val

func getInteractionDuration():
	return interactionDuration

func setInteractionDuration(val):
	interactionDuration = val

func getInteractor():
	return interactor

func setInteractor(interactor):
	self.interactor = interactor
	
func getInteracting():
	return interacting

func setInteracting(val):
	interacting = val

func getConversationText():
	return conversationText

func setConversationText(val):
	conversationText = val

func getConversationChoice():
	return conversationChoice

func setConversationChoice(val):
	conversationChoice = val

func getAllowIfActivated():
	return allowIfActivated

func setAllowIfActivated(val):
	allowIfActivated = val

func getInteractionIcon():
	return interactionIcon

func setInteractionIcon(interactionIcon):
	self.interactionIcon = interactionIcon
	
func getAssignedActor():
	return assignedActor
	
func setAssignedActor(val):
	self.assignedActor = val
	
func getOrderType():
	return orderType

func setOrderType(val):
	orderType = val

func getStopMovement():
	return stopMovement

func setStopMovement(val):
	stopMovement = val

func getOverrideAiming():
	return overrideAiming

func setOverrideAiming(val):
	overrideAiming = val

func getInteractAnywhere():
	return interactAnywhere

func setInteractAnywhere(val):
	interactAnywhere = val


func getModel():
	return Util.getModel(self)


func is_class(type):
	return type == CustomClassConstants.INTERACTABLE_CLASS_NAME or .is_class(type)


func get_class():
	return CustomClassConstants.INTERACTABLE_CLASS_NAME

"""
