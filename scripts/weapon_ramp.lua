--It's another fancy mess:
local this = {}

SS_Weapon_Ramp = Skill:new{
    Name = "Acceleration Track",
    Description = "Places down an acceleration pad that can force a target across from it to either dash as far as possible, or be flung a set distance.",
    Class = "Science",
    Icon = "weapons/deployable_track.png",
    Range = INT_MAX,
    LaunchSound = "/weapons/area_shield",
    ImpactSound = "/impact/generic/mech",
    Explo = "explopush1_",
    DeployPrefix = "Speedster_Ramp_",
    TwoClick = true,
    TipImage = {
        Unit = Point(2,4),
        Target = Point(2,2),
        Second_Click = Point(3,2)
    },
    Limited = 3,
    Upgrades = 1,
    UpgradeList = {"+1 Use"},
    UpgradeCost = {1}
}

SS_Weapon_Ramp_A = SS_Weapon_Ramp:new{
    UpgradeDescription = "Gain an additional use.",
    Limited = 4
}

--Picking where the pad will end up.
function SS_Weapon_Ramp:GetTargetArea(point)
    local ret = PointList()
    for i = DIR_START, DIR_END do
        for k = 1, self.Range do
            
            if not Board:IsValid(DIR_VECTORS[i]*k + point) then
                break
            end

            if not Board:IsBlocked(DIR_VECTORS[i]*k + point, PATH_FLYER) then
                ret:push_back(DIR_VECTORS[i]*k + point)
            end

        end
    end

    return ret
end

function SS_Weapon_Ramp:GetSkillEffect(p1,p2)
    --Just creating an arcing shot.
    local ret = SkillEffect()
    local damage = SpaceDamage(p2, 0)
    ret:AddArtillery(damage, "effects/shot_pull_U.png")

    return ret
end

--Picking where the pad faces.
function SS_Weapon_Ramp:GetSecondTargetArea(p1,p2)
    local ret = PointList()

    for i = DIR_START, DIR_END do
		local current = p2 + DIR_VECTORS[i]
        local currentOpposite = p2 - DIR_VECTORS[i]
        if Board:IsValid(current) then
            if not Board:IsBlocked(currentOpposite, PATH_FLYER) then --Don't put a booster pad in a position where it won't be possible to use it...
                ret:push_back(current)
            elseif Board:IsPawnSpace(currentOpposite) then
                ret:push_back(current)
            end
        end
	end

    return ret
end

function SS_Weapon_Ramp:GetFinalEffect(p1,p2,p3)
    local ret = self:GetSkillEffect(p1,p2)
    local dir = GetDirection(p3-p2)

    ret:AddBounce(p2,3)

    local pawnLoc = SpaceDamage(p2, 0)
    pawnLoc.sPawn = self.DeployPrefix..dir
    pawnLoc.sAnimation = self.Explo..dir
    ret:AddDamage(pawnLoc)

    return ret
end

---The actual Pawns...
Speedster_Ramp_0 = Pawn:new{
    Name = "Acceleration Track",
    Health = 1,
    MoveSpeed = 0,
    Image = "accel_mine_0",
    SkillList = {"SS_Weapon_Accel_0", "SS_Weapon_Ramper_0"},
    SoundLocation = "/support/terraformer",
    DefaultTeam = TEAM_PLAYER,
    ImpactMaterial = IMPACT_METAL,
	Pushable = false,
    Corpse = false,
    IgnoreSmoke = true
}
Speedster_Ramp_1 = Speedster_Ramp_0:new{
    Image = "accel_mine_1",
    SkillList = {"SS_Weapon_Accel_1", "SS_Weapon_Ramper_1"}
}
Speedster_Ramp_2 = Speedster_Ramp_0:new{
    Image = "accel_mine_2",
    SkillList = {"SS_Weapon_Accel_2", "SS_Weapon_Ramper_2"}
}
Speedster_Ramp_3 = Speedster_Ramp_0:new{
    Image = "accel_mine_3",
    SkillList = {"SS_Weapon_Accel_3", "SS_Weapon_Ramper_3"}
}

--The weapons...
SS_Weapon_Accel_0 = Skill:new{
    Name = "Accelerate",
    Class = "Unique",
    Description = "Fling a target adjacent to the pad across it as far as possible, colliding with obstacles.",
    LaunchSound = "/weapons/charge",
    Icon = "weapons/deploy_fx_accel.png",
    TipImage = {
        Unit = Point(2,2),
        Target = Point(2,1),
        Enemy = Point(2,3),
        CustomPawn = "Speedster_Ramp_0"
    },
    EffectDirection = 0
}
function SS_Weapon_Accel_0:GetTargetArea(point)
    return SS_AccelTargeting(point, self.EffectDirection)
end

