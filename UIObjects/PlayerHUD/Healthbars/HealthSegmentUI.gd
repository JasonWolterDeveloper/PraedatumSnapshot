extends TextureProgressBar

func on_segment_percent_full_changed(new_percent:float) -> void:
	value = roundi(100 * new_percent)
