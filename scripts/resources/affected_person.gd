extends Resource
class_name AffectedPerson

## Static content for each of the 3 fixed relatives/neighbors.
## Their *runtime* state (exposure, accepted-helper flag) lives in
## RunState.affected_persons, keyed by person_id — this Resource is
## just the authored data.

@export var person_id: String                # "tita_baby", "kuya_jun", "ate_marites"
@export var display_name: String
@export var helper_visitor_profile: VisitorProfile   # how they appear when offering help
@export var physicality_visitor_profile: VisitorProfile  # how they appear in crisis, at the gate

@export_range(0.0, 1.0) var starting_trust: float = 0.5
