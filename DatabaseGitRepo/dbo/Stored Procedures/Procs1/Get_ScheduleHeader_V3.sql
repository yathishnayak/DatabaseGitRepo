/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"OrderDetailKey" : 224132}',
	@Status BIT=0, @IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec Get_ScheduleHeader_V3 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_ScheduleHeader_V3]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)

AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@OrderDetailKey INT=270

	SELECT 
		@OrderDetailKey		=		OrderDetailKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		OrderDetailKey			INT			'$.OrderDetailKey'
	)

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

	DECLARE @SalesPersonKey		INT,
			@SalesPersonName	Varchar(50),
			@MarketLocationKey		int,
			@MarketLocation	Varchar(200),
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
			@MarketLocationKey=OH.MarketLocationKey, 
			@ConsigneeName=ISNULL(CC.ConsigneeName,''), 
			@ConsigneeKey = ISNULL(OD.ConsigneeKey, OH.ConsigneeKey),
			@Customer = C.CustName, 
			@OrderDate=OH.OrderDate,@SteamShipLine=LineName,@ScacCode=ISNULL(GICF.Ocean_carrier_scac,SSL.ScacCode),
			@ETADate=OH.ETADate,@VesselName=ISNULL(CGD.Vessel,OH.VesselName),
			@AvailableDate=CGD.AvailableDate,@DropOrLive=ISNULL(Od.DropOrLive,OH.DropLive)
	from OrderHeader OH WITH (nolock) 
	inner join OrderDetail OD WITH (nolock) on OH.OrderKey = od.OrderKey
	left join SalesPerson SP WITH (nolock) on oh.SalesPersonKey = sp.SalesPersonKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=OH.MarketLocationKey
	LEFT JOIN customer C WITH(NOLOCK) ON C.CustKey = OH.CustKey
	LEFT JOIN SteamShipLine SSL WITH (NOLOCK) ON SSL.LineKey=OH.SteamShipLinekey
	LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
	LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON CGD.OrderDetailKey=OD.OrderDetailKey
	LEFT JOIN Customer_Consignee CC WITH (NOLOCK) ON CC.ConsigneeKey=ISNULL(OD.ConsigneeKey,OH.ConsigneeKey)
	
	where od.OrderDetailKey = @OrderDetailKey


	
	SELECT TOP 1
		OD.OrderDetailkey as OrderDetailKey,		
		OD.Status AS OrderDetailStatus,
		LT.LegtypeKey AS LegTypeKey,
		LT.Instruction AS LegTypeDescription,			
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
		ContainerProperties=ISNULL(STUFF((
            SELECT ',' + TypeID
            FROM ContainerTypesLink CTLI
			INNER JOIN ContainerTypes CTI ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
			WHERE CTLI.OrderDetailKey=OD.OrderDetailkey
            FOR XML PATH('')
        ), 1, 1, ''),''),
		SchedulerLegsList =(
		    SELECT
		        RT.OrderDetailkey as OrderDetailKey,
		        RT.RouteKey,        
		        L.LegID as LegDescription,
		        L.LegKey,
		        L.LegTypeKey,
		        RT.LegNo,
		        RT.SourceAddrKey AS Pickup,
		        RT.DestinationAddrKey AS Delivery,
		        Sour.AddrName AS FromLocation, 
		        Dst.AddrName AS ToLocation,
		        RT.PickupDateFrom,
		        RT.PickupDateTo,
		        RT.DeliveryDateFrom,
		        RT.DeliveryDateTo,
		        ISNULL(RT.ConfirmationNo,'') ConfirmationNo,
		        ISNULL(RT.DelConfirmationNo,'') DelConfirmationNo,
		        RT.Status,
		        RT.IsDryRun,

				-------------------------------------------------
				-- Pickup Address Details
				-------------------------------------------------
				Sour.AddrKey  AS PickupAddrKey,
				Sour.AddrName AS PickupAddressName,
				Sour.Address1 AS PickupAddress1,
				Sour.City     AS PickupCity,
				Sour.[State]  AS PickupState,
				Sour.ZipCode  AS PickupZipcode,
				Sour.Country  AS PickupCountry,

				-------------------------------------------------
				-- Delivery Address Details
				-------------------------------------------------
				Dst.AddrKey   AS DeliveryAddrKey,
				Dst.AddrName  AS DeliveryAddressName,
				Dst.Address1  AS DeliveryAddress1,
				Dst.City      AS DeliveryCity,
				Dst.[State]   AS DeliveryState,
				Dst.ZipCode   AS DeliveryZipcode,
				Dst.Country   AS DeliveryCountry,

		        -------------------------------------------------
		        -- Expense List
		        -------------------------------------------------
		        ExpenseList =
		        (
		            SELECT 
		                OE.Itemkey,
		                OE.RouteKey,
		                I.ItemID,
		                I.[Description] AS ItemDescription,
		                CASE WHEN OE.Qty > 0 THEN OE.Qty ELSE 0 END AS Qty,
		                OE.DateFrom,
		                OE.DateTo,
		                IT.ItemType
		            FROM dbo.OrderExpense OE
		            INNER JOIN dbo.Item I ON I.ItemKey = OE.Itemkey
		            INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey = I.ItemTypeKey
		            WHERE OE.RouteKey = RT.RouteKey
		            AND IT.ItemType IN ('Expense','Expense + Service')
		            FOR JSON PATH
		        ),

		        -------------------------------------------------
		        -- Service List
		        -------------------------------------------------
		        ServiceList =
		        (
		            SELECT 
		                OE.Itemkey,
		                OE.RouteKey,
		                I.ItemID,
		                I.[Description] AS ItemDescription,
		                OE.Qty,
		                OE.DateFrom,
		                OE.DateTo
		            FROM dbo.OrderExpense OE
		            INNER JOIN dbo.Item I ON I.ItemKey = OE.Itemkey
		            INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey = I.ItemTypeKey
		            WHERE OE.RouteKey = RT.RouteKey
		            AND IT.ItemType IN ('Service','Expense + Service')
		            FOR JSON PATH
		        )

		    FROM dbo.Routes RT
		    LEFT JOIN dbo.Leg L ON L.LegKey = RT.LegKey
		    LEFT JOIN dbo.[Address] Sour ON Sour.AddrKey = RT.SourceAddrKey
		    LEFT JOIN dbo.[Address] Dst ON Dst.AddrKey = RT.DestinationAddrKey
		    WHERE RT.OrderDetailKey = OD.OrderDetailKey
		    ORDER BY RT.RouteKey
		    FOR JSON PATH
	)
	FROM dbo.OrderDetail OD 	WITH (nolock)
		LEFT JOIN  dbo.[Routes] RT WITH (nolock)		ON RT.OrderDetailKey = od.OrderDetailKey
		LEFT JOIN  dbo.Leg L	WITH (nolock)			ON L.LegKey=RT.LegKey
		LEFT JOIN  dbo.LegType LT	WITH (nolock)		ON LT.LegtypeKey=L.LegTypeKey	
		LEFT JOIN dbo.ContainerSize S WITH (nolock)		ON S.ContainerSizeKey=OD.ContainerSizeKey
		
	WHERE  Od.Orderdetailkey = @OrderDetailKey 
	ORDER BY RT.RouteKey ASC

	FOR JSON PATH
	
	SET @Status = 1
	SET @Reason = 'Success'
END;
