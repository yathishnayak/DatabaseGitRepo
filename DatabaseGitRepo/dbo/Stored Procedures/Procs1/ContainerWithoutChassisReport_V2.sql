/*
	DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 0
	SET @JSONString ='{"CsrKey":0, "CustKey":0,"DriverKey":0,"OrderNo": ""}'
 
	EXEC [ContainerWithoutChassisReport_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason 
*/
CREATE PROCEDURE [dbo].[ContainerWithoutChassisReport_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;


		DECLARE @CSRKey				INT=0,
			@CustKey				INT=0,	
			@DriverKey				INT=0,
			@OrderNo			VARCHAR(50)='';

			IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

		

	SELECT @CSRKey = CsrKey, @CustKey = CustKey, @DriverKey = DriverKey, @OrderNo = OrderNo
	from OPENJSON(@JSONString,'$')
	with (
			CsrKey		 INT				'$.CsrKey',
			CustKey		 INT				'$.CustKey',
			DriverKey	INT					'$.DriverKey',
			OrderNo		 VARCHAR(50)	     '$.OrderNo'
		 )
	select  top 50 OD.ContainerNo, OH.OrderNo, OH.OrderDate, OT.OrderType, C.CsrName, ODs.Description as StatusName,
	od.OpenLegs, od.CurrentLegNo, od.TotalLegs, CU.CustID, CU.CustName,
	L.LegID, RT.LegNo,
	RT.PickupDateFrom, Rt.PickupDateTo, Rt.DeliveryDateFrom, RT.DeliveryDateTo,
	D.DriverID, d.FirstName + ' ' + isnull(d.LastName,'') as DriverName
	from Routes RT WITH (NOLOCK) 
	inner join OrderDetail OD WITH (NOLOCK)  on RT.OrderDetailKey = OD.OrderDetailKey and Rt.RouteKey = OD.CurrentRouteKey
	inner join OrderHeader OH WITH (NOLOCK)  on OD.OrderKey = OH.OrderKey
	inner join OrderType OT WITH (NOLOCK)  on OH.OrderTypeKey = OH.OrderTypeKey
	inner join ContainerSize CS WITH (NOLOCK)  on Od.ContainerSizeKey = Cs.ContainerSizeKey
	inner join CSR C WITH (NOLOCK)  on OH.CsrKey = C.CsrKey
	inner join OrderDetailStatus ODS WITH (NOLOCK)  on OD.Status = ODS.Status
	inner join Leg L WITH (NOLOCK)  on RT.LegKey = L.LegKey
	inner join Customer CU WITH (NOLOCK)  on OH.CustKey = CU.CustKey
	left join Driver D  WITH (NOLOCK) on Rt.DriverKey = D.DriverKey
	where RT.ChassisKey is null and
	( isnull(@CSRKey,0) = 0 OR OH.CsrKey = @CSRKey) and
	( ISNULL(@CustKey,0) = 0 OR OH.CustKey = @CustKey ) and
	( isnull(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey )  and
	( ISNULL(@OrderNo,'') = '' OR OH.OrderNo like '%' + @OrderNo + '' ) 
	FOR JSON PATH

	SET @Status=1;
	SEt @Reason='Success';
   
END