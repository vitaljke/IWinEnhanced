--[[
#########################################
# IWinEnhanced Discord Agamemnoth#5566  #
################ Enhance ################
#  IWin by Atreyyo @ VanillaGaming.org  #
#########################################
]]--

---- Loading ----
if UnitClass("player") == "Warrior" then
	IWin = CreateFrame("frame",nil,UIParent)
	IWin.t = CreateFrame("GameTooltip", "IWin_T", UIParent, "GameTooltipTemplate")
	IWin_Settings = {
		["dodge"] = 0,
		["rageTimeToReserveBuffer"] = 1.5,
		["ragePerSecondPrediction"] = 10, -- change it to match your gear and buffs
		["reservedRage"] = 0,
	}
end

---- Event Register ----
IWin:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
IWin:RegisterEvent("CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF")
IWin:RegisterEvent("ADDON_LOADED")
IWin:SetScript("OnEvent", function()
	if event == "ADDON_LOADED" and arg1 == "IWinEnhanced" then
		DEFAULT_CHAT_FRAME:AddMessage("|cff0066ff IWinEnhanced system loaded.|r")
		IWin:UnregisterEvent("ADDON_LOADED")
	elseif event == "CHAT_MSG_COMBAT_SELF_MISSES" then
		if string.find(arg1,"dodge") then
			IWin_Settings["dodge"] = GetTime()
		end		
	elseif event == "CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF" then
		if string.find(arg1,"dodge") then
			IWin_Settings["dodge"] = GetTime()
		end
	end
end)

---- Spell data ----
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
	["Mortal Strike"] = 30,
	["Bloodthirst"] = 30,
	["Shield Slam"] = 20,
	["Whirlwind"] = 25,
	["Heroic Strike"] = 15 - IWin:GetTalentRank(1, 1),
	["Cleave"] = 20,
	["Execute"] = 15 - IWin:GetExecuteCostReduction(),
	["Rend"] = 10,
	["Thunder Clap"] = 20 - IWin:GetThunderClapCostReduction(),
	["Bloodrage"] = - 10,
	["Sunder Armor"] = 15 - IWin:GetTalentRank(3, 10),
	["Revenge"] = 5,
	["Overpower"] = 5,
	["Shield Bash"] = 10,
	["Pummel"] = 10,
	["Mocking Blow"] = 10,
	["Disarm"] = 20,
	["Charge"] = - 12 - IWin:GetTalentRank(1, 4) * 3,
	["Intercept"] = 10,
	["Demoralizing Shout"] = 10,
	["Battle Shout"] = 10,
	["Slam"] = 15,
	["Shield Block"] = 10,
	["Berserker Rage"] = 0 - IWin:GetTalentRank(2, 15) * 5,
}

IWin_Stance = {
	[1] = "Battle",
	[2] = "Defensive",
	[3] = "Berserker",
}

---- Functions ----
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
	end
	return 0
end

function IWin:IsBuffActive(unit, spell)
	local stack = IWin:GetBuffStack(unit, spell)
	return stack ~= 0
end

function IWin:GetActionSlot(action)
	for slot = 1, 100 do
		IWin_T:SetOwner(UIParent, "ANCHOR_NONE")
		IWin_T:ClearLines()
		IWin_T:SetAction(slot)
		local actionslot = IWin_TTextLeft1:GetText()
		IWin_T:Hide()
		if actionslot == action then
			return slot;
		end
	end
	return 2;
end

function IWin:IsOnCooldown(spell)
	if spell then
		local spellID = 1
		local bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		while (bookspell) do	
			if spell == bookspell then
				if GetSpellCooldown(spellID, "BOOKTYPE_SPELL") == 0 then
					return false
				else
					return true
				end
			end
		spellID = spellID + 1
		bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		end
	end
end

function IWin:GetCooldownRemaining(spell)
	if spell then
		local spellID = 1
		local bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		while (bookspell) do	
			if spell == bookspell then
				return GetSpellCooldown(spellID, "BOOKTYPE_SPELL")
			end
		spellID = spellID + 1
		bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
		end
	end
end

function IWin:IsSpellLearnt(spell)
	local spellID = 1
	local bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
	while (bookspell) do
		if bookspell == spell then
			return true
		end
		spellID = spellID + 1
		bookspell = GetSpellName(spellID, "BOOKTYPE_SPELL")
	end
	return false
end

function IWin:IsOverpowerAvailable()
	local overpowerTimeRemaining = GetTime() - IWin_Settings["dodge"]
 	return overpowerTimeRemaining < 5
 end

