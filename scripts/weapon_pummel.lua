local path = mod_loader.mods[modApi.currentMod].scriptPath
local worldConstants = require(path .."libs/worldConstants")

SS_Weapon_Pummel = Skill:new{
    Name = "Pummeling Sprint",
    Description = "Dash forward to knock a target back. Damage scales with distance traveled.",
    Class = "Prime",
    Icon = "weapons/prime_pummel.png",
    LaunchSound = "",
    ImpactSound = "/weapons/charge_impact",
    MinDamage = 0,
    Damage = 2,
    UpgradedDamage = 0,
    Rarity = 1,
    PathSize = 10,
    PhaseChars = 0,
    Upgrades = 2,
    UpgradeList = {"Phasing Dash", "+1 Damage"},
    UpgradeCost = {1,2},
    TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
		Target = Point(2,1)
	}
}

function SS_Weapon_Pummel:GetTargetArea(p1)
    local ret = PointList()
    for dir = DIR_START, DIR_END do
        local previousStandable = true
        for i = 1, self.PathSize do
            local currentTile = p1 + DIR_VECTORS[dir]*i
            if not Board:IsValid(currentTile) then --Off the board.
                break
            end
            if not Board:IsBlocked(currentTile, Pawn:GetPathProf()) then --If the pawn can normally move here
                ret:push_back(currentTile)
                previousStandable = true
            elseif Board:IsPawnSpace(currentTile) and self.PhaseChars ~= 1 then --If there's another pawn in the way and we cannot phase
                ret:push_back(currentTile)
                break
            elseif Board:IsPawnSpace(currentTile) and self.PhaseChars == 1 and previousStandable then --If we CAN phase but the tile directly before this found pawn is free, we can punch it.
                previousStandable = false
                ret:push_back(currentTile)
            elseif Board:IsBlocked(currentTile, Pawn:GetPathProf()) and not Board:IsPawnSpace(currentTile) then --If the given space is obstructed by anything else that isn't a pawn, we're done.
                if previousStandable then
                    ret:push_back(currentTile)
                end
                break
            end
        end
    end
    return ret
end

function SS_Weapon_Pummel:GetSkillEffect(p1,p2)
    local ret = SkillEffect()
    local direction = GetDirection(p2 - p1)

    local distance = p1:Manhattan(p2)
    local distanceTraveled = distance

    local targetObstruct = Board:IsBlocked(p2, PATH_FLYER)
    local targetChargeSpace = p2
    if targetObstruct then
        targetChargeSpace = p2 - DIR_VECTORS[direction]
        distanceTraveled = p1:Manhattan(targetChargeSpace)
    end

    if distance == 1 and targetObstruct then
        local shover = SpaceDamage(p2, self.UpgradedDamage, direction)
        shover.sAnimation = "explopunch1_"..direction
        shover.sSound = self.ImpactSound
        ret:AddMelee(p1, shover)
    else
        ret:AddSound("/props/pod_incoming")
        ret:AddSound("/mech/distance/bombling_mech/")
        local sprintSpeed = 2
        worldConstants.SetSpeed(ret, sprintSpeed)
        ret:AddCharge(Board:GetPath(p1, targetChargeSpace, PATH_FLYER), NO_DELAY)
        worldConstants.ResetSpeed(ret)

        for i = 0, (distanceTraveled - 1) do
            local currentSpace = p1 + DIR_VECTORS[direction]*i

            ret:AddDelay(0.02)
            ret:AddBounce(currentSpace, -3)

            local passThruPush = SpaceDamage(currentSpace, 0, direction)
            passThruPush.sAnimation = "exploout0_"..(direction+2)%4
            ret:AddDamage(passThruPush)
        end

        local damageSpace = p2 + DIR_VECTORS[direction]
        if targetObstruct then
            damageSpace = p2
        end
        local damage = SpaceDamage(damageSpace, math.min(self.Damage, distanceTraveled + self.UpgradedDamage), direction)
        damage.sAnimation = "explopunch1_"..direction
        damage.sSound = self.ImpactSound
        ret:AddDamage(damage)
    end

    return ret
end

SS_Weapon_Pummel_A = SS_Weapon_Pummel:new{
    UpgradeDescription = "Phase through other characters, pushing each.",
    PhaseChars = 1,
    TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
        Enemy2 = Point(2,3),
		Target = Point(2,1)
	}
}

SS_Weapon_Pummel_B = SS_Weapon_Pummel:new{
    UpgradeDescription = "Increase damage by +1 under all circumstances.",
    UpgradedDamage = 1,
    Damage = 3,
    MinDamage = 1
}

SS_Weapon_Pummel_AB = SS_Weapon_Pummel:new{
    PhaseChars = 1,
    UpgradedDamage = 1,
    Damage = 3,
    MinDamage = 1,
    TipImage = {
		Unit = Point(2,4),
		Enemy = Point(2,1),
        Enemy2 = Point(2,3),
		Target = Point(2,1)
	}
}