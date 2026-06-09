/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"OrderDetailKey" : 47701}'
	EXEC [Get_ContainerDetailByOrderDetailKey_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
    SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_ContainerDetailByOrderDetailKey_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET FMTONLY OFF;  
  
 DECLARE 
    @OrderDetailKey  int = 1  
  
  SELECT 
    @OrderDetailKey   =   OrderDetailKey
  FROM OPENJSON(@JSONString)
  WITH
  (
    OrderDetailKey        INT         '$.OrderDetailKey'
  )


 CREATE TABLE #ContCurlocation  
 (  
  OrderDetailKey INT,  
  ContCurrLocation VARCHAR(200),  
  RouteKey INT,  
  LocationType INT  
 )  
  
    
 SELECT  
  isnull(OH.OrderKey,0) OrderKey,  
  isnull(OH.OrderDate,'1900-01-01') as OrderDate,  
  isnull(OD.OrderDetailkey,0) as OrderDetailkey,  
  isnull(OT.OrderTypeKey,0) as OrderTypeKey,  
  isnull(OH.OrderNo,'') as OrderNo,  
  isnull(CR.CsrName,'') as CsrName,  
  isnull(OD.ContainerNo,'') as ContainerNo,  
  isnull(OD.ContainerID, '') as ContainerID,  
  isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,  
  isnull(OD.LastFreeDay,'') as LastFreeDay,  
  RT.PickupDate AS PickupDate ,  
  CONVERT(VARCHAR(10), CAST(RT.PickupDate AS TIME), 0) PickupTime,    
  RT.DeliveryDate AS DropOffDate,  
  --OD.DropOffTime,  
  CONVERT(VARCHAR(10), CAST(RT.DeliveryDate AS TIME), 0) DropOffTime,   
  isnull(OSD.[Description],'') AS [Status],  
  isnull(OT.OrderType,'') AS OrderType,  
  isnull(OD.BillOfLadding,OH.BillOfLading) AS BillOfLading,  
  isnull(OD.BookingNo,OH.BookingNo) AS BookingNo,  
  isnull(OD.CustRefNo,OH.BrokerRefNo) as BrokerRefNo,  
  isnull(CS.[Description],'') AS ContainerSize,  
  isnull(PT.[Description],'')  AS [Priority],  
  isnull(SR.AddrName,'') AS Source_AddrName,  
  isnull(SR.Address1,'') AS Source_Address1,  
  isnull(SR.City,'')  AS Source_City,  
  isnull(SR.[State],'')  AS Source_State,  
  isnull(SR.ZipCode,'')  AS Source_ZipCode,  
  isnull(SR.Country,'')  AS Source_Country,  
  isnull(DT.AddrName,'')  AS Destination_AddrName,  
  isnull(DT.Address1,'')  AS Destination_Address1,  
  isnull(DT.City,'')  AS Destination_City,  
  isnull(DT.[State],'')  AS Destination_State,  
  isnull(DT.ZipCode,'')  AS Destination_ZipCode,  
  isnull(DT.Country,'')  AS Destination_Country,  
  isnull(BT.AddrName,'')  AS Customer_AddrName,  
  isnull(BT.Address1,'')  AS Customer_Address1,  
  isnull(BT.City,'')  AS Customer_City,  
  isnull(BT.[State],'')  AS Customer_State,  
  isnull(BT.ZipCode,'')  AS Customer_ZipCode,  
  isnull(BT.Country,'')  AS Customer_Country,  
  isnull(RET.AddrName,'') AS Return_AddrName,  
  isnull(RET.Address1,'') AS Return_Address1,  
  isnull(RET.City,'') AS Return_City,  
  isnull(RET.[State],'') AS Return_State,  
  isnull(RET.ZipCode,'') AS Return_ZipCode,  
  isnull(RET.Country,'') AS Return_Country,   
  isnull(OD.VesselETA,'') AS VesselETA,   
  CASE   
   WHEN OD.status = 1  
   THEN 'Proceed to Schedule'   
   WHEN OD.status = 3   
   THEN 'Complete Schedule'             
   WHEN OD.status = 4  
   THEN 'Confirm/Complete Schedule'   
   WHEN OD.status = 5  
   THEN 'Process Dispatch'   
   WHEN OD.status = 7   
   THEN 'Complete Dispatch'     
   WHEN OD.status = 8   
   THEN 'Confirm/Complete Dispatch'    
   WHEN OD.status = 9   
   THEN 'Approve Invoice/Driver Pay'    
   WHEN OD.status = 10   
   THEN 'Closed'   
   WHEN OD.status = 6  
   THEN 'Approve for Invoice/Driver Pay'   
   WHEN OD.status = 2  
   THEN 'Proceed to Dispatch'  
   END AS NextAction,OH.custKey,BR.BrokerName,OD.[Weight], OD.WeightUnit,OH.VesselName,OD.SealNo,OD.CutOffDate   
   , isnull(OD.IsEmpty,0) as IsEmpty  
   , OD.DriverNotes  
   , OD.SchedulerNotes  
   , isnull(OD.IsTMF,0) as IsTMF  
   , 0 as isTransLoad   
   , isnull(CU.CustName,'') as  CustName,  
   isnull(CU.CustID,'') as CustID, ML.MarketLocationKey,MarketLocation,ISNULL(OD.Consignee,ISNULL(OH.Consignee,'')) Consignee
   , OH.SalesPersonKey
   , SP.SalesPersonName,
   ContainerProperties=ISNULL(STUFF((
            SELECT ',' + TypeID
            FROM ContainerTypesLink CTLI
			INNER JOIN ContainerTypes CTI ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
			WHERE CTLI.OrderDetailKey=OD.OrderDetailkey
            FOR XML PATH('')
            ), 1, 1, ''),''),
   HazardClasses = ISNULL(STUFF((
            SELECT ',' + Description
            FROM HazardClassesLink HCL
			INNER JOIN Container_HazardClasses CHC ON CHC.ClassKey=HCL.ClassKey
			WHERE HCL.OrderDetailKey = OD.OrderDetailkey
			ORDER BY Description
            FOR XML PATH('')
            ), 1, 1, ''),'')
   INTO #ContainerListData  
 FROM  dbo.OrderDetail OD  WITH (NOLOCK) 
  INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey  
  INNER JOIN dbo.OrderStatus OS WITH (NOLOCK) ON OS.[Status]=OH.[Status]  
  LEFT JOIN dbo.[Broker]  BR WITH (NOLOCK) ON BR.BrokerKey=OH.BrokerKey  
  INNER JOIN  dbo.OrderDetailStatus OSD WITH (NOLOCK) ON OSD.[Status] = OD.[Status]  
  INNER JOIN dbo.ContainerSize CS   WITH (NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey    
  LEFT JOIN dbo.CSR CR     WITH (NOLOCK) ON CR.CsrKey=ISNULL(OD.CSRKey,OH.CsrKey)    
  LEFT JOIN  dbo.OrderType OT    WITH (NOLOCK) ON OT.OrderTypeKey = ISNULL(OD.OrdertypeKey,OH.OrdertypeKey) 
  LEFT JOIN OrderDetailStops	ODSP	WITH (NOLOCK)   ON ODSP.OrderDetailKey=OD.OrderDetailKey
														AND ODSP.StopTypeKey=1 AND ISNULL(ODSP.IsDryRunPort,0)=0 AND ISNULL(ODSP.IsDryRunCustomer,0)=0
  LEFT JOIN OrderDetailStops	ODSD	WITH (NOLOCK)   ON ODSD.OrderDetailKey=OD.OrderDetailKey
  														AND ODSD.StopTypeKey=3 AND ISNULL(ODSD.IsDryRunPort,0)=0 AND ISNULL(ODSD.IsDryRunCustomer,0)=0 
  LEFT JOIN OrderDetailStops	ODSRT	WITH (NOLOCK)   ON ODSRT.OrderDetailKey=OD.OrderDetailKey
  														AND ODSRT.StopTypeKey=5 AND ISNULL(ODSRT.IsDryRunPort,0)=0 AND ISNULL(ODSRT.IsDryRunCustomer,0)=0
  --LEFT JOIN [Address] SR     WITH (NOLOCK) ON SR.AddrKey=isnull(OD.SourceAddrKey, OH.SourceAddrKey)  
  --LEFT JOIN [Address] DT     WITH (NOLOCK) ON DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
  LEFT JOIN [Address] SR     WITH (NOLOCK) ON SR.AddrKey=ISNULL(ODSP.StopAddrKey, OD.SourceAddrKey)
  LEFT JOIN [Address] DT     WITH (NOLOCK) ON DT.AddrKey=ISNULL(ODSD.StopAddrKey, OD.DestinationAddrKey)
  LEFT JOIN [Address] BT     WITH (NOLOCK) ON BT.AddrKey=OH.BillToAddrKey  
  --LEFT JOIN [Address] RET     WITH (NOLOCK) ON RET.AddrKey=OH.ReturnAddrKey 
  LEFT JOIN [Address] RET     WITH (NOLOCK) ON RET.AddrKey=ISNULL(ODSRT.StopAddrKey, OH.ReturnAddrKey)
  LEFT JOIN  dbo.[Priority] PT   WITH (NOLOCK) ON PT.PriorityKey=OH.PriorityKey  
  LEFT JOIN DBO.Customer CU    WITH (NOLOCK) ON OH.CustKey = CU.CustKey  
  LEFT JOIN  (SELECT MIN(PickupDateFrom) AS PickupDate , MAX(PickupDateTo) AS PickupDateTo  ,  
  MIN(DeliveryDateFrom) AS DeliveryDate ,MAX(DeliveryDateTo) AS DeliveryDateTo,OrderDetailKey  
      FROM dbo.Routes WITH (NOLOCK)  
      GROUP BY OrderDetailKey  
       ) RT ON RT.OrderDetailKey=OD.OrderDetailKey  
  LEFT JOIN  MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=OH.MarketLocationKey  
  left join SalesPerson SP with (nolock) on oh.SalesPersonKey = sp.SalesPersonKey
 WHERE  OD.OrderDetailKey = @OrderDetailKey  
 -- WHERE OD.OrderDetailKey = ISNULL(NULLIF(@OrderDetailKey, 0), OD.OrderDetailKey)
  
  
 --UPDATE CT SET IsTransLoad = 1  
 --from #ContainerListData CT  
 --inner join vOrderContainerTypes OCT WITH (NOLOCK) on  CT.OrderDetailkey = OCT.OrderDetailKey  
 --where OCT.Description like '%Transload%'  
   
  
 SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,  
 A.OrderDetailKey,W.RouteKey INTO #RouteLegNo  
 FROM #ContainerListData A WITH (NOLOCK)  
  INNER JOIN dbo.Routes W WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey  
  
  
 SELECT DISTINCT OrderDetailkey INTO #OrderDetl FROM #ContainerListData  
  
 SELECT A.OrderDetailKey,COUNT(DISTINCT RT.RouteKey) AS LegCount INTO #LegCount  
 FROM #OrderDetl A   
  LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
 GROUP BY A.OrderDetailKey  
  
 SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CompletedRoutekey INTO #CompletedLeg  
 FROM #OrderDetl A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
 WHERE RTS.Status = 5 --RTS.[Description]='Leg Completed'  
 GROUP BY A.OrderDetailKey  
  
 SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey INTO #CurrLeg  
 FROM #OrderDetl A  
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
 WHERE RTS.Status <> 5 --RTS.[Description] <> 'Leg Completed'  
 GROUP BY A.OrderDetailKey  
  
 SELECT DISTINCT A.OrderDetailKey,ISNULL(O.CurrOPenRoutekey,D.CompletedRoutekey) AS RouteKey,  
   A.LegNo INTO #ContainerRoute  
 FROM #RouteLegNo A 
  LEFT JOIN #CompletedLeg D ON D.OrderDetailKey=A.OrderDetailKey  
  LEFT JOIN #CurrLeg O ON O.OrderDetailKey=A.OrderDetailKey  
  
 SELECT DISTINCT A.OrderDetailKey,A.RouteKey,D.ToLocation INTO #ContainerRoute2  
 FROM #ContainerRoute A   
 INNER JOIN dbo.Routes D WITH (NOLOCK) ON D.RouteKey=A.RouteKey  
  
 SELECT A.CompletedRoutekey,K.ToLocation,A.OrderDetailKey INTO #ComplLegLocation   
 FROM #CompletedLeg A  
 INNER JOIN dbo.Routes K WITH (NOLOCK) ON K.RouteKey=A.CompletedRoutekey  
  
 SELECT A.OrderDetailKey,R.AddrName INTO #Sourceloc  
 FROM #OrderDetl A  
  INNER JOIN  dbo.OrderDetail J WITH (NOLOCK) on j.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.[Address] R WITH (NOLOCK) ON R.AddrKey=J.SourceAddrKey  
  
 SELECT A.OrderDetailKey,'Dispatch Complete' AS CompleteStatus INTO #CompletedCont  
 FROM #OrderDetl A  
  INNER JOIN dbo.OrderDetail D WITH (NOLOCK) ON  D.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.OrderDetailStatus W WITH (NOLOCK) ON W.Status=D.Status  
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
  INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]  
 WHERE W.Status=6 AND RTS.Status=5 --W.[Description]='Dispatch Confirmed' AND RTS.Description='Leg Completed'  
 GROUP BY A.OrderDetailKey  
  
  --*********************Curr Location***********************  
  --All Comp Leg  
  SELECT OrderDetailKey INTO #AllcompLeg   
  FROM #OrderDetl     WHERE OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)  
  
  SELECT MAX(RouteKey) AS RouteKey, A.OrderDetailKey INTO #AllComplLegdestloc   
  FROM dbo.Routes A WITH (NOLOCK)  
   INNER JOIN #AllcompLeg D ON D.OrderDetailKey=A.OrderDetailKey  
  GROUP BY A.OrderDetailKey  
  
  SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,2 AS LocType INTO #CurrntLoc1  
  FROM #AllComplLegdestloc A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey  
  INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.DestinationAddrKey  
  
  --All Open  
  SELECT MIN(CurrOPenRoutekey) AS RouteKey,OrderDetailKey  INTO #AllOPenLegSourLoc  
  FROM #CurrLeg WHERE OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CompletedLeg)  
  GROUP BY OrderDetailKey  
    
  SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,1 AS LocType INTO #CurrntLoc2  
  FROM #AllOPenLegSourLoc A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey  
  INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.SourceAddrKey  
  
  
  SELECT A.OrderDetailKey, MAX(RT.RouteKey) AS RouteKey INTO #mixedLeg  
  FROM #OrderDetl A   
   INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey  
   INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RT.[Status]=RTS.[Status]  
  WHERE A.OrderDetailKey IN ( SELECT OrderDetailKey FROM #CompletedLeg )   
   AND A.OrderDetailKey IN ( SELECT OrderDetailKey FROM #CurrLeg )  
   --AND RTS.[Description]='Leg Completed'  
   AND RTS.Status=5  
  GROUP by A.OrderDetailKey  
  
  SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,2 AS LocType INTO #CurrntLoc3  
  FROM #mixedLeg A   
  INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey  
  INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.DestinationAddrKey    
  
  INSERT INTO #ContCurlocation (OrderDetailKey,ContCurrLocation,RouteKey,LocationType)  
  SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc1  
  UNION ALL  
  SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc2  
  UNION ALL  
  SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc3  
  
  --*********Open conatiner location - Source Addrname************  
  SELECT A.OrderDetailKey INTO #OpenCont  
  FROM #OrderDetl A    
   LEFT JOIN #ContCurlocation G ON G.OrderDetailKey=A.OrderDetailKey  
  WHERE G.OrderDetailKey IS NULL  
  
  IF ( SELECT COUNT(1) FROM #OpenCont)>0  
  BEGIN  
   INSERT INTO #ContCurlocation (OrderDetailKey,ContCurrLocation,RouteKey,LocationType)  
   SELECT OD.OrderDetailKey,AD.AddrName AS  ContCurrLocation,MAX(R.RouteKey) ,-1  
   FROM OrderDetail  OD  WITH (NOLOCK) 
   INNER JOIN dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey=OD.SourceAddrKey  
   Left join Routes R WITH (NOLOCK) on OD.OrderDetailKey = R.OrderDetailKey  
   WHERE OD.OrderDetailKey IN ( SELECT OrderDetailKey FROM #OpenCont)  
   group by  OD.OrderDetailKey,AD.AddrName  
  END  
  --************************************************************  
  SELECT A.OrderDetailKey,OH.OrderTypeKey,A.LocationType AS test1,  
   CASE WHEN A.LocationType=2 THEN L.ToLocation   
     WHEN A.LocationType=1 THEN L.FromLocation   
     WHEN A.LocationType=-1 AND OH.OrderTypeKey=1 THEN 'Port'   
     WHEN A.LocationType=-1 AND OH.OrderTypeKey=2 THEN 'Customer'       
     WHEN A.LocationType=-1 AND OH.OrderTypeKey=3 THEN 'Other'  
     END AS LocationType INTO #LocationType  
  FROM #ContCurlocation A   
   INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=A.OrderDetailKey  
   INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey  
   LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey  
   LEFT JOIN dbo.Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey  
  
    
    
  SELECT ShortComment,orderdetailkey,Comment INTO #ContTypes  
  FROM (  
    SELECT   
      OC.orderdetailkey,[value] as 'Comment',LEFT([value],3) AS ShortComment  
    FROM [dbo].[Comment] C  WITH (NOLOCK) 
     CROSS APPLY STRING_SPLIT(C.[description],',')    
     INNER JOIN   
      [dbo].[OrderDetailComments] OC WITH (NOLOCK)   ON  OC.CommentKey = C.CommentKey       
    WHERE OC.OrderDetailKey IN  ( SELECT OrderDetailKey FROM #ContainerListData )  
   ) A   
  INNER JOIN ContainerTypes CT WITH (NOLOCK) ON A.Comment = CT.TypeID  OR A.Comment = CT.ShortCode  
    
    
  --******************Hazmat Container********************  
  SELECT DISTINCT CL.OrderDetailKey,1 AS IsHazmat INTO #HazCont   
  FROM #ContainerListData  CL  
  INNER JOIN  
   (  
    SELECT orderdetailkey FROM #ContTypes WHERE Comment='Hazard'  
   ) HZ ON CL.OrderDetailKey=HZ.OrderDetailKey   
  --*******************************************************  
  
  
  SELECT OrderKey,A.OrderDate,A.OrderDetailkey,A.OrderTypeKey,A.OrderNo,A.CsrName,  
   A.ContainerNo,A.ContainerID,A.ContainerSizeKey,A.LastFreeDay,A.PickupDate,A.PickupTime,  
   A.DropOffDate,A.DropOffTime,A.[Status],A.OrderType,A.BillOfLading,A.BookingNo,A.ContainerSize,  
   A.[Priority],A.Source_AddrName,A.Source_Address1,A.Source_City,A.Source_State,A.Source_ZipCode,A.Source_Country,  
   A.Destination_AddrName,A.Destination_Address1,A.Destination_City,A.Destination_State,A.Destination_ZipCode,A.Destination_Country,  
  A.Customer_AddrName,A.Customer_Address1,A.Customer_City,A.Customer_State,A.Customer_ZipCode,A.Customer_Country,  
   A.Return_AddrName,A.Return_Address1,A.Return_City,A.Return_State,A.Return_ZipCode,A.Return_Country,   
   A.NextAction,A.custKey as CustKey,A.BrokerName,A.[Weight],A.WeightUnit,A.VesselName,A.SealNo as Seal,A.CutOffDate,  
   S.AddrName,  
   CL.ContCurrLocation AS CurLocation, CL.RouteKey,  
   CAST(ISNULL(MN.legNo,0) AS VARCHAR(10))+' [ '+ISNULL(CAST(MN.legNo AS VARCHAR(10)),0)+' of '+CAST(L.LegCount AS VARCHAR(10))+' ]' AS CurLeg  
   ,W.LocationType,isnull(CDC.DocumentCount,0) as DocumentCount  
   , IsEmpty, A.IsTMF, A.DriverNotes, A.SchedulerNotes ,ISNULL(H.IsHazmat,0) AS IsHazardous,  
    isTransLoad as IsTransload
   , A.CustID, A.CustName, A.BrokerRefNo, A.VesselETA,A.MarketLocationKey,A.MarketLocation, A.Consignee  ,
   A.SalesPersonKey, A.SalesPersonName, A.ContainerProperties, A.HazardClasses
   FROM #ContainerListData A   
   LEFT JOIN #LegCount L   ON L.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #CompletedLeg K  ON K.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #ComplLegLocation Q ON Q.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #Sourceloc S   ON S.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #CompletedCont D  ON D.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #ContainerRoute2 I ON I.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #RouteLegNo M   ON M.RouteKey=I.RouteKey  
   LEFT JOIN #CurrLeg V   ON V.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #RouteLegNo MN  ON MN.RouteKey=V.CurrOPenRoutekey  
   LEFT JOIN #ContCurlocation CL ON CL.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN #LocationType W ON W.OrderDetailKey=A.OrderDetailKey  
    LEFT JOIN #HazCont H ON H.OrderDetailKey=A.OrderDetailKey  
   LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON a.OrderDetailKey = CDC.OrderDetailKey  
  FOR JSON PATH;

SET @Status = 1
SET @Reason = 'Success'

END  