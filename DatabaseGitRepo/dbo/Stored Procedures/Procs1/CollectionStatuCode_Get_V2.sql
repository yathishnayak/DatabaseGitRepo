/*
-- Status was 1 - Changed to 6 in OrderDetail Table
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [CollectionStatuCode_Get_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/

CREATE procedure [dbo].[CollectionStatuCode_Get_V2]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
	BEGIN
		SELECT StatusCodeKey,StatusCodeName,IsActive,IsDelete,CreatedDate,CreatedUser
		FROM CollectionStatuCode WITH(NOLOCK)
		FOR JSON PATH
		
		SET @Status=1
		SET @Reason = 'Success'
	END