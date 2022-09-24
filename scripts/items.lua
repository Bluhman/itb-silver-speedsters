local function boostPad_damage (dir)
    local boostPadDam = SpaceDamage(0)
    boostPadDam.sSound = "/enemy/beetle_1/attack_charge"
    boostPadDam.sAnimation = "airpush_"..dir
    boostPadDam.iPush = dir
return boostPadDam
end

boost_track_tooltip = {"Boost Track", "Any unit that stops on this space will be pushed in the direction shown."}

TILE_TOOLTIPS = { 
    boost_track_tooltip = 
    {"Boost Track", "Any unit that stops on this space will be pushed in the direction shown."}
}

Boost_Pad_0 = {Image = "combat/accel_mine_0.png", Damage = boostPad_damage(0), Icon = "combat/arrow_off_up.png", Tooltip = "boost_track_tooltip", UsedImage = ""}
Boost_Pad_1 = {Image = "combat/accel_mine_1.png", Damage = boostPad_damage(1), Icon = "combat/arrow_off_right.png", Tooltip = "boost_track_tooltip", UsedImage = ""}
Boost_Pad_2 = {Image = "combat/accel_mine_2.png", Damage = boostPad_damage(2), Icon = "combat/arrow_off_down.png", Tooltip = "boost_track_tooltip", UsedImage = ""}
Boost_Pad_3 = {Image = "combat/accel_mine_3.png", Damage = boostPad_damage(3), Icon = "combat/arrow_off_left.png", Tooltip = "boost_track_tooltip", UsedImage = ""}