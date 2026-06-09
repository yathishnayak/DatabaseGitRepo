
--  MSKU123457
-- [Get_OpenContainerLegToUpdateNew_shiva] @SearchText = 'TRHU4640350'
--   [Get_OpenContainerLegToUpdateNew_shiva]
--[Get_OpenContainerLegToUpdateNew_shiva] @Customer='', @OrderNo = '', @ContainerNo='', @PickUpDateFrom = '2020-08-01', @PickUpDateTo = '2022-09-07'
CREATE PROCEDURE [dbo].[Get_OpenContainerLegToUpdateNew] 
	@Customer		VARCHAR(50)='',
	@OrderNo		VARCHAR(20)='',
	@ContainerNo	VARCHAR(20)='',
	@PickUpDateFrom	DATE='01/01/2020',
	@PickUpDateTo	DATE='12/31/2099',
	@PickupTypeKey  SMALLINT=0,
	@PageNo				INT = 1,
	@PageSize			INT	= 10,
	@SortField			varchar(50) = 'ContainerNo',
	@IsAscending		bit = 1,
	@CreatedUSer		varchar(50) = '',
	@SearchText			varchar(200) = ''
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @StartDate		DATETIME
	DECLARE @EndDate		DATETIME
	DECLARE @PickUpFrom		VARCHAR(50)
	DECLARE @ContCmnt       VARCHAR(2000)
	DECLARE @RouteCompletedStatus	int = 0

	select status as StatusKey
	into #StatusKey
	from OrderDetailStatus  with (nolock)
	where Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold', 'Dispatch Confirmed','Approved for Invoice/Driver Pay' ) 

	select @RouteCompletedStatus = Status
	from RouteStatus with (nolock)
	where Description = 'Leg Completed'

	SET @StartDate=CAST(GETDATE() AS DATE)
	SET @EndDate=DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(hh,23,DATEADD(DD,6,@StartDate))))
	SET @PickUpFrom= ( SELECT PickUpType from PickUpType WHERE PickupTypeKey=@PickupTypeKey)

	SELECT ShortComment,orderdetailkey,Comment INTO #ContTypes
		FROM (
				SELECT 
						OC.orderdetailkey,[value] as 'Comment',LEFT([value],3) AS ShortComment
				FROM [dbo].[Comment] C  WITH (NOLOCK) 
					CROSS APPLY STRING_SPLIT(C.[description],',')  
					INNER JOIN 
						[dbo].[OrderDetailComments] OC   WITH (NOLOCK) ON  OC.CommentKey = C.CommentKey					
				WHERE OC.OrderDetailKey IN 	( SELECT OrderDetailKey FROM OrderDetail WHERE STATUS NOT IN (1,11) )
			) A 
		INNER JOIN ContainerTypes CT WITH (NOLOCK) ON A.Comment = CT.TypeID	

	SELECT	isnull(ContainerNo,'') as ContainerNo,
			isnull(DropOffDate,'01-01-1900') as DropOffDate,
			isnull(DT.AddrName,'') as FinalDestination,
			isnull(OD.OrderDetailKey,0) as OrderDetailKey,
			isnull(OD.OrderKey,0) as OrderKey,
			isnull(OrderType,'') as OrderType,
			isnull(SR.AddrName,'') as Origin,
			isnull(RS.Description,'') as StatusName,
			isnull(OrderNo,'') as OrderNo,
			isnull(CustName,'') as CustName,
			isnull(RT.ScheduledPickupDate,'01-01-1900') as ContainerTime,
			convert(bit,isnull(dbo.FN_IsOrderDetailComplete(OD.OrderDetailKey),0)) as ReadyToRelease,
			isnull(BookingNo,'') as BookingNo,
			convert(bit,0) as IsRowHidden,
			ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+
				ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') as CustAddress,
			isnull(Oh.OrderTypeKey,0) as OrderTypeKey,
			isnull(DR.DriverKey,0) as DriverKey,
			isnull(DR.DriverID + ' : ' + DR.FirstName+' '+ISNULL(DR.LastName,''),'') as DriverName,
			isnull(SRR.AddrName,'') as FromLocation,
			isnull(DTR.AddrName ,'') as ToLocation,
			convert(datetime,isnull(RT.ScheduledPickupDate,'01-01-1900')) as ScheduledPickupDate,
			convert(datetime,isnull(RT.ScheduledArrival,'01-01-1900')) as ScheduledArrival,

			isnull(RT.RouteKey,0) as RouteKey,
			convert(bigint, Isnull(ISNULL(RT.LegNo,1),1))  as LegNo,
			--isnull(1,convert(bit,0))
			ISNULL(HZ.IsHazmat,0) as IsHazmat,
			isnull(SR.Address1,'') as S_Address1,
			isnull(SR.City,'') as S_City,
			isnull(SR.State,'') as S_State,
			isnull(SR.Country,'') as S_Country,
			isnull(SR.ZipCode,'') as S_ZipCode,
			isnull(DT.Address1,'') as D_Address1,
			isnull(DT.City,'') as D_City,
			isnull(DT.State,'') as D_State,
			isnull(DT.Country,'') as D_Country,
			isnull(DT.ZipCode,'') as D_ZipCode,
			convert(datetime,isnull(RT.PickupDateFrom,'01-01-1900')) as PickupDateFrom,
			convert(datetime,isnull(RT.PickupDateTo,'01-01-1900')) as PickupDateTo,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			isnull(OD.IsEmpty,convert(bit,0)) as IsEmpty,
			isnull(PT.PickupType,'') as PickupType,
			DATEDIFF(HH,getdate(),convert(datetime,isnull(ScheduledPickupDate,getdate()))) as DelayHours,
			isnull(S.Description,'') as ContainerSize,
			case when ScheduledPickupDate is null then 'NA' 
				when DATEPART(HH,ScheduledPickupDate) >=18 OR DATEPART(HH,ScheduledPickupDate) <= 2 then 'Night'
				else 'Day' end as DayNightIndicator,
			convert(varchar(100),'') as Scheduled_DateTime
		,CAST(ISNULL(OD.CurrentLegNo,0) AS VARCHAR(50))+' of '+CAST(OD.TotalLegs AS VARCHAR(50)) AS CurLeg
			
		, OD.ContainerStatusKey
		, OD.openlegs
		, OD.CurrentLegNo
		, ContainerTypes= '' -- OCT.Description
		--STUFF(( 
		--	SELECT ', '+ShortComment 
		--	FROM #ContTypes 
		--	WHERE OrderDetailKey=A.OrderDetailKey
		--	FOR XML PATH('')), 1, 2, '')
	into #tempOutput
	FROM dbo.OrderDetail OD   WITH (NOLOCK) 
		INNER JOIN  dbo.OrderHeader OH	  WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		INNER JOIN  dbo.Customer CUS	  WITH (NOLOCK) ON CUS.CustKey=OH.CustKey
		INNER JOIN  dbo.OrderType OT	  WITH (NOLOCK) ON OT.OrderTypeKey=OH.OrderTypeKey
		INNER JOIN  dbo.[Routes] RT		  WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L			  WITH (NOLOCK) ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		  WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS   WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] CAdr	  WITH (NOLOCK) ON CAdr.Addrkey=OH.BillToAddrKey
		LEFT JOIN   dbo.[Address] SRR	  WITH (NOLOCK) ON SRR.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] DTR	  WITH (NOLOCK) ON DTR.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.[Address] SR	  WITH (NOLOCK) ON SR.Addrkey=OD.SourceAddrKey
		LEFT JOIN   dbo.[Address] DT	  WITH (NOLOCK) ON DT.Addrkey=OD.DestinationAddrKey
		LEFT JOIN   dbo.Driver DR		  WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		  WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey	
		--LEFT JOIN   dbo.OrderDetailStatus ODS   WITH (NOLOCK) ON ODS.[Status]=OD.[Status]
		LEFT JOIN   dbo.ContainerSize S	  WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey	
		Left JOIN OrderDetailStatus RS ON OD.Status = RS.Status
		Left join dbo.PickUpType PT   WITH (NOLOCK) on L.PickupTypeKey = PT.PickupTypeKey
		LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
		leFT jOIN (
				 SELECT DISTINCT orderdetailkey, 1 AS IsHazmat FROM #ContTypes WHERE Comment='Hazard'
		) HZ ON od.OrderDetailKey = HZ.OrderDetailKey
	WHERE OD.Status not in (1,11) and  RT.RouteKey = OD.CurrentRouteKey  
	AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
	AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)	
	AND (ISNULL(@SearchText,'') = '' OR
			OD.ContainerNo like '%' + @SearchText + '%' OR
			OT.OrderType  like '%' + @SearchText + '%' OR
			SRR.AddrName  like '%' + @SearchText + '%' OR
			DTR.AddrName  like '%' + @SearchText + '%' OR
			OH.OrderNo  like '%' + @SearchText + '%' OR
			RS.Description  like '%' + @SearchText + '%'  OR
			OH.BookingNo like '%' + @SearchText + '%' )
	ORDER BY ScheduledPickupDate , ContainerNo
	--************************************************************************************
	

	Declare @cnt int = 0	
	select @cnt = count(1) from #tempOutput
	
	--select * from #tempOutput
		
	--select *, 0 as RecCount  from #FinalOutput
	DECLARE @STRSQL VARCHAR(MAX)

	SET @STRSQL = '
	SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
		select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SortField  + ' ) RowNum
		from #tempOutput  
		ORDER BY ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' 
	) a
	where ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))

	PRINT (@STRSQL)
	EXEC (@STRSQL)
END
