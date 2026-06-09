/*
DECLARE @UserKey INT=29,
	@JSONString NVARCHAR(MAX)='',@Status BIT=0,@IsDebug		BIT = 1, 
		@Reason VARCHAR(100)=''
EXec [Ship_StopList] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
*/
CREATE PRoc [dbo].[Ship_StopList]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
as
Begin

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @Reason = 'ERROR'
	SET @Status = 0

	select	StopTypeKey, 
			StopTypeName, 
			StopTypeShortcode, 
			IsFoundationStop, 
			OrderBy, 
			IsActive, 
			CreateDate, 
			CreateUserKey, 
			UC.UserName as CreateUserName,
			UpdateDate, 
			UpdateUserKey , 
			UU.UserName as UpdateUserName
	from StopsMaster OS WITH (NOLOCK)
	LEFT JOIN [USER] UC WITH (NOLOCK) on Os.CreateUserKey = UC.UserKey
	LEFT JOIN [USER] UU WITH (NOLOCK) on Os.CreateUserKey = UU.UserKey
	Order by OS.OrderBy
	FOR JSON PATH
	SET @Reason = 'SUCCESS'
	SET @Status = 1

End
