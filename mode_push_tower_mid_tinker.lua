
require( GetScriptDirectory().."/util" )
require( GetScriptDirectory().."/tinker_util" )

-- Tinker should generally lane until he gets his boots of travels
-- and then leave to gank or push.
function GetDesire()
  TinkerPushDesireForLane(LANE_MID);
end

function Think()
  TinkerPushLane(LANE_MID);
end
