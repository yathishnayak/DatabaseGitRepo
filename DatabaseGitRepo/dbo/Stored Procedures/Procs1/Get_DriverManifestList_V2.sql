/*
DECLARE @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0,
	@Reason			varchar(1000) = '',
	@IsDebug		bit = 1;

    SET @IsDebug= 1
    SET @JSONString= '{"SearchCriteriaKey":0,"DriverKeys":"1418:","OrderKeys":"","OrderNo":"","containerNo":"","voucherNo":"","VoucherKeys":"","DriverHubkeys":"","WeekNum":"WK-8","MarketLocationKeys":"","TruckTypeKeys":"","CarrierMoveTypeKeys":"","SearchText":"","SortField":"voucherno","IsAscending":true,"PageSize":50,"PageNo":1,"StatusKey":3,"isDriverPay":true}'
    SET @Status= 1
    SET @Reason= 'Success'
    SET @UserKey= 486
	EXEC Get_DriverManifestList_V2 @Userkey,@JsonString,@Status output,@Reason Output,@Isdebug 
	select @Status,@Reason
*/

CREATE PROCEDURE [dbo].[Get_DriverManifestList_V2] --  
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
AS
BEGIN
       ---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER
       SET NOCOUNT ON;
       SET FMTONLY OFF;
	   SET ARITHABORT ON;
     
	 DECLARE	@StatusKey           INT= 0,
				@DriverKeys				varchar(max)= '',
				@OrderKeys				varchar(max)= '',
				@OrderDateFrom       DATE='01/01/2020',
				@OrderDateTO		 DATE='12/31/2099',
				@DeliveryDateFrom	 DATE='01/01/2020',
				@DeliveryDateTo      DATE='12/31/2099',
				@OrderNo             VARCHAR(50)='',
				@containerNo		 VARCHAR(50)='',
				@voucherNo           VARCHAR(50)='',
				@VoucherKeys			varchar(max)= '',
				@DriverHubkeys			varchar(max)= '',
				@marketLocationKeys		varchar(max)= '',
				@WeekNum				VARCHAR(5) = '',
				@TruckTypeKeys		    varchar(max)= '',
				@CarrierMoveTypeKeys	varchar(max)= '',
				@isDriverPay			Bit = 0,
				@SearchText				varchar(50)

		if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
		Begin
			SEt @Status = 0
			Set @Reason = 'Parameters not found'
			return
		End

		Select	@containerNo = Isnull(ContainerNo,''),	@StatusKey = Statuskey,
			@DriverKeys = DriverKeys, @OrderKeys = OrderKeys,
			@OrderDateFrom	= OrderDateFrom, @OrderDateTo = OrderDateTo,		
			@DeliveryDateFrom = DeliveryDateFrom, @DeliveryDateTo	= DeliveryDateTo, 
			@OrderNo = OrderNo,
			@voucherNo = voucherNo, @VoucherKeys = VoucherKeys,
			@DriverHubkeys = DriverHubkeys, @WeekNum = WeekNum,
			@MarketLocationKeys	= MarketLocationKeys,
			@TruckTypeKeys = TruckTypeKeys,
			@CarrierMoveTypeKeys = CarrierMoveTypeKeys,
			@isDriverPay = isDriverPay,
			@SearchText = ltrim(rtrim(isnull(SearchText,'')))

		from OpenJSON(@JsonString, '$')
		WITH (
			ContainerNo				varchar(20)			'$.containerNo',
			StatusKey				INT					'$.StatusKey',
			DriverKeys				varchar(max)		'$.DriverKeys',
			OrderKeys				varchar(max)		'$.OrderKeys',
			OrderDateFrom			DATE				'$.OrderDateFrom',
			OrderDateTo				DATE				'$.OrderDateTo',
			DeliveryDateFrom		DATE			    '$.DeliveryDateFrom',
			DeliveryDateTo			DATE				'$.DeliveryDateTo',
			OrderNo					VARCHAR(50)			'$.OrderNo',
			voucherNo				VARCHAR(50)			'$.voucherNo',
			VoucherKeys				varchar(max)		'$.VoucherKeys',
			DriverHubkeys			varchar(max)		'$.DriverHubkeys',
			WeekNum					VARCHAR(5)			'$.WeekNum',
			MarketLocationKeys		varchar(max)		'$.MarketLocationKeys',
			TruckTypeKeys		    varchar(max)	    '$.TruckTypeKeys',
			CarrierMoveTypeKeys		varchar(max)		'$.CarrierMoveTypeKeys',
			isDriverPay				bit					'$.isDriverPay',
			SearchText				varchar(50)			'$.SearchText'
		)

		create table #DriverKey
	(
		DriverKey	int
	)
	create table #OrderKey
	(
		OrderKey	int
	)
	create table #voucherKey
	(
		VoucherKey	int
	)
	create table #DriverHubKey
	(
		DriverhubKey	int
	)
	create table #MarketLocationKey
	(
		MarketLocationKey	int
	)
	create table #TruckTypeKey
	(
		TruckTypeKey	int
	)
	create table #CarrierMoveTypeKey
	(
		MoveTypeKey	int
	)

	if(Isnull(@DriverKeys,'') <> '')
	Begin
		insert into #DriverKey(DriverKey)
		select value from dbo.Fn_SplitParamCol(@DriverKeys)
	End
	if(Isnull(@OrderKeys,'') <> '')
	Begin
		insert into #OrderKey(OrderKey)
		select value from dbo.Fn_SplitParamCol(@OrderKeys)
	End

	if(Isnull(@VoucherKeys,'') <> '')
	Begin
		insert into #voucherKey(VoucherKey)
		select value from dbo.Fn_SplitParamCol(@VoucherKeys)
	End
	if(Isnull(@DriverHubkeys,'') <> '')
	Begin
		insert into #DriverHubKey(DriverhubKey)
		select value from dbo.Fn_SplitParamCol(@DriverHubkeys)
	End

	if(Isnull(@marketLocationKeys,'') <> '')
	Begin
		insert into #MarketLocationKey(MarketLocationKey)
		select value from dbo.Fn_SplitParamCol(@marketLocationKeys)
	End

	if(Isnull(@TruckTypeKeys,'') <> '')
	Begin
		insert into #TruckTypeKey(TruckTypeKey)
		select value from dbo.Fn_SplitParamCol(@TruckTypeKeys)
	End

	if(Isnull(@CarrierMoveTypeKeys,'') <> '')
	Begin
		insert into #CarrierMoveTypeKey(MoveTypeKey)
		select value from dbo.Fn_SplitParamCol(@CarrierMoveTypeKeys)
	End

	IF(@StatusKey = 4)
	Begin
		Set @StatusKey = 0
	End
	
	--if(isnull(@WeekNum ,'')<>'')
	--Begin
	--	DECLARE @datecol datetime = GETDATE();
	--	DECLARE @WeekNumInt INT = convert(int, replace(@weekNum,'WK-','') )
	--			, @YearNum char(4);

	--	SELECT @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

	--	-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
		       
	--	SELECT @DeliveryDateFrom = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNumInt-1), 7) ;
	--	SELECT @DeliveryDateTo = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNumInt-1), 6);
	--	SEt @OrderDateFrom = '2020-01-01'
	--	SEt @OrderDateTo = '2050-12-31'
	--End

	if(isnull(@WeekNum ,'')<>'')
	Begin
		DECLARE @WeekNumInt INT = CAST(REPLACE(@weekNum, 'WK-', '') AS INT);
        DECLARE @YearNum CHAR(4) = CAST(DATEPART(YEAR, GETDATE()) AS CHAR(4));
        SET @DeliveryDateFrom = DATEADD(WEEK, DATEDIFF(WEEK, 6, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @DeliveryDateTo = DATEADD(WEEK, DATEDIFF(WEEK, 5, '1/1/' + @YearNum) + (@WeekNumInt - 1), 7);
        SET @OrderDateFrom = '2025-07-01';
        SET @OrderDateTo = '2050-12-31';
	End

       SELECT  d.DriverID,d.FirstName DriverFirstName,d.LastName DriverLastName,
						ISNULL(DV.DriverVoucherNumber, VH.VoucherNo) voucherno,VH.VoucherDate voucherdate,
                      SR.City AS FromLocation,DT.City AS ToLocation,od.ContainerNo,I.ItemID,VD.ExtCost extcost, 
					  VD.Qty qty, VD.UnitCost unitcost,
                      ISNULL(VH.IsPaymentApproved,0)AS ispaymentapproved, 
                      ISNULL(VH.[Statuskey],9)  AS StatusKey
                      ,VH.VoucherAmount voucheramount
                      , Case when ISNULL(ID.InvoiceKey,0) = 0 then 0 else 1 end AS IsInvoiced
                      , ISNULL(IH.InvoiceNo,'NA') as invoiceNo
                      , ISNULL(IH.InvoiceDate,'') as InvoiceDate
                      , VS.Description
                      , IH.InvoiceKey
                      , VD.Voucherkey voucherkey
                      , LG.LegID
                      --, RT.FromLocation
                      --, RT.ToLocation
                      , d.DriverKey
                      , d.DrivingLicenseNo
                      , d.DrivingLicenseExpiryDate 
                      , RT.ActualArrival
                      , 'WK-' + ISNULL(CAST(DV.WeekNumber AS VARCHAR),isnull(convert(varchar,datepart(ISO_WEEK, RT.ActualArrival)),'')) as Weeknum
                      ,  CAST(0 AS Decimal)  AS ApDeductions
                      , od.OrderDetailKey
                      , case when isnull(d.OrgName,'') = '' then '' 
                             else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
                                    + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end as DriverOrg
                      , A.Week_Start_Date WeekStartDate, A.Week_End_Date WeekEndDate, d.DriverHubKey, dh.DriverHubName,VD.DriverPay,
					  TRY_CAST(
					  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
						) AS INT) AS Sort_DriverId
                             into #tmpManifst
       FROM 
              VoucherHeader VH WITH (NOLOCK) 
              INNER JOIN VoucherDetail VD WITH (NOLOCK)  ON VH.Voucherkey = VD.Voucherkey
              INNER JOIN dbo.VoucherStatus VS WITH (NOLOCK)   ON VS.[StatusKey]=VH.[StatusKey]
              INNER JOIN dbo.[routes] RT WITH (NOLOCK) ON VD.RouteKey = RT.RouteKey
              INNER JOIN dbo.OrderDetail od      ON RT.OrderDetailKey = od.OrderDetailkey
              INNER JOIN dbo.OrderHeader oh      ON oh.OrderKey = od.OrderKey
              INNER JOIN dbo.Leg LG                     ON LG.LegKey = RT.LegKey
              --INNER JOIN dbo.LegType L           ON L.LegtypeKey = LG.LegTypeKey

              INNER JOIN dbo.Driver d                   ON d.DriverKey = RT.DriverKey
              INNER JOIN dbo.RouteStatus RTS     ON RTS.[Status]=RT.[Status]
              LEFT JOIN RouteVouchers RV         ON RV.RouteKey=RT.RouteKey AND RV.VoucherKey=VH.VoucherKey
              LEFT JOIN dbo.[Address] SR         ON SR.AddrKey=RT.SourceAddrKey
              LEFT JOIN dbo.[Address] DT         ON DT.AddrKey=RT.DestinationAddrKey
              LEFT JOIN dbo.Item I               ON I.ItemKey=VD.ItemKey
              LEFT JOIN DBO.InvoiceContainers ID     ON ID.OrderDetailsKey = OD.OrderDetailKey  --AND ID.ItemKey = VD.ItemKey
              LEFT JOIN dbo.InvoiceHeader IH  ON ID.InvoiceKey = IH.InvoiceKey
			  LEFT JOIN dbo.DriverHub dH                   ON d.DriverHubKey = DH.DriverHubKey
              cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A
			  LEFT JOIN DriverVoucher DV WITH (NOLOCK) ON DV.LinkedVoucherKey=VH.VoucherKey
       WHERE 
              (  @StatusKey = 0 OR  ISNULL(VH.[Statuskey],9)  = @StatusKey )
     --         --AND (  @DriverKey =0 OR @DriverKey IS NULL OR RT.DriverKey IS NULL OR RT.DriverKey=@DriverKey )
     --         AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )
     --         --AND    (  @OrderDateFrom    IS NULL OR OH.OrderDate              IS NULL OR OH.OrderDate>=@OrderDateFrom)
     --         --AND (  @OrderDateTo         IS NULL OR OH.OrderDate              IS NULL OR OH.OrderDate<=@OrderDateTo)
     --         --AND    (  @DeliVeryDateFom  IS NULL OR RT.DeliveryDateFrom  IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
     --         --AND (  @DelivaryDateTo      IS NULL OR RT.DeliveryDateTo    IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo)
     --         AND (  @OrderNo                    = '' OR OH.OrderNo           IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
     --         AND (  @containerNo         = '' OR OD.ContainerNo       IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
     --         AND (  @voucherNo           = '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')
     --         AND (  @VoucherKey          = 0 OR @VoucherKey is null OR VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey )
			  ----AND (  @DriverHubKey          = 0 OR @DriverHubKey is null OR d.DriverHubKey IS NULL OR d.DriverHubKey=@DriverHubKey )
		AND (  isnull(@DriverKeys,'')  = '' OR Rt.DriverKey in (select Driverkey from #DriverKey)  )
		AND (  isnull(@OrderKeys,'')  ='' OR OH.OrderKey in (Select ORderKey from #OrderKey) )
		AND	(  isnull(@OrderDateFrom,'')	= '' OR OH.OrderDate		IS NULL OR OH.OrderDate between @OrderDateFrom and @OrderDateTo)
		AND	(  isnull(@DeliveryDateFrom	,'') = '' OR RT.ActualArrival is null OR 
		CASE WHEN IsRetroPay=1 THEN DV.DriverVoucherdate ELSE RT.ActualArrival END between @DeliveryDateFrom and @DeliveryDateTo)
		AND (  isnull(@OrderNo	,'')		= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
		AND (  isnull(@containerNo ,'')		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
		AND (  isnull(@voucherNo,'')		= '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')
		AND ( isnull(@searchtext,'') = '' OR 
			(   OH.OrderNo like '%' + @searchtext + '%' OR 
				OD.ContainerNo like '%' +  @searchtext + '%' OR 
				ISNULL(VH.VoucherNo,'NA') like '%' + @searchtext + '%') ) 
		AND (  isnull(@VoucherKeys,'') 		= '' OR Vh.VoucherKey in (select voucherkey from #voucherKey) )
		AND (  isnull(@DriverHubkeys,'')  = '' OR D.DriverHubKey in (Select DriverhubKey from #DriverHubKey))
		AND (  ISNULL(@marketLocationKeys,'') = '' OR  OH.MarketLocationKey in (Select MarketLocationKey From #MarketLocationKey) )
		AND (  ISNULL(@TruckTypeKeys,'') = '' OR  D.TruckTypeKey in (Select TruckTypeKey From #TruckTypeKey) )

		IF(@isDebug=1)
		BEGIN
			select* from  #tmpManifst --WHERE (ISNULL(@WeekNum, '')='' OR Weeknum =@WeekNum)
		ENd
        
		IF (@isDriverPay = 1)
		BEGIN
			DELETE FROM #tmpManifst
			WHERE TRY_CAST(
					  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
				  ) AS INT) NOT BETWEEN 700 AND 948;
		END
		ELSE IF (@isDriverPay = 0)
		BEGIN
			DELETE FROM #tmpManifst
			WHERE TRY_CAST(
					  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
				  ) AS INT) BETWEEN 700 AND 948;
		END

       select *, 
	    9999 as DriverID1
		Into #FinalData
	   from (
				 select* from  #tmpManifst WHERE (ISNULL(@WeekNum, '')='' OR Weeknum =@WeekNum)
			   --union all 
					 -- select distinct  DriverID,  DriverFirstName,    DriverLastName,       M.VoucherNo,  M.VoucherDate,       '' as PickUpPoint, '' as DeliveryPoint, '' as     ContainerNo,  
					 -- I.ItemID,     VD.ExtCost,   VD.Qty,       VD.UnitCost,  M.IsPaymentApproved, M.StatusKey,       M.VoucherAmount,     IsInvoiced,   InvoiceNo,       InvoiceDate,  
					 -- VD.Description,      InvoiceKey,   M.Voucherkey,       LegID, --FromLocation, ToLocation,   
					 -- DriverKey,       DrivingLicenseNo,    
					 -- DrivingLicenseExpiryDate,   ActualArrival,       Weeknum, VD.ExtCost as APDeductions,     OrderDetailKey,       DriverOrg,    WeekStartDate,     
					 -- WeekEndDate , M.DriverHubKey,M.DriverHubName   ,VD.DriverPay     
					 -- from   
					 -- VoucherHeader VH WITH (NOLOCK) 
					 -- INNER JOIN VoucherDetail VD WITH (NOLOCK)  ON VH.Voucherkey = VD.Voucherkey and RouteKey=0
					 -- inner join  #tmpManifst M on (VH.VoucherKey = M.Voucherkey)
					 -- inner join Item I on (vd.ItemKey = I.ItemKey)
				UNION ALL
 					  select distinct  DriverID,  DriverFirstName,    DriverLastName,      VH.DriverVoucherNumber,  Vh.DriverVoucherdate,       
						'' as PickUpPoint, '' as DeliveryPoint, isnull(VD.Remarks ,'') as     ContainerNo,  
					  I.ItemID  ,     VD.ExtCost as ExtCost,   VD.Qty,       VD.UnitCost as UnitCost, 
					   M.IsPaymentApproved as  IsPaymentApproved, M.StatusKey as StatusKey,       
					  VH.DriverVoucherAmount,   0  IsInvoiced,   
					  '' InvoiceNo,  GETDATE() InvoiceDate,  
					  VD.Description,    0  InvoiceKey,  '' Voucherkey,    ''   LegID, 
					  --'' FromLocation,  '' ToLocation,   
					  VH.DriverKey,       DrivingLicenseNo,    
					   DrivingLicenseExpiryDate,   GETDATE() ActualArrival,      'WK-'+ convert(varchar,VH.WeekNumber) Weeknum, 
					  VD.ExtCost as ApDeductions,      9999 OrderDetailKey,        DriverOrg,    WeekStartDate,     
					  WeekEndDate    , M.DriverHubKey, M.DriverHubName  ,'' DriverPay  ,'' Sort_DriverId
					  from   
					  DriverVoucherDeduction VH WITH (NOLOCK) 
					  INNER JOIN DriverVoucherDeductionDetail VD WITH (NOLOCK)  ON VH.DriverVoucherKey = VD.DriverVoucherKey
					  inner join Item I on (vd.ItemKey = I.ItemKey)
					  Inner join ITEM MI on I.MasterItemKey =MI.ItemKey
					  --inner join #tmpManifst M on ('WK-'+ convert(varchar,VH.WeekNumber) =  M.Weeknum
					  inner join #tmpManifst M on ('WK-'+ isnull(convert(varchar,datepart(ISO_WEEK, VH.DriverVoucherdate)),'') =  M.Weeknum
					  and YEAR(vh.DriverVoucherdate)=YEAR(M.voucherdate) and M.DriverKey =VH.DriverKey
					  --AND (  isnull(@OrderDateFrom,'')= '' OR VH.DriverVoucherdate IS NULL OR VH.DriverVoucherdate between @OrderDateFrom and @OrderDateTo)
					  )
					  --WHERE
					   --(  @DriverKey =0 OR @DriverKey IS NULL OR VH.DriverKey IS NULL OR VH.DriverKey=@DriverKey )
              ) X
	--order by DriverID1,Sort_DriverId, DriverID, ActualArrival,OrderDetailKey, ContainerNo, LegID, ItemID
	order by Sort_DriverId, ActualArrival,OrderDetailKey, ContainerNo, LegID, ItemID

	update #FinalData set 
		LegID = case when  CHARINDEX('(',LegID,1) = 0 then LegID else  left(LegID,CHARINDEX('(',LegID,1) - 1) end,
		ItemID = case when  CHARINDEX('(',ItemID,1) = 0 then ItemID else  left(ItemID,CHARINDEX('(',ItemID,1) - 1) end

	--	select  * 
	--from #FinalData
SET @Reason='Success'
SET @Status=1
	select  * ,--CAST(0 AS DECIMAL(18,2)) AS ApDeductions, 
	CAST(0 AS INT) RouteKey,@UserKey AS UserKey, CAST(0 AS INT) vendkey
	from #FinalData
      --order by CAST(SUBSTRING(WeekNum, 4, LEN(WeekNum)) AS INT), DriverID1
	  order by Sort_DriverId, CAST(SUBSTRING(WeekNum, 4, LEN(WeekNum)) AS INT) ASC
	  FOR JSON PATH
END
