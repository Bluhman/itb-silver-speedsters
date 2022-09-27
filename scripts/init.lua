local mod = {
    id = "squad_silver_speedsters",
    name = "Silver Speedsters",
    version = "0.0.1",
    description = "vroom vroom.",
    requirements = { "kf_ModUtils" },
    icon = "img/icon.png",
    modApiVersion = "2.7.3"
}

function mod:init()
    --sprite loading
    local sprites = require(self.scriptPath.."libs/sprites")
    sprites.addMechs(
        {
            Name="mech_sprint",
            Default         = {PosX = -17, PosY = -7},
            Animated        = {PosX = -18, PosY = -7, NumFrames = 4},
            Broken          = {PosX = -21, PosY = -7},
            Submerged       = {PosX = -17, PosY = 0},
            SubmergedBroken = {PosX = -17, PosY = 0},
            Icon= {}
        },
        {
            Name="mech_racing",
            Default         = {PosX = -19, PosY = 3},
            Animated        = {PosX = -19, PosY = 3, NumFrames = 2},
            Broken          = {PosX = -19, PosY = 3},
            Submerged       = {PosX = -19, PosY = 5},
            SubmergedBroken = {PosX = -19, PosY = 5},
            Icon= {}
        },
        {
            Name="mech_track",
            Default         = {PosX = -18, PosY = 0},
            Animated        = {PosX = -18, PosY = 0, NumFrames = 4},
            Broken          = {PosX = -18, PosY = 0},
            SubmergedBroken = {PosX = -18, PosY = 0},
            Icon= {}
        },
        --Now turning the boost pads from Items into Pawns...
        {
            Name="accel_mine_0",
            NoHanger = true,
            Default = {PosX = -28, PosY = 1},
            Animated = {PosX = -28, PosY = 1, NumFrames = 2, Time = 0.04}
        },
        {
            Name="accel_mine_1",
            NoHanger = true,
            Default = {PosX = -28, PosY = 1},
            Animated = {PosX = -28, PosY = 1, NumFrames = 2, Time = 0.04}
        },
        {
            Name="accel_mine_2",
            NoHanger = true,
            Default = {PosX = -28, PosY = 1},
            Animated = {PosX = -28, PosY = 1, NumFrames = 2, Time = 0.04}
        },
        {
            Name="accel_mine_3",
            NoHanger = true,
            Default = {PosX = -28, PosY = 1},
            Animated = {PosX = -28, PosY = 1, NumFrames = 2, Time = 0.04}
        }

    )

    --Manually add the sprite for acceleration mine death because it's the same for all four variants:
    modApi:appendAsset("img/units/player/accel_mine_death.png", self.resourcePath.."img/units/player/accel_mine_death.png")
    local accelMineDeathAnim = {
        PosX = -28, PosY = 1,
        NumFrames = 8,
        Image = "units/player/accel_mine_death.png",
        Time = 0.09,
        Loop = false
    }
    ANIMS.accel_mine_0d = ANIMS.MechUnit:new(accelMineDeathAnim)
    ANIMS.accel_mine_1d = ANIMS.MechUnit:new(accelMineDeathAnim)
    ANIMS.accel_mine_2d = ANIMS.MechUnit:new(accelMineDeathAnim)
    ANIMS.accel_mine_3d = ANIMS.MechUnit:new(accelMineDeathAnim)

    --boost pad sprites
    --for i=0,3 do
    --    modApi:appendAsset("img/combat/accel_mine_"..i..".png",  self.resourcePath.."img/combat/accel_mine_"..i..".png")
    --    Location["combat/accel_mine_"..i..".png"] = Point(-28,1)
    --end

    --palette add!(?)
    modApi:addPalette({
        id = "SilverSpeedsters",
        name = "Silver Speedsters",
        image  = "img/units/player/mech_sprint_ns",
        colorMap = {
            PlateHighlight = {255, 208, 89},
            PlateLight     = {193, 85, 85},
            PlateMid       = {158, 41, 46},
            PlateDark      = {81, 21, 43},
            PlateOutline   = {13, 2, 22},
            PlateShadow    = {54, 54, 96},
            BodyColor      = {137, 137, 158},
            BodyHighlight  = {172, 209, 226},
        }
    })

    --Weapon sprites
    modApi:appendAsset("img/weapons/brute_aries.png",self.resourcePath.."img/weapons/brute_aries.png")
    modApi:appendAsset("img/weapons/deployable_track.png",self.resourcePath.."img/weapons/deployable_track.png")
    modApi:appendAsset("img/weapons/passive_bumper.png",self.resourcePath.."img/weapons/passive_bumper.png")
    modApi:appendAsset("img/weapons/prime_pummel.png",self.resourcePath.."img/weapons/prime_pummel.png")
    modApi:appendAsset("img/weapons/deploy_fx_ramp.png",self.resourcePath.."img/weapons/deploy_fx_ramp.png")
    modApi:appendAsset("img/weapons/deploy_fx_accel.png",self.resourcePath.."img/weapons/deploy_fx_accel.png")

    --[TODO]: Weapon texts?

    --FANCY HOOKS.
    bluhSPEED_modApiExt = require (self.scriptPath.."modApiExt/modApiExt"):init()

    require(self.scriptPath.."pawns")
    --require(self.scriptPath.."items")
    require(self.scriptPath.."weapon_aries")
    require(self.scriptPath.."weapon_pummel")
    --require(self.scriptPath.."weapon_track") --this is broken af.
    fancyRamp = require(self.scriptPath.."weapon_ramp")
    fancyWeapon = require(self.scriptPath.."weapon_bumper")
end

function mod:load(options, version)
    -- Load Fancy Pants
    bluhSPEED_modApiExt:load(self, options, version)

    --DO FANCY HOOKZ
    fancyWeapon:load(bluhSPEED_modApiExt, options)
    fancyRamp:load()

    --ADD THE SQUAD!!
    modApi:addSquad(
        {
            "Silver Speedsters",
            "Speedster_Sprint_Mech", 
            "Speedster_Racing_Mech", 
            "Speedster_Track_Mech"
        },
        "Silver Speedsters",
        "These lightning-fast mechs excel at covering ground and clearing passage for mighty charging attacks.",
        self.resourcePath.."img/icon.png"
    )

end

return mod