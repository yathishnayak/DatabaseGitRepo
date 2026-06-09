/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"WeekNo":45}'
	EXEC [Get_DriverGrossIncomeReportByWeek_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status Status, @Reason Reason
**/
CREATE Proc [dbo].[Get_DriverGrossIncomeReportByWeek_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	
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
	@WeekNo		int	 = 0

	SELECT 
		@WeekNo  = WeekNo
	FROM OPENJSON(@JSONString)
	WITH(
		WeekNo INT '$.WeekNo'
	)


	if(@WeekNo = 0)
	begin
		set @WeekNo = datepart(ISO_WEEK,getdate()-7)
	end
	select 
		d.FirstName,d.LastName,d.DriverID, isnull(d.OrgName,'') as OrgName, 
		isnull(d.Orgcity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') as OrgAddress,
		isnull(convert(varchar,datepart(ISO_WEEK, VH.PaidDate)),'') as WeekNum,
		convert(decimal(18,2),sum(VD.ExtCost)) as GrossIncome, d.DriverID1
	from VoucherHeader VH WITH (NOLOCK)
		inner join Voucherdetail VD  WITH (NOLOCK) ON VH.VoucherKey = VD.Voucherkey
		Inner Join Routes RT  WITH (NOLOCK) ON VD.RouteKey = RT.RouteKey
		Inner join vDriver D  WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
	Where (@WeekNo = 0 OR datepart(ISO_WEEK,VH.PaidDate) = @WeekNo) --isnull(convert(varchar,datepart(ISO_WEEK,RT.ActualArrival)),'')= @WeekNo)
	group by d.FirstName,d.LastName,d.DriverID, isnull(convert(varchar,datepart(ISO_WEEK, VH.PaidDate)),''),
		isnull(d.OrgName,'') ,isnull(d.Orgcity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') ,
		d.DriverID1
	Order by  convert(int,d.DriverID1), WeekNum
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END