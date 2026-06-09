/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"DriverKey":0,"DriverVoucherNumber":"","DeductionItem":""}'
EXEC [Get_DriverVoucherDeductionList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE Procedure [dbo].[Get_DriverVoucherDeductionList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'JSON should not be empty'
			RETURN
	END

	DECLARE 
		@DriverVocherKey int = 0,
		@DriverKey Int = 0,
		@DateFrom DateTime ='2000-01-01',
		@DateTo DateTime = '2050-12-31',
		@DriverVoucherNumber Varchar(50) = '',
		@IsMarkedRecurring	bit = 0,
		@DeductionItem		varchar(100) = '',
		@WeekNumber Int = 0

	SELECT 
		@DriverVocherKey			=		DriverVocherKey		,
		@DriverKey 					= 		DriverKey 			,	
		@DateFrom 					= 		DateFrom 			,	
		@DateTo 					= 		DateTo 				,
		@DriverVoucherNumber 		= 		DriverVoucherNumber ,	
		@IsMarkedRecurring			= 		IsMarkedRecurring	,	
		@DeductionItem				= 		DeductionItem		,	
		@WeekNumber 				= 		WeekNumber 		
	FROM OPENJSON(@JSONString, '$')
	WITH
	(
		DriverVocherKey				INT						'$.DriverVocherKey',		
		DriverKey 					INT						'$.DriverKey', 			
		DateFrom 					DATETIME				'$.DateFrom', 			
		DateTo 						DATETIME				'$.DateTo', 				
		DriverVoucherNumber			VARCHAR(50)				'$.DriverVoucherNumber',
		IsMarkedRecurring			BIT						'$.IsMarkedRecurring',	
		DeductionItem				VARCHAR					'$.DeductionItem',		
		WeekNumber 					INT						'$.WeekNumber'
	)

	SET @DriverKey = ISNULL(@DriverKey, 0)
	SET @DateFrom = ISNULL(@DateFrom, '2000-01-01')
	SET @DateTo = ISNULL(@DateTo, '2050-12-31')
	SET @DriverVoucherNumber = ISNULL(@DriverVoucherNumber, '')
	SET @IsMarkedRecurring = ISNULL(@IsMarkedRecurring, 0)
	SET @DeductionItem = ISNULL(@DeductionItem, '')
	SET @WeekNumber = ISNULL(@WeekNumber, 0)
	
	--print 'driverkey'
	--print @DriverKey

	Select DVD.DriverVoucherKey , DVD.DriverVoucherNumber , DVD.DriverVoucherdate AS DriverVoucherDate,	DVD.DriverVoucherAmount,DVD.WeekNumber, 
			'' as [Description], D.DriverID, D.FirstName + ' '+D.LastName as [Name], 
		    D.DrivingLicenseNo, D.DrivingLicenseExpiryDate,
		    ISNULL(DVD.UpdateDate, DVD.CreateDate) as LastUpdateDate, 	
			ISNULL(DVD.UpdateUser, DVD.CreateUser) as LastUpdateBy,
			ISNULL(IsRecurring,0) as IsRecurring,
			ISNULL(DDD.DeductionItems,'') as DeductionItem
	from DriverVoucherDeduction DVD WITH (NOLOCK)
	Left Join Driver D WITH (NOLOCK) on D.DriverKey = DVD.DriverKey
	LEft join (
		SELECT DISTINCT ST2.DriverVoucherKey, 
				(
					SELECT LTRIM(RTRIM(IT.Description)) + '<br/>' AS [text()]
					FROM dbo.DriverVoucherDeductionDetail ST1 WITH (NOLOCK)
					inner join dbo.Item IT WITH (NOLOCK) on ST1.ItemKey = IT.ItemKey
					WHERE ST1.DriverVoucherKey = ST2.DriverVoucherKey
					ORDER BY ST1.DriverVoucherKey
					FOR XML PATH (''), TYPE
				).value('text()[1]','nvarchar(max)') [DeductionItems]
			FROM dbo.DriverVoucherDeduction ST2 WITH (NOLOCK)
	) DDD on DVD.DriverVoucherKey = DDD.DriverVoucherKey
	--Left Join DriverVoucherDeductionDetail DDD on DDD.DriverVoucherKey = DVD.DriverVoucherKey 
	Where 
		--( ISNULL(@DateFrom, '2000-01-01') = '2000-01-01' OR DVD.DriverVoucherdate >= @DateFrom) AND
		--( ISNULL(@DateTo, '2050-12-31') = '2050-12-31' OR DVD.DriverVoucherdate <= @DateTo) And
		---- ( ISNULL(@DriverKey,0) = 0 OR DVD.DriverKey = @DriverKey ) AND
		--( ISNULL(@WeekNumber,0) = 0 OR DVD.WeekNumber = @WeekNumber ) And
		----( isnull(@DriverVoucherNumber,'') = '' OR @DriverVoucherNumber in ('abcd'))
		--( ISNULL(@DriverVoucherNumber,'') = '' OR DVD.DriverVoucherNumber = @DriverVoucherNumber) AND
		--( @IsMarkedRecurring = 0 OR DVD.IsRecurring = @IsMarkedRecurring) AND
		--( ISNULL(@DeductionItem,'') = '' OR DDD.DeductionItems like '%' + @DeductionItem + '%')
		(@DateFrom = '2000-01-01' OR DVD.DriverVoucherdate >= @DateFrom ) AND
		(@DateTo = '2050-12-31' OR DVD.DriverVoucherdate <= @DateTo ) AND
		(@DriverKey = 0 OR DVD.DriverKey = @DriverKey ) AND
		(@WeekNumber = 0 OR DVD.WeekNumber = @WeekNumber ) AND
		(@DriverVoucherNumber = '' OR DVD.DriverVoucherNumber = @DriverVoucherNumber ) AND
		(@IsMarkedRecurring = 0 OR DVD.IsRecurring = @IsMarkedRecurring ) AND
		(@DeductionItem = '' OR DDD.DeductionItems LIKE '%' + @DeductionItem + '%' )
	Order by DVD.DriverVoucherKey
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
End