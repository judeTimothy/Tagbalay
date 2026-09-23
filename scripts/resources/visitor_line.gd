extends Resource
class_name VisitorLine

@export_multiline var text: String
@export var audio_clip: AudioStream
## Matches a trigger key used by NightPhaseController, e.g.
## "on_greet", "on_pay_offer", "on_refuse", "on_stall", "on_let_in"
@export var trigger_condition: String = ""
