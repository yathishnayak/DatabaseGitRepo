/*

DECLARE 
	@UserKey INT=952,
	--@JSONString NVARCHAR(MAX)='{"StatusKey":0,"DriverKey":0,"OrderKey":0,"OrderDateFrom":"","OrderDateTo":"","DeliveryDateFrom":"","DeliveryDateTo":"","OrderNo":"","ContainerNo":"","VoucherNo":"","VoucherKey":0,"DriverHubKey":0,"WeekNum":"","MarketLocationKey":0}',
	@JSONString NVARCHAR(MAX)='{"DriverKey":0,"OrderKey":0,"StatusKey":9,"VoucherNo":"","ContainerNo":"","OrderNo":""}',
	@Status BIT=0, @Debug INT = 1,@Reason VARCHAR(100)=''
EXEC Get_DriverDispatchList_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[Get_DriverDispatchList_V2] 
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	DECLARE
		@StatusKey			INT			=	0,
		@DriverKey			INT			=	0,
		@OrderKey			INT			=	0,
		@OrderDateFrom		DATE		=	'01/01/2020',
		@OrderDateTo		DATE		=	'12/31/2099',
		@DeliveryDateFrom	DATE		=	'01/01/2020',
		@DeliveryDateTo		DATE		=	'12/31/2099',
		@OrderNo			VARCHAR(50)	=	'',
		@ContainerNo		VARCHAR(50)	=	'',
		@VoucherNo			VARCHAR(50)	=	'',
		@VoucherKey			INT			=	0,
		@DriverHubKey		INT			=	0,
		@WeekNum			VARCHAR(5)	=	'',
		@MarketLocationKey	INT			=	0

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	SELECT 
		@StatusKey = ISNULL(StatusKey, 0), @DriverKey = ISNULL(DriverKey, 0),
		@OrderKey = ISNULL(OrderKey, 0), @OrderDateFrom = ISNULL(OrderDateFrom, '01/01/2020'),
		@OrderDateTo = ISNULL(OrderDateTo, '12/31/2099') , @DeliveryDateFrom = ISNULL(DeliveryDateFrom, '01/01/2020'),
		@DeliveryDateTo = ISNULL(DeliveryDateTo, '12/31/2099'), @OrderNo = OrderNo,
		@ContainerNo = ISNULL(ContainerNo, ''), @VoucherNo = ISNULL(VoucherNo, ''),
		@VoucherKey = VoucherKey, @DriverHubKey = DriverHubKey,
		@WeekNum = WeekNum, @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString, '$')
	WITH(
		StatusKey			INT				'$.StatusKey',
		DriverKey			INT				'$.DriverKey',
		OrderKey			INT				'$.OrderKey',
		OrderDateFrom		DATE			'$.OrderDateFrom',
		OrderDateTo			DATE			'$.OrderDateTo',
		DeliveryDateFrom	DATE			'$.DeliveryDateFrom',
		DeliveryDateTo		DATE			'$.DeliveryDateTo',
		OrderNo				VARCHAR(50)		'$.OrderNo',
		ContainerNo			VARCHAR(50)		'$.ContainerNo',
		VoucherNo			VARCHAR(50)		'$.VoucherNo',
		VoucherKey			INT				'$.VoucherKey',
		DriverHubKey		INT				'$.DriverHubKey',
		WeekNum				VARCHAR(5)		'$.WeekNum',
		MarketLocationKey	INT				'$.MarketLocationKey'
	)

	DECLARE @StrDateOrder VARCHAR(20), @StrDateDelivery	VARCHAR(20)
	DECLARE @IsWithFilter BIT = 1
	IF(@OrderDateTO = '0001-01-01 00:00:00')
	BEGIN
		SET @OrderDateTO = '2050-12-31'
	END
	IF(@DeliveryDateTo = '0001-01-01 00:00:00')
	BEGIN
		SET @DeliveryDateTo = '2050-12-31'
	END
	IF(@OrderDateFrom < CONVERT(DATE,GETDATE()-365) and @DeliveryDateFrom < CONVERT(DATE,GETDATE()-365)
			and ISNULL(@OrderNo,'')='' and ISNULL(@containerNo,'')=''  and ISNULL(@voucherNo,'')=''  and ISNULL(@VoucherKey,0)=0  
			and ISNULL(@MarketLocationKey,0)=0 and ISNULL(@DriverKey,0)=0  and ISNULL(@OrderKey,0)=0 and ISNULL(@WeekNum,'') = '')
	BEGIN
		SET @IsWithFilter = 0
	END

	IF(@IsWithFilter = 0) -- this automatically sets the range order from to only previous 60 days and delivery from to only previous 30 days
	BEGIN
		SET @OrderDateFrom = GetDate() - 60
		SET @OrderDateTO = '2050-12-31'
		SET @DeliveryDateFrom = GetDate() - 30
		SET @DeliveryDateTo = '2050-12-31'
	END
	IF(ISNULL(@WeekNum ,'')<>'')
	BEGIN
		DECLARE @datecol DATETIME = GETDATE();
		DECLARE @WeekNumInt INT = CONVERT(INT, REPLACE(@weekNum,'WK-','')), @YearNum CHAR(4);

		SELECT @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

		-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
		SELECT @DeliveryDateFrom = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNumInt-1), 7) ;
		SELECT @DeliveryDateTo = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNumInt-1), 6);
	End

	IF @IsDebug = 1
	BEGIN
		SELECT @IsWithFilter AS IsWithFilter, @OrderDateFrom AS OrderDateFrom,
				@OrderDateTo AS OrderDateTo, @DeliveryDateFrom AS DeliveryDateFrom,
				@DeliveryDateTo AS DeliveryDateTo
	END

	SELECT * INTO #OrderHeader FROM OrderHeader  OH
	WHERE	(@OrderDateFrom	IS NULL OR OH.OrderDate	IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND (@OrderDateTo	IS NULL OR OH.OrderDate	IS NULL OR OH.OrderDate<=@OrderDateTo)

	CREATE TABLE #TEMPTABLE
	(
			orderkey				INT,
			orderdetailkey			INT,
			voucheramount			NUMERIC(18,5),
			routekey				INT,
			destinationaddrkey		INT,	
			voucherkey				INT,
			StatusKey				SMALLINT,
			DocumentCount			INT,
			DocCounts				VARCHAR(50),

			orderno					VARCHAR(50),
			containerno				VARCHAR(50),
			driverid				VARCHAR(20),
			firstname				VARCHAR(100),
			lastname				VARCHAR(100),
			voucherno				VARCHAR(50),
			LegTypeID				VARCHAR(100),
			Workflow				VARCHAR(100),
			DestinationCity			VARCHAR(50),
			weekNum					VARCHAR(10),
			DriverOrg				VARCHAR(100),
			BrokerRefNo				VARCHAR(50),
			VesselETA				DATETIME,

			ActualDeparture			DATETIME,
			voucherdate				DATETIME,
			WeekStart				DATETIME,
			WeekEnd					DATETIME,
			PaidDate				DATETIME,
			CompleteDate			DATETIME,

			ispaymentapproved		BIT,
			IsDocumentVerified		BIT,
			IsRateVerified			BIT,
			IsPaid					BIT,
			DriverHubKey			INT,
			MarketLocationKey		INT,
			MarketLocation			VARCHAR(200),
			PaidUserKey				INT,
			PaidUserName			VARCHAR(100),
			IsLinked				BIT DEFAULT 0, 
			LinkedContainerNo		VARCHAR(20), 
			LinkedOrderDetailKey	INT,
			LegKey					INT
	)

	DECLARE @OpenStatusKey SMALLINT = 0;
	SELECT @OpenStatusKey = STATUS FROM RouteStatus WHERE DESCRIPTION = 'Leg Completed'

	IF @StatusKey IN (1,2,3,0)
	BEGIN
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,LegKey)

		SELECT  DISTINCT  Case when OrdCount = 1 then OH.OrderKey else 0 end AS OrderKey,
			Case when ContCount = 1 then OD.OrderDetailKey else 0 end  AS OrderDetailKey,--oh.OrderNo,
		CASE WHEN OrdCount='1' THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
		CASE WHEN ContCount='1' THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
		isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
		ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
		ISNULL(VH.[Statuskey],9)   AS StatusKey,
		VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
		NULL AS DestinationAddrKey,
		VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,

		'' AS WorkFlow, '' as LegTypeID,'' AS City,  isnull(CDC.DocumentCount,0) 		as DocumentCount
		,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) as WeekNum
		,RT.IsDocumentVerified,IsRateVerified, NULL AS CompleteDate,'' DocCount, --OD.CompleteDate AS CompleteDate
		A.Week_Start_Date as [WeekStart],
		A.Week_End_Date as [WeekEnd],
		VH.IsPaid, VH.PaidDate,
		OH.BrokerRefNo, OD.VesselETA,
		 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg,
					d.DriverHubKey AS DriverHubKey,
		ML.MarketLocationKey,ML.MarketLocation,
		VH.PaidUserKey, UI.UserID AS PaidUserName,
		OD.IsLinked, OD.LinkedContainerNo, OD.LinkedOrderDetailKey,RT.LegKey
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
		INNER JOIN dbo.#OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
		--INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
		--INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
		INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
		INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
		LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
		LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
		LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
		--LEFT JOIN dbo.VRouteDocumentCount V WITH (NOLOCK) ON V.RouteKey=RT.RouteKey
		Left join dbo.vVoucherAmt VMT	WITH (NOLOCK) ON VH.VoucherKey = VMT.voucherKey
		LEft join vVoucherWeekNums A on A.VoucherKey = VH.VoucherKey
		--****************Container Count************************
		LEFT JOIN vVoucherContainerCount DF ON DF.VoucherKey=VH.VoucherKey	
		LEFT JOIN vVoucherContainers VF ON VF.VoucherKey=VH.VoucherKey
		--**************Order Count**************************
		LEFT JOIN vVoucherOrderCount DK ON DK.VoucherKey=VH.VoucherKey
		LEFT JOIN vVoucherMultiOrders VD ON VD.VoucherKey=VH.VoucherKey
		--******************************
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey

	WHERE 	RTS.Status= @OpenStatusKey	and  VH.VoucherKey IS not NULL		
		AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],0) = @StatusKey )
		AND (  @DriverKey =0 OR @DriverKey IS NULL OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
		AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )
		AND	(  @OrderDateFrom	IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND (  @OrderDateTo		IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate<=@OrderDateTo)
		AND	(  @DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliveryDateFrom)
		AND (  @DeliveryDateTo	IS NULL OR RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DeliveryDateTo)
		AND (  @OrderNo			= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
		AND (  @containerNo		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
		AND (  @voucherNo		= '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')
		AND (  @VoucherKey		= 0 OR @VoucherKey is null OR VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey )
		AND (@DriverHubkey =0 OR @DriverHubkey IS NULL OR D.DriverHubKey IS NULL OR D.DriverHubKey= @DriverHubkey)
		AND (  ISNULL(@marketLocationKey,0) = 0 OR  CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(OH.MarketLocationKey,0) END = @marketLocationKey )
	ORDER BY VH.VoucherKey DESC
	END


	if(@StatusKey in (0,9))
	BEGIN
		
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,LegKey)
		SELECT DISTINCT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,RT.ActualArrival AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
			ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
			ISNULL(VH.[Statuskey],9)   AS StatusKey,
			VH.VoucherAmount,RT.RouteKey,RT.DestinationAddrKey,VH.VoucherKey,VH.VoucherNo,VH.VoucherDate
			,L.Instruction AS WorkFlow, LG.LegID as LegTypeID,DST.City, isnull(CDC.DocumentCount,0) as DocumentCount --
			, 'WK-' +  convert(varchar,DatePArt(iso_week,RT.ActualArrival)) as WeekNum
			,RT.IsDocumentVerified,IsRateVerified,OD.CompleteDate,'' as DocCount,
			A.Week_Start_Date as [WeekStart],
			A.Week_End_Date [WeekEnd],
			VH.IsPaid, VH.PaidDate,OH.BrokerRefNo, OD.VesselETA,
			 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg,
					d.DriverHubKey AS DriverHubKey,
			ML.MarketLocationKey,ML.MarketLocation,
					VH.PaidUserKey, UI.UserID AS PaidUserName,
					OD.IsLinked, OD.LinkedContainerNo, OD.LinkedOrderDetailKey,RT.LegKey
		--INTO #TEMPVOUCHER2
		FROM dbo.[routes] RT WITH (NOLOCK) 
			INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
			INNER JOIN dbo.#OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
			INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
			INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
			INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
			INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status] and rts.Status = @OpenStatusKey
			LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
			LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
			LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
			LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
			LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
			LEFT JOIN ContainerDocumentCount CDC	WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
			--LEFT JOIN dbo.VRouteDocumentCount V		WITH (NOLOCK) ON V.RouteKey=RT.RouteKey
			cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A 
			LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		WHERE 	 VH.VoucherKey IS NULL AND RT.ActualArrival IS NOT NULL	
			AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9) = @StatusKey )
			AND (  isnull(@DriverKey,0) =0  OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
			AND (  isnull(@OrderKey,0) =0 OR OH.OrderKey=@OrderKey )
			AND	(  @OrderDateFrom	IS NULL OR (OH.OrderDate>=@OrderDateFrom))
			AND (  @OrderDateTo		IS NULL OR (OH.OrderDate<=@OrderDateTo))
			AND	(  @DeliveryDateFrom	IS NULL OR (RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliveryDateFrom))
			AND (  @DeliveryDateTo	IS NULL OR (RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DeliveryDateTo))
			AND (  @OrderNo			= '' OR (OH.OrderNo like '%' + @OrderNo + '%' ))
			AND (  @containerNo		= '' OR (OD.ContainerNo like '%' +  @containerNo + '%' ))
			AND (@DriverHubkey =0 OR @DriverHubkey IS NULL OR D.DriverHubKey IS NULL OR D.DriverHubKey= @DriverHubkey)
			--AND (  isnull(@voucherNo,'') = '' OR (ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%'))
			--AND (  isnull(@VoucherKey,0)= 0 OR (VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey ))
			AND (  ISNULL(@marketLocationKey,0) = 0 OR  CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(OH.MarketLocationKey,0) END = @marketLocationKey )
		--ORDER BY VH.VoucherKey DESC
	END

	SELECT
				ISNULL(orderkey,0) AS orderkey,
				ISNULL(orderdetailkey,0) AS orderdetailkey,
				ISNULL(voucheramount,0) AS voucheramount,
				ISNULL(routekey,0) AS routekey,
				ISNULL(destinationaddrkey,0) AS destinationaddrkey,
				ISNULL(voucherkey,0) AS voucherkey,
				ISNULL(StatusKey,0) AS StatusKey,
				ISNULL(DocumentCount,0) AS DocumentCount,
				ISNULL(DocCounts,0) AS DocCounts,

				ISNULL(orderno,'') AS orderno,
				ISNULL(containerno,'') AS containerno,
				ISNULL(driverid,'') AS driverid,
				ISNULL(firstname,'') AS firstname,
				ISNULL(lastname,'') AS lastname,
				ISNULL(voucherno,'') AS voucherno,
				ISNULL(LegTypeID,'') AS LegTypeID,
				ISNULL(Workflow,'') AS Workflow,
				ISNULL(DestinationCity,'') AS DestinationCity,
				ISNULL(weekNum,'') AS weekNum,
				ISNULL(DriverOrg,'') AS DriverOrg,
				ISNULL(BrokerRefNo,'') AS BrokerRefNo,
				ISNULL(VesselETA,'') AS VesselETA,

				convert(datetime,isnull(ActualDeparture,'01-01-1900')) as ActualDeparture,
				convert(datetime,isnull(voucherdate,'01-01-1900')) as voucherdate,
				convert(datetime,isnull(WeekStart,'01-01-1900')) as WeekStart,
				convert(datetime,isnull(WeekEnd,'01-01-1900')) as WeekEnd,
				convert(datetime,isnull(PaidDate,'01-01-1900')) as PaidDate,

				ISNULL(ispaymentapproved,convert(bit,0)) as ispaymentapproved,
				ISNULL(IsDocumentVerified,convert(bit,0)) as IsDocumentVerified,
				ISNULL(IsRateVerified,convert(bit,0)) as IsRateVerified,
				ISNULL(IsPaid,convert(bit,0)) as IsPaid,
				ISNULL(DriverHubKey,0) AS DriverHubKey,
				ISNULL(MarketLocationKey,0) AS MarketLocationKey,
				MarketLocation,
				PaidUserKey,
				PaidUserName,
				IsLinked, LinkedContainerNo, LinkedOrderDetailKey,LegKey
			FROM  #TEMPTABLE
			where (ISNULL(@WeekNum, '')='' OR weekNum =@WeekNum)
			FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

	DROP TABLE #TEMPTABLE
END