function IWin:IsStanceActive(stance)
	local _,_,isActive = GetShapeshiftFormInfo(2)
	return stance == IWin_Stance[isActive]
end

function IWin:IsExecutePhase()
	return (UnitHealth("target") / UnitHealthMax("target")) <= 0.2
end

function IWin:IsRageAvailable(spell)
	local rageRequired = IWin_RageCost[spell] + IWin_Settings["reservedRage"]
	return UnitMana("player") >= rageRequired
end

function IWin:IsInMeleeRange()
	return CheckInteractDistance("target", 3) ~= nil
end

function IWin:GetStanceSwapRageRetain()
	return IWin:GetTalentRank(1, 5) * 5
end

function IWin:GetStanceSwapMaxRageLoss(rage)
	return rage <= UnitMana("player") - IWin:GetStanceSwapRageRetain()
end

function IWin:GetRageToReserve(spell, trigger, unit)
	local spellTriggerTime = 0
	if trigger == "cooldown" then
		spellTriggerTime = IWin:GetCooldownRemaining(spell)
	elseif trigger == "buff" then
		spellTriggerTime = IWin:GetBuffRemaining(unit, spell)
	end
	local reservedRageTime = IWin_Settings["reservedRage"] / IWin_Settings["ragePerSecondPrediction"]
	local timeToReserveRage = math.max(0, spellTriggerTime - IWin_Settings["rageTimeToReserveBuffer"] - reservedRageTime)
	return math.max(0, IWin_RageCost[spell] - IWin_Settings["ragePerSecondPrediction"] * timeToReserveRage)
end

function IWin:IsTimeToReserveRage(spell, trigger, unit)
	return IWin:GetRageToReserve(spell, trigger, unit) ~= 0
end

function IWin:SetReservedRage(spell, trigger, unit)
	IWin_Settings["reservedRage"] = IWin_Settings["reservedRage"] + IWin:GetRageToReserve(spell, trigger, unit)
end

---- Actions ----
function IWin:TargetEnemy()
	if not UnitExists("target") or UnitIsDead("target") or UnitIsFriend("target", "player") then
		TargetNearestEnemy()
	end
end

function IWin:StartAttack()
	if not IWin_Settings["AttackSlot"] then
		IWin_Settings["AttackSlot"] = IWin:GetActionSlot("Attack")
	end
	if not IsCurrentAction(IWin_Settings["AttackSlot"]) then 
		UseAction(IWin_Settings["AttackSlot"]) 
	end
end

function IWin:BattleShoutFaded()
	if IWin:IsSpellLearnt("Battle Shout") and not IWin:IsBuffActive("player","Battle Shout") and IWin:IsRageAvailable("Battle Shout") then 
		CastSpellByName("Battle Shout")
	end
end

function IWin:BerserkerStanceInstance()
	if IsInInstance() and not IWin:IsStanceActive("Berserker") and IWin:GetStanceSwapMaxRageLoss(25) then
		CastSpellByName("Berserker Stance")
	end
end

function IWin:Bloodthirst()
	if IWin:IsSpellLearnt("Bloodthirst") and not IWin:IsOnCooldown("Bloodthirst") and IWin:IsRageAvailable("Bloodthirst") then
		CastSpellByName("Bloodthirst")
	end
end

function IWin:Charge()
	if IWin:IsSpellLearnt("Charge") and not IWin:IsOnCooldown("Charge") and not IWin:IsInMeleeRange() and not UnitAffectingCombat("player") then
		if not IWin:IsStanceActive("Battle") then
			CastSpellByName("Battle Stance")
		end
		CastSpellByName("Charge")
	end
end

function IWin:ChargeOpenWorld()
	if IWin:IsSpellLearnt("Charge") and not IWin:IsOnCooldown("Charge") and not IWin:IsInMeleeRange() and not UnitAffectingCombat("player") and not IsInInstance() then
		if not IWin:IsStanceActive("Battle") and (IWin:GetStanceSwapMaxRageLoss(25) or UnitIsPVP("target")) then
			CastSpellByName("Battle Stance")
		end
		CastSpellByName("Charge")
	end
end

function IWin:Execute()
	if IWin:IsSpellLearnt("Execute") then
		if IWin:IsExecutePhase() and IWin:IsRageAvailable("Execute") then 
			CastSpellByName("Execute")
		end
	end
end

function IWin:HeroicStrikeDump()
	if IWin:IsSpellLearnt("Heroic Strike") and IWin:IsRageAvailable("Heroic Strike") and not IWin:IsExecutePhase() then
		CastSpellByName("Heroic Strike")
	end
