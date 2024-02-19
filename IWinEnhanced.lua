---- For Warriors ----
if UnitClass("player") ~= "Warrior" then return end


---- Loading ----
IWin = CreateFrame("frame",nil,UIParent)
IWin.t = CreateFrame("GameTooltip", "IWin_T", UIParent, "GameTooltipTemplate")
local IWin_Settings = {
	["rageTimeToReserveBuffer"] = 1,
	["ragePerSecondPrediction"] = 10, -- change it to match your gear and buffs
}
local IWin_CombatVar = {
	["dodge"] = 0,
	["reservedRage"] = 0,
	["reservedRageStance"] = nil,
	["charge"] = 0,
}
local Cast = CastSpellByName
local EquipSet = EquipSet


IWin:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
IWin:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
IWin:RegisterEvent("ADDON_LOADED")
IWin:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "IWin" then
		DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff IWin loaded.|r")
		IWin:UnregisterEvent("ADDON_LOADED")
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		if string.find(arg1,"dodge") then
			IWin_CombatVar["dodge"] = GetTime()
		end		
	elseif event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
		if string.find(arg1,"dodge") then
			IWin_CombatVar["dodge"] = GetTime()
		end
	end
end)


--[[                                                                                                                                                                                                                               
███████╗██████╗ ███████╗██╗     ██╗         ██████╗  █████╗ ████████╗ █████╗ 
██╔════╝██╔══██╗██╔════╝██║     ██║         ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
███████╗██████╔╝█████╗  ██║     ██║         ██║  ██║███████║   ██║   ███████║
╚════██║██╔═══╝ ██╔══╝  ██║     ██║         ██║  ██║██╔══██║   ██║   ██╔══██║
███████║██║     ███████╗███████╗███████╗    ██████╔╝██║  ██║   ██║   ██║  ██║
╚══════╝╚═╝     ╚══════╝╚══════╝╚══════╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝                                                                                                                                                                                                                                                                                                                                                                                                                                                        
]]--
IWin_ExecuteCostReduction = {
	[0] = 0,
	[1] = 2,
	[2] = 5,
}

IWin_BloodRageCostReduction = {
	[0] = 0,
	[1] = 2,
	[2] = 5,
}

IWin_ThunderClapCostReduction = {
	[0] = 0,
	[1] = 1,
	[2] = 2,
	[3] = 4,
}

function IWin:GetTalentRank(tabIndex, talentIndex)
	local _, _, _, _, currentRank = GetTalentInfo(tabIndex, talentIndex)
	return currentRank
end

function IWin:GetExecuteCostReduction()
	local executeRank = IWin:GetTalentRank(2, 10)
	return IWin_ExecuteCostReduction[executeRank]
end

function IWin:GetBloodRageCostReduction()
	local bloodrageRank = IWin:GetTalentRank(3, 3)
	return IWin_BloodrageCostReduction[bloodrageRank]
end

function IWin:GetThunderClapCostReduction()
	local thunderClapRank = IWin:GetTalentRank(1, 6)
	return IWin_ThunderClapCostReduction[thunderClapRank]
end

IWin_RageCost = {
	["Battle Shout"] = 10,
	["Berserker Rage"] = 0 - IWin:GetTalentRank(2, 15) * 5,
	["Bloodrage"] = - 10,
	["Bloodthirst"] = 30,
	["Charge"] = - 12 - IWin:GetTalentRank(1, 4) * 3,
	["Cleave"] = 20,
	["Demoralizing Shout"] = 10,
	["Disarm"] = 20,
	["Execute"] = 15 - IWin:GetExecuteCostReduction(),
	["Hamstring"] = 10,
	["Heroic Strike"] = 15 - IWin:GetTalentRank(1, 1),
	["Intercept"] = 10,
	["Mocking Blow"] = 10,
	["Mortal Strike"] = 30,
	["Overpower"] = 5,
	["Pummel"] = 10,
	["Rend"] = 10,
	["Revenge"] = 5,
	["Shield Bash"] = 10,
	["Shield Block"] = 10,
	["Shield Slam"] = 20,
	["Slam"] = 15,
	["Sunder Armor"] = 15 - IWin:GetTalentRank(3, 10),
	["Sweeping Strikes"] = 30,
	["Thunder Clap"] = 20 - IWin:GetThunderClapCostReduction(),
	["Whirlwind"] = 25,
}

IWin_Taunt = {
	"Taunt",
	"Mocking Blow",
	"Challenging Shout",
	"Growl",
	"Challenging Roar",
	"Hand of Reckoning",
}

--- Unit rarities ---
IWin_UnitClassification = {
	["worldboss"] = true,
	["rareelite"] = true,
	["elite"] = true,
	["rare"] = false,
	["normal"] = false,
	["trivial"] = false,
}

