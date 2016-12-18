require( GetScriptDirectory().."/util" )

function TinkerPushDesireForLane(lane)
  local npcBot = GetBot();
  local creepEq = FindCreepEquilibrium(lane, 0)
  if (ItemInInventory( "item_travel_boots") and creepEq ~= nil) then
    -- Assume area is dangerous if there might be heroes nearby
    local chance = (GetUnitPotentialValue(true, 1500, creepEq) / 255);
    print("likelihood: " .. chance);
    return RemapValClamped(1 - chance, 0.0, 1.0, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_HIGH)
  end
  return BOT_MODE_DESIRE_NONE;
end

-- Tinker moves in a strange way. He wants to use Boots of Travel to go to
-- locations that are far away and walk to locations that are near. If he runs
-- out of mana, he should move back to base.
function TinkerMoveToLocation(loc)
  local npcBot = GetBot();
  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );
  local itemTravelBoots = GetItemByName( "item_travel_boots" );
  local itemBlink = GetItemByName( "item_blink" );

  if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
		return;
	end;

  local dist = GetUnitToLocationDistance(npcBot, loc);
  if (TinkerCanUseTravels() and
    dist >= 1500
  )
  then
    -- This should make sure not to use it on a creep likely to die...
    npcBot:Action_UseAbilityOnLocation(itemTravelBoots, loc);
  elseif (
    TinkerCanRearmAndUseTravels() and
    dist >= 1500 and
    not itemTravelBoots:IsFullyCastable()
  )
  then
    npcBot:Action_UseAbility(abilityRearm);
  else
    if (itemBlink ~= nil and itemBlink:IsFullyCastable()) then
      npcBot:Action_UseAbilityOnLocation(itemBlink, loc);
    end
    npcBot:Action_MoveToLocation(loc);
  end
end

function TinkerCanUseTravels()
  return (
    ItemInInventory( "item_travel_boots" ) and
    GetItemByName( "item_travel_boots" ):IsFullyCastable()
  )
end

function TinkerCanRearmAndUseTravels()
  local npcBot = GetBot();
  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );
  return (
    ItemInInventory( "item_travel_boots" ) and
    abilityRearm:IsFullyCastable() and
    TinkerHasManaToTeleport()
  )
end

function TinkerHasManaToTeleport()
  local npcBot = GetBot();
  local itemTravelBoots = GetItemByName( "item_travel_boots" );
  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );
  local manaCost = itemTravelBoots:GetManaCost();
  if (itemTravelBoots:GetCooldownTimeRemaining() > 0) then
    manaCost = manaCost + abilityRearm:GetManaCost();
  end
  return (npcBot:GetMana() >= manaCost)
end

function TinkerHasManaToMarchAndTeleport()
  local npcBot = GetBot();
  local itemTravelBoots = GetItemByName( "item_travel_boots" );
  local abilityMarch = npcBot:GetAbilityByName( "tinker_march_of_the_machines" );
  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );
  local manaCost = itemTravelBoots:GetManaCost() + abilityMarch:GetManaCost();
  if (itemTravelBoots:GetCooldownTimeRemaining() > 0) then
    manaCost = manaCost + abilityRearm:GetManaCost();
  end
  return (npcBot:GetMana() >= manaCost)
end

-- Orders Tinker to push a given lane
function TinkerPushLane(lane)
  local npcBot = GetBot();
  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );

  if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
		return;
	end;

  local loc = FindCreepEquilibrium(lane, -0.03);
  if (loc ~= nil) then
    local dist = GetUnitToLocationDistance(npcBot, loc);
    if (dist <= 600) then
      local creeps = npcBot:GetNearbyCreeps(1000, true);
      ConsiderPushCreepwave();
    else
      TinkerMoveToLocation(loc);
    end
  end
end

-- Called once Tinker knows he needs to push a creepwave, but needs
--  to figure out the best manner to do so.
function ConsiderPushCreepwave()
  local npcBot = GetBot();
  local abilityMarch = npcBot:GetAbilityByName( "tinker_march_of_the_machines" );
  local marchCastRange = abilityMarch:GetCastRange();
  local marchRadius = 900; -- TODO Don't hard code.

  local abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );

  local creeps = npcBot:GetNearbyCreeps(1000, true);
  if (#creeps == 0) then return end
  if (#creeps <= 2) then
    local loc = FindCreepEquilibrium(LANE_TOP, 0);
    if (GetUnitToLocationDistance(npcBot, loc) > 200)
    then
      npcBot:Action_MoveToLocation(loc);
    elseif (npcBot:GetAttackTarget() == nil )
    then
      npcBot:Action_AttackUnit(FindCreepToLastHit(1000),true);
      return
    end
  end
  -- else, 3 or more creeps
  if (abilityMarch:IsFullyCastable()) then
    local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), marchCastRange, marchRadius, 0, 0 );
    npcBot:Action_UseAbilityOnLocation(abilityMarch, locationAoE.targetloc);
  elseif (abilityRearm:IsFullyCastable() and abilityMarch:IsTrained() and abilityMarch:GetCooldownTimeRemaining() > 0) then
    npcBot:Action_UseAbility(abilityRearm);
  elseif (npcBot:GetAttackTarget() == nil ) then
    npcBot:Action_AttackUnit(creeps[1],true);
  end
end
