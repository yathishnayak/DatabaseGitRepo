create proc DeleteDriverContact
(
	@DriverContactKey	int = 0 output,
	@DriverKey			int = 0,
	@Output				bit = 0 OUTPUT,
	@Reason				varchar(100) = '' output
)
as
begin
	set nocount on
	set fmtonly off

	declare @cnt int = 0
	select @cnt = COUNT(1) from DriverContacts where DriverContactKey = @DriverContactKey and DriverKey = @DriverKey
	if(ISNULL(@cnt,0) = 0)
	begin
		set @Output = 0
		set @Reason = 'Contact Not Exists'
	end
	begin try
		delete from DriverContacts
		where DriverContactKey = @DriverContactKey and DriverKey = @DriverKey
		set @Output = 1
		set @Reason = 'Contact Deleted Successfully'
	end try
	begin catch
		set @Output = 0
		set @Reason = 'Technical Error'
	end catch
end