--[[                                                                                                                                                                                                                               
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝ 
██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝  
╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║   
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝                                                                                                                                                                                                                                                                                                                                                                            
]]--
function IWin:GetBuffIndex(unit, spell)
	local index = 1
	while UnitBuff(unit, index) do
		IWin_T:SetOwner(WorldFrame, "ANCHOR_NONE")
		IWin_T:ClearLines()
		IWin_T:SetUnitBuff(unit, index)
		local buffName = IWin_TTextLeft1:GetText()
		if buffName == spell then
			return index
		end
		index = index + 1
	end
	return nil
end

function IWin:GetDebuffIndex(unit, spell)
	index = 1
	while UnitDebuff(unit, index) do
		IWin_T:SetOwner(WorldFrame, "ANCHOR_NONE")
		IWin_T:ClearLines()
		IWin_T:SetUnitDebuff(unit, index)
		local buffName = IWin_TTextLeft1:GetText()
		if buffName == spell then 
			return index
		end
		index = index + 1
	end	
	return nil
end

function IWin:GetBuffStack(unit, spell)
	local index = IWin:GetBuffIndex(unit, spell)
	if index then
		local _, stack = UnitBuff(unit, index)
		return stack
	end
	local index = IWin:GetDebuffIndex(unit, spell)
	if index then
		local _, stack = UnitDebuff(unit, index)
		return stack
	end
	return 0
end

function IWin:IsBuffStack(unit, spell, stack)
	return IWin:GetBuffStack(unit, spell) == stack
end

function IWin:IsBuffActive(unit, spell)
	return IWin:GetBuffStack(unit, spell) ~= 0
end

function IWin:GetBuffRemaining(unit, spell)
	if unit == "player" then
		local index = IWin:GetBuffIndex(unit, spell)
		if index then
			return GetPlayerBuffTimeLeft(index - 1)
		end
		local index = IWin:GetDebuffIndex(unit, spell)
		if index then
			return GetPlayerBuffTimeLeft(index - 1)
		end
	elseif unit == "target" then
		local libdebuff = pfUI and pfUI.api and pfUI.api.libdebuff or ShaguTweaks and ShaguTweaks.libdebuff
		if not libdebuff then
	    	DEFAULT_CHAT_FRAME:AddMessage("Either pfUI or ShaguTweaks required")
	    	return 0
		end
		local index = IWin:GetDebuffIndex(unit, spell)
		if index then
			local _, _, _, _, _, _, timeleft = libdebuff:UnitDebuff("target", index)
			return timeleft
		end
	end
	return 0
end

function IWin:GetCooldownRemaining(spell)
    local spellID = 1
    local bookspell = GetSpellName(spellID, BOOKTYPE_SPELL)
    while bookspell do
        if spell == bookspell then
            local start, duration, enabled = GetSpellCooldown(spellID, BOOKTYPE_SPELL)
            if start and start ~= 0 and duration > 0 and enabled == 1 then
                local remaining = duration - (GetTime() - start)
                if remaining > 0 then
                    return remaining
                else
                    return 0 -- Cooldown finished but not updated yet
                end
            else
                return 0 -- Spell not on cooldown or is on global cooldown
            end
        end
        spellID = spellID + 1
        bookspell = GetSpellName(spellID, BOOKTYPE_SPELL)
    end
    return nil -- Spell not found
end

function IWin:IsOnCooldown(spell)
	return IWin:GetCooldownRemaining(spell) ~= 0
end

function IWin:IsSpellLearnt(spell)
	local spellID = 1
	local bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
	while bookspell do
		if bookspell == spell then
			return true
		end
		spellID = spellID + 1
		bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
	end
	return false
end

function IWin:IsOverpowerAvailable()
	local overpowerTimeActive = GetTime() - IWin_CombatVar["dodge"]
 	return overpowerTimeActive < 3
 end


function IWin:IsCharging()
	local chargeTimeActive = GetTime() - IWin_CombatVar["charge"]
	return chargeTimeActive < 1
end

function IWin:IsStanceActive(stance)
	for index = 1, 3 do
		local _, name, active = GetShapeshiftFormInfo(index)
		if name == stance then
			return active == 1
		end
	end
	return false
end

function IWin:GetHealthPercent(unit)
	return UnitHealth(unit) / UnitHealthMax(unit)
end

function IWin:IsExecutePhase()
	return IWin:GetHealthPercent("target") <= 0.2
end

function IWin:IsRageAvailable(spell)
	local rageRequired = IWin_RageCost[spell] + IWin_CombatVar["reservedRage"]
	return UnitMana("player") >= rageRequired
end

function IWin:IsRageCostAvailable(spell)
	return UnitMana("player") >= IWin_RageCost[spell]
end

function IWin:IsInMeleeRange()
	return CheckInteractDistance("target", 3) ~= nil
end

function IWin:CalculateRageRetentionOnStanceSwap()
	return math.min(IWin:GetTalentRank(1, 5) * 5, UnitMana("player"))
end

function IWin:IsRageLossWithinTalentLimit(rage)
	return rage <= math.max(0, UnitMana("player") - IWin:CalculateRageRetentionOnStanceSwap())
end

