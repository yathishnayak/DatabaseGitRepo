
CREATE PROC [dbo].[Get_ContainerLegDetails_Delete] -- Get_ContainerLegDetails_Delete 147197
(
	@OrderDetailKey int = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OD.ContainerNo,
		--L.LegNo, 
		--CAST(ROW_number () OVER ( ORDER BY RT.RouteKey) AS SMALLINT ) 
		RT.LegNo AS LegNo,
		L.[LegID],RT.PickupDateFrom ,RT.SwitchTo,
		RT.DeliveryDateFrom ,ISNULL(Sour.AddrName,'') AS FromLocation,ISNULL(Dest.AddrName,'') AS ToLocation,	
		ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		CASE WHEN ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualDeparture END AS ActualPickup,
		CASE WHEN ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualArrival END AS  ActualDelDate,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 
		RT.[Status] AS StatusKey, RT.ConfirmationNo ,RT.DelConfirmationNo, RT.ChassisKey,
		ISNULL(RT.PickupDateFrom,RT.PickupDateTo) AS ScheduledPickupDate,	RT.PickupDateTo AS ScheduledPickupDateTo,
		ISNULL(RT.DeliveryDateFrom,RT.DeliveryDateTo) AS ScheduledDeliveryDate,RT.DeliveryDateTo AS ScheduledDeliveryDateTo, CH.chassisNo as ChassisID,
--		CASE WHEN ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> '' AND ISNULL(RT.chassistype,'') <> '' AND 
--				ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' and
--				ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
--			then 1 else 0 end as ReadyToMarkComplete,
		Case when dbo.FN_IsRouteComplete(RT.RouteKey) = 1 then 1 else 0 end as ReadyToMarkComplete,
		Sour.AddrKey as FromLocationKey, Dest.AddrKey as ToLocationKey, L.LegKey,
		Sour.AddrName AS SR_AddrName,Sour.Address1 AS SR_Address1,Sour.City AS SR_City,Sour.[State] AS SR_State,Sour.ZipCode AS SR_ZipCode,Sour.Country AS SR_Country,
		Dest.AddrName AS DR_AddrName,Dest.Address1 AS DR_Address1,Dest.City AS DR_City,Dest.[State] AS DR_State,Dest.ZipCode AS DR_ZipCode,Dest.Country AS DR_Country,
		YL.FromLocation as LegFromLocationType, L.ToLocation as LegToLocationType , 
		YL.YardLocationKey, YL.YardLocationName, YL.SourceYardID, YL.DestinationYardID,
		RT.IsEmpty,RT.IsAbandoned,RT.IsRateVerified,
		( 
				SELECT TOP 1 R.ReasonType AS [Status]
				FROM DriverRouteAcceptance F 
					LEFT JOIN RejectReasons R ON R.RejectReasonKey=F.RejectReasonKey
				WHERE F.RouteKey= RT.RouteKey
				ORDER BY AcceptanceKey DESC
			) AS [RouteStatus],
		( 
				SELECT TOP 1 R.RejectReasonDescr 
				FROM DriverRouteAcceptance F 
					LEFT JOIN RejectReasons R ON R.RejectReasonKey=F.RejectReasonKey
				WHERE F.RouteKey= RT.RouteKey
				ORDER BY AcceptanceKey DESC
			) AS [RouteStatusDescr],
		SWFrom.ToRouteKey AS SWT_RouteKey
		,SWRTo.LegKey AS SWT_LegKey,SWRTo.OrderDetailKey AS SWT_OrderDetailKey,SWRTo.ContainerNo AS SWT_ContainerNo
		, SWRTo.LegKey as SWR_LegKey, SWRTo.LegID as SWR_LegID, SWRTo.LegNo as SWR_LegNo
		--From Route Detail
		,SWRFROM.RouteKey AS SWTFrom_RouteKey
		,SWRFROM.LegKey AS SWTFrom_LegKey,SWRFROM.OrderDetailKey AS SWTFrom_OrderDetailKey,SWRFROM.ContainerNo AS SWTFrom_ContainerNo
		, SWRFROM.LegKey AS SWRFrom_LegKey, SWRFROM.LegID AS SWRFrom_LegID, SWRFROM.LegNo as SWRFrom_LegNo,Comments,RR.RejectReasonDescr AS AbandonReason
		, ISNULL(ISNULL(DrA.Phone, DrA.Phone2),'NA') AS DriverPhone,isnull(RT.IsDryRun,0) IsDryRun ,isnull(IsBobtail,0) IsBobtail
		, CAST(isnull(RT.DryRunType,0) AS INT) DryRunType
		, OD.VesselETA
		, RT.isStreetTurn
		, RT.StreetTurnSetDate
		, U1.UserName as StreetTurnSetUser
		,TT.TruckType,DR.TruckTypeKey
		,isnull(CS.Description,'') as ContainerSize 
		,isnull(CS.ContainerSizeKey,0) as ContainerSizeKey
		,isnull(OD.DriverNotes,'') as DriverNotes,
		YardCheckin,YardCheckOut,ISNULL(ChassisCategoryKey,1) AS CategoryKey,
		RT.Carrierrate, 
		CASE WHEN YD.RouteKey IS NOT NULL THEN YD.YardName +  ' to ' + YD.TMSYardName ELSE '' END AS LocationDifference
		FROM OrderDetail OD 
		INNER JOIN  dbo.[Routes] RT		ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L			ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] Sour	ON Sour.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] Dest	ON Dest.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey	
		LEFT JOIN  dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]	
		LEFT JOIN  DBO.RouteYardLink YL		 ON RT.RouteKey = YL.RouteKey
		LEFT JOIN DBO.ADDRESS DrA		ON DR.ADDRKEY = DrA.AddrKey
		LEFT JOIN DBO.[User] U1				  ON OD.StreetTurnSetUser = U1.UserKey
		LEFT JOIN ContainerSize CS ON CS.ContainerSizeKey = OD.ContainerSizeKey
		--LEFT JOIN dbo.DriverRouteAcceptance DRA ON DRA.RouteKey=RT.RouteKey
		LEFT JOIN
			(	

				SELECT DISTINCT  A.RouteKey, --CASE WHEN isnull(A.RejectReasonKey,0) > 0 THEN 'Rejected' ELSE 'Accepted' END AS [Status],
				SUBSTRING(( SELECT ';'+ convert(varchar, K.CreateDate, 25 )+' = '+D.DriverID+ 
				CASE WHEN R.RejectReasonDescr IS NULL THEN '' ELSE ' = '+ISNULL(R.RejectReasonDescr,'') END+
				CASE WHEN K.[Description] IS NULL THEN '' ELSE ' = '+ISNULL(K.[Description],'') END
							FROM DriverRouteAcceptance K 
								LEFT JOIN dbo.driver D ON D.DriverKey=K.DriverKey
								LEFT JOIN RejectReasons R ON R.RejectReasonKey=K.RejectReasonKey
							WHERE K.RouteKey=A.RouteKey
							ORDER BY K.CreateDate
							FOR XML PATH(''), TYPE
							).value('.', 'NVARCHAR(MAX)'
						 ) ,2,500) AS Comments	,
						  (
							SELECT TOP 1 [Description] 
							FROM DriverRouteAcceptance 
							WHERE RouteKey=A.RouteKey 
							ORDER BY AcceptanceKey desc
						 ) AS [Status]	
				FROM dbo.DriverRouteAcceptance A 
			) M ON M.RouteKey=RT.RouteKey
		LEFT JOIN [DriverRouteAbandon] DA  ON DA.RouteKey=RT.RouteKey
		LEFT JOIN RejectReasons RR  ON RR.RejectReasonKey=DA.AbandonReasonKey
		LEFT JOIN Routeswitch SWFrom ON SWFrom.FromRouteKey=RT.RouteKey
		LEFT JOIN Routeswitch SWTo ON SWTo.ToRouteKey=RT.RouteKey
		LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo
							, OH.OrderNo, L.LegID, L.LegNo
					FROM dbo.Routes RT 
						INNER JOIN dbo.Routeswitch SWC ON SWC.ToRouteKey=RT.RouteKey
						INNER JOIN dbo.OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
						INNER JOIN dbo.OrderHeader OH  ON OH.OrderKey=OD.OrderKey
						LEFT JOIN dbo.Leg L			   ON RT.LegKey = L.LegKey
				 )SWRTo ON SWRTo.RouteKey=SWFrom.ToRouteKey
		LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo
							, OH.OrderNo, L.LegID, L.LegNo
					FROM dbo.Routes RT 
						--INNER JOIN dbo.Routeswitch SWC ON SWC.FromRouteKey=RT.RouteKey
						INNER JOIN dbo.OrderDetail OD  ON OD.OrderDetailKey=RT.OrderDetailKey
						INNER JOIN dbo.OrderHeader OH  ON OH.OrderKey=OD.OrderKey
						LEFT JOIN dbo.Leg L			   ON RT.LegKey = L.LegKey
				 )SWRFROM ON SWRFROM.RouteKey=SWTo.FromRouteKey
		LEFT JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=DR.TruckTypeKey
		LEFT JOIN SafeGateIntegration_VGetYardDifference YD ON RT.RouteKey = YD.RouteKey
	WHERE OD.OrderDetailKey = @OrderDetailKey
	order by RT.LegNo
END
