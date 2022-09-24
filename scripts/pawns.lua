local mod = mod_loader.mods[modApi.currentMod]

local speedyColor = modApi:getPaletteImageOffset("SilverSpeedsters")

Speedster_Sprint_Mech = Pawn:new {
    Name = "Sprint Mech",
    Class = "Prime",
    Health = 3,
    MoveSpeed = 4,
    Image = "mech_sprint",
    ImageOffset = speedyColor,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true,
    SkillList = {"SS_Weapon_Pummel"},
    SoundLocation = "/mech/prime/bottlecap_mech/"
}
AddPawnName("Speedster_Sprint_Mech")

Speedster_Racing_Mech = Pawn:new {
    Name = "Racing Mech",
    Class = "Brute",
    Health = 2,
    MoveSpeed = 4,
    Image = "mech_racing",
    ImageOffset = speedyColor,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true,
    SkillList = {"SS_Weapon_Aries", "SS_Weapon_Passive_Bumper"},
    SoundLocation = "/support/vip_truck/"
}
AddPawnName("Speedster_Racing_Mech")

Speedster_Track_Mech = Pawn:new {
    Name = "Track Mech",
    Class = "Science",
    Health = 2,
    MoveSpeed = 4,
    Image = "mech_track",
    ImageOffset = speedyColor,
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
    Massive = true,
    Flying = true,
    SkillList = {"SS_Weapon_Ramp"}, --used to be "SS_Weapon_TC_Track" but it posed too many questions I couldn't answer.
    SoundLocation = "/mech/science/hydrant_mech/"
}
AddPawnName("Speedster_Track_Mech")