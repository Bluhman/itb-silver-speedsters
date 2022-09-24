--must be done because this thing has unholy hooks:
local this = {}

local path = mod_loader.mods[modApi.currentMod].scriptPath

SS_Weapon_Passive_Bumper = PassiveSkill:new{
    Name = "Crash Dampener",
    Passive = "SS_Weapon_Passive_Bumper",
    PowerCost = 1,
    Rarity = 2,
    Description = "Mechs auto-repair damage from collision.",
    Icon = "weapons/passive_bumper.png",
    TipImage = {
		Unit = Point(2,3),
		Friendly = Point(2,1),
		Enemy1 = Point(2,2),
		Target = Point(2,2)
	}
}

function SS_Weapon_Passive_Bumper:GetSkillEffect(p1, p2)
    local ret = SkillEffect()
    ret:AddDelay(1)
	local damage = SpaceDamage(Point(2,2),1)
	damage.iPush = DIR_DOWN
	ret:AddMelee(Point(2,1), damage)
	ret.effect:back().bHide = true
	return ret
end

--------
--OK TIME TO DO SOME REAL CURSED STUFF.
-- This virtual thing is used to predict where a pawn's going to end up so that we can do the stuff.
local virtual = {}

local function vIsPawnSpace(point)
    index = p2idx (point) --We can't just use raw points because stuff.
    --Check the virtual board:
    if virtual[index] then
        if virtual[index] == -1 then return false end
        if virtual[index] then return true end
    end
    return Board:IsPawnSpace(point)
end

local function vIsBlocked(point)
    index = p2idx (point)
    if virtual[index] then
        if virtual[index] == -1 then return false end
        if virtual[index] then return true end
    end
    return Board:IsBlocked(point, PATH_PROJECTILE)
end

local function vGetPawn(point)
	index = p2idx (point)
	if virtual[index] then
		if virtual[index] ~= -1 then return Board:GetPawn(virtual[index]) end
	end
	return Board:GetPawn(point)
end

------
local function IterateEffects(effect)
    --Let's not do any of this garbage if the Passive isn't in play so that we can save cycles:
    if (not IsPassiveSkill("SS_Weapon_Passive_Bumper")) then 
        return nil
    end

    --Create a record of the pawns that will be moving.
    virtual = {}
    for _, spaceDamage in ipairs(extract_table(effect)) do
        if spaceDamage:IsMovement() then
            local point = spaceDamage:MoveStart()
            local point2 = spaceDamage:MoveEnd()
            if vIsPawnSpace(point) then
                local id = Board:GetPawn(point):GetId()
                virtual[p2idx(point)] = -1 --This space is emptied.
                virtual[p2idx(point2)] = id --The pawn of this ID now lives here.
            end
        end
    end

    local ret = {}
    i = 0
    --[[Check for all the queued up skill effects that shall occur.
        Look for any that contain our mechs. We have to check both p and p2 because
        otherwise we won't account for any units that had something ELSE shoved into them.
    --]]
    for _, spaceDamage in ipairs(extract_table(effect)) do
        local point1 = spaceDamage.loc
        if vIsPawnSpace(point1) then
            local pawn =  vGetPawn(point1) --this is the pawn that's moving.
            --LOG(pawn:GetMechName())
            if (not pawn:IsGuarding() and spaceDamage.iPush) then --pawn that isn't immune to knockbacks.
                if spaceDamage.iPush <= 3 then --the pawn's being pushed in a direction that actually exists.
                    local point2 = spaceDamage.loc + DIR_VECTORS[(spaceDamage.iPush)]
                    if (vIsBlocked(point2) and Board:IsValid(point2)) then --WHOOPS we can't go there.
                        --First let's check if the bump-ee is on our side:
                        if Board:GetPawnTeam(pawn:GetSpace()) == TEAM_PLAYER then
                            LOG(spaceDamage.damage)
                            i = i+1
                            ret[i] = point1
                        end

                        if (vIsPawnSpace(point2)) then
                            local pawn2 = vGetPawn(point2)
                            --LOG(pawn2:GetMechName())
                            if Board:GetPawnTeam(pawn2:GetSpace()) == TEAM_PLAYER then
                                i = i+1
                                ret[i] = point2
                            end
                        end
                    end

                end
            end
        end
    end

    if i > 0 then 
        return ret 
    end
    return nil
end

local onSkillEffectFinal = function(skillEffect)
    if not skillEffect then 
        return 
    end
    local ret = IterateEffects(skillEffect.effect)
    if ret then
        --LOG(#ret .. "targets")
        for i = 1, #ret do
            skillEffect:AddScript([[
                local fx = SkillEffect();
                local damage = SpaceDamage(Point(]]..ret[i]:GetString()..[[), -1);
                fx:AddDamage(damage);
                Board:AddEffect(fx)
            ]])
        end
    else
        ret = IterateEffects(skillEffect.q_effect)
        if ret then
            --LOG(#ret .. "targetsB")
            for i = 1, #ret do
                skillEffect:AddQueuedScript([[
                    local fx = SkillEffect();
                    local damage = SpaceDamage(Point(]]..ret[i]:GetString()..[[), -1);
                    fx:AddDamage(damage);
                    Board:AddEffect(fx)
                ]])
            end
        end
    end
end

local onSkillEffect = function(mission, pawn, weaponId, p1, p2, skillEffect)
    if not skillEffect then 
        return 
    end
    onSkillEffectFinal(skillEffect)
end

local onSkillEffectADV = function(mission, pawn, weaponId, p1, p2, p3, skillEffect)
    if not skillEffect then 
        return 
    end
    onSkillEffectFinal(skillEffect)
end
---


function this:load(modApiExt, options)
    modApiExt:addSkillBuildHook(onSkillEffect)
    modApiExt:addSkillBuildSecondClickHook(onSkillEffectADV)
end

return this
