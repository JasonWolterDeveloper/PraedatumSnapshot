class_name GrenadeProjectile extends Projectile

@export var fuze_time = 3.0
var current_time = 0.0
var exploded = false

@onready var explosion : Explosion = $Explosion
@export var grenade_3D_model : Node3D


func _process(delta):
	super(delta)
	if actually_thrown and not exploded:
		current_time += delta
		
		if current_time >= fuze_time:
			thrown = false
			real_projectile_velocity = Vector3(0, 0, 0)
			exploded = true
			explosion.explode()
			
			if grenade_3D_model:
				grenade_3D_model.hide()


func _on_explosion_explosion_finished():
	queue_free()
