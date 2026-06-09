create Proc CarrierMovetype_List -- CarrierMovetype_List 0
(
	@DriverKey		int = 0
)
as
Begin
	set nocount on
	set fmtonly off
	select @DriverKey as DriverKey, a.MoveTypeKey, MoveTypeName, isnull(B.IsSelected,0) as IsSelected
	from CarrierMoveType A
	left join Driver_MoveType B on A.MoveTypeKey = B.MoveTypeKey and DriverKey = @DriverKey
	order by MoveTypeName

	for JSON Path
end
