/* 
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= '{"OrderDetailKey":168810}',
	@Status			BIT=0, @IsDebug		BIT = 1, @Reason			VARCHAR(100)=''
	EXec Dispatch_GetActions_Container @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Dispatch_GetActions_Container]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	Declare
		@OrderDetailKey		varchar(50) = ''	
		

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	SELECT 
		@OrderDetailKey		=	OrderDetailKey		
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			int		'$.OrderDetailKey'
	)

	--SELECT '@SortField' , @SortField

	SELECT top 1
		OD.ContainerNo, ODS.Description as ContainerDStatus, RS.Description as RouteDStatus, L.LegID, OH.CustKey, C.CustName AS Customer,
		D.FirstName+' '+D.LastName AS DriverName, CCK.ChassisCategory, OH.MarketLocationKey, ML.MarketLocation, CZ.Description AS ContainerSize,
		OH.BookingNo, OH.OrderNo,OH.BillOfLading,OH.SteamShipLineKey, SShL.LineName, OT.OrderType, OT.OrderTypeKey,
		OD.TMFCheckOff,OD.CTFCheckOff, 
		OD.IsTMFJCTPaid, OD.IsTMFCustomerPaid,
		OD.IsCTFJCTPaid, OD.IsCTFCustomerPaid,
		CS.IsEditable, D.TruckTypeKey, TT.TruckType,
		--****************Source Address***********
		SR.Address1 AS SRAddress1,
		SR.Address2 AS SRAddress2,
		SR.AddrName AS SRAddrName,
		SR.City		AS SRCity,
		SR.Country	AS SRCountry,
		SR.Email	AS SREmail,
		SR.Email2	AS SREmail2,
		SR.Fax		AS SRFax,
		SR.[State]	AS SRState,
		SR.ZipCode	AS SRZipCode,
		--****************Destination Address********
		DT.Address1 AS DTAddress1,
		DT.Address2 AS DTAddress2,
		DT.AddrName AS DTAddrName,
		DT.City		AS DTCity,
		DT.Country	AS DTCountry,
		DT.Email	AS DTEmail,
		DT.Email2	AS DTEmail2,
		DT.Fax		AS DTFax,
		DT.[State]	AS DTState,
		DT.ZipCode	AS DTZipCode,
		--**************** Routes ********
		RT.RouteKey,
		RT.OrderDetailKey,
		RT.OrderKey,
		RT.LegKey,
		RT.LegNo,
		RT.SourceAddrKey,
		RT.PickupDateFrom,
		RT.DeliveryDateFrom,
		RT.ConfirmationNo,
		RT.ChassisNo,
		RT.ChassisType,
		RT.DestinationAddrKey,
		RT.Status,
		RT.DriverKey,
		RT.ScheduledPickupDate,
		RT.ScheduledArrival,
		RT.ActualDeparture,
		RT.ActualArrival,
		RT.ChassisKey,
		RT.CompanyKey,
		RT.CreateUserKey,
		RT.UpdateUserKey,
		RT.CreateDate,
		RT.LastUpdateDate,
		RT.IsEmpty,
		RT.IsDryRun,
		RT.IsBobtail,
		RT.DryRunType,
		RT.ChassisCategoryKey,
		RT.ActualDepartureUpdateMethod,
		RT.isStreetTurn,
		RT.ActualArrivalUpdateMethod,
		RT.CarrierAssignedBy,
		RT.EmptySource, 
		--RT.NoWaitTIme, 
		RT.LegType,

		RT.LinkedContainer, 
		RT.LinkedBy, 
		RT.LinkedDate, 
		RT.LinkedContainerSource,
		OD.IsLinked
		
		--IsSelectedStatusKey = Case when RT.Status = @RouteStatusKeys then 1 else 0 end
		from Routes RT
		INNER JOIN Leg L on RT.LegKey = L.LegKey
		INNER JOIN OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey AND RT.RouteKey = OD.CurrentRouteKey
		INNER JOIN OrderHeader OH ON OD.OrderKey = OH.OrderKey
		Inner Join Customer C On OH.CustKey = C.CustKey
		Left Join Driver D On RT.DriverKey = D.DriverKey
		Left Join TruckType TT ON D.TruckTypeKey = TT.TruckTypeKey
		Left Join ChassisCategory CCK On RT.ChassisCategoryKey = CCK.ChassisCategoryKey		
		Left Join MarketLocation ML On OH.MarketLocationKey = ML.MarketLocationKey
		Inner Join ContainerSize CZ ON OD.ContainerSizeKey = CZ.ContainerSizeKey
		Left Join Chassis CS ON RT.ChassisKey = CS.chassisKey
		Left Join [Address] SR	 with ( NOLOCK)	ON	RT.SourceAddrKey = SR.AddrKey
		Left Join [Address] DT	 with ( NOLOCK)	ON	RT.DestinationAddrKey =DT.AddrKey
		Left Join SteamShipLine SShL ON OH.SteamShipLineKey = SShL.LineKey
		INNER JOIN RouteStatus RS on RT.Status = RS.Status
		INNER JOIN OrderDetailStatus ODS on OD.Status = ODS.Status
		Inner Join OrderType OT On OH.OrderTypeKey = OT.OrderTypeKey
		--Left Join DryRunType DRT ON RT.DryRunType = DRT.DryRunTypeKey
		where  OD.OrderDetailKey = @OrderDetailKey
		FOR JSON PATH, without_array_wrapper
		--, Include_null_values

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;

	
END
