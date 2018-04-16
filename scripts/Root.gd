extends Spatial

export var file_prefix = "transichubbyandcaballo"
export(int, 'Datetime', 'Unix Timestamp') var file_tag
export(bool) var add_watermark

var _tag = ""
var _index = 0

var dist = 20
var btn_displayed = true
var btn
var bg
var btn_bg_sc = Vector2( 1.0 / 64, 1.0 / 64 )
var color_min = Vector3( 0.1,0.05,0.002 )
var color_max = Vector3( 0.65,0.65,0.65 )
var color_angl = Vector3( 0,0,0 )
var color_speed = Vector3( 0.81, 0.425, 0.106 )
var main_color = Vector3(0,0,0)
var main_color_inverse = Vector3(1,1,1)
var alpha = 0
var alpha_mult = 1
var btn_text = "move, left and right drag, press space, tab to sreenshot & esc to quit, ok?"
var btn_text_count = 1
var btn_text_wait = 1

var screenshot = null
var watermark
var save_popup
	
func _on_message_pressed():
	btn_displayed = false
	btn.hide()
	
func _on_message_mouse_enter():
	pass

func _fixed_process(delta):
	if btn_displayed or alpha_mult > 0:
		if btn_text_count <= btn_text.length():
			btn_text_wait += delta
			if btn_text_wait >= 0.01:
				btn_text_wait = 0
				btn.set_text( btn_text.substr( 0, btn_text_count ) )
				btn_text_count += 1
		else:
			btn_text_wait += delta
			if btn_text_wait >= 1.5:
				btn_text_wait = 0
				var txt = btn.get_text()
				btn_text_count += 1
				if btn_text_count == btn_text.length() + 5:
					btn.set_text( "click, sis-bro!" )
				elif btn_text_count == btn_text.length() + 12:
					_on_message_pressed()
				elif btn_text_count >= btn_text.length() + 10:
					btn.set_text( "ok, i'll do it for you, lazy gril-boy..." )
				else:
					btn.set_text( txt + "... ok?" )
		alpha += delta * 20
		color_angl += color_speed * delta
		var cmult = Vector3(
			( 1 + sin( color_angl.x * PI ) ) * 0.5,
			( 1 + sin( color_angl.y * PI ) ) * 0.5,
			( 1 + sin( color_angl.z * PI ) ) * 0.5 )
		main_color = color_min + ( color_max - color_min ) * cmult
		main_color_inverse = Vector3( 1,1,1 ) - main_color
		main_color_inverse = main_color_inverse.normalized()
		var vpsize = get_viewport().get_rect().size
		btn.set_size( Vector2(vpsize.width,vpsize.height) )
		bg.set_scale( Vector2(vpsize.width,vpsize.height) )
		var a = ( 0.95 + ( ( 1 + sin( alpha * PI ) ) * 0.3 ) * 0.1 ) * alpha_mult
		bg.set_modulate( Color( main_color.x, main_color.y, main_color.z, a ) )
	if !btn_displayed:
		alpha_mult -= delta

func _input(event):
	if ( event.type == InputEvent.KEY ):
		if ( Input.is_key_pressed(KEY_TAB) ):
			make_screenshot()

func _ready():
	
	btn = get_node("overlay/message")
	btn.set_text( "ctrls" )
	bg = get_node("overlay/bg")
	var vpsize = get_viewport().get_rect().size
	btn.set_pos( Vector2(0,0) )
	btn.set_size( Vector2(vpsize.width,vpsize.height) )
	bg.set_pos( Vector2(0,0) )
	bg.set_scale( Vector2(vpsize.width,vpsize.height) )
	
	var objs = get_node("objs")
	var cab = get_node("objs/caballo")
	for i in range( 120 ):
		var a = i * 1.0 / 120 * 2 * PI
		var dup = cab.duplicate( true )
		dup.set_translation( Vector3( cos(a) * dist, sin(a) * dist, 0 ) )
		dup.set_rotation( Vector3(0,0,a) )
		objs.add_child( dup )
	cab.hide()
	
#	_check_path(output_path)
#	if not output_path[-1] == "/":
#		output_path += "/"
	if not file_prefix.empty():
		file_prefix += "_"
	
	watermark = Image()
	watermark.load("res://textures/watermark.png")
	save_popup = get_node("save_popup")
	save_popup.add_filter("*.png ; PNG Images")
	
	set_fixed_process(true)
	set_process_input( true )

############################
### screenshot functions ###
############################
# https://github.com/Maujoe/godot-simlpe-screenshot-script/blob/master/scripts/screenshot.gd

func make_screenshot():
	get_viewport().queue_screen_capture()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	screenshot = get_viewport().get_screen_capture()
	_update_tags()
	var fname = "%s%s_%s.png" % [file_prefix, _tag, _index]
	save_popup.set_current_file( fname )
	save_popup.popup_centered ( Vector2( 480, 540 ) )
	# we will wait the popup to close to continue

func _check_path(path):
	if OS.is_debug_build():
		var message = 'WARNING: No directory "%s"'
		var dir = Directory.new()
		dir.open(path)
		if not dir.dir_exists(path):
			print(message % path)

func _update_tags():
	var time
	if (file_tag == 1): time = str(OS.get_unix_time())
	else:
		time = OS.get_datetime()
		time = "%s_%02d_%02d_%02d%02d%02d" % [
			time['year'], time['month'], time['day'], 
			time['hour'], time['minute'], time['second']
			]
	if (_tag == time): _index += 1
	else:
		_index = 0
	_tag = time

func _on_save_popup_hide():
	pass

func _on_save_popup_file_selected( path ):
	#screenshot.save_png("%s%s%s_%s.png" % [output_path, file_prefix, _tag, _index])
	if add_watermark:
		var vpsize = get_viewport().get_rect().size
		screenshot.blend_rect( 
			watermark, 
			Rect2( 0,0,watermark.get_width(),watermark.get_height() ), 
			Vector2( 20, vpsize.height - ( watermark.get_height() + 20 )  ) )
	
	if ( path[-5] == '/' || path[-5] == '\\' ):
		var fname = "%s%s_%s.png" % [file_prefix, _tag, _index]
		path = path.substr(0,path.length()-4)
		path += fname
	
	screenshot.save_png( path )
	btn_displayed = true
	alpha_mult = 1
	btn_text_count = 0
	btn_text = path
	btn_text += " saved! click"
	btn.set_text( "?" )
	btn.show()
	screenshot = null
	pass
