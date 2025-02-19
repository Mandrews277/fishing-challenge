extends Node3D

func _process(delta: float) -> void:
	var _time = Time.get_ticks_msec() / 1000.0

	DebugDraw3D.draw_gizmo(Transform3D(global_basis).scaled(Vector3(0.5, 0.5, 0.5)), Color(0, 0, 1), )
	DebugDraw2D.set_text("Time", _time)
	DebugDraw2D.set_text("Frames drawn", Engine.get_frames_drawn())
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())
	DebugDraw2D.set_text("delta", delta)
