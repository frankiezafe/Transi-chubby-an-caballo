extends Spatial

var mousepos = Vector2( 0,0 )
var vpsize = Vector2( 0,0 )

var crdori = Vector3(0,0,0)
var crdori_min = Vector3(-0.45,-0.2,-1.8)
var crdori_max = Vector3(0.28,-0.05,0)
var crdtxt = null
var lines = []
var crdmat
var crdmat1

var color_min = Vector3( 0.1,0.35,0.002 )
var color_max = Vector3( 0.65,0.65,0.85 )
var color_angl = Vector3( 0,0,0 )
var color_speed = Vector3( 0.81, 0.425, 0.306 )
var main_color = Vector3(0,0,0)
var main_color_inverse = Vector3(1,1,1)
var w3d = null

#const chubbycaballo_credits = preload( "res://models/chubbycaballo_credits" )

func _fixed_process(delta):
	
	if vpsize != get_viewport().get_rect().size:
		vpsize =  get_viewport().get_rect().size
	color_angl += color_speed * delta
	var cmult = Vector3(
		( 1 + sin( color_angl.x * PI ) ) * 0.5,
		( 1 + sin( color_angl.y * PI ) ) * 0.5,
		( 1 + sin( color_angl.z * PI ) ) * 0.5 )
	main_color = color_min + ( color_max - color_min ) * cmult
	main_color_inverse = Vector3( 1,1,1 ) - main_color
	main_color_inverse = main_color_inverse.normalized()
	w3d.set_background_param( 
		Environment.BG_DEFAULT_COLOR, 
		Color( main_color.x, main_color.y, main_color.z, 1 ) )
	if ( crdtxt == null ):
		return
	crdmat1.set_parameter(
		FixedMaterial.PARAM_DIFFUSE, 
		Color( main_color.x * 1.8,main_color.y * 1.8,main_color.z * 1.8, 1 ) )
	crdmat.set_parameter(
		FixedMaterial.PARAM_DIFFUSE, 
		Color( main_color_inverse.x, main_color_inverse.y, main_color_inverse.z, 1 ) )
	crdmat.set_parameter(
		FixedMaterial.PARAM_EMISSION, 
		Color( main_color_inverse.x * 0.3,
		main_color_inverse.y * 0.3,
		main_color_inverse.z * 0.3, 1 ) )
	var mapped = crdori_min + ( crdori_max - crdori_min ) * Vector3( mousepos.y, mousepos.x, ( 0.5 + ( mousepos.x - 0.5 ) ) * 2 )
	if is_nan( mapped.x ) or is_inf( mapped.x ):
		mapped = Vector3( 0,0,0 )
	crdori += ( mapped - crdori ) * delta * 5
	crdtxt.set_rotation( Vector3( crdori.x, crdori.y, 0 ) )
	var rz = crdori.z
	var steprz = ( -crdori.z * 2 ) / lines.size()
	for l in lines:
		l.set_rotation( Vector3( 0, -rz * 0.8, rz ) )
		rz += steprz
	
func _input(event):
	if ( event.type == InputEvent.MOUSE_MOTION ):
		mousepos = event.pos
		mousepos.x = ( mousepos.x / vpsize.width )
		mousepos.y = ( mousepos.y / vpsize.height )
	elif ( event.type == InputEvent.KEY and Input.is_key_pressed(KEY_ESCAPE) ):
		get_tree().change_scene("res://enter_the_wu.tscn")

func _ready():
	w3d = get_parent().get_world().get_environment()
	set_fixed_process( true )
	set_process_input( true )

func _on_chubbycaballo_credits_enter_tree():
	crdtxt = get_node( "credit-text" )
	var txtroot = crdtxt.get_node( "chubbycaballo_credits" )
	lines.append( txtroot.get_node( "credits_001" ) )
	lines.append( txtroot.get_node( "credits_000" ) )
	lines.append( txtroot.get_node( "credits_002" ) )
	lines.append( txtroot.get_node( "credits_003" ) )
	lines.append( txtroot.get_node( "credits_004" ) )
	crdmat = lines[0].get_mesh().surface_get_material(0).duplicate( false )
	crdmat1 = lines[0].get_mesh().surface_get_material(1).duplicate( false )
	for l in lines:
		l.get_mesh().surface_set_material( 0, crdmat )
		l.get_mesh().surface_set_material( 1, crdmat1 )
	pass
