extends Spatial

var ap

func restart_anim():
	ap.set_current_animation( "le_transi" )
	ap.play()
	pass

func _process(delta):
	ap.advance( delta * 5 )
	pass

func _ready():
	var mesh = get_node("Armature").get_node("Le_Transi_de_Rene_de_Chalon").get_mesh()
	var mat = mesh.surface_get_material(0)
	var cpmat = mat.duplicate( false )
	mesh.surface_set_material( 0, cpmat )
	cpmat.set_parameter(
		FixedMaterial.PARAM_DIFFUSE, 
		Color( 0,0,0,1 ) )
	
	ap = get_parent().get_node( "AnimationPlayer" )
	ap.set_current_animation( "le_transi" )
	ap.play()
	ap.connect( "finished", self, "restart_anim" )
	set_process( true )
	pass