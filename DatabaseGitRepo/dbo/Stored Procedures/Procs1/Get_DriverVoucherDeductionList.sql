CREATE Procedure [dbo].[Get_DriverVoucherDeductionList] -- Execute [Get_DriverVoucherDeductionList] 0, 0,'2000-01-01','2050-12-31','D-0002',13
@DriverVocherKey int = 0,
@DriverKey Int = 0,
@DateFrom DateTime ='2000-01-01',
@DateTo DateTime = '2050-12-31',
@DriverVoucherNumber Varchar(50) = '',
@IsMarkedRecurring	bit = 0,
@DeductionItem		varchar(100) = '',
@WeekNumber Int = 0
as
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	Select DVD.DriverVoucherKey , DVD.DriverVoucherNumber , DVD.DriverVoucherdate ,	DVD.DriverVoucherAmount,DVD.WeekNumber, 
			'' as [Description], D.DriverID, D.FirstName + ' '+D.LastName as [Name], 
		    D.DrivingLicenseNo, D.DrivingLicenseExpiryDate,
		    isnull(DVD.UpdateDate, DVD.CreateDate) as LastUpdateDate, 	
			isnull(DVD.UpdateUser, DVD.CreateUser) as LastUpdateBy,
			isnull(IsRecurring,0) as IsRecurring,
			isnull(DDD.DeductionItems,'') as DeductionItems
	from DriverVoucherDeduction DVD
	Left Join Driver D on D.DriverKey = DVD.DriverKey
	LEft join (
		SELECT DISTINCT ST2.DriverVoucherKey, 
				(
					SELECT ltrim(rtrim(IT.Description)) + '<br/>' AS [text()]
					FROM dbo.DriverVoucherDeductionDetail ST1
					inner join dbo.Item IT on ST1.ItemKey = IT.ItemKey
					WHERE ST1.DriverVoucherKey = ST2.DriverVoucherKey
					ORDER BY ST1.DriverVoucherKey
					FOR XML PATH (''), TYPE
				).value('text()[1]','nvarchar(max)') [DeductionItems]
			FROM dbo.DriverVoucherDeduction ST2
	) DDD on DVD.DriverVoucherKey = DDD.DriverVoucherKey
	--Left Join DriverVoucherDeductionDetail DDD on DDD.DriverVoucherKey = DVD.DriverVoucherKey 
	Where 
		( isnull(@DateFrom, '2000-01-01') = '2000-01-01' OR DVD.DriverVoucherdate >= @DateFrom) AND
		( isnull(@DateTo, '2050-12-31') = '2050-12-31' OR DVD.DriverVoucherdate <= @DateTo) And
		( isnull(@DriverKey,0) = 0 OR DVD.DriverKey = @DriverKey ) AND
		( isnull(@WeekNumber,0) = 0 OR DVD.WeekNumber = @WeekNumber ) And
		--( isnull(@DriverVoucherNumber,'') = '' OR @DriverVoucherNumber in ('abcd'))
		( isnull(@DriverVoucherNumber,'') = '' OR DVD.DriverVoucherNumber = @DriverVoucherNumber) AND
		( @IsMarkedRecurring = 0 OR DVD.IsRecurring = @IsMarkedRecurring) AND
		( isnull(@DeductionItem,'') = '' OR DDD.DeductionItems like '%' + @DeductionItem + '%')
	Order by DVD.DriverVoucherKey
End
