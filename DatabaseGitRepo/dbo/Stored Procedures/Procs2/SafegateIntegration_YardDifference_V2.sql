/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"ContainerNo" : "FSCU4959760"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [SafegateIntegration_YardDifference_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[SafegateIntegration_YardDifference_V2] -- SafegateIntegration_YardDifference_V2 512,null
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	DECLARE @ContainerNo			varchar(20)

	Select @ContainerNo = ContainerNo
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo				varchar(20)		'$.ContainerNo'
		)

	SELECT * FROM 
	(SELECT RT.RouteKey,RT.LegNo, PU.ShortName PickupYard, DEL.ShortName DeliveryYard, od.ContainerNo, oh.OrderNo,L.LegId,
			RT.SFGYardDiffLogKeyPickup, RT.SFGYardChangePickup, RT.SFGYardChangePickupMessage, RT.YardIDPickupBeforeUpdate,
			RT.SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, RT.SFGYardChangeDeliveryMessage, RT.YardIDDeliveryBeforeUpdate
		FROM OrderHeader oh WITH (NOLOCK)
		INNER JOIN OrderDetail od WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
		INNER JOIN ROUTES RT WITH (NOLOCK) ON od.OrderDetailKey = RT.OrderDetailKey
		INNER JOIN LEG L WITH (NOLOCK) ON L.LegKey=RT.LegKEy
		LEFT JOIN Yard PU WITH (NOLOCK) ON Rt.SourceAddrKey = PU.AddrKey
		LEFT JOIN Yard DEL WITH (NOLOCK) ON RT.DestinationAddrKey = DEL.AddrKey
		where (YardIDPickupBeforeUpdate is not null) 
		AND
		((ISNULL(@ContainerNo,'')  <> '' AND od.ContainerNo LIKE '%' + @ContainerNo + '%') 
		OR 
		(ISNULL(@ContainerNo,'')  = '' AND od.Status = 7))
		UNION ALL 
		SELECT	RT.RouteKey,RT.LegNo, PU.ShortName PickupYard, DEL.ShortName DeliveryYard, od.ContainerNo, oh.OrderNo,L.LegId,
			RT.SFGYardDiffLogKeyPickup, RT.SFGYardChangePickup, RT.SFGYardChangePickupMessage, RT.YardIDPickupBeforeUpdate,
			RT.SFGYardDiffLogKeyDelivery, SFGYardChangeDelivery, RT.SFGYardChangeDeliveryMessage, RT.YardIDDeliveryBeforeUpdate
		FROM OrderHeader oh WITH (NOLOCK)
		INNER JOIN OrderDetail od WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
		INNER JOIN ROUTES RT WITH (NOLOCK) ON od.OrderDetailKey = RT.OrderDetailKey
		INNER JOIN LEG L WITH (NOLOCK) ON L.LegKey=RT.LegKEy
		LEFT JOIN Yard PU WITH (NOLOCK) ON Rt.SourceAddrKey = PU.AddrKey
		LEFT JOIN Yard DEL WITH (NOLOCK) ON RT.DestinationAddrKey = DEL.AddrKey
		where (YardIDDeliveryBeforeUpdate is not null) 
		AND
		((ISNULL(@ContainerNo,'')  <> '' AND od.ContainerNo LIKE '%' + @ContainerNo + '%') 
		OR 
		(ISNULL(@ContainerNo,'')  = '' AND od.Status = 7)))A ORDER BY ContainerNo
		FOR JSON PATH

		SET @Status=1
		SET @Reason='Success'
END