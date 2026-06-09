CREATE proc [dbo].[CarrierLLC_list]  --CarrierLLC_list 1
(
	@DriverKey		int = 0
)
as 
begin
	set nocount on
	set fmtonly off
	select @DriverKey as DriverKey, A.LLCKey, LLCName, ISNULL(B.IsSelected,0) as IsSelected
	from Carrier_LLC A
	left join Driver_LLC B on A.LLCKey = B.LLCKey and DriverKey = @DriverKey
	order by LLCName
	for JSON Path
end
