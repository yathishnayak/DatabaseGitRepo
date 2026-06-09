

CREATE PROCEDURE [dbo].[Get_DriverDispatchList_NEw] -- [Get_DriverDispatchList_NEw] @StatusKey = 2
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
@VoucherKey		 INT=0
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON-- 1,2
	SET FMTONLY OFF

	IF @StatusKey IN (1,2,3)
	BEGIN
	SELECT  DISTINCT  0 AS OrderKey,0 AS OrderDetailKey,--oh.OrderNo,
		CASE WHEN OrdCount='1' THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
		CASE WHEN ContCount='1' THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
		--OrderNo,OrdCount,
		isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
		ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
		ISNULL(VH.[Statuskey],9)   AS StatusKey,
		VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
		NULL AS DestinationAddrKey,
		VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,
		'' AS WorkFlow, '' as LegTypeID,'' AS City, 0 as DocumentCount
		,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,VH.VoucherDate)) as WeekNum
		,RT.IsDocumentVerified,IsRateVerified, NULL AS CompleteDate,DocCount, --OD.CompleteDate AS CompleteDate
		A.Week_Start_Date as [WeekStart],
		A.Week_End_Date as [WeekEnd],
		VH.IsPaid, VH.PaidDate,
		 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg
	FROM dbo.[routes] RT 
		INNER JOIN dbo.OrderDetail od	ON RT.OrderDetailKey = od.OrderDetailkey
		INNER JOIN dbo.OrderHeader oh	ON oh.OrderKey = od.OrderKey
		--INNER JOIN dbo.Leg LG			ON LG.LegKey = RT.LegKey
		--INNER JOIN dbo.LegType L		ON L.LegtypeKey = LG.LegTypeKey
		INNER JOIN dbo.Driver d			ON d.DriverKey = RT.DriverKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
		LEFT JOIN RouteVouchers RV		ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		ON VH.VoucherKey=RV.VoucherKey
		LEFT JOIN dbo.VoucherStatus VS	ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC ON OD.OrderDetailKey = CDC.OrderDetailKey
		LEFT JOIN dbo.VRouteDocumentCount V ON V.RouteKey=RT.RouteKey
		Left join dbo.vVoucherAmt VMT on VH.VoucherKey = VMT.voucherKey
		LEft join (
			Select A.VoucherKey, A.MinArrival, B.Week_Start_Date, B.Week_End_Date from 
			(
				select VH.VoucherKey, min(RT.ActualArrival) as MinArrival --, A.Week_Start_Date, A.Week_End_Date
				from VoucherHeader VH 
				inner join VoucherDetail VD on VH.VoucherKey = VD.Voucherkey
				inner join Routes RT on VD.RouteKey = RT.RouteKey
				inner join RouteStatus RTS on RT.Status = RTS.Status
				where RTS.Description='Leg Completed' and rt.ActualArrival is not null
				Group by VH.VoucherKey
				having min(RT.ActualArrival) is not null
			) A
			cross apply dbo.fn_getIsoWeekStartEndDates( isnull(A.MinArrival,'2022-01-01')) B
		)
		 A on A.VoucherKey = VH.VoucherKey
		--****************Container Count************************
		LEFT JOIN		
		(
		 SELECT COUNT(1) AS ContCount,VoucherKey 
		 FROM dbo.RouteVouchers RV 
			INNER JOIN Routes RT ON RT.RouteKey=RV.RouteKey 
			INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey = OD.OrderDetailkey
		GROUP BY VoucherKey
		) DF ON DF.VoucherKey=VH.VoucherKey	
		LEFT JOIN
		(
		SELECT V.VOucherKey,		
			SUBSTRING( (	SELECT ','+OD.ContainerNo AS ContNo
			FROM dbo.RouteVouchers RV 
				INNER JOIN Routes RT ON RT.RouteKey=RV.RouteKey AND RV.VoucherKey=V.VoucherKey
				INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey = OD.OrderDetailkey		
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,2,5000)AS ContNo
		FROM VoucherHeader V
		) VF ON VF.VoucherKey=VH.VoucherKey
		--**************Order Count**************************
		LEFT JOIN
		(
		 SELECT COUNT(DISTINCT OH.OrderKey) AS OrdCount,VoucherKey 
		 FROM dbo.RouteVouchers RV 
			INNER JOIN Routes RT ON RT.RouteKey=RV.RouteKey 
			INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey = OD.OrderDetailkey
			INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey = OD.OrderKey
		 GROUP BY VoucherKey
		) DK ON DK.VoucherKey=VH.VoucherKey
		LEFT JOIN
		(
		SELECT V.VOucherKey,		
			SUBSTRING( (	SELECT ','+OH.OrderNo AS OrderNo
			FROM dbo.RouteVouchers RV 
				INNER JOIN Routes RT ON RT.RouteKey=RV.RouteKey AND RV.VoucherKey=V.VoucherKey
				INNER JOIN dbo.OrderDetail OD	ON RT.OrderDetailKey = OD.OrderDetailkey
				INNER JOIN dbo.OrderHeader OH	ON OH.OrderKey = OD.OrderKey
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)') ,2,5000)AS OrdNo
		FROM VoucherHeader V
		) VD ON VD.VoucherKey=VH.VoucherKey
		--******************************
	WHERE 	RTS.Description='Leg Completed'	and  VH.VoucherKey IS not NULL		
		AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9) = @StatusKey )
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
	ORDER BY VH.VoucherKey DESC
	END
	ELSE
	BEGIN
		SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,RT.ActualArrival AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
			ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
			ISNULL(VH.[Statuskey],9)   AS StatusKey,
			VH.VoucherAmount,RT.RouteKey,RT.DestinationAddrKey,VH.VoucherKey,VH.VoucherNo,VH.VoucherDate
			,L.Instruction AS WorkFlow, LG.LegID as LegTypeID,DST.City,isnull(CDC.DocumentCount,0) as DocumentCount
			, 'WK-' +  convert(varchar,DatePArt(iso_week,RT.ActualArrival)) as WeekNum
			,RT.IsDocumentVerified,IsRateVerified,OD.CompleteDate,DocCount,
			A.Week_Start_Date as [WeekStart],
			A.Week_End_Date [WeekEnd],
			VH.IsPaid, VH.PaidDate,
			 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg
		FROM dbo.[routes] RT 
			INNER JOIN dbo.OrderDetail od	ON RT.OrderDetailKey = od.OrderDetailkey
			INNER JOIN dbo.OrderHeader oh	ON oh.OrderKey = od.OrderKey
			INNER JOIN dbo.Leg LG			ON LG.LegKey = RT.LegKey
			INNER JOIN dbo.LegType L		ON L.LegtypeKey = LG.LegTypeKey
			INNER JOIN dbo.Driver d			ON d.DriverKey = RT.DriverKey
			INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
			LEFT JOIN RouteVouchers RV		ON RV.RouteKey=RT.RouteKey
			LEFT JOIN VoucherHeader VH		ON VH.VoucherKey=RV.VoucherKey
			LEFT JOIN dbo.VoucherStatus VS	ON VS.[StatusKey]=VH.[StatusKey]
			LEFT JOIN dbo.[Address] DST ON DST.AddrKey=RT.DestinationAddrKey
			LEFT JOIN ContainerDocumentCount CDC ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEFT JOIN dbo.VRouteDocumentCount V ON V.RouteKey=RT.RouteKey
			cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A 
		WHERE 	RTS.Description='Leg Completed'	and  VH.VoucherKey IS NULL AND RT.ActualArrival IS NOT NULL	
			AND	(  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9) = @StatusKey )
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
		ORDER BY VH.VoucherKey DESC
	END
END
