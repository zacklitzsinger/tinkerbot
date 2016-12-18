
require( GetScriptDirectory().."/util" )
require( GetScriptDirectory().."/tinker_util" )

-- Tinker should generally lane until he gets his boots of travels
-- and then leave to gank or push.
function GetDesire()
  local npcBot = GetBot();
  -- If we are low on health, retreat no matter what.
  if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.25) then
    return BOT_MODE_DESIRE_VERYHIGH;
  end
  -- If we are in fountain and still healing
  if (InFountain() and (
    npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.9 or
    npcBot:GetMana() / npcBot:GetMaxMana() < 0.9
  ))
  then
    return BOT_MODE_DESIRE_VERYHIGH;
  end
  -- Stay out of tower range if possible
  if (IsTowerAttackingMe()) then
    return BOT_MODE_DESIRE_VERYHIGH;
  end
  -- If we are running out of mana and we are tower pushing, we should retreat to heal up
  if (
    (TinkerCanUseTravels() or TinkerCanRearmAndUseTravels()) and not
    TinkerHasManaToMarchAndTeleport()
  )
  then
    return BOT_MODE_DESIRE_VERYHIGH;
  end
  return BOT_MODE_DESIRE_NONE;
end

function Think()
  local npcBot = GetBot();
  if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
		return;
	end;

  local targetLocation = GetLocationAlongLane(LANE_MID, 0);
  TinkerMoveToLocation(targetLocation);
end

function IsTowerAttackingMe()
  local npcBot = GetBot();
  local NearbyTowers = npcBot:GetNearbyTowers(1000,true);
  if(#NearbyTowers > 0) then
    for _,tower in pairs( NearbyTowers)
    do
      if(GetUnitToUnitDistance(tower,npcBot) < 900) then
        return true;
      end
    end
  end
  return false;
end

function InFountain()
  local npcBot = GetBot();
  local targetLocation = GetLocationAlongLane(LANE_MID, 0);
  return (GetUnitToLocationDistance(npcBot, targetLocation) < 200)
end
