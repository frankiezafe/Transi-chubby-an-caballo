extends Camera

var cam_pos
var cam_roll = 0
var cam_speed = 0
var cam_speed_target = 0
var cam_up = Vector3( 0,1,0 )
var lookat = Vector3( 0,0,0 )
var mousepos = Vector2( 0,0 )
var mousepos_prev = Vector2( 0,0 )
var msmooth = Vector2( 5,0 )

var cubo
var cubo_vibrate = false
var cubo_sc
var cubo_sc_init
var player
var voiceID
var pitch

var mouse_pressed = false

var cubo_childs = []

func _process(delta):
	var t = get_camera_transform()
	var dir = ( t.origin - lookat ).normalized()
	cam_speed_target = msmooth.y * 0.2
	cam_up = cam_up.rotated( dir, cam_speed_target )
	if !mouse_pressed:
		msmooth += ( mousepos - msmooth ) * delta * 2
		lookat += (Vector3(0,0,0) - lookat ) * delta * 10
	else:
		lookat = Vector3( mousepos.x * 10, 0, mousepos.y * 10 )
	cam_pos = cam_pos.rotated( Vector3( 0,1,0 ), msmooth.x * delta * 1.8 )
	cam_up = cam_up.rotated( Vector3( 0,1,0 ), msmooth.x * delta * 1.8 )
	t.origin = cam_pos
	t = t.looking_at( lookat, cam_up )
	set_transform( t )
	if cubo_vibrate:
		pitch += ( ( 0.1 + randf() * 3 ) - pitch ) * delta * 0.2
		cubo_sc += ( Vector3( 
			cubo_sc_init.x * randf() * 0.5,
			cubo_sc_init.y * randf() * 0.5,
			cubo_sc_init.z + randf() * (cubo_sc_init.z * 50 - cubo_sc_init.z)
		) - cubo_sc ) * delta * 2
	else:
		pitch += ( 1 - pitch ) * delta * 2
		cubo_sc += (cubo_sc_init - cubo_sc) * delta * 0.3
	player.set_pitch_scale( voiceID, pitch )
	cubo.get_node("cubo_mesh").set_scale( cubo_sc )
	for c in cubo_childs:
		var sc = c[0].get_child(0).get_scale()
		var scl = sc.length()
		c[1] += c[2] * delta * 5 * scl
		c[0].set_rotation( c[1] )
		if scl > 0.01:
			sc += ( Vector3(0.01,0.01,0.01) - sc ) * delta * 0.4
			c[0].get_child(0).set_scale( sc )

func _input(event):
	if ( event.type == InputEvent.KEY ):
		if ( Input.is_key_pressed(KEY_ESCAPE) ):
			get_tree().change_scene("res://enter_the_wu.tscn")
		elif ( Input.is_key_pressed(KEY_SPACE) ):
			cubo_vibrate = !cubo_vibrate
	elif ( event.type == InputEvent.MOUSE_MOTION ):
		mousepos_prev = mousepos
		mousepos = event.pos
		var vps = get_viewport().get_rect().size
		mousepos.x = ( ( mousepos.x / vps.width ) - 0.5 ) * 2
		mousepos.y = ( ( mousepos.y / vps.height ) - 0.5 ) * 2
	elif ( event.type == InputEvent.MOUSE_BUTTON ):
		if event.button_index == 1:
			mouse_pressed = event.pressed
		elif event.button_index == 2:
			var objs = get_parent().get_node("objs")
			var c0
			var c
			var do_link = true
			if cubo_childs.size() < 40:
				c0 = cubo.duplicate( true )
			else:
				var i = randf() * ( cubo_childs.size() - 1 )
				c0 = cubo_childs[i][0]
				cubo_childs[i][1] = cubo.get_rotation()
				do_link = false
			c = c0.get_child( 0 )
			c.set_scale( Vector3( 0.5 + randf() * 0.05, 0.5 + randf() * 0.05, 0.5 + randf() * 0.05 ) )
			c.set_translation( cam_pos * 0.5 + lookat * 0.5 )
			c.set_rotation( Vector3( randf() * PI,  randf() * PI,  randf() * PI ) )
			if do_link:
				objs.add_child( c0 )
				cubo_childs.append( [ c0, cubo.get_rotation(), Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1)) ] )

func _ready():
	
	cubo = get_parent().get_node( "objs/cubo")
	cubo_sc = cubo.get_scale()
	cubo_sc_init = cubo.get_scale()
	
	player = get_parent().get_node( "SamplePlayer")
	voiceID = player.play("329077__vomitdog__wicked")
	pitch = player.get_pitch_scale( voiceID )
	
	var t = get_camera_transform()
	cam_pos = t.origin
	set_process( true )
	set_process_input( true )
