
CREATE VIEW Test_Delete -- SELECT * FROM Test_Delete
AS

		SELECT distinct Case when OrdCount = 1 then OH.OrderKey else 0 end AS OrderKey,
			Case when ContCount = 1 then OD.OrderDetailKey else 0 end  AS OrderDetailKey,--oh.OrderNo,
		CASE WHEN OrdCount='1' THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
		CASE WHEN ContCount='1' THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
		 isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,
		d.DriverID,d.FirstName,d.LastName,
		ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
		ISNULL(VH.[Statuskey],9)   AS StatusKey,
		VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
		NULL AS DestinationAddrKey,
		VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,

		'' AS WorkFlow, '' as LegTypeID,'' AS City,  isnull(CDC.DocumentCount,0) 		as DocumentCount
		,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) as WeekNum, Rt.DriverKey,DH.DriverHubName
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
		OD.IsLinked, upper(OD.LinkedContainerNo)LinkedContainerNo, OD.LinkedOrderDetailKey,'' LegID, 0  as Legkey,OrgName
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
		INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
		INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
		INNER JOIN (SELECT * FROM dbo.RouteStatus 	WITH (NOLOCK) WHERE Status= 5	) RTS ON RTS.[Status]=RT.[Status]
		LEFT JOIN	Leg L				WITH (NOLOCK) ON L.LegKey = RT.LegKey
		LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
		LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
		LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
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
		Left join DriverHUB DH WITH (NOLOCK) on D.DriverHubKey = DH.DriverHubKey
		--Left join TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey =  D.TruckTypeKey
	   --LEFT JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.DriverKey=D.DriverKey
	   --Left join CarrierMoveType MT WITH (NOLOCK) ON MT.MoveTypeKey = DM.MoveTypeKey

	WHERE 	 VH.VoucherKey IS not NULL		