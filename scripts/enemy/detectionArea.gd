extends Area2D
class_name DetectionArea

export(NodePath) onready var enemy = get_node(enemy) as KinematicBody2D

func _on_body_entered(body: Player) -> void:
	enemy.player_ref = body


func _on_body_exited(_body: Player) -> void:
	enemy.player_ref = null
