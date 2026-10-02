extends Node

var current_bgm_seek = 0
var main_bgm_seek = 0
var night = true
var total_debt = 69420.67
var day = 5
var after_encounter = false
var from_intro = true
var stats_revealed = false

var money = 2000
var mother = 10
var condition = 40
var meds = 0
var trust = 50
var suspicion = 0
var animosity = 0

var current_visitor_id = ""
var day_visitor_index = 0

var flags = {}
var today_pool = []

var visitor_requires = {
	"old_lady_day4": ["helped_old_lady"],
	"sinister_male_day6": ["!ermita_hidden"],
}

var visitor_schedule := {
	1: ["collector_young_day1"],
	2: ["collector_fraud_day2", "collector_young_day2"],
	3: ["old_lady_day3", "collector_young_day3", "ugly_beggar_day3"],
	4: ["chismosa_day4", "collector_young_day4", "old_lady_day4"],
	5: ["collector_old_day5", "young_kid_day5", "sinister_male_day5", "empty_day5"],
	6: ["collector_old_day6", "sinister_male_day6", "ugly_beggar_day6", "cat_man_day6"],
	7: ["collector_old_day7", "old_lady_day7", "chismosa_day7", "cat_man_day7", "shady_man_day7"],
	8: ["collector_old_day8", "cat_man_day8", "collector_young_day8", "ugly_beggar_day8"],
	9: ["collector_old_day9", "chismosa_day9", "sinister_male_day9", "shady_man_day9"],
	10: ["boss_pedro"],
	11: ["test"]
		
}

# still not working, trying to fix
func build_today_pool() -> void:
	today_pool.clear()
	for id in visitor_schedule.get(day, []):
		if _conditions_met(id):
			today_pool.append(id)
	day_visitor_index = 0

func _conditions_met(id: String) -> bool:
	for req in visitor_requires.get(id, []):
		if req.begins_with("!"):
			if flags.has(req.substr(1)):
				return false
		elif not flags.has(req):
			return false
	return true

# debugging with new function
func pick_visitor_for_today() -> void:
	var pool: Array = visitor_schedule.get(day, ["collector_young_day1"])
	print("Pool, ", pool)
	#var pool: Array = today_pool[day_visitor_index]
	if day_visitor_index >= pool.size():
		day_visitor_index = pool.size() - 1
	current_visitor_id = pool[day_visitor_index]



func visitors_remaining_today() -> int:
	var pool: Array = visitor_schedule.get(day, [])
	return max(pool.size() - day_visitor_index, 0)


func advance_to_next_day() -> void:
	day += 1
	build_today_pool()
	day_visitor_index = 0


func apply_effect(effect: String) -> void:
	if effect == "":
		return

	var open_end = effect.find("(")
	var close_end = effect.find(")")
	if open_end == -1 or close_end == -1 or close_end < open_end:
		push_warning("apply_effect: malformed effect string '" + effect + "'")
		return

	var effect_name = effect.substr(0, open_end)
	var arg_str = effect.substr(open_end + 1, close_end - open_end - 1)
	var amount = arg_str.to_float()

	match effect_name:
		"payment":
			total_debt = max(total_debt - amount, 0.0)
			money = max(money - int(amount), 0)
		"money":
			money = max(money + int(amount), 0)
		"mother":
			mother = clamp(mother + int(amount), 0, 40)
		"condition":
			condition = clamp(condition + int(amount), 0, 40)
		"meds":
			meds = max(meds + int(amount), 0)
		"trust":
			trust = clamp(trust + int(amount), 0, 100)
		"suspicion":
			suspicion = clamp(suspicion + int(amount), 0, 100)
		"animosity":
			animosity = clamp(animosity + int(amount), 0, 100)
		"hate":
			suspicion = clamp(animosity + int(amount*0.7), 0, 100)
			animosity = clamp(animosity + int(amount*0.3), 0, 100)
		"interest":
			total_debt = max(total_debt + amount, 0.0)
		"slam":
			total_debt = max(total_debt + amount, 0.0)
			suspicion = clamp(animosity + int(amount*0.1), 0, 100)
			animosity = clamp(animosity + int(amount*0.2), 0, 100)
		"flag":
			flags[arg_str] = true
		_:
			push_warning("apply_effect: unknown effect name '" + effect_name + "'")
