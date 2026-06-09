

CREATE PROCEDURE [dbo].[InsertUpdate_CSR]
	@CSRKey		INT		OUTPUT,
	--@CSRName	VARCHAR(50),
	@CSRFirstName	varchar(50),
	@CSRLastName	varchar(50),
	@IsManager			Bit,
	@CSRManagerKey		int,
	@LinkedUserKey		int,
	@StatusKey	smallint,
	@AddrKey	int,
	@UserKey	int,
	@TerminalLocationKey	int,
	@OutPut		BIT = 0 OUTPUT,
	@Reason		varchar(100) = '' OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	if(isnull(@AddrKey,0) = 0)
	Begin
		set @OutPut = 0
		SET @Reason = 'Address is missing'
		return;
	end
	if(isnull(@CSRKey,0) =  0)
	Begin
		INSERT INTO dbo.CSR (FirstName, LastName, LinkedUserKey, IsManager, CSRManagerKey, CsrName, AddrKey,CreateDate,StatusKey,StatusDate, TerminalLocationKey,IsActive)
		VALUES(@CSRFirstName, @CSRLastName, NULLIF(@LinkedUserKey,0), @IsManager, NULLIF(@CSRManagerKey,0), @CSRFirstName+' '+ISNULL(@CSRLastName,''), @AddrKey,GETDATE(),1,GETDATE(), NULLIF(@TerminalLocationKey,0),1)
		SET @OutPut=1;
	END
	else
	Begin
		update CSR set
			FirstName	= @CSRFirstName,
			LastName	= @CSRLastName,
			IsManager	= @IsManager,
			CSRManagerKey = case when @CSRManagerKey > 0 then @CSRManagerKey else null end,
			LinkedUserKey = @LinkedUserKey,
			TerminalLocationKey = @TerminalLocationKey,
			--AddrKey	= @AddrKey,
			StatusKey = @StatusKey,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		where CsrKey = @CSRKey
		SET @OutPut=1;
	end
	
END;
