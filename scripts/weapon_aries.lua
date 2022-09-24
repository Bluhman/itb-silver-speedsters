local path = mod_loader.mods[modApi.currentMod].scriptPath
local worldConstants = require(path .."libs/worldConstants")

SS_Weapon_Aries = Skill:new{
    Name = "Aries Booster",
    Description = "Dash in a straight line, pushing adjacent tiles. Deal damage and knockback to last target in front of you.",
    Class = "Brute",
    Icon = "weapons/brute_aries.png",
    Damage = 1,
    Push = 1,
    Fly = 1,
    PathSize = 3,
    PowerCost = 0,
    Rarity = 3,
    LaunchSound = "/mech/brute/tank/move",
    ChargeSound = "/weapons/charge",
    Upgrades = 2,
    UpgradeCost = {1,1},
    UpgradeList = {"+1 Max Damage", "+1 Range"},
    TipImage = {
		Unit = Point(2,4),
		Enemy = Point(1,2),
		Enemy2 = Point(3,3),
        Enemy3 = Point(2,0),
		Target = Point(2,1)
	}
}

function SS_Weapon_Aries:GetTargetArea(point)
    local ret = PointList()

    for i = DIR_START, DIR_END do
        for k = 1, self.PathSize do
            local currTile = DIR_VECTORS[i]*k+point
            if Board:IsValid(currTile) and not Board:IsBlocked(currTile, Pawn:GetPathProf()) then
                ret:push_back(currTile)
            else
                break
            end
        end
    end

    return ret
end

function SS_Weapon_Aries:GetSkillEffect(p1,p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2 - p1)
    local distance = p1:Manhattan(p2)
    local damageValue = self.Damage

    --REV IT UP!!
    local spaceEffect = SpaceDamage(p1 + DIR_VECTORS[(dir+2)%4], 0)
    spaceEffect.sAnimation = "airpush_"..((dir+2)%4)
    ret:AddDamage(spaceEffect)
    ret:AddDelay(0.5)

    --MAKE THIS CHARGE REAL FAST!!
    local iamspeed = 2
    worldConstants.SetSpeed(ret, iamspeed)
    ret:AddCharge(Board:GetSimplePath(p1,p2), NO_DELAY)
    ret:AddSound(self.ChargeSound)
    worldConstants.ResetSpeed(ret)

    for i = 0, distance do
        local pushSpace = p1 + DIR_VECTORS[dir]*i

        ret:AddDelay(0.03)
        ret:AddBounce(pushSpace, -3)

        local pushy = SpaceDamage(pushSpace + DIR_VECTORS[(dir+1)%4], 0, (dir+1)%4)
        pushy.sAnimation = "exploout0_"..(dir+1)%4
        ret:AddDamage(pushy)

        pushy = SpaceDamage(pushSpace + DIR_VECTORS[(dir-1)%4], 0, (dir-1)%4)
        pushy.sAnimation = "exploout0_"..(dir-1)%4
        ret:AddDamage(pushy)
    end

    local damageSpace = p2 + DIR_VECTORS[dir]
    local damage = SpaceDamage(damageSpace, math.min(damageValue, distance), dir)
    damage.sAnimation = "explopush2_"..dir
    ret:AddDamage(damage)

    return ret
end

SS_Weapon_Aries_A = SS_Weapon_Aries:new{
    UpgradeDescription = "Gain +1 Damage if you have traveled at least 2 spaces.",
    Damage = 2,
    MinDamage = 1
}

SS_Weapon_Aries_B = SS_Weapon_Aries:new{
    UpgradeDescription = "Increase maximum range by 1.",
    PathSize = 4,
    TipImage = {
		Unit = Point(2,5),
		Enemy = Point(1,2),
		Enemy2 = Point(3,3),
        Enemy3 = Point(2,0),
		Target = Point(2,1)
	}
}

SS_Weapon_Aries_AB = SS_Weapon_Aries:new{
    Damage = 2,
    MinDamage = 1,
    PathSize = 4,
    TipImage = {
		Unit = Point(2,5),
		Enemy = Point(1,2),
		Enemy2 = Point(3,3),
        Enemy3 = Point(2,0),
		Target = Point(2,1)
	}
}