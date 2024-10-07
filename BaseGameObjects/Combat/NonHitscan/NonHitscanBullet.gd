class_name NonHitscanBullet extends CharacterBody3D

@export var speed : float
@export var damage : float

# We want to delete ourselves after a certain amount of time even if we haven't hit anything
# just in case we don't hit anything
@export var time_to_live = 2.0
var current_life_time = 0.0

var origin_character : Character

var linear_velocity = Vector3.ZERO


## An effect use to show the sights and sounds to the player if they get hit
## by this attack
@export var player_damaged_aesthetic_effect : PlayerDamagedAestheticEffect



func fire_bullet(start_pos: Vector3, direction: Vector3, shooting_character : Character = null):
	global_position = start_pos
	var local_direction = to_local(direction)
	var direction_old_y_component = Vector3(direction.x, global_position.y, direction.z)
	var direction_no_y_component = Vector3(local_direction.x, 0, local_direction.z)
	linear_velocity = direction_no_y_component.normalized() * speed
	look_at(direction_old_y_component, Vector3.UP)
	origin_character = shooting_character


func handle_collision(collision : KinematicCollision3D):
	var body = collision.get_collider()
	
	if body and not body == origin_character:
		if body is hitbox:
			if body.get_character() is Player:
				player_damaged_aesthetic_effect.play_damage_effect()
			body.deal_damage_to_character(damage)
		if body is Character:
			deal_damage_to_character(body)
		queue_free()


func deal_damage_to_character(damaged_character : Character):
	if damaged_character is Player and player_damaged_aesthetic_effect:
		player_damaged_aesthetic_effect.play_damage_effect()
		
	RPGEventMaster.invoke_damage_event(damage, damaged_character, origin_character)


func handle_time_to_live(delta):
	current_life_time += delta
	
	if current_life_time > time_to_live:
		queue_free()


func _physics_process(delta):
	var result = move_and_collide(linear_velocity * delta)
	if result:
		handle_collision(result)
		
	handle_time_to_live(delta)
