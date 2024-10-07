class_name CompleteQuestStepEffect extends TriggerEffect

@export var quest_id : String
@export var quest_step_id : String


func activate_effect():
	if quest_id and quest_step_id:
		QuestSystemMaster.complete_quest_step(quest_id, quest_step_id)
