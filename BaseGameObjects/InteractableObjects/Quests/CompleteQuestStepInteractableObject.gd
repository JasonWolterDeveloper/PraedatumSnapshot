extends InteractableObject

@export var quest_id = ""
@export var step_id = ""


func find_quest_step_for_activator(activator: Character) -> QuestStep:
	var quest : Quest = QuestSystemMaster.find_quest_by_id(quest_id)
	
	if quest != null:
		var quest_step : QuestStep = quest.find_quest_step_by_step_id(step_id)
		
		if quest_step != null:
			return quest_step
	
	return null


func can_activate(activator: Character):
	var quest_step = find_quest_step_for_activator(activator)
	
	if quest_step != null && quest_step.check_is_active():
		return super(activator)
	return false

func activate(activator: Character):
	super(activator)
	
	var quest_step = find_quest_step_for_activator(activator)
	
	if quest_step != null:
		quest_step.complete()
		
