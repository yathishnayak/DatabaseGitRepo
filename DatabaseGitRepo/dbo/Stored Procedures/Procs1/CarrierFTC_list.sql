CREATE proc [dbo].[CarrierFTC_list]  --CarrierFTC_list 1
(
	@DriverKey		int = 0
)
as
begin
	set nocount on
	set fmtonly off
	select @DriverKey as DriverKey, A.FTCKey, FTCName, ISNULL(B.IsSelected,0) as IsSelected
	from Carrier_FTC A
	left join Driver_FTC B on A.FTCKey = B.FTCKey and DriverKey = @DriverKey

	order by FTCName
	for JSON Path
end
