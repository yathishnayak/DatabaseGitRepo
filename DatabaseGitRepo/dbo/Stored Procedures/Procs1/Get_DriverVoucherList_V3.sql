/*
DECLARE 
	@UserKey		INT				= 1144,
	@JSONString		NVARCHAR(MAX)	= '{"DriverKey":0, "ItemKey":14}',	
	@Status			BIT				= 0,
	@Reason			VARCHAR(100)	= '',
	@IsDebug		BIT				= 1
EXEC [Get_DriverVoucherList_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason 
*/

/*
DECLARE 
	@UserKey		INT				= 1144,
	@JSONString		NVARCHAR(MAX)	= '{"DriverVoucherKey":6}',	
	@Status			BIT				= 0,
	@Reason			VARCHAR(100)	= '',
	@IsDebug		BIT				= 1
EXEC [Get_DriverVoucherList_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason 
*/
CREATE PROCEDURE [dbo].[Get_DriverVoucherList_V3]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS 
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	DECLARE 
		@DriverVoucherKey		INT= 0,
		@DriverKey				INT = 0,
		@DateFrom				DATETIME ='2000-01-01',
		@DateTo					DATETIME = '2050-12-31',
		@DriverVoucherNumber	NVARCHAR(50) = '',
		@IsMarkedRecurring		BIT = 0,
		-- @DeductionItem			NVARCHAR(100) = '',
		@WeekNumber				INT = 0,
		@StatusKey				INT = 0,
		@ItemKey				INT = 0  
		
	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	SELECT	
		@DriverVoucherKey		= DriverVoucherKey,		
		@DriverKey				= DriverKey,
		@DateFrom				= DateFrom,
		@DateTo					= DateTo, 
		@DriverVoucherNumber	= DriverVoucherNumber,		
		@IsMarkedRecurring		= IsMarkedRecurring, 
		-- @DeductionItem			= DeductionItem, 
		@WeekNumber				= WeekNumber,
		@StatusKey				= StatusKey,
		@ItemKey				= ItemKey  
	FROM OPENJSON(@JsonString, '$')
	WITH (
		DriverVoucherKey				INT				'$.DriverVoucherKey',
		DriverKey					INT				'$.DriverKey',
		DateFrom					DATETIME		'$.DateFrom',
		DateTo						DATETIME		'$.DateTo',
		DriverVoucherNumber			NVARCHAR(50)	'$.DriverVoucherNumber',
		IsMarkedRecurring			BIT				'$.IsMarkedRecurring',
		-- DeductionItem				NVARCHAR(100)	'$.DeductionItem',
		WeekNumber					INT				'$.WeekNumber',
		StatusKey					INT				'$.StatusKey',
		ItemKey						INT				'$.ItemKey'  
	)

	SELECT 
		DVD.DriverVoucherKey, 
		DVD.DriverVoucherNumber, 
		DVD.DriverVoucherdate, 
		DVD.DriverVoucherAmount, 
		DVD.WeekNumber,
		'' AS [Description], 
		D.DriverId AS DriverID, 
		D.FirstName + ' ' + D.LastName AS DriverName, 
		D.DrivingLicenseNo, 
		D.DrivingLicenseExpiryDate,
		ISNULL(DVD.UpdateDate, DVD.CreateDate) AS LastUpdateDate,
		ISNULL(DVD.UpdateUser, DVD.CreateUser) AS LastUpdateBy,
		ISNULL(DVD.ContainerNo, '') AS ContainerNo,
		ISNULL(DDD.DeductionItems, '') AS DeductionItem,		
		CASE 
			WHEN ISNULL(DVD.StatusKey,0) <> 3 THEN CAST(0 AS BIT) 
			ELSE CAST(1 AS BIT) 
		END AS IsPaid

	FROM DriverVoucher DVD

	LEFT JOIN Driver D 
		ON D.DriverKey = DVD.DriverKey
	LEFT JOIN (
		SELECT DISTINCT ST2.DriverVoucherKey,
			(
				SELECT LTRIM(RTRIM(IT.[Description])) + '<br/>' 
				FROM DriverVoucherDetail ST1
				INNER JOIN ITEM IT 
					ON ST1.ItemKey = IT.ItemKey
				WHERE ST1.DriverVoucherKey = ST2.DriverVoucherKey
				FOR XML PATH (''), TYPE
			).value('text()[1]','nvarchar(max)') AS DeductionItems
		FROM dbo.DriverVoucher ST2
	) DDD 
		ON DVD.DriverVoucherKey = DDD.DriverVoucherKey

	WHERE 
		(ISNULL(@DriverVoucherKey,0) = 0 OR DVD.DriverVoucherKey = @DriverVoucherKey)
		AND (ISNULL(@DateFrom, '2000-01-01') = '2000-01-01' OR DVD.DriverVoucherdate >= @DateFrom)
		AND (ISNULL(@DateTo, '2050-12-31') = '2050-12-31' OR DVD.DriverVoucherdate <= @DateTo)
		AND (ISNULL(@DriverKey, 0) = 0 OR DVD.DriverKey = @DriverKey)
		AND (ISNULL(@WeekNumber, 0) = 0 OR DVD.WeekNumber = @WeekNumber)
		AND (ISNULL(@DriverVoucherNumber, '') = '' OR DVD.DriverVoucherNumber = @DriverVoucherNumber)
		AND (
			ISNULL(@ItemKey, 0) = 0 
			OR EXISTS (
				SELECT 1 
				FROM DriverVoucherDetail DVD1
				WHERE DVD1.DriverVoucherKey = DVD.DriverVoucherKey
				AND DVD1.ItemKey = @ItemKey
			)
		)
		AND (ISNULL(@StatusKey,0)=0 OR ISNULL(DVD.StatusKey,2)=@StatusKey)

	ORDER BY DVD.DriverVoucherKey
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END