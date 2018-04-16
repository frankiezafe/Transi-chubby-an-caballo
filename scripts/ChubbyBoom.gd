extends MeshInstance

var sc_min = Vector3( 0.3,0.3,0.3 )
var sc_max = Vector3( 0.5,0.5,0.5 )
var emit_min = Vector3( 0.14,0.0,0.0 )
var emit_max = Vector3( 0.7,0.5,0.2 )
var locmat

func _process(delta):
	set_scale( Vector3( 
		sc_min.x + randf() * (sc_max.x - sc_min.x),
		sc_min.y + randf() * (sc_max.y - sc_min.y),
		sc_min.z + randf() * (sc_max.z - sc_min.z)
		) )
	var diffc = Color( rand_range(0,1), rand_range(0,1), rand_range(0,1) )
	var emisc = Color( 
		emit_min.x + randf() * (emit_max.x - emit_min.x),
		emit_min.y + randf() * (emit_max.y - emit_min.y),
		emit_min.z + randf() * (emit_max.z - emit_min.z)
		)
	#var mesh = get_mesh()
	#var material_on_surface_zero = mesh.surface_get_material(0)
	#material_on_surface_zero.set_parameter(FixedMaterial.PARAM_EMISSION, diffc)
	locmat.set_parameter(FixedMaterial.PARAM_DIFFUSE, diffc)
	locmat.set_parameter(FixedMaterial.PARAM_EMISSION, emisc)
	
func _ready():
	var mesh = get_mesh()
	var material_on_surface_zero = mesh.surface_get_material(0)
	locmat = material_on_surface_zero.duplicate( false )
	set_material_override( locmat )
	set_process( true )
	pass