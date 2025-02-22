extends Node3D

func _process(delta: float) -> void:
	var _time = Time.get_ticks_msec() / 1000.0

	DebugDraw2D.set_text("Time", _time)
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	DebugDraw2D.set_text("delta", delta)
	DebugDraw2D.set_text("Current Number of Rope Links:", get_node("RopeGeneratorV2").links_array.size())
