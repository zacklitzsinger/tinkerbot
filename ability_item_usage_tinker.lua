
require( GetScriptDirectory().."/util" )

----------------------------------------------------------------------------------------------------

castLaserDesire = 0;
castRocketsADesire = 0;
castMarchDesire = 0;
castRearmDesire = 0;
lastBottleTime = nil;

function ItemUsageThink()
  local npcBot = GetBot();

  if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
		return;
	end;

  itemBottle = GetItemByName("item_bottle");
  if (itemBottle ~= nil )
  then
    castBottleDesire = ConsiderBottle();
		if ( castBottleDesire > 0 ) then
      lastBottleTime = DotaTime();
			npcBot:Action_UseAbility( itemBottle );
		end
  end
end

function ConsiderBottle()
	local npcBot = GetBot();

	if (not itemBottle:IsFullyCastable()) then
		return BOT_ACTION_DESIRE_NONE;
	end

  -- TODO Fix this. Bad version of waiting for bottle charge to apply.
  if (
    lastBottleTime ~= nil and
    DotaTime() - lastBottleTime <= 2.5
  )
  then
    return BOT_ACTION_DESIRE_NONE;
  end

	if (npcBot:GetMana() < npcBot:GetMaxMana() ) then
		return BOT_ACTION_DESIRE_LOW;
	end

	return BOT_ACTION_DESIRE_NONE;

end

function AbilityUsageThink()

	local npcBot = GetBot();

	-- Check if we're already using an ability or channeling
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling()) then
		return;
	end;

	abilityLaser = npcBot:GetAbilityByName( "tinker_laser" );
	abilityRockets = npcBot:GetAbilityByName( "tinker_heat_seeking_missile" );
	abilityMarch = npcBot:GetAbilityByName( "tinker_march_of_the_machines" );
  abilityRearm = npcBot:GetAbilityByName( "tinker_rearm" );

	-- Consider using each ability
	castLaserDesire, castLaserTarget = ConsiderLaser();
	castRocketsDesire = ConsiderRockets();
	castMarchDesire, castMarchLocation = ConsiderMarch();
  castRearmDesire = ConsiderRearm();

	if ( castRocketsDesire > 0 )
	then
		npcBot:Action_UseAbility( abilityRockets );
		return;
	end

	if ( castLaserDesire > 0 )
	then
		npcBot:Action_UseAbilityOnEntity( abilityLaser, castLaserTarget );
		return;
	end

	if ( castMarchDesire > 0 )
	then
		npcBot:Action_UseAbilityOnLocation( abilityMarch, castMarchLocation );
		return;
	end

  if ( castRearmDesire > 0 )
	then
		npcBot:Action_UseAbility( abilityRearm );
		return;
	end

end

----------------------------------------------------------------------------------------------------

function CanCastLaserOnTarget( npcTarget )
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end


function CanCastRocketsOnTarget( npcTarget )
  local npcBot = GetBot();
	return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable() and GetUnitToUnitDistance(npcTarget, npcBot) < 2500;
end

----------------------------------------------------------------------------------------------------

function ConsiderLaser()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityLaser:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end;

	-- Get some of its values
	local nCastRange = abilityLaser:GetCastRange();
	local nDamage = abilityLaser:GetAbilityDamage();
  local nLevel = abilityLaser:GetLevel();

  if (
    npcBot:GetActiveMode() == BOT_MODE_LANING and
    (nLevel == 1 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.8 or
     nLevel == 2 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.7 or
     nLevel == 3 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.6 or
     nLevel == 4 and npcBot:GetMana() / npcBot:GetMaxMana() > 0.5
    )
  )
  then
    -- Find target to cast laser on
    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
    for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
  	do
			if ( CanCastLaserOnTarget( npcEnemy ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
  	end
  end

	-- If we're going after someone
	if (
     npcBot:GetActiveMode() == BOT_MODE_ATTACK or
     npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil )
		then
			if ( CanCastLaserOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

----------------------------------------------------------------------------------------------------

function ConsiderRockets()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityRockets:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE;
	end;

	-- Get some of its values
	local nRange = abilityRockets:GetSpecialValueInt( "heat_seeking_missile_radius");
	local nDamage = abilityRockets:GetAbilityDamage();

	-- If we're going after someone
	if (
     npcBot:GetActiveMode() == BOT_MODE_ATTACK or
     npcBot:GetActiveMode() == BOT_MODE_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 npcBot:GetActiveMode() == BOT_MODE_GANK or
		 npcBot:GetActiveMode() == BOT_MODE_DEFEND_ALLY )
	then
		local npcTarget = npcBot:GetTarget();

		if ( npcTarget ~= nil )
		then
			if ( CanCastRocketsOnTarget( npcTarget ) )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


----------------------------------------------------------------------------------------------------

function ConsiderMarch()

	local npcBot = GetBot();

	-- Make sure it's castable
	if ( not abilityMarch:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityMarch:GetCastRange();
  local nRadius = 900; --abilityMarch:GetSpecialValueInt( "march_of_the_machines_radius")

  -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
  if ( npcBot:GetActiveMode() == BOT_MODE_FARM or
     npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
     npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
     npcBot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOTTOM or
     npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
     npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
     npcBot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOTTOM )
  then
    local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );

    if ( locationAoE.count >= 3 )
    then
      return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
    end
  end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function ConsiderRearm ()
  -- local npcBot = GetBot();
  --
	-- -- Make sure it's castable
	-- if ( not abilityRearm:IsFullyCastable() ) then
	-- 	return BOT_ACTION_DESIRE_NONE;
	-- end
  --
  -- local nManaCost = abilityRearm:GetManaCost();
  -- local nCurrentMana = npcBot:GetMana();
  --
  -- if ( abilityLaser:GetCooldownTimeRemaining() > 0 or
  --   abilityRockets:GetCooldownTimeRemaining() > 0 or
  --   abilityMarch:GetCooldownTimeRemaining() > 0
  -- )
  -- then
  --   if ( nCurrentMana - nManaCost > 75 )
  --   then
  --     return BOT_ACTION_DESIRE_LOW;
  --   end
  -- end
  return BOT_ACTION_DESIRE_NONE
end
