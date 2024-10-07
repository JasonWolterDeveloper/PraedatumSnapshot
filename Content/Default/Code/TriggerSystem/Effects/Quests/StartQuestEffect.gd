class_name StartQuestEffect extends TriggerEffect

@export var quest_scene : PackedScene


func activate_effect():
	if quest_scene:
		var quest : Quest = quest_scene.instantiate()
		var existing_quest : Quest = QuestSystemMaster.get_quest_by_id(quest.quest_id)
		if existing_quest and existing_quest.is_complete:
			return
		else:
			QuestSystemMaster.add_quest(quest)
			QuestSystemMaster.set_active_quest_id_for_ui(quest.quest_id)
