extends Node
# Autoload as "Enums" — Project Settings > Autoload
# Central place for shared enums so every script references the same values.

enum VisitorType { LEGIT, FRAUD, HELPER, PREDATOR }

enum VisitorOutcome { SAFE, WRONG_READ, COLLATERAL_PHYSICALITY }

enum PlayerAction { PAY, REFUSE, LET_IN, TALK, END_TALK }

enum GamePhase { DAY, NIGHT, END }

enum DayAction { WORK, GATHER_INTEL, REST, CARE_FOR_DEPENDENT, REINFORCE_HOUSE }

enum ExposureState { UNAWARE, AWARE, PRESSURED, HARASSED, THREATENED }

enum FailType { WRONG_READ, COLLATERAL_PHYSICALITY, DEPENDENT_DECLINE, NONE }
