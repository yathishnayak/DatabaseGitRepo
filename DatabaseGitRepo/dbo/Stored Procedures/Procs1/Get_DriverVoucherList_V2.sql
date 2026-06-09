
/*
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"driverkey":0,"drivervouchernumber":"","DeductionItem":""}',
	@Status BIT=0, @IsDebug int = 1,@Reason VARCHAR(100)=''
EXec [Get_DriverVoucherList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Get_DriverVoucherList_V2]
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
		@DriverVocherKey		INT= 0,
		@DriverKey				INT = 0,
		@DateFrom				DATETIME ='2026-01-01',
		@DateTo					DATETIME = '2050-12-31',
		@DriverVoucherNumber	NVARCHAR(50) = '',
		@IsMarkedRecurring		BIT = 0,
		@DeductionItem			NVARCHAR(100) = '',
		@WeekNumber				INT = 0

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	Select	
		@DriverVocherKey		=		DriverVocherKey,		
		@DriverKey				=		DriverKey,
		@DateFrom				=		DateFrom,
		@DateTo					=		DateTo, 
		@DriverVoucherNumber	=		DriverVoucherNumber,		
		@IsMarkedRecurring		=		IsMarkedRecurring, 
		@DeductionItem			=		DeductionItem, 
		@WeekNumber				=		WeekNumber
	from OpenJSON(@JsonString, '$')
	WITH (
		DriverVocherKey				INT				'$.DriverVocherKey',
		DriverKey					INT				'$.driverkey',
		DateFrom					DATETIME		'$.datefrom',
		DateTo						DATETIME		'$.dateto',
		DriverVoucherNumber			NVARCHAR(50)	'$.drivervouchernumber',
		IsMarkedRecurring			BIT				'$.IsMarkedRecurring',
		DeductionItem				NVARCHAR(100)	'$.DeductionItem',
		WeekNumber					INT				'$.WeekNumber'
	)

	--SET @DateFrom='2026-01-01'
	IF(@DateFrom<CONVERt(DATE,'2025-01-01') OR @Datefrom = '' OR @DateFrom is null)
	BEGIN
		set @DateFrom=GETDATE()-30
		set @DateTo=GETDATE()+30
	END
	print '----------'
	print @dateFrom
	print @DateTo
	print '-----------'

	SELECT  DVD.DriverVoucherKey, DVD.DriverVoucherNumber, DVD.DriverVoucherdate, DVD.DriverVoucherAmount, DVD.WeekNumber,
			'' as [Description], D.DriverId AS DriverID, D.FirstName + ' ' + D.LastName AS [Name], 
			D.DrivingLicenseNo, D.DrivingLicenseExpiryDate,
			ISNULL(DVD.UpdateDate, DVD.CreateDate) AS LastUpdateDate,
			ISNULL(DVD.UpdateUser, DVD.CreateUser) AS LastUpdateBy,
			ISNULL(ContainerNo, '') AS ContainerNo
			,ISNULL(DDD.DeductionItems, '') AS DeductionItem		
		FROM DriverVoucher DVD
		INNER JOIN Driver D ON D.DriverKey = DVD.DriverKey
		INNER JOIN(
					Select Distinct ST2.DriverVoucherKey,
						(
							Select LTRIM(RTRIM(IT.[Description])) + '<br/>' AS [text()]
								FROM DriverVoucherDetail ST1
							INNER JOIN ITEM IT ON ST1.ItemKey = IT.ItemKey
							WHERE ST1.DriverVoucherKey = ST2.DriverVoucherKey
							ORDER BY ST1.DriverVoucherKey
							FOR XML PATH (''), TYPE
						).value('text()[1]','nvarchar(max)') [DeductionItems] FROM dbo.DriverVoucher ST2
					)
			DDD ON DVD.DriverVoucherKey = DDD.DriverVoucherKey
			WHERE-- DVD.DriverVoucherdate >= @DateFrom AND
			(ISNULL(@DateFrom, '2026-01-01') = '2026-01-01' OR DVD.DriverVoucherdate >= @DateFrom) AND
					(ISNULL(@DateTo, '2050-12-31') = '2050-12-31' OR DVD.DriverVoucherdate <= @DateTo) AND
					(ISNULL(@DriverKey, 0) = 0 OR DVD.DriverKey = @DriverKey) AND
					(ISNULL(@WeekNumber, 0) = 0 OR DVD.WeekNumber = @WeekNumber) AND
					(ISNULL(@DriverVoucherNumber, '') = '' OR DVD.DriverVoucherNumber = @DriverVoucherNumber) 
					--AND (ISNULL(@DeductionItem, '') = '' OR DDD.DeductionItems like '%' + @DeductionItem + '%')
			ORDER BY DVD.DriverVoucherKey
			FOR JSON PATH

					--print '@DateFrom'
					--print @DateFrom
					--print '@DateTo'
					--print @DateTo

		Set @Status = 1
		SEt @Reason = 'Success'
END