function SS_Weapon_Accel_0:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2-p1)

    local affectedPawnTile = p1-DIR_VECTORS[dir]
    local pathing = Board:GetPawn(affectedPawnTile):GetPathProf()

    local target = GetProjectileEnd(p1, p2, pathing)
    local distance = affectedPawnTile:Manhattan(target)

    local doDamage = true

    if not Board:IsBlocked(target,pathing) then -- dont attack an empty edge square, just run to the edge
		doDamage = false
		target = target + DIR_VECTORS[dir]
	end

    ret:AddCharge(Board:GetPath(affectedPawnTile, target - DIR_VECTORS[dir], PATH_FLYER), NO_DELAY)
    local temp = affectedPawnTile 
    while temp ~= target  do 
        ret:AddBounce(temp,-3)
        temp = temp + DIR_VECTORS[dir]
        if temp ~= target then
            ret:AddDelay(0.06)
        end
    end

    if doDamage then
        --The affected target will now collide with something.
        local push = SpaceDamage(target - DIR_VECTORS[dir], 0, dir)
        ret:AddDamage(push)
    end

    return ret
end

SS_Weapon_Accel_1 = SS_Weapon_Accel_0:new{
    EffectDirection = 1,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(3,2),
        Enemy = Point(1,2),
        CustomPawn = "Speedster_Ramp_1"
    }
}
SS_Weapon_Accel_2 = SS_Weapon_Accel_0:new{
    EffectDirection = 2,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(2,3),
        Enemy = Point(2,1),
        CustomPawn = "Speedster_Ramp_2"
    }
}
SS_Weapon_Accel_3 = SS_Weapon_Accel_0:new{
    EffectDirection = 3,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(1,2),
        Enemy = Point(3,2),
        CustomPawn = "Speedster_Ramp_3"
    }
}

SS_Weapon_Ramper_0 = Skill:new{
    Name = "Ramp",
    Class = "Unique",
    Description = "Self-destruct the accelerator pad to send a target flying a set distance.",
    LaunchSound = "/weapons/leap",
    Icon = "weapons/deploy_fx_ramp.png",
    TipImage = {
        Unit = Point(2,2),
        Target = Point(2,0),
        Enemy = Point(2,3),
        CustomPawn = "Speedster_Ramp_0"
    },
    EffectDirection = 0
}
function SS_Weapon_Ramper_0:GetTargetArea(point)
    return SS_RampTargeting(point, self.EffectDirection)
end

function SS_Weapon_Ramper_0:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    local dir = GetDirection(p2-p1)

    local move = PointList()
    move:push_back(p1-DIR_VECTORS[dir])
    move:push_back(p2)

    ret:AddLeap(move, NO_DELAY)

    local damage = SpaceDamage(p1, DAMAGE_DEATH)
    damage.sAnimation = "ExploArt3"
    ret:AddDamage(damage)

    return ret
end

SS_Weapon_Ramper_1 = SS_Weapon_Ramper_0:new{
    EffectDirection = 1,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(4,2),
        Enemy = Point(1,2),
        CustomPawn = "Speedster_Ramp_1"
    }
}
SS_Weapon_Ramper_2 = SS_Weapon_Ramper_0:new{
    EffectDirection = 2,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(2,4),
        Enemy = Point(2,1),
        CustomPawn = "Speedster_Ramp_2"
    }
}
SS_Weapon_Ramper_3 = SS_Weapon_Ramper_0:new{
    EffectDirection = 3,
    TipImage = {
        Unit = Point(2,2),
        Target = Point(0,2),
        Enemy = Point(3,2),
        CustomPawn = "Speedster_Ramp_3"
    }
}

--Functions used to automate creation of these weapons.
function SS_AccelTargeting(point, dir)
    local ret = PointList()
    if Board:IsPawnSpace(point - DIR_VECTORS[dir]) then
        local targetPawn = Board:GetPawn(point - DIR_VECTORS[dir])
        if not Board:IsBlocked(point + DIR_VECTORS[dir], PATH_FLYER) and not targetPawn:IsGuarding() then
            ret:push_back(point + DIR_VECTORS[dir])
        end
    end

    return ret
end

function SS_RampTargeting(point, dir)
    local ret = PointList()
    if Board:IsPawnSpace(point - DIR_VECTORS[dir]) then --checking for a valid victim for ramping
        local pawn = Board:GetPawn(point - DIR_VECTORS[dir])
        if not pawn:IsGuarding() then
            local currSpace = point + DIR_VECTORS[dir]
            while Board:IsValid(currSpace) do
                if not Board:IsBlocked(currSpace, PATH_FLYER) then
                    ret:push_back(currSpace)
                end
                currSpace = currSpace + DIR_VECTORS[dir]
            end
        end
    end

    return ret
end

local function stringStarts(fullString, startString)
    return string.sub(fullString, 1, string.len(startString)) == startString
end

-- Cursed hook to make it possible for any units to move through these ramps (but not end a turn on one.)
local turnChangeHook = function(mission)
    local currentTeam = Game:GetTeamTurn()
    --This is done by making the acceleration pads get set to the team that's currently taking a turn.
    for Mx = 0, 7 do
        for My = 0, 7 do
            local point = Point(Mx,My)
            if Board:IsPawnSpace(point) and stringStarts(Board:GetPawn(point):GetType(), "Speedster_Ramp_") then
                Board:GetPawn(point):SetTeam(currentTeam)

                if currentTeam == TEAM_ENEMY then
                    --I'll use this if the pads decide to go rogue.
                end
            end
        end
    end
end

function this:load()
    modApi:addNextTurnHook(turnChangeHook)
end

return this