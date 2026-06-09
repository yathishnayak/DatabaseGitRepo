
Create Proc [dbo].[Get_TruckType]
As
Begin
	set nocount on
	set fmtonly off

	select TruckTypeKey, TruckType 
	from TruckType
	where isActive = 1 and IsDeleted = 0
	order by TruckType
End
