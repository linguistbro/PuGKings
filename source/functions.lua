local function StripRealm(name)
    return strsplit("-", name)  -- returns just the player name
end

local function calculatePoints(amount, amountTable)
    for i = #amountTable, 1, -1 do
        if amount >= amountTable[i] then
            return i
        end
    end
    return 0
end

--- Calculates and applies points for players hit by a specific spell during a boss encounter
---@param spell any This is how you get the spell: sourceNpc = damageContainer:GetSpellSource(spellID) > source = damageContainer:GetActor(sourceNpc) > spell = source:GetSpell(spellID)
---@param raidComp table Raid roster to assign points to (normal comp or progress comp)
---@param spellName string Spell name as string
---@param amountTable table Points to be deducted or awarded based on damage amount
---@param bossID number ID of the boss for this encounter
---@param bossName string Name of the boss for this encounter
---@param awardPoints boolean Deduct or award points 
---@param reason string Reason shown to players
function PuGCalculateSpellDamageTakenPoints(spell, raidComp, spellName, amountTable, bossID, bossName, awardPoints, reason)
    local points = 0

    for playerName, amount in pairs(spell.targets) do
        points = calculatePoints(amount, amountTable)
        if points > 0 then
        if awardPoints == false then points = points * -1 end
            local strippedName = StripRealm(playerName)
            for _, player in ipairs(raidComp) do
                if StripRealm(player.name) == strippedName then
                    PuGAddPointEntry(player, bossID, bossName, reason .. (spellName .. " - " .. string.format("%.2fM", amount/1000000)), points)
                    if PuGAddonDebug then print(PuGAddonDebugPrefix .. player.name .. reason .. (spellName .. " - ".. string.format("%.2fM", amount/1000000)), points) end
                    break
                end
            end
        end
    end
end

--- Calculates and awards points for players who interrupted a specific spell during a boss encounter
---@param raidComp table Raid roster to assign points to (normal comp or progress comp)
---@param playerName string Name of the player that interrupted the spell
---@param spellName string Spell name as string
---@param amount number Times player has interrupted the spell
---@param bossID number ID of the boss for this encounter
---@param bossName string Name of the boss for this encounter
---@param pointFormula function Function to calculate the points 
function PuGCalculateInterruptPoints(raidComp, playerName, spellName, amount, bossID, bossName, pointFormula)
    local points = pointFormula(amount)
    for _, player in ipairs(raidComp) do
        if StripRealm(player.name) == StripRealm(playerName) then
            PuGAddPointEntry(player, bossID, bossName, "Interrupted " .. spellName .. " " .. amount .. " times", points)
            if PuGAddonDebug then print(PuGAddonDebugPrefix .. player.name .. " interrupted " .. spellName .. " " .. amount .. " times - " .. points .. " points") end
            break
        end
    end
end