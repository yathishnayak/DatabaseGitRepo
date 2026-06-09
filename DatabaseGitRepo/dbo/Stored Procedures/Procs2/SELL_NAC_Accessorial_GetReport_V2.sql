/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"PageNumber": 1, "PageSize": 50}'
	EXEC [SELL_NAC_Accessorial_GetReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[SELL_NAC_Accessorial_GetReport_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET @Status = 0
			SET @Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@CustomerKey		INT			= 0,
		@MarketKey			INT			= 0,
		@Consignee			VARCHAR(50)	= '',
		@SalesPersonKey		INT			= 0,
		@ItemKeyStr			VARCHAR(100)= '',	
		@BvsNB				SMALLINT	= 0,	
		@IsQuote			BIT			= 0,
		@PageNumber			INT			= 1,	
		@PageSize			INT			= 50	

	SELECT 
		@CustomerKey	= CustomerKey,
		@MarketKey		= MarketKey,
		@Consignee		= Consignee,
		@SalesPersonKey	= SalesPersonKey,
		@ItemKeyStr		= ItemKeyStr,
		@BvsNB			= BvsNB,
		@IsQuote		= IsQuote,
		@PageNumber		= ISNULL(PageNumber, 1),
		@PageSize		= ISNULL(PageSize,   50)
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustomerKey		INT				'$.CustKey',
		MarketKey		INT				'$.MarketLocationKey',
		Consignee		VARCHAR(50)		'$.Consignee',
		SalesPersonKey	INT				'$.SalesPersonKey',
		ItemKeyStr		VARCHAR(100)	'$.ItemKeyStr',
		BvsNB			SMALLINT		'$.BvsNB',
		IsQuote			BIT				'$.IsQuote',
		PageNumber		INT				'$.PageNumber',
		PageSize		INT				'$.PageSize'
	)

	IF @PageNumber < 1   SET @PageNumber = 1
	IF @PageSize   < 1   SET @PageSize   = 50
	IF @PageSize   > 500 SET @PageSize   = 500

	DECLARE @Offset INT = (@PageNumber - 1) * @PageSize

	SELECT * INTO #ItemKeys FROM dbo.Fn_SplitParam(@ItemKeyStr)

	DECLARE @TotalRows INT

	SELECT @TotalRows = COUNT(*)
	FROM SELL_NAC_Accessorial_FinalDataOutput A WITH (NOLOCK)
	LEFT JOIN Customer    C  WITH (NOLOCK) ON A.CustKey        = C.CustKey
	WHERE
		(ISNULL(@CustomerKey,   0)  = 0  OR A.CustKey         = @CustomerKey) AND
		(ISNULL(@MarketKey,     0)  = 0  OR A.MarketKey        = @MarketKey)   AND
		(ISNULL(@SalesPersonKey,0)  = 0  OR C.SalesPersonKey   = @SalesPersonKey) AND
		(ISNULL(@ItemKeyStr,   '') = ''  OR A.ItemKey IN (SELECT value FROM #ItemKeys)) AND
		(ISNULL(@BvsNB,         0)  = 0  OR A.BvsNB = CASE WHEN @BvsNB = 1 THEN 'B' ELSE 'NB' END)

	SELECT Distinct
		FileProcessKey, RecordSL,
		ISNULL(A.CustID,  C.CustID)   AS CustID,
		ISNULL(A.CustName,C.CustName) AS CustName,
		RateType, Segment, MarketLocation, Terminal, City, State, Zip, LineItem,
		LocationName, IsLocationExists, Rate, FreeTime, A.BvsNB, MinCnt, MaxCnt, ContainerSize,
		EffectiveDate, EffectiveDateFrom,
		A.MarketKey AS MarketLocationKey,
		TerminalKey, A.CustKey, SegmentKey,
		@TotalRows                                      AS TotalRecords,
		--@PageSize                                       AS PageSize,
		--@PageNumber                                     AS PageNumber,
		CEILING(CAST(@TotalRows AS FLOAT) / @PageSize)  AS TotalPages
	FROM SELL_NAC_Accessorial_FinalDataOutput A WITH (NOLOCK)
	LEFT JOIN Customer    C  WITH (NOLOCK) ON A.CustKey        = C.CustKey
	LEFT JOIN SalesPerson SP WITH (NOLOCK) ON C.SalesPersonKey = SP.SalesPersonKey
	WHERE
		(ISNULL(@CustomerKey,   0)  = 0  OR A.CustKey         = @CustomerKey) AND
		(ISNULL(@MarketKey,     0)  = 0  OR A.MarketKey        = @MarketKey)   AND
		(ISNULL(@SalesPersonKey,0)  = 0  OR C.SalesPersonKey   = @SalesPersonKey) AND
		(ISNULL(@ItemKeyStr,   '') = ''  OR A.ItemKey IN (SELECT value FROM #ItemKeys)) AND
		(ISNULL(@BvsNB,         0)  = 0  OR A.BvsNB = CASE WHEN @BvsNB = 1 THEN 'B' ELSE 'NB' END)
	ORDER BY
	 FileProcessKey
	OFFSET @Offset ROWS
	FETCH NEXT @PageSize ROWS ONLY
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END