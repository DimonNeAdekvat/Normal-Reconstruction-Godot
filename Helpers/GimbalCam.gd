@tool
extends Node3D

@export_range(1.0,10.0,0.1,"or_greater") var distance : float = 5
@export_range(1.0,50.0) var angle_speed : float = 30.0
@export_range(-180,180) var angle_lr : float = 0.0
@export_range(-180,180) var angle_ud : float = 0.0
@export var autorotate : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	%Joint1.rotation_degrees.y = angle_lr
	%Joint2.rotation_degrees.x = -angle_ud
	%Camera.position.z = distance
	%Camera.size = distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	distance = max(0.1,distance)
	if %Camera.projection == Camera3D.PROJECTION_ORTHOGONAL :
		%Joint1.position.y = 1.0
		%Camera.size = distance
	else:
		%Joint1.position.y = 0.0
		%Camera.position.z = distance
	
	%Joint1.rotation_degrees.y = angle_lr
	%Joint2.rotation_degrees.x = -angle_ud
	
	if Engine.is_editor_hint():
		return
	
	angle_lr += delta * angle_speed * Input.get_axis("move_l","move_r")
	angle_ud += delta * angle_speed * Input.get_axis("move_d","move_u")
	
	if autorotate : 
		angle_lr += delta * angle_speed
	if Input.is_action_pressed("move_i") :
		distance -= delta * angle_speed * 0.25
	if Input.is_action_pressed("move_o") :
		distance += delta * angle_speed * 0.25

func set_projection(projection):
	%Camera.projection = projection
