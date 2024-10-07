extends Node

# autom_mag_repack if true causes mags to be repacked whenever a reload is
# requested. This will ensure that the player always reloads the largest mag
# they have with as many bullets as it is possible for that magazine to have
var auto_mag_repack = true

# Easy Reload Mode means that instead of having explicit magazines that we need
# to fill with bullets, guns are simply reloaded directly from ammo items that
# are in the inventory, and magazines never leave their weapons
var easy_reload_mode = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
