class_name PlayerOld
extends KinematicBody

signal update_health(dmg_value)
signal sprint_time(sprint_time)
signal weapon_switch
signal player_dead

# World
export var gravity := 98
export var inertia := 100

# Move
export var crouch_speed := 5.0
export var normal_speed := 10.0
export var sprint_speed := 20.0
export var acceleration := 5.0
export var max_slope_angle := 65.0
export var jump_power := 60.0
var velocity := Vector3.ZERO
var direction := Vector3.ZERO
var sprinting := false
var crouching := false
var has_contact := false

# Fly
export var fly_speed := 10
export var fly_accel := 4
var flying := false

# Character
export var max_health := 100.0
export var max_stamina := 3.0 # seconds
export var stamina_regen := 0.5 # seconds
export var health_regen := 1.0
var curr_health := max_health setget curr_health_set
var curr_stamina := max_stamina setget curr_stamina_set

# Guns
enum EquipmentSlots {
	Primary1,
	Primary2,
	SideArm,
	Melee,
	Item1,
	Item2,
	Item3,
	Item4
}
export(Dictionary) var equipped = {
	EquipmentSlots.Primary1: {
		"item": "res://scenes/weapons/uzi_gold_long.tscn",
		"slot": EquipmentSlots.Primary1
	},
	EquipmentSlots.Primary2: {
		"item": "res://scenes/weapons/sniper_camo.tscn",
		"slot": EquipmentSlots.Primary2
	},
	EquipmentSlots.SideArm: {
		"item": "res://scenes/weapons/pistol.tscn",
		"slot": EquipmentSlots.SideArm
	},
	EquipmentSlots.Melee: {
		"item": "res://scenes/weapons/knife_smooth.tscn",
		"slot": EquipmentSlots.Melee
	},
	EquipmentSlots.Item1: {
		"item": "res://scenes/weapons/grenade.tscn",
		"slot": EquipmentSlots.Item1
	},
	EquipmentSlots.Item2: {
		"item": "res://scenes/weapons/smoke_grenade.tscn",
		"slot": EquipmentSlots.Item2
	},
	EquipmentSlots.Item3: {
		"item": "res://scenes/weapons/flash_grenade.tscn",
		"slot": EquipmentSlots.Item3
	},
	EquipmentSlots.Item4: {}
}
var current_weapon = equipped[EquipmentSlots.Primary1];

# Instances
onready var head := $Head as Spatial
onready var camera := $CameraRig as CameraRig
onready var flashlight := $Head/HeadLamp/FlashLight as SpotLight
onready var ground_check := $Tail/GroundCheck as RayCast
onready var gun_pivot := $GunPivot as Spatial
onready var hand_trigger := $GunPivot/Arm/HandTrigger as Spatial
onready var test_timer := $TestTimer as Timer
onready var sprint_timer := $SprintTimer as Timer
onready var tail := $Tail/GroundCheck as RayCast


# getters and setters
func curr_health_set(new_val: float) -> void:
	curr_health = clamp(new_val, 0, max_health)
	emit_signal("update_health", curr_health)
	if curr_health <= 0:
		emit_signal("player_dead")


func curr_stamina_set(new_val: float) -> void:
	curr_stamina = clamp(new_val, 0, max_stamina)
	emit_signal("sprint_time", curr_stamina)


func _ready() -> void:
	print("equipped: ", equipped)
	emit_signal("update_health", self.curr_health)


func _physics_process(delta: float) -> void:
	move(delta)
	check_flashlight()
	weapon_select()


