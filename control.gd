extends Control

@onready var compatibility = false

class ShaderSelector:
	var tab : int
	var norm_ind : int
	var high_ind : int
	func _init(tabn : int,norm_indx : int,high_indx : int):
		self.tab = tabn
		self.high_ind = norm_indx
		self.high_ind = high_indx

var shader_sel_L := ShaderSelector.new(0,0,1) 
var shader_sel_R := ShaderSelector.new(0,3,7)

var empty = preload("res://Shaders/Empty.gdshader")
var n_true = preload("res://Shaders/Normals_True.gdshader")
var n_3tap = preload("res://Shaders/Normals_3tap.gdshader")
var n_4tap = preload("res://Shaders/Normals_4tap.gdshader")
var n_5tap = preload("res://Shaders/Normals_5tap.gdshader")
var n_9tap = preload("res://Shaders/Normals_9tap.gdshader")
var n_9tap_p = preload("res://Shaders/Normals_9tap_p.gdshader")

var ed_true = preload("res://Shaders/Highlights_True.gdshader")
var ed_3tap = preload("res://Shaders/Highlights_3tap.gdshader")
var ed_4tap = preload("res://Shaders/Highlights_4tap.gdshader")
var ed_5tap = preload("res://Shaders/Highlights_5tap.gdshader")
var ed_9tap = preload("res://Shaders/Highlights_9tap.gdshader")
var ed_9tap_p = preload("res://Shaders/Highlights_9tap_p.gdshader")

func  _ready():
	%Settings.hide()
	var method = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	compatibility = method != "forward_plus"
	if compatibility:
		$WarningCompat.show()
	RenderingServer.global_shader_parameter_set("compatibility",compatibility)
	_on_L_changed(0)
	_on_R_changed(0)

func select_shader(shader_sel : ShaderSelector) -> Shader:
	var new_shader = empty
	var n_true_p = n_true
	var ed_true_p = ed_true
	
	if compatibility:
		n_true_p = empty
		ed_true_p = empty
	
	if shader_sel.tab == 0:
		match shader_sel.norm_ind:
			1: new_shader = n_true_p
			3: new_shader = n_3tap
			4: new_shader = n_4tap
			5: new_shader = n_5tap
			6: new_shader = n_9tap
			7: new_shader = n_9tap_p
			_: new_shader = empty
	else :
		match shader_sel.high_ind:
			1: new_shader = ed_true_p
			3: new_shader = ed_3tap
			4: new_shader = ed_4tap
			5: new_shader = ed_5tap
			6: new_shader = ed_9tap
			7: new_shader = ed_9tap_p
			_: new_shader = empty
	return new_shader

func apply_shader_L():
	var shader = select_shader(shader_sel_L)
	var mater : ShaderMaterial = %Main/ShaderControls/ShaderPlaneL.get_active_material(0)
	mater.set_deferred("shader",shader)

func apply_shader_R():
	var shader = select_shader(shader_sel_R)
	var mater : ShaderMaterial = %Main/ShaderControls/ShaderPlaneR.get_active_material(0)
	mater.set_deferred("shader",shader)

func _on_L_changed(_val:int):
	shader_sel_L.tab = %ShaderOptionL.current_tab
	shader_sel_L.norm_ind = %ShaderOptionL/Normals.selected
	shader_sel_L.high_ind = %ShaderOptionL/Highlights.selected
	apply_shader_L()

func _on_R_changed(_val:int):
	shader_sel_R.tab = %ShaderOptionR.current_tab
	shader_sel_R.norm_ind = %ShaderOptionR/Normals.selected
	shader_sel_R.high_ind = %ShaderOptionR/Highlights.selected
	apply_shader_R()


func _on_shader_split_moved(split_val:float):
	%Main/ShaderControls.set_split(split_val)


func _on_menu_button_pressed():
	%Settings.visible = !%Settings.visible


func _on_resolution_changed(index):
	var resolution := Vector2(240,135)
	match index:
		1: resolution = Vector2(480,270)
		2: resolution = Vector2(960,540)
		3: resolution = Vector2(1920,1080)
	$Display/Viewport.size = resolution
	$Display/Viewport.size_2d_override = get_viewport_rect().size


func _on_color_shadows_changed(color: Color):
	RenderingServer.global_shader_parameter_set("shadow_color",Vector3(color.r,color.g,color.b))

func _on_color_highlights_changed(color: Color):
	RenderingServer.global_shader_parameter_set("highlight_color",Vector3(color.r,color.g,color.b))

func _on_shadow_value_changed(value):
	RenderingServer.global_shader_parameter_set("shadow_strength",value)

func _on_highlight_value_changed(value):
	RenderingServer.global_shader_parameter_set("highlight_strength",value)

func _on_camera_proj_changed(index):
	if index == 1:
		%Main/GimbalCam.set_projection(Camera3D.PROJECTION_PERSPECTIVE)
	else: 
		%Main/GimbalCam.set_projection(Camera3D.PROJECTION_ORTHOGONAL)

func _on_rs_camera_pressed():
	%Main/GimbalCam.angle_lr = 135
	%Main/GimbalCam.angle_ud = 30

func _on_exit_pressed():
	get_tree().quit()

func _on_fix_void_toggled(button_pressed):
	print(button_pressed)
	RenderingServer.global_shader_parameter_set("fix_void",button_pressed)
