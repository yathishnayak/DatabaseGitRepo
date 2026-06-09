/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '',  @IsDebug	bit = 1
set @JsonString = '{"IsAscending":true,"IsInvoiced":null,"ContainerNo":"","BookingNo":"","CSRKey":"97:","BrokerRef":"","StatusKey":1,"PageNo":1,"PageSize":50,"SortField":"ContainerNo"}'
exec Charge_GetWarehouseContainerList @UserKey, @JSONString, @Status output, @Reason output, @IsDebug
select @Status, @Reason
*/

CREATE Proc [dbo].[Charge_GetWarehouseContainerList]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	

	DECLARE 
		@ContainerNo	varchar(20),
		@AgingDaysFrom	int,
		@AgingDaysTo	int,
		@CustKeys		varchar(500),
		@BookingNo		varchar(50),
		@CSRKeys		varchar(500),
		@BrokerRef		varchar(50),
		@StatusKey		int, -- 0 : All
		@PageNo			int,
		@PageSize		int,
		@SearchText		varchar(50),
		@SortField		varchar(50),
		@IsAscending	Bit = 1,
		@IsInvoiced		BIT

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @ContainerNo = ContainerNo,@AgingDaysFrom = AgingDaysFrom,@AgingDaysTo = AgingDaysTo,
		   @CustKeys=CustKeys,@BookingNo=BookingNo,@CSRKeys=CSRKeys,@BrokerRef=BrokerRef,@StatusKey=StatusKey,
		   @PageNo = PageNo,  @PageSize =PageSize, @SearchText = SearchText, @SortField = SortField,
		   @IsAscending = IsAscending, @IsInvoiced=IsInvoiced
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo		varchar(20)		'$.ContainerNo',
		AgingDaysFrom	int				'$.AgingDaysFrom',
		AgingDaysTo		int				'$.AgingDaysTo',
		CustKeys		varchar(500)	'$.CustKey',
		BookingNo		varchar(50)		'$.BookingNo',
		CSRKeys			varchar(500)	'$.CSRKey',
		BrokerRef		varchar(50)		'$.BrokerRef',
		StatusKey		int				'$.StatusKey', -- 0 : All
		PageNo			int				'$.PageNo',
		PageSize		int				'$.PageSize',
		SearchText		varchar(50)		'$.SearchText',
		SortField		varchar(50)		'$.SortField',
		IsAscending		bit				'$.IsAscending',
		IsInvoiced		bit				'$.IsInvoiced'
	)
	CREATE TABLE #CustKeys
	(
		CustKey		int,
		CustName	varchar(200)
	)
	IF(LEN(ISNULL(@CustKeys,'')) > 0)
	BEGIN
		insert into #CustKeys(CustKey)
		select value from dbo.Fn_SplitParamCol(@CustKeys)
	END

	CREATE TABLE #CSRKeys
	(
		CSRKey		int,
		CSRName		varchar(100)
	)
	IF(LEN(ISNULL(@CSRKeys,'')) > 0)
	BEGIN
		insert into #CSRKeys(CSRKey)
		select value from dbo.Fn_SplitParamCol(@CSRKeys)
	END

	if(@AgingDaysFrom > 0 and @AgingDaysTo = 0)
	Begin
		set @AgingDaysTo = 1000
	End

	if(@AgingDaysFrom = 0 and @AgingDaysTo > 0)
	Begin
		set @AgingDaysFrom = 1
	end
	if(@IsDebug = 1)
	Begin
		Select @ContainerNo as ContainerNo,@AgingDaysFrom as AgingDaysFrom,@AgingDaysTo as AgingDaysTo,
			@CustKeys as CustKey,@BookingNo as BookingNo,@CSRKeys as CSRKey,@BrokerRef as BrokerRef,
			@StatusKey as StatusKey, @PageNo  as  PageNo,  @PageSize  as PageSize, @SearchText  as  SearchText, 
			@SortField  as  SortField,		   @IsAscending  as IsAscending
		select '#CustKeys',* from #CustKeys
		Select '#CSRKeys',* from #CSRKeys
	End
	

	select OH.OrderNo, --OD.CompleteDate,
	    OD.ActualPickupDate CompleteDate,OH.CustKey, CU.CustID, CU.CustName,
		upper(OD.ContainerNo) as ContainerNo,OD.status as ContainerStatusKey, ODS.Description as ContainerStatus, 
		DateDIFF(d, OD.CompleteDate,GetDate()) as AgingDays,
		OT.OrderType, OH.BookingNo, CS.CsrName, OH.CsrKey, OH.BrokerRefNo, OH.Consignee,
		isnull(WCD.StatusKey,1) as StatusKey, WS.Description as StatusName,
		WCD.ContainerMode, WCD.PalletCount, WCD.InDate, WCD.OutDate, WCD.IsNoOutDate,
		WCD.IsStoring, OD.OrderDetailKey, ISNULL(IC.InvoiceKey,0) InvoiceKey,
		TotalAmount = isnull( WC.TotalAmount,0),
		ISNULL(InvoiceNo,'') InvoiceNo,U.UserName AS InvoicerName,
		WCD.PalletRestriction, WCD.WHLocation,WCD.DOWorkScope, WCD.SpecialInstruction,WCD.Priority,WCD.Sorting,
		Case when WCD.StatusKey is null then 'New' else 'Exist' end as SortOrd
	into #Temp
	from orderDetail OD WITH (NOLOCK) 
	inner join OrderDetailStatus ODS WITH (NOLOCK) on Od.Status = ODS.Status
	LEft join InvoiceContainers IC WITH (NOLOCK) on OD.OrderDetailKey = IC.OrderDetailsKey
	inner join OrderHeader OH WITH (NOLOCK) on OD.orderkey = OH.OrderKey
	inner join Customer CU WITH (NOLOCK) ON oh.CustKey = cu.CustKey
	inner join OrderType OT WITH (NOLOCK) ON oh.OrderTypeKey = OT.OrderTypeKey
	LEft join CSR CS WITH (NOLOCK) on OH.CsrKey = CS.CsrKey
	inner join ContainerTypesLink CTL WITH (NOLOCK) on OD.OrderDetailKey = CTL.OrderDetailKey
	INNER JOIN ContainerTypes CT  WITH (NOLOCK) ON CTL.ContainerTypeKey = CT.ContainerTypeKey and CT.ContainerTypeKey = 6
	LEft join Warehouse_ContainerDetails WCD  WITH (NOLOCK) on OD.OrderDetailKey = WCd.OrderDetailKey
	LEft join WarehouseStatus WS  WITH (NOLOCK) ON isnull(WCD.StatusKey,1) = WS.StatusKey
	LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON IC.InvoiceKey=IH.InvoiceKey
	LEFT JOIN [User] U WITH (NOLOCK) ON U.UserKey=IH.CreateUserKey
	Left join (Select OrderDetailKey , sum(ExtAmt) TotalAmount from Warehouse_Charges WITH (NOLOCK) 
			group by OrderDetailKey) WC On OD.OrderDetailKey = WC.OrderDetailKey
	WHERE CT.TypeDescription = 'Transload' and IC.InvoiceKey is null --and isnull(WCD.StatusKey,1) = @StatusKey
		and (OD.status in (1,2,3,4,6,10, 12,13,14) OR (SELECT Count(1) FROM Routes RT WITH (NOLOCK)
		INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey AND L.ToLocation='Consignee' 
		AND RT.OrderDetailKey=OD.OrderDetailKey AND RT.Status=5)>0 AND OD.Status=7)  --and isnull(WCD.StatusKey,1) <> 9 
		and OH.OrderDate >= convert(date, '2024-10-07')
	
	if(@IsDebug = 1)
	Begin
		select '#Temp', * from #Temp
		select '#Temp', * from #Temp where ContainerNo like  '%' + @ContainerNo + '%'
	end

	select *
	INTO #FinalData
	from #Temp A
	where 1 = 1 
		and (isnull(StatusKey,1) = @StatusKey)
		and (isnull(@ContainerNo,'') = '' OR A.ContainerNo like '%'+ @ContainerNo + '%')
		and (isnull(@AgingDaysFrom,0) = 0 OR isnull(@AgingDaysTo,0) = 0 OR 
			A.AgingDays between @AgingDaysFrom and @AgingDaysTo)
		and (Isnull(@custkeys,'') = '' OR A.CustKey in (select CustKey from #CustKeys))
		and (isnull(@BookingNo,'') = '' OR A.BookingNo like '%'+ @BookingNo + '%')
		and (isnull(@BrokerRef,'') = '' OR A.BrokerRefNo like '%'+ @BrokerRef + '%')
		and (Isnull(@CSRKeys,'') = '' OR A.CsrKey in (select CsrKey from #CSRKeys))
		--AND (ISNULL(@IsInvoiced,0)=0 OR InvoiceKey =(CASE WHEN @IsInvoiced =1 THEN InvoiceKey ELSE 0 END))
		AND (
    @IsInvoiced IS NULL
    OR (@IsInvoiced = 1 AND ISNULL(InvoiceKey,0) > 0)
    OR (@IsInvoiced = 0 AND ISNULL(InvoiceKey,0) = 0)
)
		and (Isnull(@SearchText,'') = '' OR 
			A.ContainerNo like '%'+ @SearchText + '%' OR
			A.CsrName like '%'+ @SearchText + '%' OR
			A.BookingNo like '%'+ @SearchText + '%' OR
			A.BrokerRefNo like '%'+ @SearchText + '%' OR
			A.CustName like '%'+ @SearchText + '%' OR
			A.CustID like '%'+ @SearchText + '%' OR
			A.OrderType like '%'+ @SearchText + '%' OR
			A.Consignee like '%'+ @SearchText + '%' 
		)
	if(@IsDebug = 1)
	Begin
		select '#FinalData',* from #FinalData
	End

	select distinct WS.StatusKey,WS.Description as StatusName, isnull(cnt,0) as StatusCount 
	into #StatusData
	from  WarehouseStatus  WS WITH (NOLOCK)
	Left join (select StatusKey, count(1) as cnt from  #temp group by Statuskey ) T on WS.StatusKey = T.StatusKey

	if(@IsDebug = 1)
	Begin
		select '#StatusData',* from #StatusData
	end

		declare @cnt int
		select @cnt = count(1) from #FinalData where ( StatusKey = @StatusKey)

		DECLARE @STRSQL VARCHAR(MAX)

		select *, 0 as RowNum, 0 as RecCount into  #FinalData_temp from #FinalData WHERE 1 <> 1 

		SET @STRSQL = '
		SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
			select top 1000000 *, ROW_NUMBER() Over(Order by SortOrd ASC , ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END 
				+ ') RowNum
			from #FinalData
			where (' + convert(varchar, isnull(@StatusKey,0)) + ' = 0 OR StatusKey = ' +  convert(varchar, isnull(@StatusKey,0)) + ')'+
		+') a
		where RowNum  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
		+' Order BY ROWNUM'

		if(@IsDebug = 1)
		Begin
			SElect * from #FinalData order by sortOrd 
		End

		PRINT (@STRSQL)
		insert into #FinalData_temp
		EXEC (@STRSQL)

		SET @Status=1
		SET @Reason='Success'
		select 
		ContainerList = (
			select * from #FinalData_temp A 
			FOR JSON PATH
		) ,
		DashboardData = (
			select A.StatusKey, A.StatusName, isnull(A.StatusCount ,0) as StatusCount
			from #StatusData A
			FOR JSON PATH
		) FOR JSON PATH
		
END