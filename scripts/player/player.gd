extends CharacterBody2D
class_name Player

@export var texture: PlayerTexture
@export var wall_ray: RayCast2D 
@export var stats: Stats 

var jump_count: int = 0
var direction: int = 1

var landing: bool = false
var on_wall: bool = false
var attacking: bool = false
var defending: bool = false
var crouching: bool = false
var on_hit: bool = false
var dead: bool = false
#Essa variável vai auxiliar no código para quando ela estiver na ação de attack, defese ou croach o personagem não
#vai poder pular e movimentação horizontal:'
var can_track_input: bool = true 
var not_on_wall: bool = true

@export var jump_speed: int
@export var speed: int
@export var wall_jump_speed: int
@export var player_gravity: int
@export var wall_gravity: int
@export var wall_impulse_speed: int

#Godot recomenda usar essa funcão para objetos que usam a física. Funções proprias da godot não precisa especificar
#se é void ou não:
func _physics_process(delta: float) -> void:
	horizontal_moviment_env()
	vertical_moviment_env()
	gravity(delta)
	actions_env()
	#Esse é um metódo do KinematicBody que aplica uma velocidade linear ao objeto e apartir disso ele vai movimentar 
	#o personagem, a vantagem é que além de movimentar o personagem, ele vai slidar. Slide faz com que ele se movimente
	#e quando ele encontrar uma colisão dependendo dos parâmetros ele vai executar determinadas ações, se não 
	#especificar um parâmetro quando ele encontrar uma colisão ele vai parar:
	move_and_slide()
	texture.animate(velocity)
	
func horizontal_moviment_env() -> void:
	#Vai retorna qual é a direção. Se for pra esquerda é -1, se for para a direita é 1 e se pressionar
	#os dois ou nenhum vai ser 0:
	var input_direction: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if can_track_input == false or attacking:
		velocity.x = 0
		return
		
	velocity.x = input_direction * speed

func vertical_moviment_env() -> void:
	#Essa condição é necessária para resetar os pulos e a pessoa poder da mais 2 pulos, se essa condição
	#for colocada depois do ins_action_just... ele vai passar a dar 3 pulos:
	if is_on_floor() or is_on_wall():
		jump_count = 0
	#Essa condição faz o jogador das 2 pulos e ele analisa se a pessoa aperta o espaço e segurar ou
	#aperta rapidamente ele faça apenas uma vez a ação:
	var jump_condition = can_track_input and not attacking
	if Input.is_action_just_pressed("jump") and jump_count < 2 and jump_condition:
		jump_count += 1
		if next_to_wall() and not is_on_floor():
			velocity.y = wall_jump_speed
			velocity.x = wall_impulse_speed * direction
		else:
			velocity.y = jump_speed

func actions_env() -> void:
	attack()
	defense()
	crouch()

func attack() -> void:
	var attack_condition: bool = not attacking and not defending and not crouching
	#Is_on_floor entra no If para o personagem só poder atacar quando estiver no chão:
	if Input.is_action_just_pressed("attack") and attack_condition and is_on_floor(): 
		attacking = true
		texture.normal_attack = true

func defense() -> void:
	if Input.is_action_pressed("defense") and is_on_floor() and not crouching:
		defending = true
		stats.shielding = true
		can_track_input = false
	elif not crouching:
		defending = false
		can_track_input = true
		stats.shielding = false
		texture.defending_off = true

func crouch() -> void:
	if Input.is_action_pressed("crouch") and is_on_floor() and not defending:
		crouching = true
		stats.shielding = false
		can_track_input = false
	elif not defending:
		crouching = false
		can_track_input = true
		stats.shielding = false
		texture.crouching_off = true

#Aplicando a velocidade em y, delta e valor de gravidade a cada frame:
func gravity(delta: float) -> void:
	if next_to_wall() :
		velocity.y += delta * wall_gravity
		if velocity.y >= wall_gravity:
			velocity.y = wall_gravity
	else:
		velocity.y += delta*player_gravity
		#Limitador de velocidade de queda na vertical:
		if velocity.y >= player_gravity:
			velocity.y = player_gravity

func next_to_wall() -> bool:
	if wall_ray.is_colliding() and not is_on_floor():
		#Esse condição vai fazer com que quando o personagem pule na parede ele não comece ja deslizar para baixo
		#ele começa a deslizar para cima porque a força de pulo da vertical pra cima é muito maior que a gravidade pra baixo:
		if not_on_wall:
			#Se ele não estava perto da parede posteriormente, então ele vai zerar a velocidade em Y pois dessa forma 
			#quando o personagem colidir com a parede ele não vai aplicar essa força para cima já que a velocidade 
			#está zerada em Y. Assim aplicando o deslizamento para baixo:
			velocity.y = 0
			not_on_wall = false
		return true
	else:
		not_on_wall = true
		return false
