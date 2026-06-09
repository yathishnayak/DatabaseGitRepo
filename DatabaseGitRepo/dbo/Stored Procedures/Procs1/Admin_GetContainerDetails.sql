

/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"ContainerNo":"ACEI2408763"}'
SET	@IsDebug  = 0

EXEC [Admin_GetContainerDetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/

CREATE PROCEDURE [dbo].[Admin_GetContainerDetails]  
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	@Result1		VARCHAR(1000)	= ''	OUTPUT,
	@Result2		VARCHAR(1000)	= ''	OUTPUT,
	@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@IsDebug		BIT				= 0
)

AS

BEGIN
	
	DECLARE @ContainerNo VARCHAR(20) = ''

	SELECT	@ContainerNo = ContainerNo
	FROM	OPENJSON(@JSONString, '$')
			WITH (
					ContainerNo			VARCHAR(20)	 '$.ContainerNo'
				)

	DECLARE @JSON NVARCHAR(MAX)
	
	--SET @JSON = 
	--(SELECT		OH.OrderNo, OD.ContainerNo, Ordertype,  OH.OrderKey,OD.OrderDetailKey,  OH.CreateDate OrderCreatedDate
	--			, CASE WHEN ISNULL(OD.IsEmpty,0)  = 0 THEN '' ELSE 'Yes' END IsEmpty
	--			,ISNULL(OS.Description,'') AS OrderStatus, ODS.Description AS OrderDetailStatus
	--			, ROuteDetails = (SELECT  L.LegID, RT.LegNo, D.DriverID, RT.RouteKey , RT.CreateDate RouteCreatedDate 
	--							, ISNULL(ScheduledDeparture,ScheduledPickupDate)ScheduledDeparture,ISNULL(ScheduledArrival,'')ScheduledArrival
	--							, ISNULL(ActualDeparture,'')ActualDeparture,ISNULL(ActualArrival,'')ActualArrival
	--							, RS.Description RouteStatus, PickupNoWaitTIme,DeliveryNoWaitTime
	--							, CASE WHEN ISNULL(IsEmpty,0)  = 0 THEN '' ELSE 'Yes' END IsEmpty
	--							, CASE WHEN ISNULL(IsDryRun,0) = 0 THEN '' ELSE 'Yes' END IsDryRun 
	--							, CASE WHEN ISNULL(IsDryRun,0) = 0 THEN '' ELSE DT.DryRunType END DryRunType
	--							, AdditionalInfo = (SELECT			ISNULL(R.FromLocationWaitTimeFrom,'')FromLocationWaitTimeFrom
	--																,ISNULL(R.FromLocationWaitTimeTo,'')FromLocationWaitTimeTo
	--																,ISNULL(ToLocationWaitTimeFrom,'')ToLocationWaitTimeFrom
	--																,ISNULL(R.ToLocationWaitTimeTo,'')ToLocationWaitTimeTo
	--																,LegType,ISNULL(LinkedContainer,'') LinkedContainer
	--																,ISNULL(CD.chassisNo,'')MasterchassisNo, ISNULL(R.chassisNo,'')chassisNo
	--																,ISNULL(CC.ChassisCategory,'') ChassisCategory
	--												FROM			Routes  R
	--												LEFT JOIN		Chassis CD ON R.ChassisKey = CD.ChassisKey 
	--												LEFT JOIN		ChassisCategory CC ON R.ChassisCategoryKey = CC.ChassisCategoryKey
	--												WHERE			R.RouteKey = RT.RouteKey FOR JSON PATH )
	--							, OrderExpense = (SELECT			OE.Itemkey,I.Description,OE.UnitCost,Qty,NewUnitCost,OE.CreateDate, ChargeSource 
	--												FROM			OrderExpense  OE
	--												INNER JOIN		Item I ON OE.Itemkey = I .ItemKey WHERE OE.RouteKey = RT.RouteKey FOR JSON PATH )
	--							, DriverExceptions = (SELECT		DE.DriverException,DriverExceptionText, D.DriverID , DED.CreateDate 
	--													FROM		DriverExceptionDetails DED
	--													INNER JOIN	DriverExceptions DE ON DED.DriverExceptionKey = DE.DriverExceptionKey
	--													INNER JOIN	Driver D ON DED.DriverKey = D.DriverKey
	--													WHERE DED.RouteKey = RT.RouteKey FOR JSON PATH )
	--							, DriverAcceptance = (SELECT AcceptanceKey,Description AS IsAccepted,DRA.CreateDate,RejectReasonKey,RejectReasonDescr,DRA.CreateUserKey
	--													,ActionDate, D.FirstName DriverName FROM DriverRouteAcceptance  DRA
	--													INNER JOIN Driver D ON DRA.DriverKey = D.DriverKey
	--													WHERE DRA.RouteKey = RT.RouteKey FOR JSON PATH )
	--							, DocDetails = (SELECT		OriginalFileName, DT.description AS DocumentType,  OriginalFileType
	--														,FileSizeinMB,FilePath,DR.DriverID,DocumentTypeDesc AS ScreenName
	--										FROM			Document D
	--										INNER JOIN		ContainerLegDocuments CLD ON D.DocumentKey = CLD.DocumentKey
	--										LEFT JOIN		(SELECT * FROM DriverDocuments) DD ON D.DocumentKey = DD.DocumentKey
	--										LEFT JOIN		OrderDetailDocuments ODD ON DD.DocumentKey = ODD.DocumentKey
	--										LEFT JOIN		(SELECT * FROM ContainerLegDocuments  WHERE RouteKey = 577465) LD ON D.DocumentKey = LD.DocumentKey
	--										LEFT JOIN		DocumenType DT ON D.DocumentType = DT.DocumentTypeKey
	--										LEFT JOIN		Driver DR ON DD.DriverKey = DR.DriverKey
	--										WHERE			CLD.RouteKey = RT.RouteKey FOR JSON PATH )

	--				FROM		Routes  RT WITH (NOLOCK)
	--				INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
	--				LEFT JOIN	Driver D WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
	--				LEFT JOIN	RouteStatus RS WITH (NOLOCK) ON RT.Status = RS.Status
	--				LEFT JOIN	DryRunType DT WITH (NOLOCK) ON ISNULL(RT.DryRunType,0) = DT.DryRunTypeKey
	--				WHERE		RT.OrderDetailkey = OD.OrderDetailkey
	--				ORDER BY	ISNULL(RT.LegNo,0)
	--				FOR JSON PATH)
	--			,OrderDetailsStops = (
	--				SELECT 
	--						OrderDetailStopKey,OrderStopKey,StopTypeKey,StopName,StopNumber,LocationType, FromRouteKey, ToRouteKey
	--				FROM 
	--						OrderDetailStops ODS WITH (NOLOCK)
	--				WHERE 
	--						ODS.OrderDetailKey = OD.OrderDetailkey
	--				FOR JSON PATH
	--			)
	--FROM		OrderDetail OD WITH (NOLOCK)  
	--INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	--INNER JOIN	OrderType OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
	--LEFT JOIN	OrderStatus OS WITH (NOLOCK)  ON OH.Status = OS.Status
	--LEFT JOIN	OrderDetailStatus ODS WITH (NOLOCK)  ON OD.Status = ODS.Status
	--WHERE		OD.ContainerNo = @ContainerNo
	--ORDER BY	OH.CreateDate 
	--FOR JSON PATH)

	SET @JSON = (
		SELECT				
				OH.OrderNo, 
				OD.ContainerNo,
				Ordertype,  
				OH.OrderKey,
				OD.OrderDetailKey,  
				OH.CreateDate AS OrderCreatedDate,

				CASE 
					WHEN ISNULL(OD.IsEmpty,0) = 0 THEN '' 
					ELSE 'Yes' 
				END AS IsEmpty,
				
				ISNULL(OS.Description,'') AS OrderStatus, 
				ODS.Description AS OrderDetailStatus,
				
				ROuteDetails = (
					SELECT  
							L.LegID, 
							RT.LegNo,
							D.DriverID, 
							RT.RouteKey,
							RT.CreateDate AS RouteCreatedDate,
							ISNULL(ScheduledDeparture,ScheduledPickupDate) AS ScheduledDeparture,
							ISNULL(ScheduledArrival,'') AS ScheduledArrival,
							ISNULL(ActualDeparture,'') AS ActualDeparture,
							ISNULL(ActualArrival,'') AS ActualArrival,
							RS.Description AS RouteStatus,

							--ISNULL(PickupNoWaitTIme,0) AS PickupNoWaitTIme,
							--ISNULL(DeliveryNoWaitTime,0) AS DeliveryNoWaitTime,
							
							RT.IsManual AS IsManual, 
							RT.FromODStopKey AS FromODStopKey, 
							RT.ToODStopKey AS ToODStopKey,

							CASE 
								WHEN ISNULL(IsEmpty,0)  = 0 THEN '' 
								ELSE 'Yes' 
							END AS IsEmpty,
							
							CASE 
								WHEN ISNULL(IsDryRun,0) = 0 THEN '' 
								ELSE 'Yes' 	
							END AS IsDryRun,
							
							CASE 
								WHEN ISNULL(IsDryRun,0) = 0 THEN '' 
								ELSE DT.DryRunType 
							END AS DryRunType,
							
							AdditionalInfo = (
								SELECT					
										ISNULL(R.FromLocationWaitTimeFrom,'') AS FromLocationWaitTimeFrom,
										ISNULL(R.FromLocationWaitTimeTo,'') AS FromLocationWaitTimeTo,
										ISNULL(ToLocationWaitTimeFrom,'') AS ToLocationWaitTimeFrom,
										ISNULL(R.ToLocationWaitTimeTo,'') AS ToLocationWaitTimeTo,
										LegType,
										ISNULL(LinkedContainer,'') AS LinkedContainer,
										ISNULL(CD.chassisNo,'') AS MasterchassisNo,
										ISNULL(R.chassisNo,'') AS chassisNo,
										ISNULL(CC.ChassisCategory,'') AS ChassisCategory
								FROM			
										Routes  R WITH (NOLOCK)
									LEFT JOIN Chassis CD WITH (NOLOCK) ON R.ChassisKey = CD.ChassisKey
									LEFT JOIN ChassisCategory CC WITH (NOLOCK) ON R.ChassisCategoryKey = CC.ChassisCategoryKey
								WHERE	
										R.RouteKey = RT.RouteKey 
								FOR JSON PATH 
							),
							OrderExpense = (
								SELECT 
										OE.Itemkey,
										I.Description,
										OE.UnitCost,
										Qty,
										NewUnitCost,
										OE.CreateDate, 
										ChargeSource
								FROM	
										OrderExpense OE WITH (NOLOCK)
									INNER JOIN Item I WITH (NOLOCK) ON OE.Itemkey = I.ItemKey 
								WHERE 
										OE.RouteKey = RT.RouteKey 
								FOR JSON PATH 
							),
							DriverExceptions = (
								SELECT		
										DE.DriverException,
										DriverExceptionText, 
										D.DriverID,
										DED.CreateDate
								FROM		
										DriverExceptionDetails DED WITH (NOLOCK)
									INNER JOIN	DriverExceptions DE WITH (NOLOCK) ON DED.DriverExceptionKey = DE.DriverExceptionKey
									INNER JOIN	Driver D WITH (NOLOCK) ON DED.DriverKey = D.DriverKey
								WHERE 
										DED.RouteKey = RT.RouteKey 
								FOR JSON PATH 
							),
							DriverAcceptance = (
								SELECT 
										AcceptanceKey,
										Description AS IsAccepted,
										DRA.CreateDate,
										RejectReasonKey,
										RejectReasonDescr,
										DRA.CreateUserKey,
										ActionDate, 
										D.FirstName AS DriverName 
								FROM 
										DriverRouteAcceptance DRA WITH (NOLOCK)
									INNER JOIN Driver D WITH (NOLOCK) ON DRA.DriverKey = D.DriverKey
								WHERE 
										DRA.RouteKey = RT.RouteKey 
								FOR JSON PATH 
							),
							DocDetails = (
								SELECT	
                                        D.DocumentKey,
										OriginalFileName, 
										DT.description AS DocumentType,  
										OriginalFileType,
										FileSizeinMB,
										FilePath,
										DR.DriverID,
										DocumentTypeDesc AS ScreenName,
                                        D.CreateDate
								FROM	
										Document D WITH (NOLOCK)
									INNER JOIN ContainerLegDocuments CLD WITH (NOLOCK) ON D.DocumentKey = CLD.DocumentKey
									LEFT JOIN (
												SELECT	* 
												FROM	DriverDocuments WITH (NOLOCK)
											) DD ON D.DocumentKey = DD.DocumentKey
									LEFT JOIN OrderDetailDocuments ODD WITH (NOLOCK) ON DD.DocumentKey = ODD.DocumentKey
									LEFT JOIN (
												SELECT	* 
												FROM	ContainerLegDocuments WITH (NOLOCK)
												WHERE RouteKey = RT.RouteKey --577465
											) LD ON D.DocumentKey = LD.DocumentKey
									LEFT JOIN DocumenType DT WITH (NOLOCK) ON D.DocumentType = DT.DocumentTypeKey
									LEFT JOIN Driver DR WITH (NOLOCK) ON DD.DriverKey = DR.DriverKey
								WHERE			
										CLD.RouteKey = RT.RouteKey 
								FOR JSON PATH 
							)
					FROM		
							Routes  RT WITH (NOLOCK)
						INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
						LEFT JOIN	Driver D WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
						LEFT JOIN	RouteStatus RS WITH (NOLOCK) ON RT.Status = RS.Status
						LEFT JOIN	DryRunType DT WITH (NOLOCK) ON ISNULL(RT.DryRunType,0) = DT.DryRunTypeKey
					WHERE 
							RT.OrderDetailkey = OD.OrderDetailkey
					ORDER BY 
							ISNULL(RT.LegNo,0)
					FOR JSON PATH ,INCLUDE_NULL_VALUES
				),
				OrderDetailsStops = (
					SELECT	 
							ODstp.OrderDetailStopKey,
							ODstp.OrderStopKey,
							ODstp.StopTypeKey,
							ODstp.StopName,
							ODstp.StopNumber,
							ODstp.LocationType,
							ODstp.FromRouteKey,
							ODstp.ToRouteKey
					FROM	
							OrderDetailStops ODstp WITH (NOLOCK)
					WHERE 
							ODstp.OrderDetailKey = OD.OrderDetailkey
					ORDER BY
							ODstp.StopNumber ASC
					FOR JSON PATH
				),
				OrderStops = (
					SELECT
							OStp.OrderStopKey,
							OStp.StopTypeKey,
							OStp.StopName,
							OStp.StopNumber, 
							OStp.LocationType, 
							OStp.StopAddrKey
					FROM	
							OrderStops OStp WITH (NOLOCK)
					WHERE
							OStp.OrderKey = OD.OrderKey
					FOR JSON PATH
				)
		FROM		
				OrderDetail OD WITH (NOLOCK)
			INNER JOIN	OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
			INNER JOIN	OrderType OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
			LEFT JOIN	OrderStatus OS WITH (NOLOCK) ON OH.Status = OS.Status
			LEFT JOIN	OrderDetailStatus ODS WITH (NOLOCK) ON OD.Status = ODS.Status
		WHERE		
				OD.ContainerNo = @ContainerNo
		ORDER BY
				OH.CreateDate 
		FOR JSON PATH		
	)


	SELECT @JSON AS JSONResult

	SET @Status = 1
	SET @IntMessage = 'Success'
	SET @ExtMessage = 'Success'
END
