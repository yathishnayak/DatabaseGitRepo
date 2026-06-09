CREATE proc [dbo].[Get_Config]
(
	@ID int = 0
)
as
	set nocount on
	set fmtonly off
	select * from MailConfig
	where id = @ID
