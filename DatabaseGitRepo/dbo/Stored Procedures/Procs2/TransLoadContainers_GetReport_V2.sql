/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [TransLoadContainers_GetReport_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[TransLoadContainers_GetReport_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @PickupDateFrom DATE='01/01/2020',
			@PickupDateTo			DATE='01/12/2030',
			@DeleveryDateFrom	DATE='01/01/2020',
			@DeleveryDateTo			DATE='01/12/2030',
			@CSRKey			INT = 0,
			@StatusKey	INT=0,
			@IsTransLoad BIT = 0,
			@CustomerKey INT = 0



			IF ISJSON(@JSONString) <> 1
BEGIN
    SET @JSONString = '{}'
END


	SELECT @PickupDateFrom = PickupDateFrom, @PickupDateTo = PickupDateTo, @DeleveryDateFrom = DeliveryDateFrom, @DeleveryDateTo = DeliveryDateTo, @CSRKey = CSRKey, @StatusKey=StatusKey,@IsTransLoad =IsTransLoad,
			@CustomerKey=CustomerKey
	from OPENJSON(@JSONString, '$')
	with (
			PickupDateFrom			DATE '$.PickupDateFrom',
			PickupDateTo			DATE  '$.PickupDateTo',
			DeliveryDateFrom		DATE  '$.DeliveryDateFrom',
			DeliveryDateTo			DATE '$.DeliveryDateTo',
			CsrKey					INT '$.CsrKey',
			StatusKey				INT   '$.StatusKey',
			IsTransLoad				BIT   '$.IsTransLoad',
			CustomerKey				INT '$.CustKey'
		 )

declare @OpenStatusKey smallint =0;
	set @PickupDateFrom = isnull(@PickupDateFrom, convert(Date,'01/01/2020'))
	set @PickupDateTo = isnull(@PickupDateTo, convert(Date,'01/12/2050'))

	set @DeleveryDateFrom = isnull(@DeleveryDateFrom, convert(Date,'01/01/2020'))
	set @DeleveryDateTo = isnull(@DeleveryDateTo, convert(Date,'01/12/2050'))

	select @OpenStatusKey = Status from OrderDetailStatus WITH (NOLOCK)	where Description  = 'Open'
	
	DECLARE @STRSQL NVARCHAR(MAX)

	set @STRSQL = 
	'SELECT top 100
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,''1900-01-01'') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailKey,
			isnull(OT.OrderTypeKey,0) as OrderTypeKey,
			isnull(OH.OrderNo,'''') as OrderNo,
			isnull(CR.CsrName,'''') as CsrName,
			isnull(OD.ContainerNo,'''') as ContainerNo,
			isnull(OD.ContainerID, '''') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			isnull(OD.LastFreeDay,'''') as LastFreeDay,
			RT.PickupDateFrom AS PickupDate ,
			CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			RT.DeliveryDateFrom AS DropOffDate,
			CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,	
			isnull(OSD.[Description],'''') AS [Status],
			isnull(OT.OrderType,'''') AS OrderType,
			isnull(OH.BillOfLading,'''') AS BillOfLading,
			isnull(OH.BookingNo,'''') AS BookingNo,
			isnull(OH.BrokerRefNo,'''') as BrokerRefNo,
			isnull(CS.[Description],'''') AS ContainerSize,
			isnull(PT.[Description],'''')  AS [Priority],
			isnull(SR.AddrName,'''') AS S_AddrName,
			isnull(SR.Address1,'''') AS S_Address1,
			isnull(SR.City,'''')  AS S_City,
			isnull(SR.[State],'''')  AS S_State,
			isnull(SR.ZipCode,'''')  AS S_ZipCode,
			isnull(SR.Country,'''')  AS S_Country,
			isnull(DT.AddrName,'''')  AS D_AddrName,
			isnull(DT.Address1,'''')  AS D_Address1,
			isnull(DT.City,'''')  AS D_City,
			isnull(DT.[State],'''')  AS D_State,
			isnull(DT.ZipCode,'''')  AS D_ZipCode,
			isnull(DT.Country,'''')  AS D_Country,
			isnull(BT.AddrName,'''')  AS B_AddrName,
			isnull(BT.Address1,'''')  AS B_Address1,
			isnull(BT.City,'''')  AS B_City,
			isnull(BT.[State],'''')  AS B_State,
			isnull(BT.ZipCode,'''')  AS B_ZipCode,
			isnull(BT.Country,'''')  AS B_Country,
			isnull(RET.AddrName,'''') AS R_AddrName,
			isnull(RET.Address1,'''') AS R_Address1,
			isnull(RET.City,'''') AS R_City,
			isnull(RET.[State],'''') AS R_State,
			isnull(RET.ZipCode,'''') AS R_ZipCode,
			isnull(RET.Country,'''') AS R_Country,	
			isnull(OD.VesselETA,'''') AS VesselETA,	
			CASE 
				WHEN OD.status = 1 THEN ''Proceed to Schedule'' 
				WHEN OD.status = 3 THEN ''Complete Schedule''          
				WHEN OD.status = 4 THEN ''Confirm/Complete Schedule'' 
				WHEN OD.status = 5 THEN ''Process Dispatch'' 
				WHEN OD.status = 7 THEN ''Complete Dispatch''   
				WHEN OD.status = 8 THEN ''Confirm/Complete Dispatch''  
				WHEN OD.status = 9 THEN ''Approve Invoice/Driver Pay''  
				WHEN OD.status = 10 THEN ''Closed'' 
				WHEN OD.status = 6 THEN ''Approve for Invoice/Driver Pay'' 
				WHEN OD.status = 2 THEN ''Proceed to Dispatch''
				END AS NextAction,
			OH.custKey as CustKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
			, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as IsTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			ISNULL(UU.UserName,'''') AS CreatedUser,
			OD.[Status] as StatusKey,
			CAST(ISNULL(od.CurrentLegNo,0) AS VARCHAR(10))+'' [ ''+ ISNULL(CAST(od.CurrentLegNo AS VARCHAR(10)),0)+ '' of ''+CAST(od.TotalLegs AS VARCHAR(10))+'' ]'' AS CurLeg,
			l.FromLocation  AS LocationType ,
			RA.AddrName AS CurLocation, RT.RouteKey, RP.AddrName, 
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			B.LastFreeDay as  Int_LFD, convert(bit, case when isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end) as IntDataExists 
		
		FROM  dbo.OrderDetail OD					WITH (NOLOCK)		
			INNER JOIN dbo.OrderHeader OH			WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
			INNER JOIN dbo.OrderStatus OS			WITH (NOLOCK)	ON OS.[Status]=OH.[Status]
			LEFT JOIN dbo.[Broker]  BR				WITH (NOLOCK)	ON BR.BrokerKey=OH.BrokerKey
			INNER JOIN  dbo.OrderDetailStatus OSD	WITH (NOLOCK)	ON OSD.[Status] = OD.[Status]
			INNER JOIN dbo.ContainerSize CS			WITH (NOLOCK)	ON CS.ContainerSizeKey = OD.ContainerSizeKey		
			LEFT JOIN dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey=OH.CsrKey		
			LEFT JOIN  dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
			LEFT JOIN [Address] SR					WITH (NOLOCK)	ON	SR.AddrKey=OD.SourceAddrKey
			LEFT JOIN [Address] DT					WITH (NOLOCK)	ON	DT.AddrKey=OD.DestinationAddrKey
			LEFT JOIN [Address] BT					WITH (NOLOCK)	ON	BT.AddrKey=OH.BillToAddrKey
			LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey=OH.ReturnAddrKey
			LEFT JOIN  dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
			LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
			LEFT Join DBO.[User] UU					WITH (NOLOCK)	ON OD.CreateUserKey = uu.UserKey
			LEft join Routes RT WITH (NOLOCK) on OD.CurrentRouteKey = Rt.RouteKey
			inner join vContainerType CT WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and Ct.TypeID = ''Transload''
			LEft join Address RA with (nolock) on RT.DestinationAddrKey = RA.AddrKey
			LEFT join Leg L WITH (NOLOCK) ON RT.LegKey = l.LegKey
			LEFT JOIN ADDRESS RP WITH (NOLOCK) ON RT.SourceAddrKey = RP.AddrKey
			LEFT JOIN vContainerType HZ WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey AND CT.TypeID = ''Hazard''
			LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEft join Int_ContainerAvailability B with (NOLOCK) on OD.OrderDetailkey  = B.OrderDetailKey
		WHERE  1=1 ' +
			--' AND ( (	RT.PickupDateFrom is null or RT.PickupDateTo is null) OR
			--(RT.DeliveryDateFrom is null OR RT.DeliveryDateTo is null) OR
			--' + case when @PickupDateFrom is null OR @PickupDateTo is null then ' 1=1 '  
			-- else '( RT.PickupDateFrom  >= ''' +  convert(varchar, @PickupDateFrom, 101) + 
			-- '''  and RT.PickupDateTo  <=''' + convert(varchar, @PickupDateTo,101) + ''') OR 
			--( RT.PickupDateTo >= ''' +  convert(varchar, @PickupDateFrom, 101) + ''' and ' 
			--+ ' RT.PickupDateTo <= ''' + convert(varchar, @PickupDateTo,101) + ''')' end + ') ' +
			--'AND ( ' + case when @DeleveryDateFrom	IS NULL then ' 1 = 1 ' else ' RT.DeliveryDateFrom IS NULL  OR 
			--	 RT.DeliveryDateFrom >= ''' +  convert(varchar, @DeleveryDateFrom, 101) + ''''  end + ') ' +
			--'AND ( ' + case when @DeleveryDateTo	IS NULL then ' 1 = 1 '  else + '  RT.DeliveryDateTo IS NULL OR 
			--	RT.DeliveryDateTo <= ''' +  convert(varchar, @DeleveryDateTo, 101) + '''' end + ') ' + 
	' AND ( ' +
CASE
    WHEN @PickupDateFrom IS NULL AND @PickupDateTo IS NULL
        THEN '1=1'
    ELSE
        ' CONVERT(date,RT.PickupDateFrom) 
          BETWEEN ''' + CONVERT(varchar(10),@PickupDateFrom,120) + '''
              AND ''' + CONVERT(varchar(10),@PickupDateTo,120) + ''' '
END + ') ' +

' AND ( ' +
CASE
    WHEN @DeleveryDateFrom IS NULL AND @DeleveryDateTo IS NULL
        THEN '1=1'
    ELSE
        ' CONVERT(date,RT.DeliveryDateFrom) 
          BETWEEN ''' + CONVERT(varchar(10),@DeleveryDateFrom,120) + '''
              AND ''' + CONVERT(varchar(10),@DeleveryDateTo,120) + ''' '
END + ') '+

			'AND ( ' + case when Isnull(@CSRKey, 0) = 0 then ' 1=1 ' else 'OH.CsrKey= ' + convert(varchar, @CSRKey) end + ' ) ' +	
			'AND ( ' + case when isnull(@statusKey,0) = 0 then ' 1=1 ' else ' OD.[Status] = ' + convert(varchar,@statusKey) end + ') ' +
			'AND ( ' + case when isnull(@CustomerKey,0) = 0 then ' 1=1 ' else ' CU.CustKey = ' + convert(varchar,@CustomerKey) end + ' ) '  
			
	
	SET @STRSQL = @STRSQL + ' FOR JSON PATH, INCLUDE_NULL_VALUES'
		
				IF @IsDebug = 1
		BEGIN
			PRINT @STRSQL
		END


		EXEC (@STRSQL)


		SET @Status = 1
		SET @Reason = 'Success'


END