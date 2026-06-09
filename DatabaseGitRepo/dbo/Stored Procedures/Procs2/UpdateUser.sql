


create proc [dbo].[UpdateUser]
(
	@UserKey	int,
	@UserName	varchar(50)
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	IF(isnull(@UserKey,0) > 0 AND ISNULL(@UserName,'') <> '')
	Begin
		declare @cnt int = 0
		select @cnt = count(1) from [user] where userkey = @userkey
		if(isnull(@cnt,0) = 0)
		begin
			insert into [USER] (UserKey, UserName)
			select @UserKey, @UserName
		end
		else
		begin
			update [user] set
				UserName = @USerName
			where UserKey = @UserKey
		end
	End
END