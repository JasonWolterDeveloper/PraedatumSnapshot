class_name QuestStatusConditionEvaluator extends ConditionEvaluator

@export var quest_id : String = ""
## Leave quest_step_id as blank to evaluate the quest itself. Otherwise this will
## evalute the specific quest step
@export var quest_step_id : String = ""

# Check for quest_started
@export var is_started : bool = true
# Check for quest_completed
@export var is_completed : bool = false

func evaluate():
	if quest_step_id != "":
		if is_completed and QuestSystemMaster.is_quest_step_complete(quest_id, quest_step_id):
			return evaluate_true()
		elif is_started and QuestSystemMaster.is_quest_step_started(quest_id, quest_step_id):
			return evaluate_true()
	else:
		if is_completed and QuestSystemMaster.is_quest_complete(quest_id):
			return evaluate_true()
		elif is_started and QuestSystemMaster.is_quest_started(quest_id):
			return evaluate_true()
	return evaluate_false()
