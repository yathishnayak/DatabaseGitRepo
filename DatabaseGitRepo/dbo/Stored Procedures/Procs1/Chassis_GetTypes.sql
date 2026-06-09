create proc [dbo].[Chassis_GetTypes]
as
begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	select distinct ChassisType from Chassis
	where ChassisType <> 'Ext'
	order by ChassisType
End
