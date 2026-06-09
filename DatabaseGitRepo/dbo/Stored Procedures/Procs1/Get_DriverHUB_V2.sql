/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_DriverHUB_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_DriverHUB_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS

BEGIN
	SELECT DriverHubKey,DriverHubName FROM DriverHUB  WITH (NOLOCK)
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END