



Create  PROCEDURE [dbo].[Get_VoucherStatusDashboard_ASH] -- [Get_VoucherStatusDashboard] 0
@StatusKey		INT= 0,
@DriverKey		INT= 0,
@OrderKey		INT= 0,
@OrderDateFrom	DATE='01/01/2020',
@OrderDateTO	DATE='12/31/2099',
@DeliVeryDateFom DATE='01/01/2020',
@DelivaryDateTo	DATE='12/31/2099',
@OrderNo		VARCHAR(50)='',
@containerNo	VARCHAR(50)='',
@voucherNo		VARCHAR(50)='',
@VoucherKey		INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Declare @OpenStatusKey smallint = 0;

	select @OpenStatusKey = Status from RouteStatus where Description = 'Leg Completed'
	SELECT StatusKey, [Description] AS StatusName INTO #VouchStatus
	FROM dbo.VoucherStatus 
	UNION ALL 
	SELECT 9,'PendingToProcess'

	select *   INTO #Temp from 
	(
		SELECT 1 StatusKey, 'Pending' StatusName , 0 AS StatusCount
		union all 
		SELECT 2 , 'Approved'  , 0 
		union all 
		SELECT 3, 'Paid Vouchers' , 0 
		union all 
		SELECT 9 , 'PendingToProcess' , 0 
	) X


	--SELECT S.StatusKey, StatusName , ISNULL(A.cnt,0) AS StatusCount
	--INTO #Temp
	--FROM #VouchStatus S
	--LEFT JOIN (
	--		SELECT Z.StatusKey, count(1) cnt 
	--		FROM (
	--				SELECT  DISTINCT  0 AS OrderKey,0 AS OrderDetailKey,--oh.OrderNo,
	--					CASE WHEN OrdCount='1' THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
	--					CASE WHEN ContCount='1' THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
	--					--OrderNo,OrdCount,
	--					isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
	--					ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
	--					ISNULL(VH.[Statuskey],9)   AS StatusKey,
	--					VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
	--					NULL AS DestinationAddrKey,
	--					VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,
	--					'' AS WorkFlow, '' as LegTypeID,'' AS City, 0 as DocumentCount
	--					,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) as WeekNum
	--					,RT.IsDocumentVerified,IsRateVerified, NULL AS CompleteDate,'' DocCount, --OD.CompleteDate AS CompleteDate
	--					A.Week_Start_Date as [WeekStart],
	--					A.Week_End_Date as [WeekEnd],
	--					VH.IsPaid, VH.PaidDate,
	--					OH.BrokerRefNo, OD.VesselETA,
	--					 case when isnull(d.OrgName,'') = '' then '' 
	--							else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
	--								+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg
	
	--				FROM dbo.[routes] RT WITH (NOLOCK)
	--					INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
	--					INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
	--					--INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
	--					--INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
	--					INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
	--					INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
	--					LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
	--					LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
	--					LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
	--					LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
	--					--LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
	--					--LEFT JOIN dbo.VRouteDocumentCount V WITH (NOLOCK) ON V.RouteKey=RT.RouteKey
	--					Left join dbo.vVoucherAmt VMT	WITH (NOLOCK) ON VH.VoucherKey = VMT.voucherKey
	--					LEft join vVoucherWeekNums A on A.VoucherKey = VH.VoucherKey
	--					--****************Container Count************************
	--					LEFT JOIN vVoucherContainerCount DF ON DF.VoucherKey=VH.VoucherKey	
	--					LEFT JOIN vVoucherContainers VF ON VF.VoucherKey=VH.VoucherKey
	--					--**************Order Count**************************
	--					LEFT JOIN vVoucherOrderCount DK ON DK.VoucherKey=VH.VoucherKey
	--					LEFT JOIN vVoucherMultiOrders VD ON VD.VoucherKey=VH.VoucherKey
	--					--******************************
	--				WHERE  1<>1 and	RTS.Status= @OpenStatusKey	and  VH.VoucherKey IS not NULL		
	--					AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9) = @StatusKey )
	--				/*	AND (  @DriverKey =0 OR @DriverKey IS NULL OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
	--					AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )
	--					AND	(  @OrderDateFrom	IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate>=@OrderDateFrom)
	--					AND (  @OrderDateTo		IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate<=@OrderDateTo)
	--					AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
	--					AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo)
	--					AND (  @OrderNo			= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
	--					AND (  @containerNo		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
	--					AND (  @voucherNo		= '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')
	--					AND (  @VoucherKey		= 0 OR @VoucherKey is null OR VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey )
	--				*/

	--				union all
	--					SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,RT.ActualArrival AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
	--						ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
	--						ISNULL(VH.[Statuskey],9)   AS StatusKey,
	--						VH.VoucherAmount,RT.RouteKey,RT.DestinationAddrKey,VH.VoucherKey,VH.VoucherNo,VH.VoucherDate
	--						,L.Instruction AS WorkFlow, LG.LegID as LegTypeID,DST.City,0 as DocumentCount -- isnull(CDC.DocumentCount,0)
	--						, 'WK-' +  convert(varchar,DatePArt(iso_week,RT.ActualArrival)) as WeekNum
	--						,RT.IsDocumentVerified,IsRateVerified,OD.CompleteDate,'' as DocCount,
	--						A.Week_Start_Date as [WeekStart],
	--						A.Week_End_Date [WeekEnd],
	--						VH.IsPaid, VH.PaidDate,OH.BrokerRefNo, OD.VesselETA,
	--						 case when isnull(d.OrgName,'') = '' then '' 
	--							else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
	--								+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg

	--					FROM dbo.[routes] RT WITH (NOLOCK) 
	--						INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
	--						INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
	--						INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
	--						INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
	--						INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
	--						INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status] and rts.Status = @OpenStatusKey
	--						LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
	--						LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
	--						LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
	--						LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
	--						--LEFT JOIN ContainerDocumentCount CDC	WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
	--						--LEFT JOIN dbo.VRouteDocumentCount V		WITH (NOLOCK) ON V.RouteKey=RT.RouteKey
	--						cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A 
	--					WHERE  1<>1	and VH.VoucherKey IS NULL AND RT.ActualArrival IS NOT NULL	
	--						AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9) = @StatusKey )
	--				/*		AND (  isnull(@DriverKey,0) =0  OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
	--						AND (  isnull(@OrderKey,0) =0 OR OH.OrderKey=@OrderKey )
	--						AND	(  @OrderDateFrom	IS NULL OR (OH.OrderDate>=@OrderDateFrom))
	--						AND (  @OrderDateTo		IS NULL OR (OH.OrderDate<=@OrderDateTo))
	--						AND	(  @DeliVeryDateFom	IS NULL OR (RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom))
	--						AND (  @DelivaryDateTo	IS NULL OR (RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo))
	--						AND (  @OrderNo			= '' OR (OH.OrderNo like '%' + @OrderNo + '%' ))
	--						AND (  @containerNo		= '' OR (OD.ContainerNo like '%' +  @containerNo + '%' ))
	--					*/
	--								) Z
	--						GROUP BY StatusKey
	--		) A ON S.StatusKey = A.StatusKey;

	SELECT statusKey, StatusName, StatusCount, 'I' AS LEVEL FROM #temp
	UNION ALL
	SELECT 0, 'All', SUM(StatusCount) AS StatusCount, 'S' AS LEVEL FROM #temp ;

END