func move(delta: float) -> void:
	compute_input_direction()
	
	# check movement speed
	var speed := normal_speed
	if Input.is_action_just_pressed("sprint") and not sprinting and is_on_floor():
		sprinting = true
		crouching = false
		sprint_timer.start(self.curr_stamina)
	elif (Input.is_action_just_pressed("sprint") and sprinting) or direction.length() <= 0: # stop sprinting if toggled or if movement stopped
		sprinting = false
		sprint_timer.stop()
	
	if sprinting and is_on_floor():
		speed = sprint_speed
		if sprint_timer.paused:
			sprint_timer.paused = false
		self.curr_stamina = sprint_timer.time_left
	if sprinting and not is_on_floor():
		if not sprint_timer.paused:
			sprint_timer.paused = true
	if not sprinting:
		# regen stamina
		if self.curr_stamina < max_stamina:
			self.curr_stamina += stamina_regen * delta
	
	if Input.is_action_just_pressed("crouch"):
		if not crouching and is_on_floor():
			crouching = true
			sprinting = false
		elif crouching:
			crouching = false
	
	if crouching:
		speed = crouch_speed
	
	if not sprinting and not crouching:
		speed = normal_speed
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	
	if is_on_floor():
		has_contact = true
		var collision_norm := tail.get_collision_normal()
		var floor_angle := rad2deg(acos(collision_norm.dot(Vector3.UP)))
		if floor_angle > max_slope_angle:
			velocity.y -= gravity * delta # apply gravity in on floor and on a steep slope
	else:
		if not tail.is_colliding():
			has_contact = false
		velocity.y -= gravity * delta
	
	if has_contact and not is_on_floor():
		move_and_collide(Vector3(0, -1, 0))
	
	var snap := Vector3.DOWN * 20
	if Input.is_action_just_pressed("jump") and has_contact:
		crouching = false
		snap = Vector3.ZERO
		velocity.y += jump_power
		has_contact = false
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 20, deg2rad(45), false)


func compute_input_direction() -> void:
	# detect movement direction
	var head_basis := head.get_global_transform().basis
	if has_contact: # move only if player is on ground
		direction = Vector3.ZERO
		if Input.is_action_pressed("move_forward"):
			direction -= head_basis.z
		elif Input.is_action_pressed("move_backward"):
			direction += head_basis.z
		
		if Input.is_action_pressed("move_left"):
			direction -= head_basis.x
		elif Input.is_action_pressed("move_right"):
			direction += head_basis.x
		direction.y = 0
		direction = direction.normalized()


func fly(delta: float) -> void:
	# Input
	direction = Vector3.ZERO
	var aim := head.get_global_transform().basis
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction = direction.normalized()
	
	# Acceleration and Deacceleration
	var target: Vector3 = direction * fly_speed
	velocity = velocity.linear_interpolate(target, fly_accel * delta)
	
	# Move
	velocity = move_and_slide(velocity)


func check_flashlight() -> void:
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()


func weapon_select() -> void:
	var change_equipment = current_weapon
	if Input.is_action_just_pressed("primary_weapon"):
		if current_weapon.hash() == equipped[EquipmentSlots.Primary1].hash():
			change_equipment = equipped[EquipmentSlots.Primary2]
		else:
			change_equipment = equipped[EquipmentSlots.Primary1]
	if Input.is_action_just_pressed("sidearm_weapon"):
		change_equipment = equipped[EquipmentSlots.SideArm]
	if Input.is_action_just_pressed("melee_weapon"):
		change_equipment = equipped[EquipmentSlots.Melee]
	if Input.is_action_just_pressed("item1"):
		change_equipment = equipped[EquipmentSlots.Item1]
	if Input.is_action_just_pressed("item2"):
		change_equipment = equipped[EquipmentSlots.Item2]
	if Input.is_action_just_pressed("item3"):
		change_equipment = equipped[EquipmentSlots.Item3]
	if Input.is_action_just_pressed("item4"):
		change_equipment = equipped[EquipmentSlots.Item4]
	if Input.is_action_just_pressed("holster"):
		change_equipment = {}
	
	
	if change_equipment != current_weapon:
		if change_equipment:
			if change_equipment.hash() != current_weapon.hash():
				# change equipment
				for item in hand_trigger.get_children():
					item.free() # remove anything holding in hand
				var weapon = load(change_equipment["item"]).instance()
				hand_trigger.add_child(weapon) # draw the weapon into hand
				current_weapon = change_equipment
				emit_signal("weapon_switch")
		else:
			# unequip
			for item in hand_trigger.get_children():
				item.free() # remove anything holding in hand
			current_weapon = change_equipment
			emit_signal("weapon_switch")


func _on_TestTimer_timeout():
	self.curr_health = 20 if self.curr_health > 30 else 40


func _on_SprintTimer_timeout():
	sprinting = false
