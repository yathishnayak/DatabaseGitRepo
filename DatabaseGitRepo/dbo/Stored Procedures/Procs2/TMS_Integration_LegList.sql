
CREATE proc [dbo].[TMS_Integration_LegList]
(
	@OrderTypeKey	smallint = 0
)
as
select LegKey, LegID, FromLocation, ToLocation,PickUpType
from Leg L with (nolock)
inner join LegType LT with (nolock) on L.LegTypeKey = LT.LegtypeKey
inner join PickUpType PT with (nolock) on L.PickupTypeKey = PT.PickupTypeKey
where LT.OrderTypeKey = @OrderTypeKey
order by L.LegID
For JSON PATH
