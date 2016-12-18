
require( GetScriptDirectory().."/util" )

-- Tinker should generally lane until he gets his boots of travels
-- and then leave to gank or push.
function GetDesire()
  local npcBot = GetBot();
  if (printed == nil ) then
    -- PrintObject( npcBot:GetPlayer():GetAssignedHero() );
    -- for itemSlot=0,6 do
    --   local item = npcBot:GetItemInSlot(itemSlot);
    --   if (item ~= nil)
    --   then
    --     PrintObject( item );
    --   end
    -- end
    printed = true;
  end

  -- Actual laning logic
  -- Rune logic seems broken, so for the time being, lower desire to
  -- lane around rune times if we have bottle.
  if (DotaTime() < 0 or DotaTime() % 120 > 110 and ItemInInventory( "item_bottle" ))
  then
    return BOT_MODE_DESIRE_LOW;
  end
  -- When we get boots of travel, the laning phase is over
  if (not ItemInInventory( "item_travel_boots" )) then
    return BOT_MODE_DESIRE_HIGH;
  end
  return BOT_MODE_DESIRE_NONE;
end
