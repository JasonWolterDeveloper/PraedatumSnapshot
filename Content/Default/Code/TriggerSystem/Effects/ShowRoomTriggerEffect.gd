class_name ShowRoomTriggerEffect extends TriggerEffect


@export var hide_room_box : RoomHideBlackBox


func activate_effect():
	if hide_room_box:
		hide_room_box.fade_out()
