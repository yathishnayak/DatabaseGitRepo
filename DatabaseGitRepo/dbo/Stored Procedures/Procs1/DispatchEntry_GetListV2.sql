
/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"PageNo":1,"PageSize":10,"Ascending":false,"SearchText":"IMPT2511017","DriverKey":0,"MarketLocationKey":0,"CarrierStatus":0,"Dispatcher":0,"IsDriverApp":0,"ContainerNo":"","Customer":"","LegType":"","OrderNo":"","TabStatus":"1:","WeekDay":"","PickupTypeKey":0,"PickupDateFrom":"2020-01-01T00:00:00.000Z","PickupDateTo":"2050-01-01T00:00:00.000Z","ContainerType":"",
	"OrderType":"","LocationType":"","ContainerLocation":"","SortField":"voucherno","LegID":"","EmptyvLoaded":0,"DropvLive":"","DroppedContainer":"","Urgent":0 }',
	@Status BIT=0, @IsDebug BIT = 0,
	@Reason VARCHAR(100)='', @JSONResult Nvarchar(MAX) = ''
EXEC DispatchEntry_GetListV2 @UserKey,@JSONString,@Status OUTPUT,@IsDebug,@Reason OUTPUT, @JSONResult Output
SELECT @Status, @Reason, @JSONResult
**/

