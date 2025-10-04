extends Node3D


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			$AnimationPlayer.play("swipe")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.play("ready")
