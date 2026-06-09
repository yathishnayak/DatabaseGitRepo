/*
DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"OrderDetailKey":224199}' 
EXEC [Get_ContainerLegDetails_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Get_ContainerLegDetails_V2]
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

	DECLARE @OrderDetailKey INT=0;


	 SELECT @OrderDetailKey=OrderDetailKey
	 FROM OPENJSON(@JSONString, '$')
		WITH (
			   OrderDetailKey         INT      '$.OrderDetailKey'
			  )



		   
 --DECLARE @hasActualPickup Bit=0, @hasActualDelivery Bit=0

		 SELECT OD.ContainerNo,  
		  --L.LegNo,   
		  --CAST(ROW_number () OVER ( ORDER BY RT.RouteKey) AS SMALLINT )   
		  ISNULL(RT.LegNo,0) AS LegNo,  
		  Replace(Replace(L.[LegID],'(Live)',''),'(Drop)','')   
		   + case when (L.legid not like '%Live%' OR  L.legid not like '%Drop%') and   
			L.ToLocation in ('Customer','Consignee','Shipper') then   
		   Case when RT.LegType = 'Live' then ' [Live]' when RT.LegType = 'Drop' then ' [Drop]' else '' end   
		   else '' end as LegID,  
		  RT.PickupDateFrom ,RT.SwitchTo,  
		  RT.DeliveryDateFrom AS DeliveryDate  ,ISNULL(Sour.AddrName,'') AS FromLocation,ISNULL(Dest.AddrName,'') AS ToLocation,   
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
		  ISNULL(RT.PickupDateFrom,RT.PickupDateTo) AS ScheduledPickupFrom, RT.PickupDateTo AS ScheduledPickupTo,  
		  ISNULL(RT.DeliveryDateFrom,RT.DeliveryDateTo) AS ScheduledDeliveryFrom,RT.DeliveryDateTo AS ScheduledDeliveryTo, ISNULL(CH.chassisNo, RT.ChassisNO) as ChassisID,  
		--  CASE WHEN ISNULL(RT.driverKey ,0) > 0 AND ISNULL(RT.ChassisNo,'') <> '' AND ISNULL(RT.chassistype,'') <> '' AND   
		--    ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' and  
		--    ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'  
		--   then 1 else 0 end as ReadyToMarkComplete,  
		  Case when dbo.FN_IsRouteComplete(RT.RouteKey) = 1 then 1 else 0 end as ReadyToMarkComplete,  
		  Sour.AddrKey as FromLocationKey, Dest.AddrKey as ToLocationKey, L.LegKey,  
		  --CASE WHEN RT.LegKey IN (2,8,14,21,23,25,27,30,32,34,35,36,37,38,39,46,47,50,51,52,53,54,55,56,1,9,17,18,24,26,29,31,45,59) THEN CAST(1 AS BIT)  
		  --ELSE CAST(0 AS BIT) END ShowLinkContainerOption,  
		  CAST(1 AS BIT) AS ShowLinkContainerOption,  
		  Sour.AddrName AS S_AddrName,Sour.Address1 AS S_Address1,Sour.City AS S_City,Sour.[State] AS S_State,Sour.ZipCode AS S_ZipCode,Sour.Country AS S_Country,  
		  Dest.AddrName AS D_AddrName,Dest.Address1 AS D_Address1,Dest.City AS D_City,Dest.[State] AS D_State,Dest.ZipCode AS D_ZipCode,Dest.Country AS D_Country,  
		  YL.FromLocation as LegFromLocationType, L.ToLocation as LegToLocationType ,   
		  YL.YardLocationKey, YL.YardLocationName, YL.SourceYardID, YL.DestinationYardID,  
		  RT.IsEmpty,RT.IsAbandoned,ISNULL(RT.IsRateVerified,0) AS IsRateVerified,  
		  --(   
		  --  SELECT TOP 1 R.ReasonType AS [Status]  
		  --  FROM DriverRouteAcceptance F   
		  --   LEFT JOIN RejectReasons R ON R.RejectReasonKey=F.RejectReasonKey  
		  --  WHERE F.RouteKey= RT.RouteKey  
		  --  ORDER BY AcceptanceKey DESC  
		  -- ) AS [RouteStatus],  
		  M.[Status] AS [RouteStatus],  
		  (   
			SELECT TOP 1 R.RejectReasonDescr   
			FROM DriverRouteAcceptance F WITH (NOLOCK)  
			 LEFT JOIN RejectReasons R WITH (NOLOCK) ON R.RejectReasonKey=F.RejectReasonKey  
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
		  , isnull(RT.IsStreetTurn,0) AS IsStreetTurn
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
			   DRE.DriverId AS ExceptionDriverId,DED.CreateDate AS DriverExceptionDate,DE.DriverException AS ReasonCode  
			   FROM DriverExceptionDetails DED WITH (NOLOCK)   
			   LEFT JOIN DriverExceptions DE WITH (NOLOCK) ON DE.DriverExceptionKey=DED.DriverExceptionKey  
			   LEFT JOIN Driver DRE WITH (NOLOCK) ON DRE.DriverKey=DED.DriverKey  
			   WHERE DED.RouteKey=RT.RouteKey FOR JSON PATH),  
		  --DED.CreateDate AS DriverExceptionDate,DE.DriverException AS ReasonCode,'Exce' AS ExceptionType,DRE.DriverId AS ExceptionDriverId,  
		  DriverInstructions,  
		  --CASE WHEN ISNULL(RT.LinkedContainer,'')<>'' THEN ISNULL(RT.LinkedContainer,'')+ ' ' +ISNULL(RT.LinkedContainerType,'') 
		  --ELSE '' END AS LinkedContainer,
		  ISNULL(RT.LinkedContainer,'') LinkedContainer,
		  ISNULL(RT.LinkedContainerType,'') LinkedContainerType,
		 ISNULL(RT.NoEmptyAvailableMarked, 0) AS NoEmptyAvailableMarked,

		ISNULL(RT.NoEmptyAvailableMarkedBY, 0) AS NoEmptyAvailableMarkedBY,RT.NoEmptyAvailableMarkedDate,  
		  AcceptanceKey=(SELECT top 1 ISNULL(AcceptanceKey,0) FROM DriverRouteAcceptance WITH (NOLOCK) WHERE [Description]='pending' AND RT.RouteKey=RouteKey),  
		  ShowChassisSplitCB =(CASE WHEN L.FromLocation = 'Port' OR L.ToLocation = 'Port' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END),  
		  --CAST(0 AS BIT)  ShowChassisSplitCB,  
		  ISNULL(IsChassisSplit,0) AS IsChassisSplit,  
		  LinkedContainerSource,NoEmptyMarkedSource,  
		  CWTFromTime,CWTToTime,PWTFromTime,PWTToTime,OD.LinkedContainerNo,U9.UserName AS Dispatcher,  
		  DriverSetDate,  
		  --AllowActuals= CASE WHEN L.FromLocation IN ('Customer','Consignee','Shipper') THEN CAST(0 AS BIT)   
		  --       WHEN DriverSetDate IS NOT NULL AND   
		  --       DATEDIFF(minute,DriverSetDate,GETDATE())>=20 THEN CAST(1 AS BIT)   
		  --       ELSE CAST(0 AS BIT) END  
				 AllowActuals=  CAST(1 AS BIT)   ,
		  RT.MiscReason, RT.LegType,
		  ISNULL(RT.IsManual,0) AS IsManual,
		  ShowDelete = CASE WHEN ISNULL(vGRFD.RouteKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END ,
		  IsVoucherCreated = CASE WHEN ISNULL(RV.RouteKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		  IsInvoiceCreated= CASE WHEN ISNULL(OI.OrderDetailsKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
		  HasActualPickup = CASE WHEN ISNULL(RT.ActualDeparture,'')<>'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END,
		  HasActualDelivery= CASE WHEN ISNULL(RT.ActualArrival,'')<>'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
		  FROM OrderDetail OD WITH (NOLOCK)  
		  INNER JOIN  dbo.[Routes] RT WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey  
		  INNER JOIN  dbo.Leg L WITH (NOLOCK)  ON RT.LegKey=L.LegKey  
		  INNER JOIN  dbo.LegType LT WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey  
		  INNER JOIN  dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=ISNULL(RT.[Status] ,1)  
		  LEFT JOIN   dbo.[Address] Sour WITH (NOLOCK) ON Sour.Addrkey=RT.SourceAddrkey  
		  LEFT JOIN   dbo.[Address] Dest WITH (NOLOCK) ON Dest.Addrkey=RT.DestinationAddrkey  
		  LEFT JOIN   dbo.Driver DR WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey  
		  LEFT JOIN   dbo.Chassis CH WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey   
		  LEFT JOIN  dbo.OrderDetailStatus ODS WITH (NOLOCK) ON ODS.[Status]=OD.[Status]   
		  LEFT JOIN  DBO.RouteYardLink YL WITH (NOLOCK)  ON RT.RouteKey = YL.RouteKey  
		  LEFT JOIN DBO.ADDRESS DrA WITH (NOLOCK) ON DR.ADDRKEY = DrA.AddrKey  
		  LEFT JOIN DBO.[User] U1 WITH (NOLOCK) ON OD.StreetTurnSetUser = U1.UserKey  
		  LEFT JOIN ContainerSize CS WITH (NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey  
		  --LEFT JOIrN dbo.DriverRouteAcceptance DRA ON DRA.RouteKey=RT.RouteKey  
		  LEFT JOIN  
		   (   
  
			SELECT DISTINCT  A.RouteKey, --CASE WHEN isnull(A.RejectReasonKey,0) > 0 THEN 'Rejected' ELSE 'Accepted' END AS [Status],  
			SUBSTRING(( SELECT ';'+ convert(varchar,  ISNULL(K.ActionDate,K.CreateDate), 25 )+' = '+D.DriverID+   
			CASE WHEN R.RejectReasonDescr IS NULL THEN '' ELSE ' = '+ISNULL(R.RejectReasonDescr,'') END+  
			CASE WHEN K.[Description] IS NULL THEN '' ELSE ' = '+ISNULL(K.[Description],'') END  
			   FROM DriverRouteAcceptance K WITH (NOLOCK)  
				LEFT JOIN dbo.driver D WITH (NOLOCK) ON D.DriverKey=K.DriverKey  
				LEFT JOIN RejectReasons R WITH (NOLOCK) ON R.RejectReasonKey=K.RejectReasonKey  
			   WHERE K.RouteKey=A.RouteKey AND [Description]<>'pending'  
			   ORDER BY K.CreateDate  
			   FOR XML PATH(''), TYPE  
			   ).value('.', 'NVARCHAR(MAX)'  
			   ) ,2,500) AS Comments ,  
				(  
			   SELECT TOP 1 [Description]   
			   FROM DriverRouteAcceptance WITH (NOLOCK)   
			   WHERE RouteKey=A.RouteKey   
			   ORDER BY AcceptanceKey desc  
			   ) AS [Status]   
			FROM dbo.DriverRouteAcceptance A WITH (NOLOCK)   
		   ) M ON M.RouteKey=RT.RouteKey   
		  LEFT JOIN [DriverRouteAbandon] DA WITH (NOLOCK) ON DA.RouteKey=RT.RouteKey  
		  LEFT JOIN RejectReasons RR WITH (NOLOCK) ON RR.RejectReasonKey=DA.AbandonReasonKey  
		  LEFT JOIN Routeswitch SWFrom WITH (NOLOCK) ON SWFrom.FromRouteKey=RT.RouteKey  
		  LEFT JOIN Routeswitch SWTo WITH (NOLOCK) ON SWTo.ToRouteKey=RT.RouteKey  
		  LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo  
			   , OH.OrderNo, L.LegID, L.LegNo  
			 FROM dbo.Routes RT WITH (NOLOCK)  
			  INNER JOIN dbo.Routeswitch SWC WITH (NOLOCK) ON SWC.ToRouteKey=RT.RouteKey  
			  INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=RT.OrderDetailKey  
			  INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey  
			  LEFT JOIN dbo.Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey  
			 )SWRTo ON SWRTo.RouteKey=SWFrom.ToRouteKey  
		  LEFT JOIN ( SELECT RT.LegKey,RT.RouteKey ,OD.OrderDetailKey,OD.ContainerNo  
			   , OH.OrderNo, L.LegID, L.LegNo  
			 FROM dbo.Routes RT WITH (NOLOCK)  
			  --INNER JOIN dbo.Routeswitch SWC ON SWC.FromRouteKey=RT.RouteKey  
			  INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=RT.OrderDetailKey  
			  INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey  
			  LEFT JOIN dbo.Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey  
			 )SWRFROM ON SWRFROM.RouteKey=SWTo.FromRouteKey  
		  LEFT JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=DR.TruckTypeKey  
		  -- LEFT JOIN AuditLogDetail LD ON LD.AuditKey = RT.SFGYardDiffLogKey  
		  LEFT JOIN DBO.[User] U2 WITH (NOLOCK) ON RT.EmptySetUser = U2.UserKey  
		  LEFT JOIN DBO.[User] U3 WITH (NOLOCK) ON RT.ChassisChangedUser = U3.UserKey  
		  LEFT JOIN DBO.[User] U4 WITH (NOLOCK) ON RT.BobtailSetUser = U4.UserKey  
		  LEFT JOIN DBO.[User] U5 WITH (NOLOCK) ON RT.DryRunSetUser = U5.UserKey  
		  LEFT JOIN DBO.[User] U6 WITH (NOLOCK) ON OD.ContainerNoUser = U6.UserKey  
		  LEFT JOIN DBO.[User] U7 WITH (NOLOCK) ON RT.ActualDepartureUpdateUser = U7.UserKey  
		  LEFT JOIN DBO.[User] U8 WITH (NOLOCK) ON RT.ActualArrivalUpdateUser = U8.UserKey  
		  LEFT JOIN DBO.[User] U9 WITH (NOLOCK) ON RT.DriverSetBy = U9.UserKey  
		  --LEFT JOIN DriverExceptionDetails DED  ON DED.RouteKey=RT.RouteKey  
		  --LEFT JOIN DriverExceptions DE    ON DE.DriverExceptionKey=DED.DriverExceptionKey  
		  --LEFT JOIN Driver DRE WITH (NOLOCK) ON DRE.DriverKey=DED.DriverKey  
		  LEFT JOIN vGetRoutesForDelete vGRFD ON vGRFD.RouteKey=RT.RouteKey
		  LEFT JOIN (SELECT DISTINCT RV.RouteKey FROM RouteVouchers RV WITH (NOLOCK) 
					INNER JOIN VoucherHeader VH WITH (NOLOCK)  ON RV.VoucherKey = VH.VoucherKey
					) RV ON RT.RouteKey=RV.RouteKey
		  LEFT JOIN (SELECT DISTINCT IC.OrderDetailsKey FROM InvoiceContainers  IC WITH (NOLOCK) 
					INNER JOIN InvoiceHeader IH WITH (NOLOCK)  ON IC.InvoiceKey = IH.InvoiceKey
					) OI ON OD.OrderDetailKey=OI.OrderDetailsKey
		 WHERE OD.OrderDetailKey = @OrderDetailKey  
		 order by RT.LegNo  
		 FOR JSON PATH ;

		 SET @Status=1;
		 SET @Reason='Success';

END