function IWin:CalculateRageReservationAmount(spell, trigger, unit)
	local spellTriggerTime = 0
	if trigger == "nocooldown" then
		return IWin_RageCost[spell]
	elseif trigger == "cooldown" then
		spellTriggerTime = IWin:GetCooldownRemaining(spell) or 0
	elseif trigger == "buff" or trigger == "partybuff" then
		spellTriggerTime = IWin:GetBuffRemaining(unit, spell) or 0
	end
	local reservedRageTime = 0
	if IWin_Settings["ragePerSecondPrediction"] > 0 then
		reservedRageTime = IWin_CombatVar["reservedRage"] / IWin_Settings["ragePerSecondPrediction"]
	end
	local timeToReserveRage = math.max(0, spellTriggerTime - IWin_Settings["rageTimeToReserveBuffer"] - reservedRageTime)
	if trigger == "partybuff" or IWin:IsSpellLearnt(spell) then
		return math.max(0, IWin_RageCost[spell] - IWin_Settings["ragePerSecondPrediction"] * timeToReserveRage)
	end
	return 0
end

function IWin:ShouldReserveRageForSpell(spell, trigger, unit)
	return IWin:CalculateRageReservationAmount(spell, trigger, unit) ~= 0
end

function IWin:UpdateRageReservationForSpell(spell, trigger, unit)
	IWin_CombatVar["reservedRage"] = IWin_CombatVar["reservedRage"] + IWin:CalculateRageReservationAmount(spell, trigger, unit)
end

function IWin:IsTanking()
	return UnitIsUnit("targettarget", "player")
end

function IWin:GetItemID(itemLink)
	for itemID in string.gfind(itemLink, "|c%x+|Hitem:(%d+):%d+:%d+:%d+|h%[(.-)%]|h|r$") do
		return itemID
	end
end

function IWin:IsShieldEquipped()
	local offHandLink = GetInventoryItemLink("player", 17)
	if offHandLink then
		local _, _, _, _, _, itemSubType = GetItemInfo(tonumber(IWin:GetItemID(offHandLink)))
		return itemSubType == "Shields"
	end
	return false
end

function IWin:IsElite()
	local classification = UnitClassification("target")
	return IWin_UnitClassification[classification]
end

function IWin:IsCurrentStanceForReservedRage(stance)
	if IWin_CombatVar["reservedRageStance"] then
		return IWin_CombatVar["reservedRageStance"] == stance
	end
	return true
end

function IWin:IsTaunted()
	local index = 1
	while IWin_Taunt[index] do
		local taunt = IWin:IsBuffActive("target", IWin_Taunt[index])
		if taunt then
			return true
		end
		index = index + 1
	end
	return false
end
---- End utility functions ----

--[[                                                                                                                                                                                                                               
 █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗       ██╗       ███████╗██████╗ ███████╗██╗     ██╗     ███████╗
██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝       ██║       ██╔════╝██╔══██╗██╔════╝██║     ██║     ██╔════╝
███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗    ████████╗    ███████╗██████╔╝█████╗  ██║     ██║     ███████╗
██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║    ██╔═██╔═╝    ╚════██║██╔═══╝ ██╔══╝  ██║     ██║     ╚════██║
██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║    ██████║      ███████║██║     ███████╗███████╗███████╗███████║
╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝    ╚═════╝      ╚══════╝╚═╝     ╚══════╝╚══════╝╚══════╝╚══════╝                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
]]--
function IWin:TargetEnemy()
	if not UnitExists("target") or UnitIsDead("target") or UnitIsFriend("target", "player") then
		TargetNearestEnemy()
	end
end

function IWin:StartAttack()
	if not PlayerFrame.inCombat then
		AttackTarget()
	end
end

function IWin:BattleShoutFaded()
	if IWin:IsSpellLearnt("Battle Shout") and not IWin:IsBuffActive("player","Battle Shout") and IWin:IsRageCostAvailable("Battle Shout") then 
		Cast("Battle Shout")
	end
end

function IWin:BerserkerRage()
	if IWin:IsSpellLearnt("Berserker Rage") and IWin:IsStanceActive("Berserker Stance") and not IWin:IsOnCooldown("Berserker Rage") and UnitAffectingCombat("player") and IWin:IsTanking() then
		Cast("Berserker Rage")
	end
end

function IWin:BerserkerRageImmune()
	if IWin:IsSpellLearnt("Berserker Rage") and not IWin:IsOnCooldown("Berserker Rage") then
		if not IWin:IsStanceActive("Berserker Stance") then
			Cast("Berserker Stance")
		end
		Cast("Berserker Rage")
	end
end

function IWin:BerserkerStanceInstance()
	if IWin:IsSpellLearnt("Berserker Stance") and IsInInstance() and not IWin:IsStanceActive("Berserker Stance") and IWin:IsRageLossWithinTalentLimit(5) then
		Cast("Berserker Stance")
	end
end

