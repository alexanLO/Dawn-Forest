extends Control
class_name Inventory

@export var slot_container: GridContainer

var current_state: String

#Basicamente, esses planos a gente está criando aqui para lidar com os itens.
#Quando a gente tiver um inventário funcional, por exemplo, a gente ter algum item, a gente tem que
#abrir o inventário. Então, ter a animação de abra o inventário ou o clique, ele vai variar baseado nisso.
#Ou então nós só vamos poder clicar se a gente vê dentro do slot de algum dos itens e aqueles lotes tiver
#um item, entre outras coisas.
var can_click: bool
var is_visible: bool

var item_index: int
var item_quantity: int = 99

#Essas 2 lista vai ser usada uma para popular os itens e a outra vai ser ultilizada para a serialização dos dados
#Quando a gente chega na parte de serviço ou de dados que a gente vai e#star salvando e carregando as
#informações do nosso jogo, a gente vai precisar de uma lista auxiliar, porque essa essa lista auxiliar.
#Ela vai conter todas as informações que nós vamos estar salvando e carregando.
#E é por meio dessa lista auxiliar que nós vamos enviar para a nossa lista em run time em tempo real,
#os itens atuais.
var slot_item_info: Array = [
	"", "", "", "", "", "", "", "", "", "",
	"", "", "", "", "", "", "", "", "", "",
	"", "", "", "", "", "", "", 
]
var slot_list: Array = [
	"", "", "", "", "", "", "", "", "", "",
	"", "", "", "", "", "", "", "", "", "",
	"", "", "", "", "", "", "", 
]

func _ready() -> void:
	for children in slot_container.get_children():
		children.connect("empty_slot", Callable(self, "empty_slot"))

func update_slot(item_name: String, item_image: CompressedTexture2D, item_info: Array) -> void:
	var existing_item_index: int = slot_list.find(item_name)
	if existing_item_index != -1:
		var item_slot: TextureRect = slot_container.get_child(existing_item_index)
		if item_slot.amount < item_quantity and item_slot.item_type != "Equipament" and item_slot.item_type != "Weapon":
			var current_amount: int = item_slot.amount + item_info[4]
			if current_amount > item_quantity:
				var leftover: int = current_amount - item_quantity
				item_info[3] = item_quantity - item_slot.amount
				item_slot.update_item(item_name, item_image, item_info)
				item_info[3] = leftover
				update_slot(item_name, item_image, item_info)
				return
			item_slot.update_item(item_name, item_image, item_info)
			return
			
	var aux_item_index: int = slot_list.rfind(item_name)
	if aux_item_index != -1:
		var item_slot: TextureRect = slot_container.get_child(aux_item_index)
		if item_slot.amount < item_quantity and item_slot.item_type != "Equipament" and item_slot.item_type != "Weapon":
			item_slot.update_item(item_name, item_image, item_info)
			return
			
	for index in slot_container.get_child_count():
		var slot: TextureRect = slot_container.get_child(index)
		if slot.item_name == "":
			slot_list[index] = item_name
			slot_item_info[index] = [item_name, item_image, item_info]
			slot.update_item(item_name, item_image, item_info)
			return
	

func empty_slot(index: int) -> void:
	slot_list[index] = ""
	slot_item_info[index] = ""
