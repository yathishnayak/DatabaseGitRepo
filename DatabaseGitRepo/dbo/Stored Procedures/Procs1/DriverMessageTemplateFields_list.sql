

CREATE PROC [dbo].[DriverMessageTemplateFields_list]
as
begin
	set nocount on
	set fmtonly off
	select FieldKey,FieldValue
	from DriverMessageTemplateFields
	order by FieldValue
end
