extends Control

@export var pressed_color := Color.GRAY

var dragging : bool = false

@onready var handle := $Handle
@onready var split := $Split

@onready var handle_radius = handle.size * handle.get_global_transform_with_canvas().get_scale() / 2
@onready var split_cen_pos = split.size * split.get_global_transform_with_canvas().get_scale() / 2

signal split_moved(split_val : float)

func is_point_inside_handle(pos : Vector2) -> bool:
	var center : Vector2 = handle_radius + handle.global_position
	var vector : Vector2 = pos - center
	if vector.length_squared() <= handle_radius.x * handle_radius.x:
		return true
	else:
		return false


func move_handle(pos : Vector2) -> void:
	var rect : Rect2 = get_global_rect()
	var pos_l = Vector2(\
		clampf(pos.x,rect.position.x,rect.end.x),\
		clampf(pos.y,rect.position.y,rect.end.y))
	var pos_s = pos_l / rect.size
	
	emit_signal("split_moved",pos_s.x)
	
	var global_scale = get_global_transform_with_canvas().get_scale()
	
	var vec_h : Vector2 = pos_l - handle_radius
	var vec_s : float = (pos_l - split_cen_pos).x
	
	handle.global_position = vec_h - handle.pivot_offset * global_scale
	split.global_position.x = vec_s - split.pivot_offset.x * global_scale.x

func _input(event : InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if is_point_inside_handle(event.position):
			if not dragging and event.is_pressed():
				dragging = true
				get_viewport().set_input_as_handled()
		if dragging and not event.is_pressed():
			dragging = false
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		move_handle(event.position)
		get_viewport().set_input_as_handled()

func _process(_delta : float):
	var rect : Rect2 = get_global_rect()
	var handle_center = handle.global_position + handle_radius
	handle_center = Vector2(\
		clampf(handle_center.x,rect.position.x,rect.end.x),\
		clampf(handle_center.y,rect.position.y,rect.end.y))
	handle.global_position = handle_center - handle_radius
	var split_center = split.global_position.x + split_cen_pos.x
	split_center = clampf(split_center,rect.position.x,rect.end.x)
	split.global_position.x = split_center - split_cen_pos.x
