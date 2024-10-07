extends Node

const ENEMY_DEATH_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/RPGEnemyDeathEvent.tscn")

# ----- Health & Damage Event Variables ----- #
const HEAL_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/HealEvent.tscn")

# ----- Mana Event Variables ----- #
const PAY_MANA_COST_EVENT = preload("res://BaseGameObjects/RPGMechanics/RPGAbilities/Events/PayManaCostEvent.tscn")
const RESTORE_MANA_EVENT = preload("res://BaseGameObjects/RPGMechanics/RPGAbilities/Events/RestoreManaEvent.tscn")

# ----- Weapon Event Variables ----- #
const RELOAD_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/ReloadEvent.tscn")
const RATE_OF_FIRE_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/RateOfFireEvent.tscn")
const RECOIL_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/RecoilEvent.tscn")
const RECOIL_RECOVERY_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/RecoilRecoveryEvent.tscn")
const MOVEMENT_SPREAD_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/MovementSpreadEvent.tscn")
const MOVEMENT_SPREAD_RECOVERY_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/MovementSpreadRecoveryEvent.tscn")
const AMMO_CONSUMPTION_EVENT = preload("res://BaseGameObjects/RPGMechanics/Events/WeaponEvents/AmmoConsumptionEvent.tscn")

# ----- Morale Buff Event Variables ----- $
const START_MORALE_BUFF_EVENT = preload("res://BaseGameObjects/RPGMechanics/MoraleBuffs/MoraleBuffEvents/StartMoraleBuffEvent.tscn")


# ----------- Morale Buff Events ---------- #


func invoke_start_morale_buff_event(morale_buff : MoraleBuff):
	var start_morale_buff_event : StartMoraleBuffEvent = START_MORALE_BUFF_EVENT.instantiate()
	start_morale_buff_event.morale_buff = morale_buff
	
	start_morale_buff_event.invoke_event()



# ---------- Weapon Events ---------- #


func invoke_ammo_consumption_event(gun : Gun, amount : int):
	var ammo_consumption_event : AmmoConsumptionEvent
	ammo_consumption_event.gun = gun
	ammo_consumption_event.amount = amount
	
	ammo_consumption_event.invoke_event()


func invoke_movement_spread_event(weapon : Weapon, delta : float) -> void:
	var movement_spread_event : MovementSpreadEvent = MOVEMENT_SPREAD_EVENT.instantiate()
	movement_spread_event.weapon = weapon
	movement_spread_event.delta = delta
	
	movement_spread_event.invoke_event()


func invoke_movement_spread_recovery_event(weapon : Weapon, delta : float) -> void:
	var movement_spread_recovery_event : MovementSpreadRecoveryEvent = MOVEMENT_SPREAD_RECOVERY_EVENT.instantiate()
	movement_spread_recovery_event.weapon = weapon
	movement_spread_recovery_event.delta = delta
	
	movement_spread_recovery_event.invoke_event()


func invoke_recoil_recovery_event(weapon : Weapon, delta : float) -> void:
	var recoil_event : RecoilRecoveryEvent = RECOIL_RECOVERY_EVENT.instantiate()
	recoil_event.weapon = weapon
	recoil_event.delta = delta
	
	recoil_event.invoke_event()


func invoke_recoil_event(weapon : Weapon, recoil_amount : float) -> void:
	var recoil_event : RecoilEvent = RECOIL_EVENT.instantiate()
	recoil_event.weapon = weapon
	recoil_event.recoil_amount = recoil_amount
	
	recoil_event.invoke_event()


func invoke_rate_of_fire_event(weapon : Weapon):
	var rate_of_fire_event : RateOfFireEvent = RATE_OF_FIRE_EVENT.instantiate()
	rate_of_fire_event.weapon = weapon
	
	rate_of_fire_event.invoke_event()


func invoke_reload_event(reload_master : ReloadMaster):
	var reload_event : ReloadEvent = RELOAD_EVENT.instantiate()
	reload_event.reload_master = reload_master
	
	reload_event.invoke_event()


func invoke_experience_event(experience_gained : int):
	var experience_event = RPGEventConstants.EXPERIENCE_EVENT.instantiate()
	experience_event.experience_gained = experience_gained
	experience_event.invoke_event()


func invoke_enemy_death_event(enemy: Enemy):
	var enemy_death_event : RPGEnemeyDeathEvent = ENEMY_DEATH_EVENT.instantiate()
	enemy_death_event.dying_enemy = enemy
	
	enemy_death_event.invoke_event()


func invoke_pay_mana_cost_event(mana_cost : float, character : Character = WarriorMaster.player):
	var pay_mana_event : PayManaCostEvent = PAY_MANA_COST_EVENT.instantiate()
	pay_mana_event.mana_cost = mana_cost
	pay_mana_event.mana_cost_payer = character
	
	pay_mana_event.invoke_event()


func invoke_restore_mana_event(mana_restore : float):
	var restore_mana_event : RestoreManaEvent = RESTORE_MANA_EVENT.instantiate()
	restore_mana_event.mana_restore = mana_restore
	
	restore_mana_event.invoke_event()



# --------- Health and Damage Events ---------- #


func invoke_heal_event(heal_amount : float, healed_character : Character):
	var heal_event : HealEvent = HEAL_EVENT.instantiate()
	
	heal_event.heal_amount = heal_amount
	heal_event.healed_character = healed_character
	
	heal_event.invoke_event()


func invoke_damage_event(damage_amount : float, 
						damaged_character : Character, 
						damager_character : Character = null, 
						weapon : Weapon = null, 
						bullet : Bullet = null):
	var damage_event = RPGEventConstants.DAMAGE_EVENT.instantiate()
	
	damage_event.damager_character = damager_character
	damage_event.damaged_character = damaged_character
	damage_event.damage_amount = damage_amount
	damage_event.weapon = weapon
	damage_event.bullet = bullet
	
	damage_event.invoke_event()
