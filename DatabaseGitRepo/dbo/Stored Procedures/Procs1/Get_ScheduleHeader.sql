CREATE PROCEDURE [dbo].[Get_ScheduleHeader] -- [Get_ScheduleHeader] 330
@OrderDetailKey INT=270
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	CREATE TABLE #ContType
	(
	OrderDetailKey INT,
	CommentKey	INT,
	Comment		VARCHAR(100),
	ContNo		VARCHAR(20),
	ShortCmnt	VARCHAR(10)
	)

	INSERT INTO #ContType (OrderDetailKey,CommentKey,Comment,ContNo,ShortCmnt)
	EXECUTE Get_ContainerTypeForContainer @OrderDetailKey=@OrderDetailKey, @Container=''

	DECLARE @SalesPersonKey		int,
			@SalesPersonName	Varchar(50),
			@MarketLocationKey		int,
			@MarketLocation	Varchar(200),
			--@Consignee		VARCHAR(100),
			@ConsigneeName		VARCHAR(100),
			@ConsigneeKey			INT,
			@Customer        VARCHAR(200),
			@OrderDate			DATETIME,
			@ETADate			DATETIME,
			@SteamShipLine		NVARCHAR(200),
			@ScacCode			NVARCHAR(200),
			@VesselName			NVARCHAR(200),
			@AvailableDate		DATETIME,
			@DropOrLive			NVARCHAR(10)


	select @SalesPersonKey = OH.SalesPersonKey, @SalesPersonName = SP.SalesPersonName, @MarketLocation=MarketLocation, 
			@MarketLocationKey=OH.MarketLocationKey, --@Consignee=ISNULL(OH.Consignee,OD.Consignee), 
			@ConsigneeName=ISNULL(CC.ConsigneeName,''), 
			@ConsigneeKey = ISNULL(OD.ConsigneeKey, OH.ConsigneeKey),
			@Customer = C.CustName, 
			@OrderDate=OH.OrderDate,@SteamShipLine=LineName,@ScacCode=ISNULL(GICF.Ocean_carrier_scac,SSL.ScacCode),
			@ETADate=OH.ETADate,@VesselName=ISNULL(CGD.Vessel,OH.VesselName),
			@AvailableDate=CGD.AvailableDate,@DropOrLive=ISNULL(Od.DropOrLive,OH.DropLive)
	from OrderHeader OH with (nolock) 
	inner join OrderDetail OD with (nolock) on OH.OrderKey = od.OrderKey
	left join SalesPerson SP with (nolock) on oh.SalesPersonKey = sp.SalesPersonKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=OH.MarketLocationKey
	LEFT JOIN customer C WITH(NOLOCK) ON C.CustKey = OH.CustKey
	LEFT JOIN SteamShipLine SSL WITH (NOLOCK) ON SSL.LineKey=OH.SteamShipLinekey
	LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
	LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON CGD.OrderDetailKey=OD.OrderDetailKey
	LEFT JOIN Customer_Consignee CC WITH (NOLOCK) ON CC.ConsigneeKey=ISNULL(OD.ConsigneeKey,OH.ConsigneeKey)
	
	where od.OrderDetailKey = @OrderDetailKey


	
	SELECT TOP 1
		OD.OrderDetailkey,		
		OD.Status AS OrderDetailStatus,
		LT.LegtypeKey AS LegTypeKey,
		LT.Instruction AS WorkFlow,			
		OD.LastFreeDay,
		OD.CutOffDate		
		, ISNULL(OD.IsEmpty,0) as IsEmpty
		, ISNULL(OD.IsTMF,0) as IsTMF
		, OD.DriverNotes
		, OD.SchedulerNotes
		,S.ContainerSizeKey
		, S.Description as ContainerSize
		,OD.ContainerNo
		,OD.SealNo
		,OD.[Weight]
		,OD.WeightUnit
		,OD.TMFCheckOff
		,OD.CTFCheckOff
		,OD.SizeCheckOff
		, isnull(@SalesPersonKey,0) as SalesPersonKey
		, isnull(@SalesPersonName,'NA') as SalesPersonName
		--,isnull(STUFF((  
		--	SELECT ', '+Comment FROM #ContType 
		--	WHERE OrderDetailKey=OD.OrderDetailKey
		--	FOR XML PATH('')), 1, 2, ''),'') AS  ContainerType	,
			,ISNULL(@MarketLocationKey,0) AS MarketLocationKey,ISNULL(@MarketLocation,0) AS MarketLocation,
			'' as Consignee, 
			@ConsigneeName as ConsigneeName, 
			@ConsigneeKey AS ConsigneeKey,
			@Customer Customer,
			@OrderDate AS OrderDate,@ETADate AS ETADate,
			@SteamShipLine AS SteamShipLine,@ScacCode AS ScacCode,
			CONVERT(VARCHAR,@AvailableDate,101)  AS Available,
			CASE WHEN @DropOrLive='L' OR @DropOrLive='LIVE' THEN 'LIVE' WHEN 
			@DropOrLive='D' OR @DropOrLive='Drop' THEN 'Drop' ELSE 'N/A' END  AS DropOrLive,
			@VesselName AS VesselName,
			OD.CustRefNo AS BrokerRefNo,
		ContainerType=ISNULL(STUFF((
            SELECT ',' + TypeID
            FROM ContainerTypesLink CTLI
			INNER JOIN ContainerTypes CTI ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
			WHERE CTLI.OrderDetailKey=OD.OrderDetailkey
            FOR XML PATH('')
            ), 1, 1, ''),'')
	FROM dbo.OrderDetail OD 	with (nolock)
		LEFT JOIN  dbo.[Routes] RT with (nolock)		ON RT.OrderDetailKey = od.OrderDetailKey
		LEFT JOIN  dbo.Leg L	with (nolock)			ON L.LegKey=RT.LegKey
		LEFT JOIN  dbo.LegType LT	with (nolock)		ON LT.LegtypeKey=L.LegTypeKey	
		LEFT JOIN dbo.ContainerSize S with (nolock)		ON S.ContainerSizeKey=OD.ContainerSizeKey
		
	WHERE  Od.Orderdetailkey = @OrderDetailKey 
	ORDER BY RT.RouteKey ASC
END;
