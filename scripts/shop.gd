extends Node2D

# upgrades have to be bought in order, one tier at a time
const UPGRADES = {
	"boots": [8, 20],
	"gun": [10, 20, 30],
	"ammo": [15, 30, 45],
}
const EXTRAS = {
	"life": 10,
	"trench_coat": 10,
}

var offers = []

func _ready():
	offers = [offer("boots", "life"), offer("gun", "trench_coat"), offer("ammo", "life")]
	var items = [$Item1, $Item2, $Item3]
	for i in items.size():
		items[i].get_node("Sprite2D").texture = load("res://sprites/items/%s.png" % offers[i])
		items[i].get_node("Price").text = str(price(offers[i]))
		items[i].body_entered.connect(buy.bind(offers[i]))

# once an upgrade is maxed out its slot sells something else
func offer(upgrade, fallback):
	if Game.get(upgrade) < UPGRADES[upgrade].size():
		return upgrade
	return fallback

func price(item):
	if item in EXTRAS:
		return EXTRAS[item]
	return UPGRADES[item][Game.get(item)]

# one thing per visit, then he leaves
func buy(body, item):
	if not body.has_method("pick_up") or Game.coins < price(item):
		return
	Game.coins -= price(item)
	if item in EXTRAS:
		body.pick_up(item)
	else:
		Game.set(item, Game.get(item) + 1)
	queue_free()
