
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

CorkFu_Priest_PWFort = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_PWFort",
	nicename = "Power Word: Fortitude",

	k = {
		spell = "Power Word: Fortitude",
		multispell = "Prayer of Fortitude",
		icon = "Spell_Holy_WordFortitude",
		ranklevels = {1,12,24,36,48,60},
	},
})


CorkFu_Priest_TouchofWeak = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_TouchofWeak",
	nicename = "Touch of Weakness",

	k = {
		spell = "Touch of Weakness",
		icon = "Spell_Shadow_DeadofNight",
		selfonly = true,
	},
})


CorkFu_Priest_Feedback = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_Feedback",
	nicename = "Feedback",

	k = {
		spell = "Feedback",
		icon = "Spell_Shadow_RitualOfSacrifice",
		selfonly = true,
	},
})


CorkFu_Priest_InnerFire = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_InnerFire",
	nicename = "Inner Fire",

	k = {
		spell = "Inner Fire",
		selfonly = true,
		icon = "Spell_Holy_InnerFire",
	},
})


CorkFu_Priest_FearWard = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_FearWard",
	nicename = "Fear Ward",

	k = {
		spell = "Fear Ward",
		icon = "Spell_Holy_Excorcism",
	},
})


CorkFu_Priest_Spirit = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_Spirit",
	nicename = "Divine Spirit",

	k = {
		spell = "Divine Spirit",
		multispell = "Prayer of Spirit",
		icon = "Spell_Holy_HolyProtection",
		ranklevels = {30,40,50,60},
	},
})


CorkFu_Priest_PWShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_PWShield",
	nicename = "Power Word: Shield",

	k = {
		spell = "Power Word: Shield",
		icon = "Spell_Holy_PowerWordShield",
		ranklevels = {6,12,18,24,30,36,42,48,54,60},
	},
})


CorkFu_Priest_ShadProt = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_ShadProt",
	nicename = "Shadow Protection",

	k = {
		spell = "Shadow Protection",
		icon = "Spell_Shadow_AntiShadow",
		ranklevels = {30,42,56},
	},
})
