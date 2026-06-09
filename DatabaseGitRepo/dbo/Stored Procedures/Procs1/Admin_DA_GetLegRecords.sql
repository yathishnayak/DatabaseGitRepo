

CREATE PRocEDURE [dbo].[Admin_DA_GetLegRecords]
(
	@Routekey INT = 527771
)

AS

BEGIN
	IF OBJECT_ID('tempdb..#TMPROutes') IS NOT NULL
	BEGIN
		DROP TABLE #TMPROutes;
	END


	DECLARE @ContainerNo VARCHAR(20) = ''
	-- DECLARE @RouteKey INT = 527771
	SELECT * INTO #TMPROutes FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey
	DECLARE @OrderDetailKey INT = (SELECT OrderDetailKey FROM #TMPROutes RT WHERE RouteKey = @RouteKey)
	DECLARE @LinkedContainerNo VARCHAR(50) = (SELECT LinkedContainerNo FROM OrderDetail RT WHERE OrderDetailKey = @OrderDetailKey)



	SELECT (
	SELECT			OH.OrderKey,OD.OrderDetailKey,RT.RouteKey, LegID, OT.OrderType, ContainerNo, RA.Description AS IsAccepted
					, FromLocationWaitTimeFrom,FromLocationWaitTimeTo,ToLocationWaitTimeFrom,ToLocationWaitTimeTo, CC.ChassisCategory ,RT.LegType
					,IsLinked,LinkedContainerNo,LinkedOrderDetailKey, RT.Status
					, ActualDepartureUpdate = (SELECt			ActualDeparture,ActualDepartureUpdateMethod,ActualDepartureUpdateDate,ActualDepartureUpdateUser
					FROM			#TMPROutes RT
					WHERE			RT.RouteKey = @RouteKey
					FOR JSON PATH)
					, ActualArrivalUpdate = (SELECt	 ActualArrival,ActualArrivalUpdateMethod,ActualArrivalUpdateDate,ActualArrivalUpdateUser
					FROM			#TMPROutes RT
					WHERE			RT.RouteKey = @RouteKey
					FOR JSON PATH)
					, IsPairEmpty = (SELECt	 MarkedNoEmptyAvailable,	MarkedNoEmptyAvailableBY 
					FROM			#TMPROutes RT
					WHERE			RT.RouteKey = @RouteKey
					FOR JSON PATH)
	FROM			OrderHeader OH
	INNER JOIN		OrderDetail OD ON OH.OrderKey = OD.OrderKey
	INNER JOIN		#TMPROutes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	INNER JOIN		OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
	--LEFT JOIN		Chassis CD ON RT.ChassisKey = CD.ChassisKey 
	LEFT JOIN		DriverRouteAcceptance RA ON RT.RouteKey = RA.RouteKey
	LEFT JOIN		ChassisCategory CC ON RT.ChassisCategoryKey = CC.ChassisCategoryKey
	LEFT JOIn		Leg L On RT.LegKey = L.LegKey
	WHERE			RT.RouteKey = @RouteKey
	FOR JSON PATH)

	-- '[ACTUAL DEPARTURE UPDATE]' '[ACTUAL ARRIVAL UPDATE]'




	--SELECt			'[CONTAINER UPDATE]',OD.ContainerNo,OD.ContainerNoSource,OD.ContainerNoUser,OD.ContainerNoDate
	--				,'[CHASSIS UPDATE]',RT.ChassisKey,RT.ChassisNo, CD.chassisNo AS ChassisMasterData, ChassisSource,ChassisChangedUser,ChassisChangedDate
	--FROM			#TMPROutes RT
	--INNER JOIN		OrderDetail OD ON RT.OrderDetailKey = OD.OrderDetailKey
	--LEFT JOIN		Chassis CD ON RT.ChassisKey = CD.ChassisKey 
	--WHERE			RT.RouteKey = @RouteKey


	--SELECt			'[DRY RUN UPDATE]',IsDryRun,DryRunSource,DryRunSetUser,DryRunSetDate
	--FROM			#TMPROutes
	--WHERE			RouteKey = @RouteKey

	--SELECt			'[CHARGE NOTES]',ChargeNotes
	--FROM			#TMPROutes
	--WHERE			RouteKey = @RouteKey


	--SELECt		*
	--FROM		(SELECT 'ActiveRoute' OutputData) AS A   
	--LEFT JOIN	(SELECT * FROM DA_ActiveDriverRoutes WHERE RouteKey = @RouteKey) B ON 1 = 1


	--SELECt		*
	--FROM		(SELECT 'Linked Containers' OutputData) AS A   
	--LEFT JOIN	(SELECT			OrderDetailKey, ContainerNo, IsLinked,LinkedContainerNo,LinkedOrderDetailKey
	--			FROM			OrderDetail
	--			WHERE			ContainerNo = @LinkedContainerNo) B ON 1 = 1

	--SELECt		*
	--FROM		(SELECT 'ScreensCompleted' OutputData) AS A   
	--LEFT JOIN	(SELECT			* FROm DA_AppDriverScreenDetails 
	--			WHERE RouteKey = @RouteKey) B ON 1 = 1

	--SELECt		*
	--FROM		(SELECT 'Upload Details' OutputData) AS A   
	--LEFT JOIN	(SELECT			D.DocumentKey,DocumentType DocumentTypeKey,DT.description AS DocumentType,  OriginalFileName,OriginalFileType,FileSizeinMB,FilePath,DriverKey,OrderDetailKey,RouteKey
	--							,DocumentTypeDesc AS ScreenName
	--			FROM			Document D
	--			INNER JOIN		DriverDocuments DD ON D.DocumentKey = DD.DocumentKey
	--			INNER JOIN		OrderDetailDocuments ODD ON DD.DocumentKey = ODD.DocumentKey
	--			INNER JOIN		ContainerLegDocuments LD ON D.DocumentKey = LD.DocumentKey
	--			INNER JOIN		DocumenType DT ON D.DocumentType = DT.DocumentTypeKey
	--			WHERE			RouteKey = @RouteKey) B ON 1 = 1

	--SELECt		*
	--FROM		(SELECT 'Driver Exceptions' OutputData) AS A   
	--LEFT JOIN	(SELECT			* FROM DriverExceptionDetails 
	--			WHERE RouteKey = @RouteKey) B ON 1 = 1


	--SELECt		*
	--FROM		(SELECT 'Audit Logs' OutputData) AS A   
	--LEFT JOIN	(SELECT			*
	--			FROM			AuditLogDetail
	--			WHERE			RefKey = @OrderDetailKey AND DateCreated > CAST(CONVERT(VARCHAR,GETDATE(),101) AS DATETIME)
	--			) B ON 1 = 1
	--Order By		DateCreated DESC


	--SELECt		*
	--FROM		(SELECT 'OrderExpense' OutputData) AS A   
	--LEFT JOIN	(SELECT			OE.Itemkey,I.Description, RouteKey,OE.UnitCost,Qty,NewUnitCost,OE.CreateDate, ChargeSource 
	--			FROM			OrderExpense  OE
	--			INNER JOIN		Item I ON OE.Itemkey = I .ItemKey
	--			WHERE			RouteKey = @RouteKey) B ON 1 = 1 --   AND ChargeSource = 'DriverApp'
END
