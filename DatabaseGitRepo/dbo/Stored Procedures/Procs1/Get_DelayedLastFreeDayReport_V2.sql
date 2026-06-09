/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_DelayedLastFreeDayReport_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_DelayedLastFreeDayReport_V2]
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT C.CustName,OH.OrderNo,RT.OrderKey,RT.OrderDetailKey ,RT.RouteKey,L.LegID,
		Sour.AddrName AS FromLocation,Dst.AddrName AS ToLocation,RT.IsEmpty, RT.PickupDateFrom,
		RT.PickupDateTo,RT.DeliveryDateFrom,RT.DeliveryDateTo,OD.ContainerNo,
		RT.ActualDeparture as ActualPickup, RT.ActualArrival As ActualDelivery,
		case when RT.ActualDeparture is null then 'Not Picked' else 'Not Delivered' end as Remarks,
		case when RT.ActualDeparture is null then DATEDIFF(d,isnull(RT.pickupDateTo,RT.PickupDateFrom), GETDATE()) else 0 end as DelayedPickupDays,
		OD.LastFreeDay,
		case when RT.ActualArrival is null then  DATEDIFF(d,isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom), GETDATE()) else 0 end as DelayedDeliveryDays,
		 DATEDIFF(d,OD.LastFreeDay, GETDATE()) as DelayedDays
		from OrderDetail OD  WITH (NOLOCK)
		inner join Routes RT WITH (NOLOCK) on OD.OrderDetailKey = RT.OrderDetailKey
		inner join OrderDetailStatus OS WITH (NOLOCK) on OD.Status = OS.Status
		INNER JOIN dbo.OrderHeader OH	WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		INNER JOIN dbo.Customer C		WITH (NOLOCK) ON C.CustKey=OH.CustKey
		INNER JOIN dbo.Leg L			WITH (NOLOCK) ON L.LegKey=RT.LegKey
		INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
		LEFT JOIN  dbo.[Address] Sour	WITH (NOLOCK) ON Sour.AddrKey=RT.SourceAddrKey
		LEFT JOIN  dbo.[Address] Dst	WITH (NOLOCK) ON Dst.AddrKey=RT.DestinationAddrKey
		where OD.LastFreeDay<= GETDATE() and RT.Status < 5
		Order by OrderKey, OrderDetailKey, RouteKey
		FOR JSON PATH;

		SET @Status=1
		SET @Reason='Success'

END