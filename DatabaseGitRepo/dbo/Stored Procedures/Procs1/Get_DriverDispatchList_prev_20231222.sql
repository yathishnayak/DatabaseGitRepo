

--exec [dbo].[Get_DriverDispatchList] @StatusKey=3,@WeekNum ='WK-50'
/*exec [dbo].[Get_DriverDispatchList] @StatusKey=0,@DriverKey=0,@OrderKey=0,@OrderDateFrom='2023-8-16 22:04:33.5855277',
	@OrderDateTO='2023-11-16 22:04:33.5855277',@DeliVeryDateFom='2023-10-16 00:00:00',@DelivaryDateTo='2023-12-16 00:00:00',
	@OrderNo='',@containerNo='MSDU1710270',@voucherNo='',@VoucherKey=0,@DriverHubkey=0,@WeekNum='',@marketLocationKey=0
	*/
CREATE Procedure [dbo].[Get_DriverDispatchList_prev_20231222] -- [Get_DriverDispatchList]  @ContainerNo='MSDU1710270', @MarketLocationKey=0
@StatusKey		 INT= 0,
@DriverKey		 INT= 0,
@OrderKey		 INT= 0,
@OrderDateFrom	 DATE='01/01/2020',
@OrderDateTO	 DATE='12/31/2099',
@DeliVeryDateFom DATE='01/01/2020',
@DelivaryDateTo	 DATE='12/31/2099',
@OrderNo		 VARCHAR(50)='',
@containerNo	 VARCHAR(50)='',
@voucherNo		 VARCHAR(50)='',
@VoucherKey		 INT=0,
@DriverHubkey	 INT=0,
@WeekNum         VARCHAR(5) = '',
@marketLocationKey		INT = 0
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON-- 1,2
	SET FMTONLY OFF

	Declare @StrDateOrder varchar(20), @StrDateDelivery		varchar(20)
	set @StrDateOrder = Convert(varchar, @OrderDateFrom, 101)
	if(@StrDateOrder = Convert(varchar,Getdate()-30,101))
	Begin
		Set @OrderDateFrom = GetDate() - 60
	end
	set @StrDateDelivery = Convert(varchar, @DeliVeryDateFom, 101)
	if(@StrDateDelivery = Convert(varchar,Getdate()-30,101))
	Begin
		Set @DeliVeryDateFom = GetDate() - 30
	end
	if(isnull(@WeekNum ,'')<>'')
	Begin
		DECLARE @datecol datetime = GETDATE();
		DECLARE @WeekNumInt INT = convert(int, replace(@weekNum,'WK-','') )
				, @YearNum char(4);

		SELECT @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

		-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
		SELECT @DeliVeryDateFom = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNumInt-1), 7) ;
		SELECT @DelivaryDateTo = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNumInt-1), 6);
	End
	CREATE TABLE #TEMPTABLE
	(
			orderkey			INT,
			orderdetailkey		INT,
			voucheramount		NUMERIC(18,5),
			routekey			INT,
			destinationaddrkey	INT,	
			voucherkey			INT,
			StatusKey			smallint,
			DocumentCount		INT,
			DocCounts			varchar(50),

			orderno				VARCHAR(50),
			containerno			VARCHAR(50),
			driverid			VARCHAR(20),
			firstname			VARCHAR(100),
			lastname			VARCHAR(100),
			voucherno			VARCHAR(50),
			LegTypeID			VARCHAR(100),
			Workflow			VARCHAR(100),
			DestinationCity		VARCHAR(50),
			weekNum				VARCHAR(10),
			DriverOrg			VARCHAR(100),
			BrokerRefNo			VARCHAR(50),
			VesselETA			DateTime,

			ActualDeparture		DateTime,
			voucherdate			DateTime,
			WeekStart			DateTime,
			WeekEnd				DateTime,
			PaidDate			DateTime,
			CompleteDate		DateTime,

			ispaymentapproved	bit,
			IsDocumentVerified	bit,
			IsRateVerified		bit,
			IsPaid				bit,
			DriverHubKey		int,
			MarketLocationKey	INT,
			MarketLocation		VARCHAR(200),
			PaidUserKey			int,
			PaidUserName		varchar(100)
	)

	Declare @OpenStatusKey smallint = 0;
	select @OpenStatusKey = Status from RouteStatus where Description = 'Leg Completed'

	IF @StatusKey IN (1,2,3,0)
	BEGIN
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName)

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
		VH.PaidUserKey, UI.UserID AS PaidUserName
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
		INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
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
		AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
		AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo)
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
		PaidUserKey, PaidUserName)
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
					VH.PaidUserKey, UI.UserID AS PaidUserName
		--INTO #TEMPVOUCHER2
		FROM dbo.[routes] RT WITH (NOLOCK) 
			INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
			INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
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
			AND	(  @DeliVeryDateFom	IS NULL OR (RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom))
			AND (  @DelivaryDateTo	IS NULL OR (RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo))
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
				PaidUserName
			FROM  #TEMPTABLE
			where (ISNULL(@WeekNum, '')='' OR weekNum =@WeekNum)

END