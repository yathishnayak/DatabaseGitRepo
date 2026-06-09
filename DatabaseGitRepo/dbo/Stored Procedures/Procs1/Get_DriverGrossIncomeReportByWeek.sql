CREATE Proc [dbo].[Get_DriverGrossIncomeReportByWeek] -- Get_DriverGrossIncomeReportByWeek 45
(
	@weekNo		int	 = 0
)
AS
begin
	SET NOCOUNT ON
	SET FMTONLY OFF

	if(@weekNo = 0)
	begin
		set @weekNo = datepart(ISO_WEEK,getdate()-7)
	end
	select 
		d.FirstName,d.LastName,d.DriverID, isnull(d.OrgName,'') as OrgName, 
		isnull(d.Orgcity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') as OrgAddress,
		isnull(convert(varchar,datepart(ISO_WEEK, VH.PaidDate)),'') as Weeknum,
		convert(decimal(18,2),sum(VD.ExtCost)) as GrossIncome, d.DriverID1
	from VoucherHeader VH WITH (NOLOCK)
		inner join Voucherdetail VD  WITH (NOLOCK) ON VH.VoucherKey = VD.Voucherkey
		Inner Join Routes RT  WITH (NOLOCK) ON VD.RouteKey = RT.RouteKey
		Inner join vDriver D  WITH (NOLOCK) ON RT.DriverKey = D.DriverKey
	Where (@weekNo = 0 OR datepart(ISO_WEEK,VH.PaidDate) = @weekNo) --isnull(convert(varchar,datepart(ISO_WEEK,RT.ActualArrival)),'')= @weekNo)
	group by d.FirstName,d.LastName,d.DriverID, isnull(convert(varchar,datepart(ISO_WEEK, VH.PaidDate)),''),
		isnull(d.OrgName,'') ,isnull(d.Orgcity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' + isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') ,
		d.DriverID1
	Order by  convert(int,d.DriverID1), Weeknum
END
