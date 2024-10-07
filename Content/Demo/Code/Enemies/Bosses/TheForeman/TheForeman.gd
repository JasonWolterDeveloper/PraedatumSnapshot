class_name Foreman extends Zombie

@export var skull_key_scene : PackedScene
@export var foreman_defeated_trigger_id : String = "foreman_defeated"

@export var spawners : Array[PhysicalEnemySpawner] = []
@export var monster_closets : Array[MonsterClosetRoom] = []

var current_number_of_call_ins = 0
# var max_number_of_call_ins = 3

@export var monster_closet_call_in_stages : Array[int] = [1, 3]


func on_death():
	BossUIMaster.end_boss_fight(self)
	drop_item_from_scene(skull_key_scene)
	var defeat_trigger : Trigger = TriggerMaster.get_trigger_by_id(foreman_defeated_trigger_id)
	defeat_trigger.activate()
	super()


func trigger_call_ins():
	if current_number_of_call_ins in monster_closet_call_in_stages:
		activate_random_monster_closet()
	if current_number_of_call_ins == 0:
		spawn_from_number_of_spawners(4)
	elif current_number_of_call_ins == 1:
		spawn_from_number_of_spawners(2)
	else:
		spawn_from_number_of_spawners(4)
	current_number_of_call_ins += 1


func activate_random_monster_closet() -> void:
	if monster_closets:
		var monster_closet : MonsterClosetRoom = Util.pick_random_array_element(monster_closets)
		monster_closet.activate_monster_closet()
		Util.delete_object_from_array(monster_closets, monster_closet)


func spawn_from_number_of_spawners(number_of_spawners : int):
	var spawner_set = Util.pick_random_array_elements(spawners, number_of_spawners)
	
	for spawner : PhysicalEnemySpawner in spawner_set:
		spawner.spawn()
	


"""
func _process(delta):
	super(delta)
	if Input.is_action_just_pressed("debug_7"):
		ai_disabled = false
		BossUIMaster.start_boss_fight(self)
"""
