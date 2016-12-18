function ItemInInventory( item_name )
  return (GetItemByName( item_name ) ~= nil);
end

function GetItemByName( item_name )
  local npcBot = GetBot();
  for itemSlot=0,6 do
    local item = npcBot:GetItemInSlot(itemSlot);
    if (item ~= nil and item:GetName() == item_name)
    then
      return item
    end
  end
  return nil;
end

-- Finds the closest point to radiant base where there are enemy creeps visible
function FindCreepEquilibrium(lane, iDelta)
  local npcBot = GetBot();
  local topLocation = nil;
  local topCount = 0;
  for i=0,1,0.01 do
    local loc = GetLocationAlongLane(lane, i);
    local enemyAOE = npcBot:FindAoELocation( true, false, loc, 0, 200, 0, 0 );
    local creepCount = enemyAOE.count;
    if ( creepCount > topCount ) then
      topLocation = GetLocationAlongLane(lane, i + iDelta);
      topCount = creepCount;
    end
  end
  return topLocation;
end

-- Finds a good creep to last hit in the range
function FindCreepToLastHit(range)
  local npcBot = GetBot();
  if (npcBot:GetAttackTarget() ~= nil) then return nil end;
  local creeps = npcBot:GetNearbyCreeps(range, true);
  local lowest_hp = 100000;
  local weakest_creep = nil;
  for creep_k,creep in pairs(creeps)
  do
    if(creep:IsAlive()) then
      local creep_hp = creep:GetHealth();
      if(lowest_hp > creep_hp) then
        lowest_hp = creep_hp;
        weakest_creep = creep;
      end
    end
  end
  return weakest_creep;
end

function PrintObject( obj )
  for key,value in pairs(getmetatable(obj)) do
    for key2,value2 in pairs(value) do
      print("found member " .. key2 .. ", " .. tostring(value2));
    end
  end
end

function PrintObject2( obj )
  for key,value in pairs((obj)) do
    print("found member " .. key .. ", " .. tostring(value));
  end
end
