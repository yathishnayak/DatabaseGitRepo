/**
DECLARE 
	@UserKey INT=953,
	@JSONString NVARCHAR(MAX)='
	{"PageNo":1,"PageSize":10,"Ascending":true,"SearchText":"","DriverKey":0,"MarketLocationKey":0,"CarrierStatus":0,"Dispatcher":0,"Status":1,
    "IsDriverApp":0,"EmptyvLoaded":0,"Urgent":false,"SearchCriteriaKey":0}
    ',
	@Status BIT=0, @IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec Dispatch_GetList_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Dispatch_GetList_V2]
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

 DECLARE
     @Weekday               CHAR(3) ='',    
     @Customer              VARCHAR(50)='',    
     @OrderNo               VARCHAR(20)='',    
     @ContainerNo           VARCHAR(20)='',    
     @LegType               VARCHAR(200)='',
     @ContainerType         VARCHAR(100)='',   
     @PickUpDateFrom        DATE='01/01/2020',    
     @PickUpDateTo          DATE='12/31/2099',    
     @PickupTypeKey         SMALLINT=0,    
     @BookingNo             VARCHAR(50) = '',    
     @DriverKey             INT = 0,    
     @marketLocationKey     INT = 0,    
     @searchText            NVARCHAR(MAX)='',    
     @LegID                 VARCHAR(100)='',    
     @CarrierStatus         INT=0,    
     @Dispatcher            INT=0,    
     @IsDriverApp           INT=0,
     @SearchCriteriaKey     INT = 0,
     @StatusKey             NVARCHAR(20) = 0,
     @PageNo                INT = 1,
     @PageSize              INT = 10

 SELECT @Weekday = WeekDay, @Customer = Customer, @OrderNo = OrderNo,
        @ContainerNo = ContainerNo, @LegType = LegType, @ContainerType = ContainerType,
        @PickUpDateFrom = PickupDateFrom, @PickUpDateTo = PickupDateTo, @PickupTypeKey = PickupTypeKey,
        @BookingNo = BookingNo, @DriverKey = DriverKey, @marketLocationKey = MarketLocationKey,
        @searchText = ltrim(rtrim(isnull(searchText,''))), @LegID = LegID, @CarrierStatus = CarrierStatus,
        @Dispatcher = Dispatcher, @IsDriverApp = IsDriverApp, @SearchCriteriaKey = SearchCriteriaKey,
        @StatusKey = StatusKey,
        @PageNo   = ISNULL(PageNo,  1),
        @PageSize = ISNULL(PageSize, 10)
FROM OPENJSON(@JSONString, '$')
	WITH (
            [Weekday]           CHAR(3)         '$.Weekday',    
            Customer            VARCHAR(50)     '$.Customer',
            OrderNo             VARCHAR(20)     '$.OrderNo',
            ContainerNo         VARCHAR(20)     '$.ContainerNo',
            LegType             VARCHAR(200)    '$.LegType',
            ContainerType       VARCHAR(100)    '$.ContainerType',
            PickUpDateFrom      DATE            '$.PickUpDateFrom',
            PickUpDateTo        DATE            '$.PickUpDateTo',
            PickupTypeKey       SMALLINT        '$.PickupTypeKey',    
            BookingNo           VARCHAR(50)     '$.BookingNo',
            DriverKey           INT             '$.DriverKey',
            marketLocationKey   INT             '$.MarketLocationKey',    
            searchText          NVARCHAR(MAX)   '$.SearchText',    
            LegID               VARCHAR(100)    '$.LegID',    
            CarrierStatus       INT             '$.CarrierStatus',    
            Dispatcher          INT             '$.Dispatcher',    
            IsDriverApp         INT             '$.IsDriverApp',
            SearchCriteriaKey   INT             '$.SearchCriteriaKey',
            StatusKey           NVARCHAR(20)    '$.Status',
            PageNo              INT             '$.PageNo',
            PageSize            INT             '$.PageSize'
    )

 SET @PageNo   = CASE WHEN ISNULL(@PageNo,   0) < 1 THEN 1  ELSE @PageNo   END
 SET @PageSize = CASE WHEN ISNULL(@PageSize, 0) < 1 THEN 10 ELSE @PageSize END

 DECLARE @OffsetRows INT = (@PageNo - 1) * @PageSize

     IF( @PickUpDateFrom='0001-01-01 00:00:00')    
     BEGIN
      SET @PickUpDateFrom = '2020-01-01'    
     END    
     
     IF(@PickUpDateTo='0001-01-02 00:00:00')    
     BEGIN    
      SET @PickUpDateTo = '2050-12-31'    
     END

    IF(@IsDebug=1)
    BEGIN
	    SELECT '@searchText', @searchText;
	    SELECT '@PageNo', @PageNo, '@PageSize', @PageSize, '@OffsetRows', @OffsetRows; -- ► NEW
    END
    
    DECLARE @OrderDetailKey    INT
    DECLARE @StartDate         DATETIME
    DECLARE @EndDate           DATETIME
    DECLARE @PickUpFrom        VARCHAR(50)
    DECLARE @ContCmnt          VARCHAR(2000)
    DECLARE @HazardTypeKey     SMALLINT
    
    SET @StartDate=CAST(GETDATE() AS DATE)
    SET @EndDate= DATEADD(d,7,@StartDate)
    SET @PickUpFrom= ( SELECT PickUpType FROM PickUpType  WITH (NOLOCK) WHERE PickupTypeKey=@PickupTypeKey)
    SELECT @HazardTypeKey  = ContainerTypeKey FROM ContainerTypes  WITH (NOLOCK)  WHERE TypeID = 'Hazard'

    IF(@IsDebug = 1)
    BEGIN
        SELECT '@StartDate', @StartDate, '@EndDate', @EndDate;
        SELECT '@PickUpFrom', @PickUpFrom, '@HazardTypeKey', @HazardTypeKey, '@ContCmnt', @ContCmnt;
    END    
     
 SELECT [Value] AS ContainerType INTO #ContainerType FROM Fn_SplitParamCol(@ContainerType)     
    
 SELECT [Value] AS LegKey INTO #LegKeys FROM Fn_SplitParam(@LegID)    
     
 SELECT  OrderDetailkey INTO #OrderDetailkey_Temp FROM OrderDetail WHERE ContainerNo = ISNULL(@searchText,'-') AND ISNULL(ContainerNo,'') <> ''    
    
 CREATE TABLE #OrderDetailStatus    
 (    
  StatusKey INT    
 )    

 IF(@IsDebug = 1)
 BEGIN
    Select '#OrderDetailkey_Temp', * FROM #OrderDetailkey_Temp;
 END
    
 IF((SELECT count(1) FROM #OrderDetailkey_Temp) > 0)    
  BEGIN    
   INSERT into #OrderDetailStatus    
   SELECT [Status] FROM OrderDetailStatus  WITH (NOLOCK)
  END    
 ELSE    
  BEGIN    
   INSERT into #OrderDetailStatus    
   SELECT [Status] FROM OrderDetailStatus WITH (NOLOCK)    
   WHERE Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold','Open')    
  END    
    
 Set @StatusKey = replace(@StatusKey,':','')    
 if(isnull(@StatusKey,'') = '')    
 Begin    
  set @StatusKey = 0    
 End    
 
 CREATE TABLE #OrderDetailKeys
  (
	  OrderDetailKey    INT
  )
  
DECLARE @IsSearchActive BIT = 0;

IF(ISNULL(@SearchText,'') <> '')
BEGIN
    SET @IsSearchActive = 1;

    IF(Charindex(',',@SearchText)=0)
	BEGIN
		INSERT INTO #OrderDetailKeys
		SELECT DISTINCT OrderDetailKey
		FROM OrderDetail OD WITH (NOLOCK)
		INNER JOIN OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
		where OH.OrderNo =  @SearchText  OR
			ISNULL(OD.BookingNo,OH.BookingNo) =  @SearchText   OR
			ContainerNo =  @SearchText  OR
			ISNULL(OD.BillOfLadding,OH.BillOfLading)=  @SearchText  OR                
            ISNULL(OD.CustRefNo,OH.BrokerRefNo) =  @SearchText
	END
	ELSE
    BEGIN
	    IF(@SearchCriteriaKey = 1)
	    BEGIN
		    INSERT INTO #OrderDetailKeys
			    SELECT OrderDetailKey
			    FROM OrderDetail OD WITH (NOLOCK)
			    WHERE ContainerNo IN (SELECT VALUE FROM fn_splitparam(@searchText))
	    END		
	    ELSE IF(@SearchCriteriaKey = 2)
	    BEGIN
		    INSERT INTO #OrderDetailKeys
			    SELECT DISTINCT OrderDetailKey
			    FROM OrderDetail OD WITH (NOLOCK)
			    inner join OrderHeader OH WITH (NOLOCK) on OD.orderKey = OH.orderKey
			    WHERE OrderNo IN (SELECT VALUE FROM fn_splitparam(@searchText))
	    END
	    ELSE IF(@SearchCriteriaKey = 3)
	    BEGIN
		    INSERT INTO #OrderDetailKeys
			    SELECT DISTINCT OrderDetailKey
				    FROM OrderDetail OD WITH (NOLOCK)
				    INNER JOIN OrderHeader OH WITH (NOLOCK) on OH.OrderKey = OD.OrderKey
				    WHERE ISNULL(OD.BillOfLadding, OH.BillOfLading) IN (SELECT VALUE FROM fn_splitparam(@SearchText))
	    END
	    ELSE IF(@SearchCriteriaKey = 5)
	    BEGIN
		    INSERT INTO #OrderDetailKeys
			    SELECT OrderDetailKey
			    FROM OrderDetail OD WITH (NOLOCK)
			    INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
			    WHERE ISNULL(OD.CustRefNo,OH.BrokerRefNo) IN (SELECT VALUE FROM fn_splitparam(@searchText))
	    END
    END
END

DECLARE @HasTempKeys BIT = CASE WHEN EXISTS(SELECT 1 FROM #OrderDetailkey_Temp) 
                                THEN 1 ELSE 0 END

IF(@IsDebug=1)
BEGIN
	SELECT '#OrderDetailKeys',* FROM #OrderDetailKeys;
END
   
  SELECT
  WeekNum =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  datepart(WEEKDAY, RT.PickupDateFrom )     
      WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN -9 ELSE 9 END ,    
   [WeekDay] =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  LEFT(DATENAME(DW,RT.PickupDateFrom ) ,3)    
      WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN 'PAS' ELSE 'FUT' END ,    
    CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, PickupDateFrom), 0) AS TIME),0) AS ContainerPickUpTime,    
   OD.ContainerNo,OrderType, OD.DropOffDate,    
   isnull(SR.AddrName,'') AS Origin,     
   isnull(DT.AddrName,'') AS FinalDestination,
   OD.OrderDetailKey,OD.OrderKey,OrderNo,CustName,RTS.Description as StatusName ,     
   convert(bit,isnull(dbo.FN_IsOrderDetailComplete(OD.OrderDetailKey),0)) as ReadyToRelease,     
   convert(bit,isnull(dbo.FN_MoveComplete(OD.OrderDetailKey),0)) AS ReadytoMoveComplete,    
   isnull( OH.BookingNo,'') as BookingNo,    
   ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+    
    ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') as  CustAddress,     
	ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) OrderTypeKey,    
  ISNULL(RC.TotalLegs,0) AS LegNo,
  CAST(
    CASE 
        WHEN ISNULL(OD.CurrentLegNo,0) = 0 THEN 1 
        ELSE OD.CurrentLegNo 
    END 
AS VARCHAR(50))
+ ' of ' +
CAST(ISNULL(RC.TotalLegs,0) AS VARCHAR(50)) AS CurLeg

   ,isnull(SRR.AddrName,'') AS FromLocation,    
   isnull(DTR.AddrName,'') AS ToLocation,    
   isnull(DR.DriverID + ' : ' + DR.FirstName+' '+ISNULL(DR.LastName,''),'')  AS DriverName,    
   Dr.DriverKey,    
   isnull(RT.ScheduledPickupDate,'01-01-1900') as ScheduledPickupDate,    
   isnull(RT.ScheduledArrival,'01-01-1900') as ScheduledArrival,    
   RT.RouteKey    
   ,isnull(SRR.AddrName,'') AS S_AddrName,    
   isnull(SRR.Address1,'') AS S_Address1,     
   isnull(SRR.City,'') AS S_City,    
   isnull(sRR.State,'') as s_State ,    
   isnull(SRR.ZipCode,'') AS S_ZipCode,    
   isnull(SRR.Country,'') AS S_Country    
   ,isnull(DTR.AddrName,'') AS D_AddrName,    
   isnull(DTR.Address1,'') AS D_Address1,    
   isnull(DTR.City,'') AS D_City,    
   isnull(DTR.State,'') AS D_State,     
   isnull(DTR.ZipCode,'') AS D_ZipCode,    
   isnull(DTR.Country,'') AS D_Country,    
   isnull(RT.PickupDateFrom,'01-01-1900')  as PickupDateFrom,    
   isnull(RT.PickupDateTo,'01-01-1900') as PickupDateTo,    
   isnull(RT.DeliveryDateFrom,'01-01-1900')  as DeliveryDateFrom,    
   isnull(RT.DeliveryDateTo,'01-01-1900') as DeliveryDateTo,    
   Case when isnull(HZ.TypeID,'') = '' then 0 else 1 end as IsHazmat,    
   isnull(CDC.DocumentCount,0) as DocumentCount,    
   isnull(od.IsEmpty,0) as IsEmpty,    
   isnull(pt.PickUpType,'') as PickUpType,    
   isnull(s.Description,'') as ContainerSize,     
   isnull(s.ContainerSizeKey,0) as ContainerSizeKey,    
   isnull(od.VesselETA,'01-01-1900') as VesselETA,    
   isnull(BillOfLading,'') as BillOfLading,    
   ContainerType= '',    
   od.IsStreetTurn,    
   ISNULL(u2.UserName,'') AS StreetTurnSetUser,    
   OD.StreetTurnSetDate,    
   OD.IsLinked,    
   OD.LinkedContainerNo,    
   OD.LinkedOrderDetailKey,    
      CAST(ISNULL(OD.TMFCheckOff,0)AS BIT) TMFCheckOff ,    
   CAST(ISNULL(OD.CTFCheckOff,0) AS BIT) CTFCheckOff ,    
   CAST(ISNULL(OD.IsTMFJCTPaid,0) AS BIT) IsTMFJCTPaid,    
   CAST(ISNULL(OD.IsTMFCustomerPaid,0) AS BIT) IsTMFCustomerPaid,    
   CAST(ISNULL(OD.IsCTFJCTPaid,0) AS BIT) IsCTFJCTPaid,    
   CAST(ISNULL(OD.IsCTFCustomerPaid,0) AS BIT) IsCTFCustomerPaid,    
   RT.[Status],    
   L.LegID as LegID,    
   isnull(RT.ScheduledPickupDate,'01-01-1900') as ContainerTime,    
   DelayHours =  Case when RT.[Status] = 2 then 0     
        when RT.ScheduledPickupDate is null then 0    
        else DATEDIFF(HOUR, RT.ScheduledPickupDate, Getdate()) end,    
   DayNightIndicator = Case when RT.ScheduledPickupDate is null then 'NA'    
       when DATEPART(Hour,RT.ScheduledPickupDate) >= 18 then 'Night'    
       when DATEPART(Hour,RT.ScheduledPickupDate) <= 2 then 'Night'    
       else 'Day' end,    
   STUFF((SELECT distinct ', ' + CMT.MoveTypeName    
         from CarrierMoveType CMT  WITH (NOLOCK)    
   INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1    
            FOR XML PATH(''), TYPE    
            ).value('.', 'NVARCHAR(MAX)')     
        ,1,2,'') MoveTypes,    
  CASE WHEN RT.ActualDepartureUpdateMethod ='DriverApp' OR RT.ActualArrivalUpdateMethod='DriverApp' OR     
    RT.ChassisSource='DriverApp' OR RT.DryRunSource='DriverApp' OR     
    RT.EmptySource='DriverApp' OR RT.BobtailSource='DriverApp' OR    
    RT.StreetTurnSource='DriverApp' THEN 1    
  ELSE 2 END AS IsDriverApp,    
  ML.MarketLocationKey,ML.MarketLocation,TT.TruckType,DR.TruckTypeKey, SL.LineName AS SteamShipLine,    
  CH.chassisNo AS ChassisNo, CUS.CustID AS CustID, OH.CustKey AS CustKey, CAST(ISNULL(MarkedNoEmptyAvailable,0) AS BIT) MarkedNoEmptyAvailable,    
  PortDropLegCount=(SELECT COUNT(LegKey) FROM [Routes] RTI WITH (NOLOCK) WHERE RTI.OrderDetailKey=OD.OrderDetailKey AND LegKey IN (35,37,39,52,54,56)),    
  LAST_ROUTEKEY,
  ETA_ATAChangedByUser,ContainerStatusChangedByUser,ISNULL(MBLChangedByUser,0) MBLChangedByUser,
  LFDChangedByUser, SSLChangedByUser, Size_TypeChangedByUser,HoldChangedByUser,VesselChangedByUser,
  AvailableChangedByUser,HoldTypeChangedByUser,AvailableDateChangedByUser
 into #Data    
      
FROM (SELECT * FROM dbo.OrderDetail WITH (NOLOCK)    
      WHERE @HasTempKeys = 0
         OR (@HasTempKeys = 1 AND OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailkey_Temp))
     ) OD
  INNER JOIN  dbo.OrderHeader OH   WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey    
  INNER JOIN  dbo.Customer CUS   WITH (NOLOCK) ON CUS.CustKey=OH.CustKey    
  INNER JOIN  dbo.OrderType OT   WITH (NOLOCK) ON OT.OrderTypeKey=isnull(OD.ordertypekey,OH.OrderTypeKey )  
  INNER JOIN  dbo.[Routes] RT    WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey    
  LEFT JOIN (
    SELECT OrderDetailKey, COUNT(*) AS TotalLegs
    FROM Routes WITH (NOLOCK)
    GROUP BY OrderDetailKey
) RC ON RC.OrderDetailKey = OD.OrderDetailKey
  INNER JOIN (SELECT ORDERDETAILKEY , MAX(ROUTEKEY) AS LAST_ROUTEKEY FROM DBO.ROUTES  WITH (NOLOCK) GROUP BY ORDERDETAILKEY)    
   RTM  ON RTM.OrderDetailKey=OD.OrderDetailKey
  INNER JOIN  dbo.Leg L     WITH (NOLOCK) ON RT.LegKey=L.LegKey    
  INNER JOIN  dbo.LegType LT    WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey    
  INNER JOIN  dbo.RouteStatus RTS   WITH (NOLOCK) ON RTS.[Status]=ISNULL(RT.[Status],1)     
  LEFT JOIN   dbo.[Address] CAdr   WITH (NOLOCK) ON CAdr.Addrkey=OH.BillToAddrKey    
  LEFT JOIN   dbo.[Address] SRR   WITH (NOLOCK) ON SRR.Addrkey=RT.SourceAddrkey    
  LEFT JOIN   dbo.[Address] DTR   WITH (NOLOCK) ON DTR.Addrkey=RT.DestinationAddrkey    
  LEFT JOIN   dbo.[Address] SR   WITH (NOLOCK) ON SR.Addrkey=OD.SourceAddrKey    
  LEFT JOIN   dbo.[Address] DT   WITH (NOLOCK) ON DT.Addrkey=OD.DestinationAddrKey    
  LEFT JOIN   dbo.Driver DR    WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey    
  LEFT JOIN   dbo.Chassis CH    WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey     
  LEFT JOIN   dbo.ContainerSize S   WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey     
  Left JOIN OrderDetailStatus RS  WITH (NOLOCK) ON OD.[Status] = RS.[Status]  
  Left join dbo.PickUpType PT   WITH (NOLOCK) on L.PickupTypeKey = PT.PickupTypeKey    
  LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey    
  Inner join #OrderDetailStatus ODS on ODS.StatusKey = OD.[Status]    
  lEFT jOIN [USER] u2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey    
  LEFT JOIN (SELECT TOP 1 HZ1.* FROM vContainerType HZ1  WITH (NOLOCK)    
  LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON HZ1.ORDERDETAILKEY=OD1.OrderDetailKey AND HZ1.ContainerTypeKey = @HazardTypeKey) HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey    
  LEFT JOIN (SELECT TOP 1 CTL1.* FROM ContainerTypesLink CTL1  WITH (NOLOCK)    
  LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON CTL1.OrderDetailKey=OD1.OrderDetailKey AND CTL1.IsSelected = 1) CTL ON HZ.ORDERDETAILKEY = OD.OrderDetailKey    
  LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey    
  LEFT JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=DR.TruckTypeKey    
  LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey    
  LEFT JOIN (select distinct ODI.OrderDetailKey,    
     CASE WHEN DRA.Description ='Reject' AND ISNULL(RTI.DriverKey,0)=0 THEN 1
     WHEN RTI.[Status] in (2,3) THEN 2
     WHEN RTI.[Status]=4 THEN 3
     WHEN RTI.[Status]=1 THEN 4
     WHEN DRA.Description='Accept' THEN 5
     ELSE 0    
     END AS RouteStatus    
     from Orderdetail ODI  WITH (NOLOCK)    
     LEFT JOIN Routes RTI  WITH (NOLOCK) ON (RTI.RouteKey=ODI.CurrentRouteKey)    
     LEFT JOIN DriverRouteAcceptance DRA WITH (NOLOCK) ON DRA.RouteKey=RTI.RouteKey) CS ON CS.OrderDetailKey=OD.OrderDetailKey     
	OUTER APPLY (
						SELECT TOP 1 *
						FROM Container_GnosisData CGDI WITH (NOLOCK)
						WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
						)CGD
 WHERE OD.Status not in (11,14,15) and  RT.RouteKey = LAST_ROUTEKEY    
 AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)    
 AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)     
 AND (@Weekday  IS NULL OR @Weekday=''  OR     
   LEFT( (CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN upper(DATENAME(DW,RT.PickupDateFrom ) )    
      WHEN RT.PickupDateFrom<@StartDate THEN 'PAS'ELSE 'FUT' END),3)= @Weekday)    
  AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)    
  AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)      
  AND (isnull(@PickupTypeKey,0) = 0 OR L.PickupTypeKey = @PickupTypeKey)     
  AND (Isnull(@ContainerType,'') = '' OR CTl.ContainerTypeKey in (select ContainerType from #ContainerType))    
  AND (Isnull(@LegID,'') = '' OR RT.LegKey in (select LegKey from #LegKeys))  
  AND (isnull(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey)    
  AND (  ISNULL(@marketLocationKey,0) = 0 OR  OH.MarketLocationKey = @marketLocationKey )    
  AND (ISNULL(@Dispatcher,0)=0 OR RT.CarrierAssignedBy=@Dispatcher)    
  AND (ISNULL(@CarrierStatus,'')='' OR CS.RouteStatus=@CarrierStatus)
  AND (@IsSearchActive = 0 OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys))

    
 IF(@IsDebug = 1)    
 BEGIN
  SELECT '#Data', COUNT(1) FROM #Data    
  SELECT * FROM #OrderDetailStatus          
 END
 
 SELECT A.[Description] AS StatusName ,A.[Status],COUNT(ContainerNo) AS ContainerCount,'I' as [Level]     
 INTO #DashBoarData1    
 FROM dbo.RouteStatus A WITH (NOLOCK)    
  LEFT JOIN #Data F ON F.StatusName=A.Description    
 GROUP BY A.[Description],A.[Status]    
 UNION ALL    
 SELECT 'Total Containers' ,0,COUNT(ContainerNo) AS ContainerCount,'S' as Level    
 FROM dbo.RouteStatus A WITH (NOLOCK)    
  LEFT JOIN #Data F ON F.StatusName=A.Description    
       
 SELECT A.StatusName,A.[Status],A.ContainerCount,A.[Level],ISNULL(B.OrderBy ,50) AS OrderBy     
 INTO #DashBoarData    
 FROM  #DashBoarData1 A    
 LEFT JOIN dbo.RouteStatus B ON B.[Description]=A.StatusName    

 DECLARE @TotalCount INT = (
     SELECT COUNT(1)
     FROM #Data
     WHERE (ISNULL(@StatusKey, 0) = 0 OR @StatusKey = [Status])
       AND (ISNULL(@IsDriverApp, 0) = 0 OR IsDriverApp = @IsDriverApp)
 )
 
    IF(@IsDebug = 1)
    BEGIN
      SELECT * 
      FROM #data    
      WHERE (ISNULL( @StatusKey,0) = 0 OR @StatusKey = [Status])     
      AND (ISNULL(@IsDriverApp,0)=0 OR IsDriverApp=@IsDriverApp)    
      ORDER BY ContainerTime, ScheduledPickupDate, ContainerNo
      OFFSET @OffsetRows ROWS FETCH NEXT @PageSize ROWS ONLY
    END
    
IF(@IsDebug = 0)
BEGIN
     SELECT    
      DispatchListResult = (    
        SELECT *     
        FROM #data    
        WHERE (ISNULL(@StatusKey, 0) = 0 OR @StatusKey = [Status])     
          AND (ISNULL(@IsDriverApp, 0) = 0 OR IsDriverApp = @IsDriverApp)    
        ORDER BY ContainerTime, ScheduledPickupDate, ContainerNo
        OFFSET @OffsetRows ROWS FETCH NEXT @PageSize ROWS ONLY
        FOR JSON AUTO    
      ),    
      DashBoardData = (    
        SELECT A.[Status] AS StatusKey, A.StatusName AS Description,     
               A.Level, A.OrderBy, A.ContainerCount AS DispatchCount     
        FROM #DashBoarData A
        FOR JSON AUTO    
      ),
      TotalCount  = @TotalCount
      --PageNo      = @PageNo,
      --PageSize    = @PageSize,
      --TotalPages  = CEILING(CAST(@TotalCount AS FLOAT) / @PageSize)
     FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
 END

 DROP TABLE #data
 DROP TABLE #DashBoarData
 DROP TABLE #OrderDetailStatus
 DROP TABLE #OrderDetailkey_Temp
 DROP TABLE #LegKeys
 DROP TABLE #ContainerType
 DROP TABLE #OrderDetailKeys
 DROP TABLE #DashBoarData1

 SET @Status = 1;
 SET @Reason = 'Success';
END