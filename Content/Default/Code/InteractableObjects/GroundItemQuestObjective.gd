class_name GroundItemQuestObjective extends GroundItem


@export var quest_id : String
@export var quest_step_id : String


func activate(activator):
	super(activator)
	QuestSystemMaster.complete_quest_step(quest_id, quest_step_id)
