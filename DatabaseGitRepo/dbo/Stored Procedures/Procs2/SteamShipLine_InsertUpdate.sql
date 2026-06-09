CREATE Proc [dbo].[SteamShipLine_InsertUpdate]
(
	@LineKey		int output,
	@LineName		varchar(100),
	@ScacCode       varchar(30),
	@IsActive		bit = 0,
	@UserKey		int,
	@Output			Bit = 0 output
)
as
Begin
	set nocount on
	set fmtonly off
	set @Output = 0

	begin try
	if(ISNULL(@LineKey,0) = 0)
	begin
		insert into SteamShipLine (LineName,ScacCode,IsActive, CreateUser, CreateDate)
		select @LineName,@ScacCode,@IsActive, @UserKey, GETDATE()
		set @LineKey = SCOPE_IDENTITY();
		set @Output = 1
	end
	ELSE
	Begin
		update SteamShipLine set
			LineName = @LineName,
			ScacCode = @ScacCode,
			IsActive = @IsActive,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		where LineKey = @LineKey

		set @Output = 1
	end
	return
	end try
	begin catch
		set @Output = 0
		set @LineKey = 0
		return
	end catch
End