function IWin:Bloodrage()
    if IWin:IsSpellLearnt("Bloodrage")
        and UnitMana("player") < 70 --cast blood rage if player is below 70 rage
        and (
                (IWin:IsStanceActive("Defensive Stance") and IWin:GetHealthPercent("player") > 0.40)  --if in defensive stance, only use bloodrage above 40% hp
                or (not IWin:IsStanceActive("Defensive Stance") and IWin:GetHealthPercent("player") > 0.25) --in berserker and battle stance, cast bloodrage when above 25% hp
            )
        and (
                IWin:IsStanceActive("Defensive Stance")
            or (
                    UnitAffectingCombat("player")
                and (
                    	IWin:IsSpellLearnt("Mortal Strike")
                    or IWin:IsSpellLearnt("Bloodthirst")
                    or IWin:IsSpellLearnt("Shield Slam")
                    )
                )
            ) then
        Cast("Bloodrage")
    end
end

function IWin:Bloodthirst()
	if  IWin:IsRageAvailable("Bloodthirst") then
		Cast("Bloodthirst")
	end
end

function IWin:Charge()
	if IWin:IsSpellLearnt("Charge") and not IWin:IsOnCooldown("Charge") and not IWin:IsInMeleeRange() and not UnitAffectingCombat("player") then
		if not IWin:IsStanceActive("Battle Stance") then
			Cast("Battle Stance")
		end
		Cast("Charge")
		IWin_CombatVar["charge"] = GetTime()
	end
end

function IWin:ChargeOpenWorld()
	if IWin:IsSpellLearnt("Charge") and not IWin:IsOnCooldown("Charge") and not IWin:IsInMeleeRange() and not UnitAffectingCombat("player") and not IsInInstance() then
		if not IWin:IsStanceActive("Battle Stance") and (IWin:IsRageLossWithinTalentLimit(5) or UnitIsPVP("target")) then
			Cast("Battle Stance")
		end
		Cast("Charge")
		IWin_CombatVar["charge"] = GetTime()
	end
end

function IWin:Cleave()
	if IWin:IsSpellLearnt("Cleave") then
		if IWin:IsRageAvailable("Cleave") then
			Cast("Cleave")
		end
	end
end

function IWin:CleaveStance()
	if IWin:IsStanceActive("Defensive Stance") then
		if not IWin:IsSpellLearnt("Sweeping Strikes") and IWin:IsSpellLearnt("Berserker Stance") then
			Cast("Berserker Stance")
		elseif IWin:IsSpellLearnt("Battle Stance") then
			Cast("Battle Stance")
		end
	end
end

function IWin:DPSStance()
	if IWin:IsStanceActive("Defensive Stance") then
		if IWin:IsSpellLearnt("Berserker Stance") then
			Cast("Berserker Stance")
		elseif IWin:IsSpellLearnt("Battle Stance") then
			Cast("Battle Stance")
		end
	end
end

function IWin:Execute()
    -- Check if Execute is learned, if it's the execute phase, and if rage is available for Execute
    if IWin:IsSpellLearnt("Execute") and IWin:IsExecutePhase() and IWin:IsRageAvailable("Execute") then
        -- Equip "Execute" gear set if the target is elite and in execute phase
        if IWin:IsElite() then
            -- EquipSet("Execute")  -- Adjust this command based on your equipment management addon/API
        end
        
        -- Calculate Attack Power and Bloodthirst damage
        local baseAP, posBuffAP, negBuffAP = UnitAttackPower("player")
        local totalAP = baseAP + posBuffAP + negBuffAP
        local BTDmg = totalAP * 0.45
        
        -- Check for Bloodthirst conditions
        if IWin:IsSpellLearnt("Bloodthirst") and BTDmg >= 900 and UnitMana("player") >= 30 then
            CastSpellByName("Bloodthirst")
        else
            -- Cast Execute if the target is a PVP target or an Elite and Bloodthirst conditions aren't met
            if UnitIsPVP("target") or IWin:IsElite() then
                Cast("Execute")
            end
        end
    end
end



function IWin:ReserveExecuteRage()
    if IWin:IsSpellLearnt("Execute") and IWin:IsExecutePhase() and (UnitIsPVP("target") or IWin:IsElite()) then 
        IWin:UpdateRageReservationForSpell("Execute", "cooldown")
    end
end

function IWin:Hamstring()
	if IWin:IsSpellLearnt("Hamstring") and IWin:IsInMeleeRange() and IWin:IsRageCostAvailable("Hamstring") then
		Cast("Hamstring")
	end
end

function IWin:HeroicStrike()
    if IWin:IsSpellLearnt("Heroic Strike") and UnitMana("player") >= 30 then
        -- Determine which spell is learned and get its cooldown
        local spellCooldown
        if IWin:IsSpellLearnt("Bloodthirst") then
            spellCooldown = IWin:GetCooldownRemaining("Bloodthirst")
        elseif IWin:IsSpellLearnt("Mortal Strike") then
            spellCooldown = IWin:GetCooldownRemaining("Mortal Strike")
        end

        -- If the learned spell is on cooldown for more than 2 seconds, attempt to cast Heroic Strike
        if spellCooldown == nil or spellCooldown >= 2 then
            if IWin:IsRageAvailable("Heroic Strike") then
                CastSpellByName("Heroic Strike")
            end
        end
    end
