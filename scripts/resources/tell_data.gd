extends Resource
class_name TellData

## A single behavioral/social tell. Tells are pooled and shared across
## visitor types — the same tell can be a strong signal on one visitor
## and a red herring on another, which is what keeps reads ambiguous.

@export var tell_id: String                # "hesitation_a", "overexplain_b", etc.
@export_multiline var tell_text: String     # line or stage direction shown/spoken
@export var audio_clip: AudioStream         # nullable pre-VO
@export var tell_type: String = ""          # "hesitation", "overexplain", "urgency", "tone_mismatch", "gate_gap_cue"
@export_range(0.0, 1.0) var suspicion_weight: float = 0.5
@export var is_red_herring: bool = false    # can appear on a SAFE visitor too
