--update Driver Set DriverID = RIGHT( CONVERT(varchar,1000 + driverkey),case when LEN(driverkey) < 2 then 2 else LEN(driverkey) end) + '-' + upper(LEFT(trim(FirstName),1)) + upper(LEFT(trim(isnull(LastName,'A')),1))
create proc InsertUpdateDriverContact
(
	@DriverContactKey	int = 0 output,
	@DriverKey			int = 0,
	@ContactName		varchar(100) = '',
	@ContactNumber		varchar(100) = '',
	@ContactDesig		varchar(100) = '',
	@ContactEmail		varchar(100) = '',
	@Output				bit = 0 OUTPUT,
	@Reason				varchar(100) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @CNT int = 0
	select @CNT = COUNT(1) 
	from DriverContacts 
	where DriverContactKey = @DriverContactKey
	begin try
		if(ISNULL(@CNT,0) = 0)
		begin
			insert into DriverContacts(DriverKey, ContactName, ContactDesignation, ContactNumber, ContactEmail )
			select @DriverKey, @ContactName, @ContactDesig, @ContactNumber, @ContactEmail
			set @DriverContactKey = SCOPE_IDENTITY()
			set @Output = 1
			set @Reason = 'Contact Inserted Successfully'
		end
		else
		BEGIN
			update DriverContacts set
				ContactName = @ContactName,
				ContactEmail = @ContactEmail,
				ContactDesignation = @ContactDesig,
				@ContactNumber = @ContactNumber
			where DriverContactKey = @DriverContactKey
			set @Output = 1
			set @Reason = 'Contact Updated Successfully'
		END
	end try
	begin catch
		set @Reason = 'Technical Error'
		set @Output = 0
	end catch
END
