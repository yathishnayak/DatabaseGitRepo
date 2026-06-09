/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
EXEC [Warehouse_GetPriorities] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Warehouse_GetPriorities]
(
	@UserKey      INT = 0,
	@JSONString   NVARCHAR(MAX) = '',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
SET NOCOUNT ON
SET FMTONLY OFF
SET ARITHABORT ON;
BEGIN

	SET @Status = 1
	SET @Reason = 'Success'

	SELECT PriorityKey,[Description],ColorCode 
	FROM dbo.[Priority] A  WITH (NOLOCK)
	LEFT JOIN dbo.[Status] S WITH (NOLOCK) ON S.StatusKey = A.StatusKey
	WHERE S.StatusName = 'Active'

	FOR JSON PATH;
END