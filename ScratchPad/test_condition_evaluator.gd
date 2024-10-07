extends Node

@export var condition_evaluator : ConditionEvaluator


func _process(delta: float) -> void:
	DebugMaster.log_debug(condition_evaluator.evaluate())