CREATE PROCEDURE [dbo].[DispatchEntry_GetListV2]   
(
    @UserKey    INT=951,
    @JSONString	NVARCHAR(MAX) = '',
    @Status BIT=0 OUTPUT,
    @IsDebug BIT = 0,
    @Reason VARCHAR(100)='' OUTPUT,
    @JSONResult NVARCHAR(MAX) = '' OUTPUT
)
AS    
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

    DECLARE @Weekday		 CHAR(20)='',    
        @Customer            VARCHAR(50)='',    
        @OrderNo             VARCHAR(20)='',    
        @ContainerNo         VARCHAR(20)='',    
        @LegType             VARCHAR(200)='', 
		@TabStatus           VARCHAR(100)='',
        @ContainerType       VARCHAR(100)='',   
        @PickUpDateFrom      DATE='01/01/2020',    
        @PickUpDateTo        DATE='12/31/2099',    
        @PickupTypeKey       SMALLINT=0,    
        @BookingNo           VARCHAR(50) = '',    
        @DriverKey           INT = 0,    
        @marketLocationKey   INT = 0,    
        @searchText          VARCHAR(100)='',    
        @LegID               VARCHAR(100)='',    
        @CarrierStatus       INT=0,    
        @Dispatcher          INT=0,    
        @IsDriverApp         INT=0,    
        @OrderDetailKey      INT,   
        @StartDate           DATETIME,     
        @ENDDate             DATETIME,    
        @PickUpFrom          VARCHAR(50),    
        @ContCmnt            VARCHAR(2000),    
        @HazardTypeKey       SMALLINT,
        @OrderType           VARCHAR(100)='',
        @LocationType        VARCHAR(200)='',
        @EmptyvLoaded        INT=0,
		@DropvLive			 CHAR(1)='',
		@ContainerLocation	 VARCHAR(100)='',
		@DroppedContainer    VARCHAR(100)='',
		@RangeStartDate		 DATE,
		@RangeEndDate		 DATE,
		@Urgent				 BIT

    IF(ISNULL(ltrim(rtrim(@JSONString)) ,'') = '')
    BEGIN
        SET @Status = 0
        SET @Reason = 'Parameters NOT found'
		Commit
        return
    END

	BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @Weekday = Weekday, @Customer = ISNULL(Customer,''), @OrderNo = ISNULL(OrderNo,''), @ContainerNo = ISNULL(ContainerNo,''), @LegType = ISNULL(LegType,''),
            @TabStatus = ISNULL(TabStatus,''),@ContainerType = ISNULL(ContainerType,''), @PickUpDateFrom = ISNULL(PickUpDateFrom,'01/01/2020'), @PickUpDateTo = ISNULL(PickUpDateTo,'12/31/2099'),
            @PickupTypeKey = ISNULL(PickupTypeKey, 0), @BookingNo = ISNULL(BookingNo,''), @DriverKey = ISNULL(DriverKey, 0), @marketLocationKey = ISNULL(marketLocationKey,0),
            @searchText = ISNULL(searchText,''), @LegID = ISNULL(LegID,''), @CarrierStatus = ISNULL(CarrierStatus,0), @Dispatcher = ISNULL(Dispatcher,0),
            @IsDriverApp = ISNULL(IsDriverApp,0), @OrderDetailKey = ISNULL(OrderDetailKey,0), @StartDate = ISNULL(StartDate,''), @ENDDate = ISNULL(ENDDate,''),
            @PickUpFrom = ISNULL(PickUpFrom,''), @ContCmnt = ISNULL(ContCmnt,''), @HazardTypeKey = ISNULL(HazardTypeKey,0), @OrderType = ISNULL(OrderType,''),
            @LocationType = ISNULL(LocationType,''), @EmptyvLoaded = ISNULL(EmptyvLoaded,0), @DropvLive = ISNULL(DropvLive,''), @ContainerLocation = ISNULL(ContainerLocation,''),
			@DroppedContainer = ISNULL(DroppedContainer,''), @Urgent = ISNULL(Urgent,'')
        FROM OpenJSON(@JSONString, '$')
	    WITH (
	    	Weekday				    CHAR(20)		   '$.Weekday',
	    	Customer				VARCHAR(50)	   '$.Customer',
	    	OrderNo					VARCHAR(20)	   '$.OrderNo',
	    	ContainerNo				VARCHAR(20)	   '$.ContainerNo',
	    	LegType					VARCHAR(200)   '$.LegType',
			TabStatus				VARCHAR(100)   '$.TabStatus',
	    	ContainerType			VARCHAR(100)   '$.ContainerType',
	    	PickUpDateFrom			DATE		   '$.PickUpDateFrom',
	    	PickUpDateTo			DATE		   '$.PickUpDateTo',
	    	PickupTypeKey			SMALLINT	   '$.PickupTypeKey',
	    	BookingNo				VARCHAR(50)	   '$.BookingNo',
	    	DriverKey				INT			   '$.DriverKey',
	    	marketLocationKey		INT			   '$.MarketLocationKey',
	    	searchText				VARCHAR(100)   '$.SearchText',
	    	LegID					VARCHAR(100)   '$.LegID',
	    	CarrierStatus			INT			   '$.CarrierStatus',
	    	Dispatcher				INT			   '$.Dispatcher',
	    	IsDriverApp				INT			   '$.IsDriverApp',
	    	OrderDetailKey			INT			   '$.OrderDetailKey',
	    	StartDate				DATETIME	   '$.StartDate',
	    	ENDDate					DATETIME	   '$.ENDDate',
            PickUpFrom				VARCHAR(50)	   '$.PickUpFrom',
            ContCmnt				VARCHAR(2000)  '$.ContCmnt',
	    	HazardTypeKey			SMALLINT	   '$.HazardTypeKey',
	    	OrderType				VARCHAR(100)   '$.OrderType',
            LocationType            VARCHAR(200)   '$.LocationType',
            EmptyvLoaded            INT            '$.EmptyvLoaded',
			DropvLive				CHAR(1)		   '$.DropvLive',
			ContainerLocation		VARCHAR(100)   '$.ContainerLocation',
			DroppedContainer        VARCHAR(100)   '$.DroppedContainer',
			Urgent					BIT			   '$.Urgent'
	    )

		IF( @PickUpDateFrom='0001-01-01 00:00:00')    
		BEGIN
		    SET @PickUpDateFrom = '2020-01-01'
		END

		IF(@PickUpDateTo='0001-01-02 00:00:00')    
		BEGIN
		    SET @PickUpDateTo = '2050-12-31'
		END

        SET @StartDate=CAST(GETDATE() AS DATE)
        SET @ENDDate= DATEADD(d,7,@StartDate)

		SELECT @RangeStartDate = StartDate, @RangeEndDate = EndDate
		FROM v_DateRanges
		WHERE RangeName = @Weekday

        SET @PickUpFrom= ( SELECT PickUpType
        FROM PickUpType  WITH (NOLOCK)
        WHERE PickupTypeKey=@PickupTypeKey)

        SELECT @HazardTypeKey  = ContainerTypeKey
        FROM ContainerTypes  WITH (NOLOCK)
        WHERE TypeID = 'Hazard'

        SELECT [Value] AS ContainerType
        INTO #ContainerType
        FROM Fn_SplitParamCol(@ContainerType)

        SELECT [Value] AS LegKey
        INTO #LegKeys
        FROM Fn_SplitParam(@LegID)

        SELECT [Value] AS OrderTypeKey
        INTO #OrderTypeKeys
        FROM Fn_SplitParamCol(@OrderType)

        SELECT [Value] AS LocationType
        INTO #LocationTypes
        FROM Fn_SplitParamCol(@LocationType)

		SELECT [Value] AS ContainerLocationKey
        INTO #ContainerLocationKeys
        FROM Fn_SplitParamCol(@ContainerLocation)

		--select *  from #LocationTypes
        -- UPDATE #LocationTypes
        -- SET LocationType=REPLACE(LocationType,'To ','')
        -- UPDATE #LocationTypes
        -- SET LocationType=REPLACE(LocationType,'From ','')

        SELECT OrderDetailkey
        INTO #OrderDetailkey_Temp
        FROM OrderDetail
        WHERE ContainerNo = ISNULL(@searchText,'-') AND ISNULL(ContainerNo,'') <> ''

        --SET @OrderDetailKey = ISNULL(@OrderDetailKey,0)    

        IF @IsDebug = 1    
        BEGIN
            SELECT @searchText, @OrderDetailKey
        END

        CREATE TABLE #OrderDetailStatus
        (
            StatusKey INT
        )

        -- SELECT @IsContainerSearch    

        IF((SELECT COUNT(1)
        FROM #OrderDetailkey_Temp) > 0)    
        BEGIN
            INSERT INTO #OrderDetailStatus
            SELECT Status
            FROM OrderDetailStatus  WITH (NOLOCK)
        END    
        ELSE    
        BEGIN
            INSERT INTO #OrderDetailStatus
            SELECT Status
            FROM OrderDetailStatus WITH (NOLOCK)
            WHERE Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold')
        END

        SET @TabStatus = REPLACE(@TabStatus,':','')
        IF(ISNULL(@TabStatus,'') = '')    
        BEGIN
            SET @TabStatus = 0
        END

        --DECLARE @JSONResult NVARCHAR(MAX) = ''

        SELECT TOP 1000
            WeekNum =  CASE 
						WHEN RT.PickupDateFrom BETWEEN @StartDate AND @ENDDate THEN  DATEPART(WEEKDAY, RT.PickupDateFrom )     
						WHEN RT.PickupDateFrom < CONVERT(Date,@StartDate) THEN -9 ELSE 9 END,
            [WeekDay] = CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @ENDDate THEN  LEFT(DATENAME(DW,RT.PickupDateFrom ), 3)    
							 WHEN RT.PickupDateFrom < CONVERT(Date,@StartDate) THEN 'PAS' ELSE 'FUT' END ,
            --ISNULL(MIN(PickupDateFrom) OVER( PARTITION BY OD.OrderDetailKey Order by OD.OrderDetailKey ),'12:00') AS ContainerPickUpTime,    
            CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, PickupDateFrom), 0) AS TIME),0) AS ContainerPickUpTime,
            OD.ContainerNo, OrderType, OD.DropOffDate,
            ISNULL(SR.AddrName,'') AS Origin,
            ISNULL(DT.AddrName,'') AS FinalDestination,--Origin,FinalDestination,    
            OD.OrderDetailKey, OD.OrderKey, OrderNo, CustName, RTS.Description AS StatusName ,
            CONVERT(BIT,ISNULL(dbo.FN_IsOrderDetailComplete(OD.OrderDetailKey),0)) AS ReadytoReleASe,
            CONVERT(BIT,ISNULL(dbo.FN_MoveComplete(OD.OrderDetailKey),0)) AS ReadytoMoveComplete,
            ISNULL( OH.BookingNo,'') AS BookingNo,
            ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+    
            ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') AS  CustAddress,
            ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) OrderTypeKey,
            CONVERT(BIGINT,ISNULL(OD.CurrentLegNo,0) ) AS LegNo, 
			CAST(ISNULL(OD.CurrentLegNo,0) AS VARCHAR(50))+' of '+CAST(OD.TotalLegs AS VARCHAR(50)) AS CurLeg, 
			ISNULL(SRR.AddrName,'') AS FromLocation,
            ISNULL(DTR.AddrName,'') AS ToLocation,
            ISNULL(DR.DriverID + ' : ' + DR.FirstName+' '+ISNULL(DR.LAStName,''),'')  AS DriverName,
            Dr.DriverKey,
            ISNULL(RT.ScheduledPickupDate,'01-01-1900') AS ScheduledPickupDate,
            ISNULL(RT.ScheduledArrival,'01-01-1900') AS ScheduledArrival,
            RT.RouteKey, 
			ISNULL(SRR.AddrName,'') AS S_AddrName,
            ISNULL(SRR.Address1,'') AS S_Address1,
            ISNULL(SRR.City,'') AS S_City,
            ISNULL(sRR.State,'') AS s_State ,
            ISNULL(SRR.ZipCode,'') AS S_ZipCode,
            ISNULL(SRR.Country,'') AS S_Country, 
			ISNULL(DTR.AddrName,'') AS D_AddrName,
            ISNULL(DTR.Address1,'') AS D_Address1,
            ISNULL(DTR.City,'') AS D_City,
            ISNULL(DTR.State,'') AS D_State,
            ISNULL(DTR.ZipCode,'') AS D_ZipCode,
            ISNULL(DTR.Country,'') AS D_Country,
            ISNULL(RT.PickupDateFrom,'01-01-1900')  AS PickupDateFrom,
            ISNULL(RT.PickupDateTo,'01-01-1900') AS PickupDateTo,
            ISNULL(RT.DeliveryDateFrom,'01-01-1900')  AS DeliveryDateFrom,
            ISNULL(RT.DeliveryDateTo,'01-01-1900') AS DeliveryDateTo,
            --ISNULL(HZ.IsHazmat,0)  AS IsHazmat,     
            CASE WHEN ISNULL(HZ.TypeID,'') = '' THEN 0 ELSE 1 END AS IsHazmat,
            ISNULL(CDC.DocumentCount,0) AS DocumentCount,
            ISNULL(OD.IsEmpty,0) AS IsEmpty,
            ISNULL(PT.PickUpType,'') AS PickUpType,
            ISNULL(S.Description,'') AS ContainerSize,
            ISNULL(S.ContainerSizeKey,0) AS ContainerSizeKey,
            ISNULL(OD.VesselETA,'01-01-1900') AS VesselETA,
            ISNULL(BillOfLading,'') AS BillOfLading,
            ContainerType= '',
            --STUFF((     
            -- SELECT ', '+ ShortComment     
            -- FROM #ContTypes     
            -- WHERE OrderDetailKey=A.OrderDetailKey    
            -- FOR XML PATH('')), 1, 2, ''),    
            OD.isStreetTurn,
            ISNULL(U2.UserName,'') AS StreetTurnSETUser,
            OD.StreetTurnSETDate,
            OD.IsLinked,
            OD.LinkedContainerNo,
            OD.LinkedOrderDetailKey,
			ODSD.DropOrLive,
            CAST(ISNULL(OD.TMFCheckOff,0)AS BIT) TMFCheckOff ,
            CAST(ISNULL(OD.CTFCheckOff,0) AS BIT) CTFCheckOff ,
            CAST(ISNULL(OD.IsTMFJCTPaid,0) AS BIT) IsTMFJCTPaid,
            CAST(ISNULL(OD.IsTMFCustomerPaid,0) AS BIT) IsTMFCustomerPaid,
            CAST(ISNULL(OD.IsCTFJCTPaid,0) AS BIT) IsCTFJCTPaid,
            CAST(ISNULL(OD.IsCTFCustomerPaid,0) AS BIT) IsCTFCustomerPaid,
            RT.Status,
            L.LegID AS LegID,
            ISNULL(RT.ScheduledPickupDate,'01-01-1900') AS ContainerTime,
            DelayHours =  CASE WHEN RT.Status = 2 THEN 0     
            WHEN RT.ScheduledPickupDate IS NULL THEN 0    
            ELSE DATEDIFF(HOUR, RT.ScheduledPickupDate, GETDATE()) END,
            DayNightIndicator = CASE WHEN RT.ScheduledPickupDate IS NULL THEN 'NA'    
            WHEN DATEPART(HOUR, RT.ScheduledPickupDate) >= 18 THEN 'Night'    
            WHEN DATEPART(HOUR, RT.ScheduledPickupDate) <= 2 THEN 'Night'    
             ELSE 'Day' END,
            STUFF((SELECT DISTINCT ', ' + CMT.MoveTypeName
            FROM CarrierMoveType CMT WITH (NOLOCK)
                INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1
            --   WHERE DR.DriverKey = DM.DriverKey     
            FOR XML PATH(''), TYPE    
                ).value('.', 'NVARCHAR(MAX)'),1,2,'') MoveTypes,
            CASE WHEN RT.ActualDepartureUpdateMethod ='DriverApp' OR RT.ActualArrivalUpdateMethod='DriverApp' OR
                RT.ChASsisSource='DriverApp' OR RT.DryRunSource='DriverApp' OR
                RT.EmptySource='DriverApp' OR RT.BobtailSource='DriverApp' OR
                RT.StreetTurnSource='DriverApp' THEN 1    
            ELSE 2 END AS IsDriverApp,
            ML.MarketLocationKey, ML.MarketLocation, TT.TruckType, DR.TruckTypeKey, SL.LineName AS SteamShipLine,
            RT.ChassisNo AS ChassisNo, CUS.CustID AS CustID, OH.CustKey AS CustKey, CAST(ISNULL(MarkedNoEmptyAvailable,0) AS BIT) MarkedNoEmptyAvailable,
            PortDropLegCount=(SELECT COUNT(LegKey)
            FROM [Routes] RTI WITH (NOLOCK)
            WHERE RTI.OrderDetailKey = OD.OrderDetailKey AND LegKey IN (35, 37, 39, 52, 54, 56)),
            LAST_ROUTEKEY,
            ETA_ATAChangedByUser, ContainerStatusChangedByUser, ISNULL(MBLChangedByUser,0) MBLChangedByUser,
            LFDChangedByUser, SSLChangedByUser, Size_TypeChangedByUser, HoldChangedByUser, VesselChangedByUser,
            AvailableChangedByUser, HoldTypeChangedByUser, AvailableDateChangedByUser,
            RT.ActualArrival ActualDelDate,RT.ActualDeparture  ActualPickup,
            L.FromLocation FromDirection,L.ToLocation ToDirection, CR.CsrName AS Dispatcher, CR.CsrKey AS DispatcherKey, CCK.ChassisCategoryKey
        INTO #Data

        FROM (SELECT *
            FROM dbo.OrderDetail WITH (NOLOCK)
            WHERE ((SELECT count(1)
                FROM #OrderDetailkey_Temp) > 0 AND OrderDetailKey IN (SELECT OrderDetailKey
                FROM #OrderDetailkey_Temp)  ) OR ( (SELECT count(1)
                FROM #OrderDetailkey_Temp) = 0 )) OD
            INNER JOIN dbo.OrderHeader OH   WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
            INNER JOIN dbo.Customer CUS   WITH (NOLOCK) ON CUS.CustKey=OH.CustKey
            INNER JOIN dbo.OrderType OT   WITH (NOLOCK) ON OT.OrderTypeKey=ISNULL(OD.ordertypekey,OH.OrderTypeKey )
            INNER JOIN dbo.[Routes] RT    WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey --AND RT.RouteKey = OD.CurrentRouteKey
            INNER JOIN (SELECT ORDERDETAILKEY , MAX(ROUTEKEY) AS LAST_ROUTEKEY
            FROM DBO.ROUTES  WITH (NOLOCK)
            GROUP BY ORDERDETAILKEY)     
            RTM ON RTM.OrderDetailKey=OD.OrderDetailKey
            INNER JOIN dbo.Leg L     WITH (NOLOCK) ON RT.LegKey=L.LegKey
            INNER JOIN dbo.LegType LT    WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey
            INNER JOIN dbo.RouteStatus RTS   WITH (NOLOCK) ON RTS.[Status]=ISNULL(RT.[Status],1)
            LEFT JOIN dbo.Driver DR    WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey
            LEFT JOIN dbo.Chassis CH    WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey
			LEFT JOIN ChassisCategory CCK WITH (NOLOCK) ON RT.ChassisCategoryKey = CCK.ChassisCategoryKey -- added
            --LEFT JOIN dbo.OrderDetailStatus ODS   WITH (NOLOCK) ON ODS.[Status]=OD.[Status]    
            LEFT JOIN dbo.ContainerSize S   WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey
            LEFT JOIN OrderDetailStatus RS  WITH (NOLOCK) ON OD.Status = RS.Status
            LEFT JOIN dbo.PickUpType PT   WITH (NOLOCK) ON L.PickupTypeKey = PT.PickupTypeKey
            LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEFT JOIN dbo.OrderDetailStops ODSP WITH (NOLOCK) ON OD.OrderDetailKey = ODSP.OrderDetailKey AND ODSP.StopTypeKey=1  
																 AND ISNULL(ODSP.IsDryRunPort,0)=0 AND ISNULL(ODSP.IsDryrunCustomer,0)=0 
            LEFT JOIN dbo.OrderDetailStops ODSD WITH (NOLOCK) ON OD.OrderDetailKey = ODSD.OrderDetailKey AND ODSD.StopTypeKey=3  
																 AND ISNULL(ODSD.IsDryRunPort,0)=0 AND ISNULL(ODSD.IsDryrunCustomer,0)=0  --added for DropOrLive filter
			LEFT JOIN dbo.[Address] CAdr   WITH (NOLOCK) ON CAdr.Addrkey=OH.BillToAddrKey
            --LEFT JOIN dbo.[Address] SRR   WITH (NOLOCK) ON SRR.Addrkey=RT.SourceAddrkey
            --LEFT JOIN dbo.[Address] DTR   WITH (NOLOCK) ON DTR.Addrkey=RT.DestinationAddrkey
			LEFT JOIN dbo.[Address] SRR   WITH (NOLOCK) ON SRR.Addrkey=ISNULL(ODSP.StopAddrKey,RT.SourceAddrkey)
            LEFT JOIN dbo.[Address] DTR   WITH (NOLOCK) ON DTR.Addrkey=ISNULL(ODSD.StopAddrKey,RT.DestinationAddrkey)
            LEFT JOIN dbo.[Address] SR   WITH (NOLOCK) ON SR.Addrkey=OD.SourceAddrKey
            LEFT JOIN dbo.[Address] DT   WITH (NOLOCK) ON DT.Addrkey=OD.DestinationAddrKey
            INNER JOIN #OrderDetailStatus ODS ON ODS.StatusKey = OD.Status
            LEFT JOIN [USER] U2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
            --LEFT JOIN (    
            --   SELECT DISTINCT orderdetailkey, 1 AS IsHazmat FROM #ContTypes WHERE Comment='Hazard'    
            --) HZ ON od.OrderDetailKey = HZ.OrderDetailKey    
            LEFT JOIN (SELECT TOP 1 HZ1.*
            FROM vContainerType HZ1
            LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON HZ1.ORDERDETAILKEY=OD1.OrderDetailKey AND HZ1.ContainerTypeKey = @HazardTypeKey) HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey
            LEFT JOIN (SELECT TOP 1 CTL1.*
            FROM ContainerTypesLink CTL1  WITH (NOLOCK)
            LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON CTL1.OrderDetailKey=OD1.OrderDetailKey AND CTL1.IsSELECTed = 1) CTL ON HZ.ORDERDETAILKEY = OD.OrderDetailKey
            --LEFT JOIN vContainerType HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey AND HZ.ContainerTypeKey = @HazardTypeKey    
            --LEFT JOIN ContainerTypesLink CTL on OD.OrderDetailKey = CTL.OrderDetailKey and CTL.IsSELECTed = 1    
            LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
            LEFT JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=DR.TruckTypeKey
            LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
			LEFT JOIN dbo.CSR CR WITH (NOLOCK)	ON CR.CsrKey= ISNULL(OD.Dispatcher, RT.Dispatcher) -- added
            LEFT JOIN (SELECT DISTINCT ODI.OrderDetailKey,
            CASE WHEN DRA.Description ='Reject' AND ISNULL(RTI.DriverKey,0)=0 THEN 1 --rejected    
            WHEN RTI.Status IN (2,3) THEN 2 --in progress    
            WHEN RTI.Status=4 THEN 3 --driver ASsigned    
            WHEN RTI.Status=1 THEN 4 --pENDing    
            WHEN DRA.Description='Accept' THEN 5 --accept    
            ELSE 0    
            END AS RouteStatus
            FROM Orderdetail ODI  WITH (NOLOCK)
                LEFT JOIN Routes RTI  WITH (NOLOCK) ON (RTI.RouteKey = ODI.CurrentRouteKey)
                LEFT JOIN DriverRouteAcceptance DRA WITH (NOLOCK) ON DRA.RouteKey=RTI.RouteKey) CS ON CS.OrderDetailKey = OD.OrderDetailKey     
            --AND CS.RouteStatus=@CarrierStatus    
            --LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON CGD.OrderDetailKey=OD.OrderDetailKey
	        OUTER APPLY (
	    		SELECT TOP 1 *
				FROM Container_GnosisData CGDI WITH (NOLOCK)
				WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
	    	) CGD
            WHERE OD.Status NOT IN (1,11) AND RT.RouteKey = LAST_ROUTEKEY
            AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom >= @PickUpDateFrom)
            AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom <= @PickUpDateTo)
            AND (@Weekday  IS NULL OR @Weekday='' OR
            --LEFT( (CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @ENDDate THEN UPPER(DATENAME(WEEKDAY, RT.PickupDateFrom ) )    
            --WHEN RT.PickupDateFrom < @StartDate THEN 'PAS' ELSE 'FUT' END),3)= @Weekday)
			((@Weekday = 'Past' AND CAST(RT.PickupDateFrom AS DATE) < @RangeStartDate)
			OR (@Weekday = 'Future' AND CAST(RT.PickupDateFrom AS DATE) > @RangeStartDate)
			OR (@Weekday NOT IN ('Past','Future') AND CAST(RT.PickupDateFrom AS DATE) BETWEEN @RangeStartDate AND @RangeEndDate))) -- added
            AND (ISNULL(@Customer,'') = '' OR CUS.CustName LIKE '%' + @Customer + '%')
            AND (ISNULL(@OrderNo ,'') = '' OR OH.OrderNo LIKE '%' + @OrderNo + '%')
            AND (ISNULL(@ContainerNo,'') = '' OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')
            AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom >= @PickUpDateFrom)
            AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom <= @PickUpDateTo)
            AND (ISNULL(@PickupTypeKey,0) = 0 OR L.PickupTypeKey = @PickupTypeKey)
            AND (ISNULL(@BookingNo,'') = '' OR OH.BookingNo LIKE '%' + @BookingNo + '%')
            AND (ISNULL(@ContainerType,'') = '' OR CTl.ContainerTypeKey IN (SELECT ContainerType
            FROM #ContainerType))
            AND (ISNULL(@LegID,'') = '' OR RT.LegKey IN (SELECT LegKey
            FROM #LegKeys))
            AND (ISNULL(@OrderType,'') = '' OR ISNULL(OD.OrderTypeKey,OH.OrderTypekey) IN (SELECT OrderTypeKey
            FROM #OrderTypeKeys)) -- added
            AND (ISNULL(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey)
            AND (  ISNULL(@marketLocationKey,0) = 0 OR OH.MarketLocationKey = @marketLocationKey )
            AND (ISNULL(@Dispatcher,0) = 0 OR RT.CarrierASsignedBy = @Dispatcher)
            AND (ISNULL(@CarrierStatus,'') = '' OR CS.RouteStatus = @CarrierStatus)
            AND (@EmptyvLoaded = 0 OR (OD.IsEmpty = 1 AND @EmptyvLoaded = 1) OR (OD.IsEmpty IS NULL AND @EmptyvLoaded = 2))--added for loaded filter
            AND (ISNULL(@LocationType,'') = '' OR 'From ' + L.FromLocation IN (SELECT LocationType
            FROM #LocationTypes)) -- added
            AND (ISNULL(@LocationType,'') = '' OR 'TO ' + L.ToLocation IN (SELECT LocationType
            FROM #LocationTypes)) -- added
			AND (ISNULL(@DropvLive, '') = '' OR ODSD.DropOrLive = @DropvLive)
			AND (ISNULL(@Urgent, 0) = 0 OR ((RT.ScheduledPickupDate < GETDATE() AND RT.ActualDeparture IS NULL) OR
			(RT.ScheduledArrival < GETDATE() AND RT.ActualArrival IS NULL)))
            AND (  ISNULL(@SearchText ,'') = '' OR
            OH.OrderNo LIKE '%' +  @SearchText + '%' OR
            DTR.AddrName LIKE '%' +  @SearchText + '%' OR
            ISNULL(CAdr.AddrName,'') LIKE '%' +  @SearchText + '%' OR
            DT.AddrName LIKE '%' +  @SearchText + '%' OR
            CH.chassisNo LIKE '%' +  @SearchText + '%' OR
            OD.ContainerNo LIKE '%' +  @SearchText + '%' OR
            OH.BookingNo LIKE '%' +  @SearchText + '%' OR
            OH.BillOfLading LIKE '%' +  @SearchText + '%' OR
            OT.OrderType LIKE '%' +  @SearchText + '%' OR
            OH.BrokerRefNo LIKE '%' +  @SearchText + '%' OR
            CUS.CustName LIKE '%' +  @SearchText + '%'     
        )

        ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo

        IF(@IsDebug = 1)    
        BEGIN
            SELECT '#Data', COUNT(1)
            FROM #Data
            SELECT *
            FROM #OrderDetailStatus
        END
            SELECT A.[Description] AS StatusName , A.[Status], COUNT(ContainerNo) AS ContainerCount, 'I' AS [Level]
            INTO #DashBoarData1
            FROM dbo.RouteStatus A WITH (NOLOCK)
                LEFT JOIN #Data F ON F.StatusName=A.Description
            GROUP BY A.[Description],A.[Status]
        UNION ALL
            SELECT 'Total Containers' , 0, COUNT(ContainerNo) AS ContainerCount, 'S' AS Level
            FROM dbo.RouteStatus A WITH (NOLOCK)
            LEFT JOIN #Data F ON F.StatusName=A.Description

        SELECT A.StatusName, A.Status, A.ContainerCount, A.[Level], ISNULL(B.OrderBy ,50) AS OrderBy
        INTO #DashBoarData
        FROM #DashBoarData1 A
        LEFT JOIN dbo.RouteStatus B ON B.[Description]=A.StatusName

        SET @JSONResult = JSON_QUERY((
        SELECT
            DispatchListResult = (    
            SELECT *
            FROM #data
            WHERE (ISNULL( @TabStatus,0) = 0 OR @TabStatus = Status)
            AND (ISNULL(@IsDriverApp,0)=0 OR IsDriverApp=@IsDriverApp)
            ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo
            FOR JSON AUTO    
        ),
            DashBoardData  = (    
            SELECT A.Status AS StatusKey, A.StatusName AS Description,
            A.Level, A.OrderBy, A.ContainerCount AS DispatchCount
            FROM #DashBoarData A
            FOR JSON AUTO    
        ),
            DryRunTypeList	= (
            SELECT DISTINCT	DryRunTypeKey, DryRunType 
            FROM  DryRunType  WITH (NOLOCK)
			WHERE ISNULL(DryRunType,'')<>''	
            ORDER BY DryRunTypeKey 
            FOR JSON AUTO
        ),
            TruckTypeList  = (
            SELECT TruckTypeKey, TruckType 
            FROM  TruckType  WITH (NOLOCK)
			ORDER BY TruckTypeKey 
            FOR JSON AUTO
        ),
            WeekDaysList  = (
            SELECT RangeName, StartDate, EndDate 
            FROM  v_DateRanges
            FOR JSON AUTO
        )
			FOR JSON PATH, without_array_wrapper
        ))

        SELECT @JSONResult AS JSONResult
        SET @Status = 1
        SET @Reason = 'Success'

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        If @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

        SET @Status = 0
        SET @Reason = ERROR_MESSAGE()
    END CATCH
END 
