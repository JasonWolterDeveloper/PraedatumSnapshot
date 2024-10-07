extends AreaOfEffect

func _ready():
	super()
	$AnimationPlayer.play("ParticleEffect")
