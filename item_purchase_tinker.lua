
-- Attach to global so reloading scripts doesn't recreate the table and
-- start buying items from the start.
if ( _G.tableItemsToBuy == nil ) then
	_G.tableItemsToBuy = {
					"item_tango",
					"item_mantle",
					"item_circlet",
	        "item_recipe_null_talisman",
					"item_bottle",
					"item_boots",
	        "item_recipe_travel_boots",
	        "item_soul_ring",
	        "item_blink",
	        "item_staff_of_wizardry",
	        "item_recipe_dagon",
					"item_sheepstick",
				};
end


----------------------------------------------------------------------------------------------------

function ItemPurchaseThink()

	if ( #_G.tableItemsToBuy == 0 )
	then
		npcBot:SetNextItemPurchaseValue( 0 );
		return;
	end

	local sNextItem = _G.tableItemsToBuy[1];
	local npcBot = GetBot();

	npcBot:SetNextItemPurchaseValue( GetItemCost( sNextItem ) );

	if ( npcBot:GetGold() >= GetItemCost( sNextItem ) )
	then
		npcBot:Action_PurchaseItem( sNextItem );
		table.remove( _G.tableItemsToBuy, 1 );
	end

end

----------------------------------------------------------------------------------------------------
