CREATE PROC [dbo].[Get_ContainerLegDetails_shiva] -- Get_ContainerLegDetails_shiva 151675
(
	@OrderDetailKey int = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	SELECT OD.ContainerNo,
		--L.LegNo, 
		--CAST(ROW_number () OVER ( ORDER BY RT.RouteKey) AS SMALLINT ) 
		RT.LegNo AS LegNo,
		L.[LegID] + case when L.legid not like '%Live%' OR  L.legid not like '%Drop%' then 
			Case when RT.LegType = 'Live' then ' [Live]' when RT.LegType = 'Drop' then ' [Drop]' else '' end 
			else '' end as LegID,
		RT.PickupDateFrom ,RT.SwitchTo,
		RT.DeliveryDateFrom ,ISNULL(Sour.AddrName,'') AS FromLocation,ISNULL(Dest.AddrName,'') AS ToLocation,	
		ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		CASE WHEN ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualDeparture END AS ActualPickup,
		CASE WHEN ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualArrival END AS  ActualDelDate,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 

		--CAST(CASE WHEN ISNULL(RT.DriverKey,0)=0 THEN 1 
		--WHEN ISNULL(RT.ChassisNo,'')='' AND ISNULL(RT.ChassisKey,0)=0 THEN 4
		--WHEN ISNULL(RT.ActualDeparture,'')='' THEN 2
		--WHEN ISNULL(RT.ActualArrival,'')='' THEN 3
		--ELSE RT.[Status]
		--END AS SMALLINT) AS StatusKey, 
		RT.[Status] AS StatusKey,
		
		RT.ConfirmationNo ,RT.DelConfirmationNo, RT.ChassisKey,
		ISNULL(RT.PickupDateFrom,RT.PickupDateTo) AS ScheduledPickupDate,	RT.PickupDateTo AS ScheduledPickupDateTo,
		ISNULL(RT.DeliveryDateFrom,RT.DeliveryDateTo) AS ScheduledDeliveryDate,RT.DeliveryDateTo AS ScheduledDeliveryDateTo, CH.chassisNo as ChassisID,
--		CASE WHEN ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> '' AND ISNULL(RT.chassistype,'') <> '' AND 
--				ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' and
--				ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
--			then 1 else 0 end as ReadyToMarkComplete,
		Case when dbo.FN_IsRouteComplete(RT.RouteKey) = 1 then 1 else 0 end as ReadyToMarkComplete,
		Sour.AddrKey as FromLocationKey, Dest.AddrKey as ToLocationKey, L.LegKey,
		--CASE WHEN RT.LegKey IN (2,8,14,21,23,25,27,30,32,34,35,36,37,38,39,46,47,50,51,52,53,54,55,56,1,9,17,18,24,26,29,31,45,59) THEN CAST(1 AS BIT)
		--ELSE CAST(0 AS BIT) END ShowLinkContainerOption,
		CAST(1 AS BIT) AS ShowLinkContainerOption,
		Sour.AddrName AS SR_AddrName,Sour.Address1 AS SR_Address1,Sour.City AS SR_City,Sour.[State] AS SR_State,Sour.ZipCode AS SR_ZipCode,Sour.Country AS SR_Country,
		Dest.AddrName AS DR_AddrName,Dest.Address1 AS DR_Address1,Dest.City AS DR_City,Dest.[State] AS DR_State,Dest.ZipCode AS DR_ZipCode,Dest.Country AS DR_Country,
		YL.FromLocation as LegFromLocationType, L.ToLocation as LegToLocationType , 
		YL.YardLocationKey, YL.YardLocationName, YL.SourceYardID, YL.DestinationYardID,
		RT.IsEmpty,RT.IsAbandoned,RT.IsRateVerified,
		--( 
		--		SELECT TOP 1 R.ReasonType AS [Status]
		--		FROM DriverRouteAcceptance F 
		--			LEFT JOIN RejectReasons R ON R.RejectReasonKey=F.RejectReasonKey
		--		WHERE F.RouteKey= RT.RouteKey
		--		ORDER BY AcceptanceKey DESC
		--	) AS [RouteStatus],
		M.[Status] AS [RouteStatus],
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
		, SWRFROM.LegKey AS SWRFrom_LegKey, SWRFROM.LegID AS SWRFrom_LegID, SWRFROM.LegNo as SWRFrom_LegNo,M.Comments,RR.RejectReasonDescr AS AbandonReason
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
		CASE WHEN ISNULL(SFGYardChangePickup,'') = 'Pickup' THEN SFGYardChangePickupMessage ELSE '' END AS FromLocationDifference,
		CASE WHEN ISNULL(SFGYardChangeDelivery,'') = 'Delivery' THEN SFGYardChangeDeliveryMessage ELSE '' END AS ToLocationDifference,
		RT.ContainerNoSource,ContainerNoDate,ChassisSource,ChassisChangedDate,
		EmptySource,EmptySetDate,DryRunSource,DryRunSetDate,BobTailSource,BobtailSetDate,
		StreetTurnSource,U2.UserName EmptySetUser,U3.UserName ChassisChangedUser,
		U4.UserName BobtailSetUser,U5.UserName DryRunSetUser,U6.UserName ContainerNoUser,
		ActualDepartureUpdateDate,U7.UserName ActualDepartureUpdateUser,ActualDepartureUpdateMethod,
		ActualArrivalUpdateDate, U8.UserName ActualArrivalUpdateUser,ActualArrivalUpdateMethod,
		--ChargeNotes, 
		ChargeNotes=(SELECT I.ItemId,OE.RouteKey,RTI.ChargeNotes, OE.CreateDate AS ChargeDate,DI.DriverId As ChargeDriverId FROM Orderexpense OE WITH (NOLOCK)
					 INNER JOIN Item I WITH (NOLOCK) ON I.ItemKey=OE.ItemKey
					 INNER JOIN Routes RTI WITH (NOLOCK) ON RT.RouteKey=OE.RouteKey
					 INNER JOIN Driver DI WITH (NOLOCK) ON DI.DriverKey=RTI.DriverKey
					 WHERE OE.ChargeSource='DriverApp' AND RTI.RouteKey=RT.RouteKey FOR JSON PATH), 
		CompletionNotes,
		--ISNULL(DED.DriverExceptionText,'')+ISNULL(DE.DriverException,'') AS DrverException,
		DrverException=(SELECT ISNULL(DE.DriverException,'')+' : '+ISNULL(DED.DriverExceptionText,'') AS DrverException,
							CASE WHEN DE.ExceptionType ='Pickup' THEN 'PU Error' WHEN DE.ExceptionType='Delivery' THEN 'DEL Error' END AS ExceptionType,
							DRE.DriverId AS ExceptionDriverId,DED.CreateDate	AS DriverExceptionDate,DE.DriverException AS ReasonCode
							FROM DriverExceptionDetails DED  
							LEFT JOIN DriverExceptions DE WITH (NOLOCK) ON DE.DriverExceptionKey=DED.DriverExceptionKey
							LEFT JOIN Driver DRE WITH (NOLOCK) ON DRE.DriverKey=DED.DriverKey
							WHERE DED.RouteKey=RT.RouteKey FOR JSON PATH),
		--DED.CreateDate	AS DriverExceptionDate,DE.DriverException AS ReasonCode,'Exce' AS ExceptionType,DRE.DriverId AS ExceptionDriverId,
		DriverInstructions,
		RT.LinkedContainer ,RT.NoEmptyAvailableMarked,RT.NoEmptyAvailableMarkedBY,RT.NoEmptyAvailableMarkedDate,
		AcceptanceKey=(SELECT top 1 ISNULL(AcceptanceKey,0) FROM DriverRouteAcceptance WHERE [Description]='pending' AND RT.RouteKey=RouteKey),
		ShowChassisSplitCB =(CASE WHEN L.FromLocation = 'Port' OR L.ToLocation = 'Port' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),
		--CAST(0 AS BIT)  ShowChassisSplitCB,
		ISNULL(IsChassisSplit,0) AS IsChassisSplit,
		LinkedContainerSource,NoEmptyMarkedSource,
		CWTFromTime,CWTToTime,PWTFromTime,PWTToTime,
		DriverSetDate,AllowActuals=CASE WHEN DriverSetDate IS NOT NULL AND 
									DATEDIFF(minute,DriverSetDate,GETDATE())>=20 THEN CAST(1 AS BIT) 
									ELSE CAST(0 AS BIT) END
		FROM OrderDetail OD 
		INNER JOIN  dbo.[Routes] RT		ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L			ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS ON RTS.[Status]=ISNULL(RT.[Status]	,1)
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
				SUBSTRING(( SELECT ';'+ convert(varchar,  ISNULL(K.ActionDate,K.CreateDate), 25 )+' = '+D.DriverID+ 
				CASE WHEN R.RejectReasonDescr IS NULL THEN '' ELSE ' = '+ISNULL(R.RejectReasonDescr,'') END+
				CASE WHEN K.[Description] IS NULL THEN '' ELSE ' = '+ISNULL(K.[Description],'') END
							FROM DriverRouteAcceptance K 
								LEFT JOIN dbo.driver D ON D.DriverKey=K.DriverKey
								LEFT JOIN RejectReasons R ON R.RejectReasonKey=K.RejectReasonKey
							WHERE K.RouteKey=A.RouteKey AND [Description]<>'pending'
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
		-- LEFT JOIN AuditLogDetail LD ON LD.AuditKey = RT.SFGYardDiffLogKey
		LEFT JOIN DBO.[User] U2				  ON RT.EmptySetUser = U2.UserKey
		LEFT JOIN DBO.[User] U3				  ON RT.ChassisChangedUser = U3.UserKey
		LEFT JOIN DBO.[User] U4				  ON RT.BobtailSetUser = U4.UserKey
		LEFT JOIN DBO.[User] U5				  ON RT.DryRunSetUser = U5.UserKey
		LEFT JOIN DBO.[User] U6				  ON OD.ContainerNoUser = U6.UserKey
		LEFT JOIN DBO.[User] U7				  ON RT.ActualDepartureUpdateUser = U7.UserKey
		LEFT JOIN DBO.[User] U8				  ON RT.ActualArrivalUpdateUser = U8.UserKey
		--LEFT JOIN DriverExceptionDetails DED  ON DED.RouteKey=RT.RouteKey
		--LEFT JOIN DriverExceptions DE		  ON DE.DriverExceptionKey=DED.DriverExceptionKey
		--LEFT JOIN Driver DRE WITH (NOLOCK) ON DRE.DriverKey=DED.DriverKey
	WHERE OD.OrderDetailKey = @OrderDetailKey
	order by RT.LegNo
END
