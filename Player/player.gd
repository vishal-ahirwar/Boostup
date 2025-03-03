extends RigidBody3D
## verticle force on ship
@export_range(750,10000)
var force_mag:float=1000.0
## horizontal force on ship
@export_range(10,1000)
var torque_mag:float=100.0

@export_file("*.tscn") var next_level_file_path:String

@onready var death_sound:AudioStreamPlayer = $death_sound
@onready var win_sound: AudioStreamPlayer = $win_sound
@onready var engine_sound: AudioStreamPlayer3D = $engine_sound
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var b_is_transitioning:bool=false
var cpu:String
var model:String
var system_name:String

func initSystemInfo()->void:
	cpu=OS.get_processor_name()
	model=OS.get_model_name()
	system_name=OS.get_name()
	print("cpu : "+cpu)
	print("model : "+model)
	print("os : "+system_name)		
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		apply_central_force(basis.y*delta*force_mag)
		if engine_sound.playing==false:
			engine_sound.play()
		if booster_particles.emitting==false:
			booster_particles.emitting=true
	else:
		engine_sound.stop()
		booster_particles.emitting=false
		
	if Input.is_action_pressed("ui_left"):
		apply_torque(Vector3(0.0,0.0,torque_mag*delta))
		right_booster_particles.emitting=true
	else:
		right_booster_particles.emitting=false
		
	if Input.is_action_pressed("ui_right"):
		apply_torque(Vector3(0.0,0.0,torque_mag*delta*-1.0))
		left_booster_particles.emitting=true
	else:
		left_booster_particles.emitting=false
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _on_body_entered(body: Node) -> void:
	if not b_is_transitioning:
		if "Goal" in body.get_groups():
			onSuccess() # Replace with function body.
		if "Danger" in body.get_groups():
			onCrash()


func onCrash()->void:
	print("U lose!")
	death_sound.play()
	explosion_particles.emitting=true
	set_process(false)
	b_is_transitioning=true
	var tween:Tween=get_tree().create_tween()
	tween.tween_interval(2.45)
	tween.tween_callback(get_tree().reload_current_scene)

func onSuccess()->void:
	print("U won")
	win_sound.play()
	success_particles.emitting=true
	b_is_transitioning=true
	set_process(false)
	var tween:Tween=get_tree().create_tween()
	tween.tween_interval(2.31)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file_path))
