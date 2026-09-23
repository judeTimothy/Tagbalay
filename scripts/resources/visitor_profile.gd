extends Resource
class_name VisitorProfile

## One .tres per: each Legit variant (3), Fraud (1), each Helper (3), Predator (1).
## The visitor_type + flags differentiate behavior — content authors duplicate
## a .tres and change fields rather than writing new script.

@export var visitor_id: String
@export var display_name: String
@export var visitor_type: Enums.VisitorType

@export_group("Art")
@export var portrait_silhouette: Texture2D
@export var portrait_variants: Array[Texture2D] = []   # disguise states, Fraud/Predator

@export_group("Dialogue")
@export var greet_lines: Array[VisitorLine] = []
@export var tell_pool: Array[TellData] = []             # draw 2-4 per visit
@export var tells_per_visit: int = 3
## key: PlayerAction as String ("PAY","REFUSE","LET_IN","TALK") -> Array[VisitorLine]
@export var response_lines: Dictionary = {}

@export_group("Mechanics")
@export_range(0.0, 1.0) var base_aggression: float = 0.2
@export var debt_knowledge_accurate: bool = true    # false for Fraud/Predator claims
@export var wants_entry_not_payment: bool = false   # true only for Predator
@export var can_be_paid: bool = true                # false for Predator (payment isn't the ask)

@export_group("Outcome Weights")
@export var safe_if_refused: bool = true
@export var safe_if_paid: bool = true               # false for Fraud (money sink) / n/a Predator
@export var fatal_if_let_in: bool = false           # true for Predator and genuine threats

## Links back to AffectedPerson.tres for Helper-type profiles only.
@export var linked_person_id: String = ""


func get_random_tells(count: int = -1) -> Array[TellData]:
	var n: int = count if count > 0 else tells_per_visit
	var pool := tell_pool.duplicate()
	pool.shuffle()
	n = min(n, pool.size())
	return pool.slice(0, n)


func get_response(action: Enums.PlayerAction) -> VisitorLine:
	var key: String = Enums.PlayerAction.keys()[action]
	var lines: Array = response_lines.get(key, [])
	if lines.is_empty():
		return null
	return lines[randi() % lines.size()]
