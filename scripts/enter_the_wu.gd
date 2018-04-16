extends Sprite

var color_min = Vector3( 0.1,0.05,0.002 )
var color_max = Vector3( 0.65,0.65,0.65 )
var color_angl = Vector3( 0,0,0 )
var color_speed = Vector3( 0.81, 0.425, 0.106 )
var main_color = Vector3(0,0,0)
var main_color_inverse = Vector3(1,1,1)
var bg_alpha_min = 0.3
var bg_alpha_max = 0.95
var bg_alpha = bg_alpha_min
var bg_alpha_target = bg_alpha_min
var chub_rot = Vector3(0,-1.5708,0)
var mousepos = Vector2( 0,0 )
var mousedelta = Vector2( 0,0 )

var title_label_bg
var title_label
var btn_bg
var btn_bg_sc = Vector2( 1.0 / 64, 1.0 / 64 )
var btn_go
var btn_credits
var target_bg = null
var w3d
var light
var cam
var campos
var campos_init
var campos_target
var chub

var vpsize
var vpsize_mult = Vector2( 2,2 )

var laughing_tiggered = false

var wait_until_activate = 2
var title_x = 100

func _on_btn_go_mouse_enter():
	target_bg = btn_go
func _on_btn_credits_mouse_enter():
	target_bg = btn_credits

func resize_ui():
	var vprect = get_viewport().get_rect()
	vpsize =  get_viewport().get_rect().size
	title_label.set_pos( Vector2( title_x, vpsize.height * 0.5 ) )
	var btnsize = Vector2( vpsize.width * 0.5, vpsize.height / 2 )
	btn_go.set_pos( Vector2( vpsize.width * 0.5, 0 ) )
	btn_credits.set_pos( Vector2( vpsize.width * 0.5, btnsize.y ) )
	btn_go.set_size( btnsize )
	btn_credits.set_size( btnsize )
	btn_bg.set_scale( btn_bg_sc * btnsize )
	set_region_rect( Rect2( 0,0,vpsize.width*vpsize_mult.x,vpsize.height*vpsize_mult.y ) )
	
func update_ui():
	if vpsize != get_viewport().get_rect().size:
		 resize_ui()
	title_label_bg.set_pos( Vector2( title_x + rand_range( -3,3 ), vpsize.height * 0.5 ) )
	set_modulate( Color( main_color.x,main_color.y,main_color.z, bg_alpha ) )
	if btn_bg.is_visible():
		btn_bg.set_modulate( Color( main_color_inverse.y,main_color_inverse.z,main_color_inverse.x, 0.8 ) )
		if target_bg != null:
			btn_bg.set_pos( target_bg.get_pos() )

func update_3d():
	w3d.set_background_param( Environment.BG_DEFAULT_COLOR, Color( main_color.x,main_color.y,main_color.z, 1 ) )
	light.set_color( DirectionalLight.COLOR_DIFFUSE, Color( main_color_inverse.x,main_color_inverse.y,main_color_inverse.z, 1 ) )
	chub.set_rotation( chub_rot )
	cam.set_translation( campos )

func _fixed_process(delta):
	color_angl += color_speed * delta
	var cmult = Vector3(
		( 1 + sin( color_angl.x * PI ) ) * 0.5,
		( 1 + sin( color_angl.y * PI ) ) * 0.5,
		( 1 + sin( color_angl.z * PI ) ) * 0.5 )
	main_color = color_min + ( color_max - color_min ) * cmult
	main_color_inverse = Vector3( 1,1,1 ) - main_color
	main_color_inverse = main_color_inverse.normalized()
	chub_rot += Vector3( 0,delta * 0.1,0 )
	bg_alpha += ( bg_alpha_target - bg_alpha ) * delta * 20
	mousedelta = Vector2(0,0)
	campos_target = campos_init + Vector3( 0,-mousepos.y * 2.5, 0 )
	campos += ( campos_target - campos ) * delta
	
	if wait_until_activate > 0:
		wait_until_activate -= delta
	
	update_ui()
	update_3d()

func _input(event):
	if ( event.type == InputEvent.MOUSE_MOTION ):
		mousepos = event.pos
		mousepos.x = ( ( mousepos.x / vpsize.width ) - 0.5 ) * 2
		mousepos.y = ( ( mousepos.y / vpsize.height ) - 0.5 ) * 2
		mousedelta.x = ( ( event.relative_x / vpsize.width ) - 0.5 ) * 2
		mousedelta.y = ( ( event.relative_y / vpsize.height ) - 0.5 ) * 2
	elif ( event.type == InputEvent.KEY and Input.is_key_pressed(KEY_ESCAPE) ):
		get_tree().quit()

func _on_btn_hover():
	if wait_until_activate > 0:
		pass
	if !laughing_tiggered:
		get_node("ambient").play("132252__robinhood76__02940-insane-women-laughter")
		laughing_tiggered = true
	vpsize_mult = Vector2( 1,2 )
	bg_alpha_target = bg_alpha_max
	btn_bg.show()
	resize_ui()

func _on_btn_leave():
	if wait_until_activate > 0:
		pass
	vpsize_mult = Vector2( 2,2 )
	bg_alpha_target = bg_alpha_min
	btn_bg.hide()
	resize_ui()

func _ready():
	# UI
	title_label_bg = get_node( "title-bg" )
	title_label = get_node( "title" )
	btn_bg = get_node( "btn_bg" )
	btn_bg.hide()
	btn_go = get_node( "btn_go" )
	btn_credits = get_node( "btn_credits" )
	# 3D
	w3d = get_parent().get_world().get_environment()
	light = get_node( "chub/chub_light" )
	cam = get_node( "chub/chub_cam" )
	campos = cam.get_translation()
	campos_init = cam.get_translation()
	campos_target = cam.get_translation()
	chub = get_node("chub/chub")
	# sound
	get_node("ambient").play("198834__genghis-attenborough__incidental-guitar-16")
	# launching
	set_fixed_process(true)
	set_process_input( true )
	resize_ui()

func _on_btn_go_pressed():
	#var sc = load("res://first.tscn").instance()
	#get_parent().remove_child( this )
	#get_parent().add_child(sc)
	#hide()
	get_tree().change_scene("res://go.tscn")

func _on_btn_credits_pressed():
	get_tree().change_scene("res://credits.tscn")