end

function IWin:Intercept()
	if IWin:IsSpellLearnt("Intercept")
		and not IWin:IsOnCooldown("Intercept")
		and not IWin:IsInMeleeRange()
		and not IWin:IsCharging()
		and (
				(
					not UnitAffectingCombat("player")
					and IWin:IsOnCooldown("Charge")
				)
				or UnitAffectingCombat("player")
			)
		and (
				(
					IWin:IsRageCostAvailable("Intercept")
					and (
							IWin:IsStanceActive("Berserker Stance")
							or IWin:CalculateRageRetentionOnStanceSwap() >= IWin_RageCost["Intercept"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			) then
		if not IWin:IsStanceActive("Berserker Stance") then
			Cast("Berserker Stance")
		end
		if not IWin:IsRageCostAvailable("Intercept") then
			Cast("Bloodrage")
		end
		Cast("Intercept")
	end
end

function IWin:MockingBlow()
	if IWin:IsSpellLearnt("Mocking Blow") and not IWin:IsTanking() and IWin:IsOnCooldown("Taunt") and not IWin:IsOnCooldown("Mocking Blow") and not IWin:IsTaunted() then
		if not IWin:IsStanceActive("Battle Stance") then
			Cast("Battle Stance")
		end
		Cast("Mocking Blow")
	end
end

function IWin:MortalStrike()
	if  IWin:IsRageAvailable("Mortal Strike") then
		Cast("Mortal Strike")
	end
end


function IWin:Overpower()
	if not (IWin:IsElite() and IWin:IsExecutePhase()) then
		if IWin:IsSpellLearnt("Overpower") and IWin:IsOverpowerAvailable() and not IWin:IsOnCooldown("Overpower") and IWin:IsRageAvailable("Overpower") and IWin:IsCurrentStanceForReservedRage("Battle Stance") then
			-- Modify this condition to check for player having 20 or less rage
			if not IWin:IsStanceActive("Battle Stance") and (UnitMana("player") <= 20 or UnitIsPVP("target")) then
				Cast("Battle Stance")
			end
			-- Add a condition to check for player's rage being 20 or less before casting Overpower
			if UnitMana("player") <= 20 then
				Cast("Overpower")
			end
		end
	end
end


function IWin:Pummel()
	if IWin:IsSpellLearnt("Pummel")
		and not IWin:IsOnCooldown("Pummel")
		and (
				(
					IWin:IsRageCostAvailable("Pummel")
					and (
							IWin:IsStanceActive("Berserker Stance")
							or IWin:CalculateRageRetentionOnStanceSwap() >= IWin_RageCost["Pummel"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			)
		and (
				not IWin:IsShieldEquipped()
				or IWin:IsStanceActive("Berserker Stance")
			) then
		if not IWin:IsStanceActive("Berserker Stance") then
			Cast("Berserker Stance")
		end
		if not IWin:IsRageCostAvailable("Pummel") then
			Cast("Bloodrage")
		end
		Cast("Pummel")
	end
end

function IWin:Revenge()
	if IWin:IsSpellLearnt("Revenge") and not IWin:IsOnCooldown("Revenge") and IWin:IsRageCostAvailable("Revenge") then
		if not IWin:IsStanceActive("Defensive Stance") then
			Cast("Defensive Stance")
		end
		Cast("Revenge")
	end
end

function IWin:UpdateRageReservationForSpellRevenge()
	if IWin:IsTanking() then
		IWin:UpdateRageReservationForSpell("Revenge", "cooldown")
	end
end

function IWin:ShieldBash()
	if IWin:IsSpellLearnt("Shield Bash")
		and not IWin:IsOnCooldown("Shield Bash")
		and IWin:IsShieldEquipped() 
		and (
				(
					IWin:IsRageCostAvailable("Shield Bash")
					and (
							not IWin:IsStanceActive("Berserker Stance")
							or IWin:CalculateRageRetentionOnStanceSwap() >= IWin_RageCost["Shield Bash"]
						)
				)
				or not IWin:IsOnCooldown("Bloodrage")
			) then
		if IWin:IsStanceActive("Berserker Stance") then
			Cast("Defensive Stance")
		end
		if not IWin:IsRageCostAvailable("Shield Bash") then
			Cast("Bloodrage")
		end
		Cast("Shield Bash")
	end
end

function IWin:ShieldSlam()
	if IWin:IsSpellLearnt("Shield Slam") and not IWin:IsOnCooldown("Shield Slam") and IWin:IsRageAvailable("Shield Slam") then
		Cast("Shield Slam")
	end
end

function IWin:SunderArmor()
	if IWin:IsSpellLearnt("Sunder Armor") and IWin:IsRageAvailable("Sunder Armor") then
		Cast("Sunder Armor")
	end
end

function IWin:SunderArmorFirstStack()
    local sunderArmorDuration = IWin:GetBuffRemaining("target", "Sunder Armor")
    if not sunderArmorDuration or sunderArmorDuration <= 5 then
        Cast("Sunder Armor")
    end
	end

function IWin:SweepingStrikes()
	if IWin:IsSpellLearnt("Sweeping Strikes") and IWin:IsCurrentStanceForReservedRage("Battle Stance") then
		if IWin:ShouldReserveRageForSpell("Sweeping Strikes", "cooldown") and UnitAffectingCombat("player") then
			IWin_CombatVar["reservedRageStance"] = "Battle Stance"
			if not IWin:IsStanceActive("Battle Stance") then
				Cast("Battle Stance")
			end
		end
		if not IWin:IsOnCooldown("Sweeping Strikes") and IWin:IsRageAvailable("Sweeping Strikes") then 
			Cast("Sweeping Strikes")
		end
	end
end

function IWin:TankStance()
	if IWin:IsSpellLearnt("Defensive Stance") then
		if UnitAffectingCombat("player") and not IWin:IsStanceActive("Defensive Stance") then
			Cast("Defensive Stance")
		end
	else
		Cast("Battle Stance")
	end
end

function IWin:Taunt()
	if IWin:IsSpellLearnt("Taunt") and not IWin:IsTanking() and not IWin:IsOnCooldown("Taunt") and not IWin:IsTaunted() then
		if not IWin:IsStanceActive("Defensive Stance") then
			Cast("Defensive Stance")
		end
		Cast("Taunt")
	end
end

function IWin:ThunderClap()
	if IWin:IsSpellLearnt("Thunder Clap") and IWin:IsRageAvailable("Thunder Clap") and not IWin:IsOnCooldown("Thunder Clap") then
		if IWin:IsStanceActive("Berserker Stance") then
			Cast("Battle Stance")
		end
		Cast("Thunder Clap")
	end
end

function IWin:DemoShout()
    if IWin:IsSpellLearnt("Demoralizing Shout") and IWin:IsRageAvailable("Demoralizing Shout") and not IWin:IsOnCooldown("Demoralizing Shout") then
        if not IWin:IsBuffActive("target", "Demoralizing Shout") then -- Check if the target does not have the Demoralizing Shout debuff
            if not IWin:IsStanceActive("Defensive Stance") then
                Cast("Defensive Stance")
            end
            Cast("Demoralizing Shout")
        end
    end
end

function IWin:Whirlwind()
	if IWin:IsSpellLearnt("Whirlwind") and IWin:IsCurrentStanceForReservedRage("Berserker Stance") then
		if IWin:ShouldReserveRageForSpell("Whirlwind", "cooldown") and UnitAffectingCombat("player") then
			IWin_CombatVar["reservedRageStance"] = "Berserker Stance"
			if not IWin:IsStanceActive("Berserker Stance") then
				Cast("Berserker Stance")
			end
		end
		if not IWin:IsOnCooldown("Whirlwind") and IWin:IsRageAvailable("Whirlwind") and IWin:IsInMeleeRange() 
		then 
			Cast("Whirlwind")
		end
	end
end
---- End actions ----


--[[                                                                                                                                                                                                                               
██████╗  ██████╗ ████████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
██████╔╝██║   ██║   ██║   ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
██╔══██╗██║   ██║   ██║   ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
██║  ██║╚██████╔╝   ██║   ██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        


       _                _             _             
      (_)              | |           | |            
  ___  _  _ __    __ _ | |  ___    __| | _ __   ___ 
 / __|| || '_ \  / _` || | / _ \  / _` || '_ \ / __|
 \__ \| || | | || (_| || ||  __/ | (_| || |_) |\__ \
 |___/|_||_| |_| \__, ||_| \___|  \__,_|| .__/ |___/
                  __/ |                 | |         
                 |___/                  |_|         
]]--
SLASH_IDPS1 = '/idps'
function SlashCmdList.IDPS()
    IWin_CombatVar["reservedRage"] = 0
    IWin_CombatVar["reservedRageStance"] = nil
    IWin:TargetEnemy() 									--target nearest alive enemy
    IWin:DPSStance() 									--cast berserker stance if we have it, battle stance if we don't
    IWin:Bloodrage() 									--cast bloodrage if above 25% hp
	-- IWin:SunderArmorFirstStack()
    IWin:BattleShoutFaded() 							--cast battle shout if it's not active and player has rage for it
    IWin:UpdateRageReservationForSpell("Battle Shout", "buff", "player")
	-- IWin:Overpower()
	IWin:Execute()
    IWin:ReserveExecuteRage()
	if IWin:IsSpellLearnt("Bloodthirst") and (not IWin:IsOnCooldown("Bloodthirst") or IWin:GetCooldownRemaining("Bloodthirst") < 1) then
		IWin:Bloodthirst()
		IWin:UpdateRageReservationForSpell("Bloodthirst", "cooldown")
	elseif IWin:IsSpellLearnt("Mortal Strike") and (not IWin:IsOnCooldown("Mortal Strike") or IWin:GetCooldownRemaining("Mortal Strike") < 1) then
		IWin:MortalStrike()
		IWin:UpdateRageReservationForSpell("Mortal Strike", "cooldown")
	else
		IWin:Whirlwind()
		IWin:UpdateRageReservationForSpell("Whirlwind", "cooldown")
	end
	IWin:HeroicStrike()
    IWin:BerserkerRage()
    IWin:StartAttack()
end


--[[                                                                                                                                                                                                                               
                           _             
                          | |            
   __ _   ___    ___    __| | _ __   ___ 
  / _` | / _ \  / _ \  / _` || '_ \ / __|
 | (_| || (_) ||  __/ | (_| || |_) |\__ \
  \__,_| \___/  \___|  \__,_|| .__/ |___/
                             | |         
                             |_|                 ]]--
SLASH_ICLEAVE1 = '/icleave'
function SlashCmdList.ICLEAVE()
	IWin_CombatVar["reservedRage"] = 0
	IWin_CombatVar["reservedRageStance"] = nil
	IWin:TargetEnemy()
	IWin:CleaveStance()
	IWin:Bloodrage()
	IWin:BattleShoutFaded()
	IWin:UpdateRageReservationForSpell("Battle Shout", "buff", "player")
	if IWin:IsSpellLearnt("Sweeping Strikes") then
        IWin:SweepingStrikes()
        IWin:UpdateRageReservationForSpell("Sweeping Strikes", "cooldown")
    end

	if IWin:IsSpellLearnt("Whirlwind") and (not IWin:IsOnCooldown("Whirlwind") or IWin:GetCooldownRemaining("Whirlwind") < 1) then
		IWin:Whirlwind()
		IWin:UpdateRageReservationForSpell("Whirlwind", "cooldown")
	else
		local bloodthirstOnCooldown = IWin:IsSpellLearnt("Bloodthirst") and IWin:GetCooldownRemaining("Bloodthirst") > 1
		local mortalStrikeOnCooldown = IWin:IsSpellLearnt("Mortal Strike") and IWin:GetCooldownRemaining("Mortal Strike") > 1
		
		if not bloodthirstOnCooldown and IWin:IsSpellLearnt("Bloodthirst") then
			IWin:Bloodthirst()
			IWin:UpdateRageReservationForSpell("Bloodthirst", "cooldown")
		elseif not mortalStrikeOnCooldown and IWin:IsSpellLearnt("Mortal Strike") then
			IWin:MortalStrike()
			IWin:UpdateRageReservationForSpell("Mortal Strike", "cooldown")
		else
			if bloodthirstOnCooldown or mortalStrikeOnCooldown then
				IWin:Cleave()  -- Queue Cleave as a rage dump
			end
			-- Additional check right after attempting to queue Cleave
			-- if (IWin:IsSpellLearnt("Whirlwind") and IWin:GetCooldownRemaining("Whirlwind") < 1) or 
			--    (IWin:IsSpellLearnt("Bloodthirst") and IWin:GetCooldownRemaining("Bloodthirst") < 1.5) or 
			--    (IWin:IsSpellLearnt("Mortal Strike") and IWin:GetCooldownRemaining("Mortal Strike") < 1.5) then
			-- 	SpellStopCasting()  -- Cancel the queued Cleave
			-- end
		end
	end
	IWin:Overpower()
	IWin:Execute()
	IWin:ReserveExecuteRage()
	IWin:BerserkerRage()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                               
  _                 _           _                _         _                            _   
 | |               | |         (_)              | |       | |                          | |  
 | |_  __ _  _ __  | | __  ___  _  _ __    __ _ | |  ___  | |_  __ _  _ __  __ _   ___ | |_ 
 | __|/ _` || '_ \ | |/ / / __|| || '_ \  / _` || | / _ \ | __|/ _` || '__|/ _` | / _ \| __|
 | |_| (_| || | | ||   <  \__ \| || | | || (_| || ||  __/ | |_| (_| || |  | (_| ||  __/| |_ 
  \__|\__,_||_| |_||_|\_\ |___/|_||_| |_| \__, ||_| \___|  \__|\__,_||_|   \__, | \___| \__|
                                           __/ |                            __/ |           
                                          |___/                            |___/                   ]]--
SLASH_ITANK1 = '/itank'
function SlashCmdList.ITANK()
	IWin_CombatVar["reservedRage"] = 0
	IWin_CombatVar["reservedRageStance"] = nil
	IWin:TargetEnemy()
	IWin:TankStance()
	IWin:Bloodrage()
	IWin:ShieldSlam()
	IWin:UpdateRageReservationForSpell("Shield Slam", "cooldown")
	IWin:MortalStrike()
	IWin:UpdateRageReservationForSpell("Mortal Strike", "cooldown")
	IWin:Bloodthirst()
	IWin:UpdateRageReservationForSpell("Bloodthirst", "cooldown")
	IWin:Revenge()
	IWin:UpdateRageReservationForSpellRevenge()
	IWin:SunderArmorFirstStack()
	IWin:BattleShoutFaded()
	IWin:UpdateRageReservationForSpell("Battle Shout", "buff", "player")
	IWin:SunderArmor()
	IWin:UpdateRageReservationForSpell("Sunder Armor", "nocooldown")
	IWin:BerserkerRage()
	IWin:HeroicStrike()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                               
  _                 _                         
 | |               | |                        
 | |_  __ _  _ __  | | __   __ _   ___    ___ 
 | __|/ _` || '_ \ | |/ /  / _` | / _ \  / _ \
 | |_| (_| || | | ||   <  | (_| || (_) ||  __/
  \__|\__,_||_| |_||_|\_\  \__,_| \___/  \___|                                                                                             
]]--
SLASH_IHODOR1 = '/ihodor'
function SlashCmdList.IHODOR()
	IWin_CombatVar["reservedRage"] = 0
	IWin_CombatVar["reservedRageStance"] = nil
	IWin:TargetEnemy()
	IWin:TankStance()
	IWin:Bloodrage()
	local improvedThunderClapRank = IWin:GetTalentRank(1, 6) -- Assuming tab 1 and index 6 for "Improved Thunder Clap"
    if improvedThunderClapRank == 3 then
        IWin:ThunderClap()
        IWin:UpdateRageReservationForSpell("Thunder Clap", "cooldown")
    end
	IWin:DemoShout()
	IWin:UpdateRageReservationForSpell("Demoralizing Shout", "cooldown")
	-- IWin:Whirlwind()
	-- IWin:UpdateRageReservationForSpell("Whirlwind", "cooldown")
	IWin:ShieldSlam()
	IWin:UpdateRageReservationForSpell("Shield Slam", "cooldown")
	IWin:MortalStrike()
	IWin:UpdateRageReservationForSpell("Mortal Strike", "cooldown")
	IWin:Bloodthirst()
	IWin:UpdateRageReservationForSpell("Bloodthirst", "cooldown")
	IWin:Revenge()
	IWin:UpdateRageReservationForSpellRevenge()
	IWin:SunderArmorFirstStack()
	IWin:BattleShoutFaded()
	IWin:UpdateRageReservationForSpell("Battle Shout", "buff", "player")
	IWin:SunderArmor()
	IWin:UpdateRageReservationForSpell("Sunder Armor", "nocooldown")
	IWin:BerserkerRage()
	IWin:Cleave()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                               
        _                                   __ _         _                                _   
       | |                                 / /(_)       | |                              | |  
   ___ | |__    __ _  _ __  __ _   ___    / /  _  _ __  | |_  ___  _ __  ___  ___  _ __  | |_ 
  / __|| '_ \  / _` || '__|/ _` | / _ \  / /  | || '_ \ | __|/ _ \| '__|/ __|/ _ \| '_ \ | __|
 | (__ | | | || (_| || |  | (_| ||  __/ / /   | || | | || |_|  __/| |  | (__|  __/| |_) || |_ 
  \___||_| |_| \__,_||_|   \__, | \___|/_/    |_||_| |_| \__|\___||_|   \___|\___|| .__/  \__|
                            __/ |                                                 | |         
                           |___/                                                  |_|         ]]--
SLASH_ICHASE1 = '/ichase'
function SlashCmdList.ICHASE()
	IWin:TargetEnemy()
	IWin:Charge()
	IWin:Intercept()
	IWin:Hamstring()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                               
  _         _                                   _   
 (_)       | |                                 | |  
  _  _ __  | |_  ___  _ __  _ __  _   _  _ __  | |_ 
 | || '_ \ | __|/ _ \| '__|| '__|| | | || '_ \ | __|
 | || | | || |_|  __/| |   | |   | |_| || |_) || |_ 
 |_||_| |_| \__|\___||_|   |_|    \__,_|| .__/  \__|
                                        | |         
                                        |_|             
]]--
SLASH_IKICK1 = '/ikick'
function SlashCmdList.IKICK()
	IWin:TargetEnemy()
	IWin:ShieldBash()
	IWin:Pummel()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                               
                  _                              
                 | |                             
  ____ ___  _ __ | | __  _ __  __ _   __ _   ___ 
 |_  // _ \| '__|| |/ / | '__|/ _` | / _` | / _ \
  / /|  __/| |   |   <  | |  | (_| || (_| ||  __/
 /___|\___||_|   |_|\_\ |_|   \__,_| \__, | \___|
                                      __/ |      
                                     |___/           
]]--
SLASH_IFEARDANCE1 = '/ifeardance'
function SlashCmdList.IFEARDANCE()
	IWin:TargetEnemy()
	IWin:BerserkerRageImmune()
	IWin:StartAttack()
end

--[[                                                                                                                                                                                                                                 _                        _   
 | |                      | |  
 | |_  __ _  _   _  _ __  | |_ 
 | __|/ _` || | | || '_ \ | __|
 | |_| (_| || |_| || | | || |_ 
  \__|\__,_| \__,_||_| |_| \__|                                                                      
]]--
SLASH_ITAUNT1 = '/itaunt'
function SlashCmdList.ITAUNT()
	IWin:TargetEnemy()
	IWin:Taunt()
	IWin:MockingBlow()
	IWin:StartAttack()
end
