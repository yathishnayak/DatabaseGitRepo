/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@JSONSTRING NVARCHAR(MAX) = '{}'
	EXEC [GetDispatcherUsers] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output
	SELECT @status AS Status, @reason AS Reason
**/
CREATE PROCEDURE [dbo].[GetDispatcherUsers]
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
SET NOCOUNT ON;
SET FMTONLY OFF;
SET ARITHABORT ON;
	SELECT Distinct U.UserKey,U.UserName FROM Routes RT WITH (NOLOCK)
	INNER JOIN [User] U WITH (NOLOCK) ON U.UserKey=RT.CarrierAssignedBy
	FOR JSON PATH;
	SET @Status = 1
	SET @Reason = 'Success'
END
