extends Node

var current_bgm_seek = 0
var main_bgm_seek = 0
var night = true
var total_debt = 69420.67
var day = 1
var after_encounter = false
var from_intro = true
var stats_revealed = false

var money = 3500
var mother = 20
var condition = 20
var meds = 0
var trust = 0
var suspicion = 0

var current_visitor_id: String = ""
var day_visitor_index: int = 0   # position within today's list

var visitor_schedule := {
	1: ["collector_young_day1"],
	2: ["collector_fraud_day2", "collector_young_day2"],
	3: ["old_lady_day3", "collector_young_day3", "ugly_beggar_day3"],
	4: ["chismosa_day4", "collector_young_day4", "old_lady_day4"],
	5: ["collector_old_day5", "young_kid_day5", "sinister_male_day5", "empty_day5"],
	6: ["collector_old_day6", "sinister_male_day6", "collector_young_day2"],
	7: ["collector_fraud_day2", "collector_young_day2"]
}


func pick_visitor_for_today() -> void:
	var pool: Array = visitor_schedule.get(day, ["collector_young_day1"])
	if day_visitor_index >= pool.size():
		day_visitor_index = pool.size() - 1  # safety net, stay on last entry
	current_visitor_id = pool[day_visitor_index]


func visitors_remaining_today() -> int:
	var pool: Array = visitor_schedule.get(day, [])
	return max(pool.size() - day_visitor_index, 0)


func advance_to_next_day() -> void:
	day += 1
	day_visitor_index = 0


func apply_effect(effect: String) -> void:
	if effect == "":
		return

	var open_paren = effect.find("(")
	var close_paren = effect.find(")")
	if open_paren == -1 or close_paren == -1 or close_paren < open_paren:
		push_warning("apply_effect: malformed effect string '" + effect + "'")
		return

	var effect_name = effect.substr(0, open_paren)
	var arg_str = effect.substr(open_paren + 1, close_paren - open_paren - 1)
	var amount = arg_str.to_float()

	match effect_name:
		"payment":
			# Player pays down the debt out of pocket.
			total_debt = max(total_debt - amount, 0.0)
			money = max(money - int(amount), 0)
		"money":
			money = max(money + int(amount), 0)
		"mother":
			mother = clamp(mother + int(amount), 0, 100)
		"condition":
			condition = clamp(condition + int(amount), 0, 100)
		"meds":
			meds = max(meds + int(amount), 0)
		"trust":
			trust = clamp(trust + int(amount), 0, 100)
		"suspicion":
			suspicion = clamp(suspicion + int(amount), 0, 100)
		_:
			push_warning("apply_effect: unknown effect name '" + effect_name + "'")
