/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"ScreenName":"GnosisTracking"}'
exec Columns_GetUserScreenColumns @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE proc [dbo].[Columns_GetUserScreenColumns]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)	
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	declare @Screen		varchar(100)

	if(len(isnull(@JSONString,''))=0)
	Begin
		set @Status = 0
		SEt @Reason = 'Required parameters not received'
		Return
	End

	SELECT @Screen = Screen
	from OpenJSON(@JsonString, '$')
	WITH (
		Screen				varchar(100)	'$.ScreenName'
	)

	if(len(isnull(@Screen,''))=0)
	Begin
		set @Status = 0
		SEt @Reason = 'Screen Name not received'
		Return
	End

	if((Select count(1) from UserScreenColumns WITH (NOLOCK) where UserKey = @UserKey and ScreenName = @Screen) > 0)
	Begin
			Select @UserKey as UserKey, @Screen as ScreenName,JSON_QUERY(ColumnsStatus) as ColumnStatus
			from UserScreenColumns USC WITH (NOLOCK)
			where UserKey = @UserKey and ScreenName = @Screen
			Order by USC.ColumnsStatus
			FOR JSON PATH, without_array_wrapper

	end
	ELSE If((Select count(1) from UserScreenColumns where UserKey = 0 and ScreenName = @Screen) > 0)
	BEGIN
			Select @UserKey as UserKey, @Screen as ScreenName, JSON_QUERY(ColumnsStatus) as ColumnStatus
			from UserScreenColumns USC WITH (NOLOCK)
			where UserKey = 0 and ScreenName = @Screen
			Order by USC.ColumnsStatus
			FOR JSON PATH, without_array_wrapper
	END
	ELSE
	BEGIN
		SEt @Status = 0
		SEt @Reason = 'Dynamic Columns Not defined'
		return
	END
	SEt @Status = 1
	SEt @Reason = 'SUCCESS'
END