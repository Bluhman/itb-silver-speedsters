SS_Weapon_TC_Track = Skill:new{
    Name = "Tracklayer",
    Description = "Places down a stretch of one-time use pads that propel targets that stand on them in a given direction.",
    Class = "Science",
    Icon = "weapons/deployable_track.png",
    --Rarity = 2,
    Range = 3,
    LaunchSound = "/weapons/area_shield",
    ImpactSound = "/impact/generic/mech",
    Explo = "explopush1_",
    BeneathTarget = 0,
    TwoClick = true,
    Upgrades = 1,
    UpgradeCost = {2},
    UpgradeList = {"Beneath Target"},
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Second_Click = Point(4,2)
    }
}

--Picking where the pad will end up.
function SS_Weapon_TC_Track:GetTargetArea(point)
    local ret = PointList()
    for i = DIR_START, DIR_END do
        for k = 1, self.Range do
            if not Board:IsItem(DIR_VECTORS[i]*k + point) then
                if not Board:IsBlocked(DIR_VECTORS[i]*k + point, PATH_FLYER) then
				ret:push_back(DIR_VECTORS[i]*k + point)
                elseif Board:IsPawnSpace(DIR_VECTORS[i]*k + point) and self.BeneathTarget == 1 then
                ret:push_back(DIR_VECTORS[i]*k + point)
			    end
            end
        end
    end

    return ret
end

function SS_Weapon_TC_Track:GetSkillEffect(p1,p2)
    --Just creating an arcing shot.
    local ret = SkillEffect()
    local damage = SpaceDamage(p2, DAMAGE_ZERO)
    ret:AddArtillery(damage, "effects/shot_pull_U.png")

    return ret
end

--Picking where the pad faces.
function SS_Weapon_TC_Track:GetSecondTargetArea(p1,p2)
    local ret = PointList()

    for i = DIR_START, DIR_END do
		for k = 1, 2 do
            local newPoint = p2 + DIR_VECTORS[i]*k
            if Board:IsItem(newPoint) then
                break
            end
            if not Board:IsBlocked(newPoint, PATH_GROUND) then
                ret:push_back(newPoint)
            elseif Board:IsPawnSpace(newPoint) and self.BeneathTarget == 1 then
                ret:push_back(newPoint)
            else
                break
            end
        end
	end

    return ret
end

function SS_Weapon_TC_Track:GetFinalEffect(p1,p2,p3)
    local ret = self:GetSkillEffect(p1,p2)
    local dir = GetDirection(p3-p2)

    local distance = p2:Manhattan(p3)
    for i = 0, distance do
        local extraSpace = p2 + DIR_VECTORS[dir]*i

        ret:AddDelay(0.06)
        ret:AddBounce(extraSpace, -3)

        local pathLayer = SpaceDamage(extraSpace, 0)
        pathLayer.sItem = "Boost_Pad_"..dir
        pathLayer.sAnimation = self.Explo..dir
        ret:AddDamage(pathLayer)
    end

    return ret
end

SS_Weapon_TC_Track_A = SS_Weapon_TC_Track:new{
    UpgradeDescription="Allows you to place pads beneath units.",
    BeneathTarget = 1,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Second_Click = Point(4,2),
        Friendly = Point(2,2),
        Enemy1 = Point(4,2)
    }
}