end

function IWin:Overpower()
	if IWin:IsSpellLearnt("Overpower") and IWin:IsOverpowerAvailable() and not IWin:IsOnCooldown("Overpower") and IWin:IsRageAvailable("Overpower") then
		if not IWin:IsStanceActive("Battle") and (IWin:GetStanceSwapMaxRageLoss(25) or UnitIsPVP("target")) then
			CastSpellByName("Battle Stance")
		end
		CastSpellByName("Overpower")
	end
end

function IWin:Whirlwind()
	if IWin:IsSpellLearnt("Whirlwind") then
		if IWin:IsTimeToReserveRage("Whirlwind", "cooldown") and not IWin:IsStanceActive("Berserker") then
			CastSpellByName("Berserker Stance")
		end
		if not IWin:IsOnCooldown("Whirlwind") and IWin:IsRageAvailable("Whirlwind") and IWin:IsInMeleeRange() then 
			CastSpellByName("Whirlwind")
		end
	end
end

---- idebug button ----
SLASH_IDEBUG1 = '/idebug'
function SlashCmdList.IDEBUG()
	local effect, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", 1)
	DEFAULT_CHAT_FRAME:AddMessage(effect .. "?" .. rank .. "?" .. texture .. "?" .. stacks .. "?" .. dtype .. "?" .. duration .. "?" .. timeleft)
end

---- idps button ----
SLASH_IDPS1 = '/idps'
function SlashCmdList.IDPS()
	IWin_Settings["reservedRage"] = 0
	IWin:TargetEnemy()
	IWin:BattleShoutFaded()
	IWin:SetReservedRage("Battle Shout", "buff", "player")
	IWin:Overpower()
	IWin:Execute()
	IWin:SetReservedRage("Execute", "cooldown")
	IWin:Whirlwind()
	IWin:SetReservedRage("Whirlwind", "cooldown")
	IWin:HeroicStrikeDump()
	IWin:ChargeOpenWorld()
	IWin:StartAttack()
end

---- ichase button ----
SLASH_ICHASE1 = '/ichase'
function SlashCmdList.ICHASE()
	IWin:Charge()

end

