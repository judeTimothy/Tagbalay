extends Node
# Registered as an autoload singleton ("Enums") in Project Settings.
# Do NOT add class_name here — a script can't be both an autoload singleton
# and a global class under the same name; Godot rejects that as the class
# "hiding" the singleton.

enum VisitorType { LEGIT, FRAUD, HELPER, PREDATOR }

enum VisitorOutcome { SAFE, WRONG_READ, COLLATERAL_PHYSICALITY }

enum PlayerAction { PAY, REFUSE, LET_IN, TALK, END_TALK }

enum GamePhase { DAY, NIGHT, END }

enum DayAction { WORK, GATHER_INTEL, REST, CARE_FOR_DEPENDENT, REINFORCE_HOUSE }

enum ExposureState { UNAWARE, AWARE, PRESSURED, HARASSED, THREATENED }

enum FailType { WRONG_READ, COLLATERAL_PHYSICALITY, DEPENDENT_DECLINE, NONE }
