/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"StatusKey" : 0, "DriverKey" : 0, "OrderKey" : 0, "OrderDateFrom" : "", "OrderDateTo" : "", "DeliveryDateFrom" : "", "DeliveryDateTo" : "", "OrderNo" : "", "ContainerNo" : "", "VoucherNo" : "", "VoucherKey" : 0, "MarketLocationKey" : 0}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_VoucherStatusDashboard_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_VoucherStatusDashboard_V3] -- [Get_VoucherStatusDashboard] 0
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@StatusKey			INT= 0,
	@DriverKey			INT= 0,
	@OrderKey			INT= 0,
	@OrderDateFrom		DATE='01/01/2020',
	@OrderDateTO		DATE='12/31/2099',
	@DeliVeryDateFom	 DATE='01/01/2020',
	@DelivaryDateTo		DATE='12/31/2099',
	@OrderNo			VARCHAR(50)='',
	@containerNo		VARCHAR(50)='',
	@voucherNo			VARCHAR(50)='',
	@VoucherKey			INT=0,
	@MarketLocationKey	INT=0

	SELECT
	@StatusKey						=		StatusKey			,
	@DriverKey						=		DriverKey			,
	@OrderKey						=		OrderKey			,
	@OrderDateFrom					=		OrderDateFrom		,
	@OrderDateTO					=		OrderDateTO			,
	@DeliVeryDateFom				=		DeliVeryDateFom		,
	@DelivaryDateTo					=		DelivaryDateTo		,
	@OrderNo						=		OrderNo				,
	@containerNo					=		containerNo			,
	@voucherNo						=		voucherNo			,
	@VoucherKey						=		VoucherKey			,
	@MarketLocationKey				=		MarketLocationKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
	StatusKey					INT					'$.StatusKey'			,
	DriverKey					INT					'$.DriverKey'			,
	OrderKey					INT					'$.OrderKey'				,
	OrderDateFrom				DATE				'$.OrderDateFrom'		,
	OrderDateTO					DATE				'$.OrderDateTo'			,
	DeliVeryDateFom				DATE				'$.DeliveryDateFrom'		,
	DelivaryDateTo				DATE				'$.DeliveryDateTo'		,
	OrderNo						VARCHAR(50)			'$.OrderNo'				,
	containerNo					VARCHAR(50)			'$.ContainerNo'			,
	voucherNo					VARCHAR(50)			'$.VoucherNo'			,
	VoucherKey					INT					'$.VoucherKey'			,
	MarketLocationKey			INT					'$.MarketLocationKey'
	)

	Declare @IsWithFilter Bit = 1

	if(@OrderDateFrom < convert(Date,Getdate()-365) and @DeliVeryDateFom < convert(Date,Getdate()-365)
			and @OrderNo='' and @containerNo=''  and @voucherNo=''  and @VoucherKey=0  
			and @MarketLocationKey=0 and @DriverKey=0  and @OrderKey=0 )
	Begin
		SEt @IsWithFilter = 0
	end

	if(@IsWithFilter = 0)
	Begin
		Set @OrderDateFrom = GetDate() - 60
		Set @OrderDateTO = '2050-12-31'
		Set @DeliVeryDateFom = GetDate() - 30
		SEt @DelivaryDateTo = '2050-12-31'
	end

	Declare @OpenStatusKey smallint = 0;

	select @OpenStatusKey = Status from RouteStatus WITH (NOLOCK) where Description = 'Leg Completed'
	SELECT StatusKey, [Description] AS StatusName INTO #VouchStatus
	FROM dbo.VoucherStatus WITH (NOLOCK) 
	UNION ALL 
	SELECT 9,'PendingToProcess'

	

	SELECT S.StatusKey, StatusName , ISNULL(A.cnt,0) AS StatusCount
	INTO #Temp
	FROM #VouchStatus S
	LEFT JOIN (
			SELECT Z.StatusKey, count(1) cnt 
			FROM (
					SELECT  DISTINCT  
						ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
						ISNULL(VH.[Statuskey],9)   AS StatusKey,
						VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,
						OH.BrokerRefNo, OD.VesselETA
					FROM dbo.[routes] RT WITH (NOLOCK)
						INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
						INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
						INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
						INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
						LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
						LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
						LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
						LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
						Left join dbo.vVoucherAmt VMT	WITH (NOLOCK) ON VH.VoucherKey = VMT.voucherKey
					WHERE 	RTS.Status= 5 	and  VH.VoucherKey IS not NULL		
					--WHERE 	RTS.Status= @OpenStatusKey 	and  VH.VoucherKey IS not NULL	
					AND	(  @OrderDateFrom	IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate>=@OrderDateFrom)
					AND (  @OrderDateTo		IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate<=@OrderDateTo)
					AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
					AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateTo	IS NULL OR RT.DeliveryDateTo<=@DelivaryDateTo)
					AND (  @MarketLocationKey = 0 OR oh.MarketLocationKey = @MarketLocationKey  )
				union all
						SELECT  
							ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
							ISNULL(VH.[Statuskey],9)   AS StatusKey,
							VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,
							OH.BrokerRefNo, OD.VesselETA
						FROM dbo.[routes] RT WITH (NOLOCK) 
			INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
			INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
			INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
			INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
			INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
			INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status] and rts.Status = @OpenStatusKey
			LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
			LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
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
							-- AND (@DriverHubkey =0 OR @DriverHubkey IS NULL OR D.DriverHubKey IS NULL OR D.DriverHubKey= @DriverHubkey)
							AND (  isnull(@voucherNo,'') = '' OR (ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%'))
							AND (  isnull(@VoucherKey,0)= 0 OR (VH.VoucherKey IS NULL OR VH.VoucherKey=@VoucherKey ))
							AND (  ISNULL(@marketLocationKey,0) = 0 OR  OH.MarketLocationKey = @marketLocationKey )
									) Z
							GROUP BY StatusKey
			) A ON S.StatusKey = A.StatusKey;

	SELECT StatusKey, StatusName, StatusCount, 'I' AS LEVEL FROM #temp
	UNION ALL
	SELECT 0, 'All', SUM(StatusCount) AS StatusCount, 'S' AS LEVEL FROM #temp 
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

END
