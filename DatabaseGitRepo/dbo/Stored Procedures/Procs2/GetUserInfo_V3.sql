/**
Declare 
	@UserKey		INT = 951,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [GetUserInfo_V3] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[GetUserInfo_V3]
(
	@UserKey		INT = 951,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 6366311182 AS MobileNo, 'yathishnayak@trikaiser.com' AS Email
	--FROM [User] WITH(NOLOCK) 
	--WHERE UserKey = @UserKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

	SET @Status = 1
	SET @Reason = 'Success'
END