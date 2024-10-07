extends InteractableObject

@export var quest_to_start_scene : PackedScene

# An instantiated version of the quest we start used for reference info like
# quest_id, Display_name, etc.
var reference_quest: Quest

func _ready():
	reference_quest = quest_to_start_scene.instantiate()

func activate(activator : Character):
	super(activator)
	start_quest_for_player(activator)

func start_quest_for_player(player_character : Character):
	var new_quest = quest_to_start_scene.instantiate()
	QuestSystemMaster.start_quest(new_quest)
	
func can_activate(activator : Character):
	if QuestSystemMaster.has_quest_id(reference_quest.quest_id):
		return false
	return super(activator)