--[[
-- itank button --
SLASH_ITANK1 = '/itank'
function SlashCmdList.ITANK()
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
		if not IWin_Settings["AttackSlot"] then IWin_Settings["AttackSlot"] = IWin:GetActionSlot("Attack") end
		if not IsCurrentAction(IWin_Settings["AttackSlot"]) then 
			UseAction(IWin_Settings["AttackSlot"]) 
		end
		local _,_,isActive = GetShapeshiftFormInfo(2)
		if isActive then -- if prot stance
			if IWin:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not IWin:OnCooldown("Bloodrage") then 
				c("Bloodrage") 
				return
			end
			if IWin:GetSpell("Revenge") and not IWin:OnCooldown("Revenge") and UnitMana("player") > 4 then
				c("Revenge")
				return
			end
			if IWin:GetSpell("Bloodthirst") and not IWin:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
				c("Bloodthirst")
				return
			end
			if not IWin:GetBuff("target","Sunder Armor") then
				c("Sunder Armor")
			else
				if IWin:GetBuff("target","Sunder Armor",1) < 5 then
					c("Sunder Armor")
				end
			end
			if IWin:GetSpell("Heroic Strike") and UnitMana("player") > 30 then
				c("Heroic Strike")
			end
			return
		end
		-- interrupt function, turned off for now
		if IWin_Settings["interrupt"][UnitName("target")] ~= nil and (GetTime()-IWin_Settings["interrupt"][UnitName("target")]) < 2 and CheckInteractDistance("target", 1 ) ~= nil then
			if IWin:GetSpell("Pummel") and not IWin:OnCooldown("Pummel") then
				c("Berserker Stance")
				c("Pummel")
				return
			end
		end
		-- auto use cds, turned off for now
		if IWin:IsBoss(UnitName("target")) and CheckInteractDistance("target", 1 ) ~= nil and (UnitHealth("target")/UnitHealthMax("target")) < 0.95 then 
			if IWin:GetSpell("Death Wish") and not IWin:OnCooldown("Death Wish") then
				c("Death Wish")
			end
		end
		if (UnitHealth("target") / UnitHealthMax("target")) <= 0.2 and UnitMana("player") > 9 then 
			c("Execute") 
			return
		end
		
		if GetTime() - IWin_Settings["dodge"] < 5 then
			if IWin:GetSpell("Overpower") and not IWin:OnCooldown("Overpower") and UnitMana("player") < 30 and UnitMana("player") > 4 then
				c("Battle Stance");
				c("Overpower")
			end
		end
		c("Berserker Stance")
		if IWin:GetSpell("Battle Shout") and not IWin:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
		if IWin:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not IWin:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		if IWin:GetSpell("Bloodthirst") and not IWin:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
			c("Bloodthirst")
			return
		elseif IWin:GetSpell("Whirlwind") and not IWin:OnCooldown("Whirlwind") and UnitMana("player") > 29 then 
			if CheckInteractDistance("target", 1) ~= nil then 
				c("Whirlwind") 
				return
			end
		elseif IWin:GetSpell("Heroic Strike") and UnitMana("player") > 29 then
				c("Heroic Strike")
		end
	end
end

-- iturtle button --
SLASH_ITURTLE1 = '/iturtle'
function SlashCmdList.ITURTLE()
	local c = CastSpellByName
	if UnitClass("player") == "Warrior" then 
		if not IWin_Settings["AttackSlot"] then IWin_Settings["AttackSlot"] = IWin:GetActionSlot("Attack") end
		if not IsCurrentAction(IWin_Settings["AttackSlot"]) then 
			UseAction(IWin_Settings["AttackSlot"]) 
		end
		local _,_,isActive = GetShapeshiftFormInfo(2)
		if isActive then -- if prot stance
			if IWin:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not IWin:OnCooldown("Bloodrage") then 
				c("Bloodrage") 
				return
			end
			if IWin:GetSpell("Revenge") and not IWin:OnCooldown("Revenge") and UnitMana("player") > 4 then
				c("Revenge")
				return
			end
			if IWin:GetSpell("Bloodthirst") and not IWin:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
				c("Bloodthirst")
				return
			end
			if not IWin:GetBuff("target","Sunder Armor") then
				c("Sunder Armor")
			else
				if IWin:GetBuff("target","Sunder Armor",1) < 5 then
					c("Sunder Armor")
				end
			end
			if IWin:GetSpell("Heroic Strike") and UnitMana("player") > 30 then
				c("Heroic Strike")
			end
			return
		end
		-- interrupt function, turned off for now
		if IWin_Settings["interrupt"][UnitName("target")] ~= nil and (GetTime()-IWin_Settings["interrupt"][UnitName("target")]) < 2 and CheckInteractDistance("target", 1 ) ~= nil then
			if IWin:GetSpell("Pummel") and not IWin:OnCooldown("Pummel") then
				c("Berserker Stance")
				c("Pummel")
				return
			end
		end
		-- auto use cds, turned off for now
		if IWin:IsBoss(UnitName("target")) and CheckInteractDistance("target", 1 ) ~= nil and (UnitHealth("target")/UnitHealthMax("target")) < 0.95 then 
			if IWin:GetSpell("Death Wish") and not IWin:OnCooldown("Death Wish") then
				c("Death Wish")
			end
		end
		if (UnitHealth("target") / UnitHealthMax("target")) <= 0.2 and UnitMana("player") > 9 then 
			c("Execute") 
			return
		end
		
		if GetTime() - IWin_Settings["dodge"] < 5 then
			if IWin:GetSpell("Overpower") and not IWin:OnCooldown("Overpower") and UnitMana("player") < 30 and UnitMana("player") > 4 then
				c("Battle Stance");
				c("Overpower")
			end
		end
		c("Berserker Stance")
		if IWin:GetSpell("Battle Shout") and not IWin:GetBuff("player","Battle Shout") then 
			if UnitExists("target") and (UnitHealth("target") / UnitHealthMax("target")) > 0.2 and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			elseif not UnitExists("target") and UnitMana("player") > 9 then
				c("Battle Shout") 
				return
			end
		end
		if IWin:GetSpell("Bloodrage") and UnitAffectingCombat("player") and UnitMana("player") < 40 and not IWin:OnCooldown("Bloodrage") then 
			c("Bloodrage") 
			return
		end
		if IWin:GetSpell("Bloodthirst") and not IWin:OnCooldown("Bloodthirst") and UnitMana("player") > 29 then
			c("Bloodthirst")
			return
		elseif IWin:GetSpell("Whirlwind") and not IWin:OnCooldown("Whirlwind") and UnitMana("player") > 29 then 
			if CheckInteractDistance("target", 1) ~= nil then 
				c("Whirlwind") 
				return
			end
		elseif IWin:GetSpell("Heroic Strike") and UnitMana("player") > 29 then
				c("Heroic Strike")
		end
	end
end
]]--