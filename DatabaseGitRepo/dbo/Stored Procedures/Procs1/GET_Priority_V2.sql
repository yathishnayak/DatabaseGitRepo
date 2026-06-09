/**
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [GET_Priority_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[GET_Priority_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT PriorityKey,[Description],ColorCode 
	FROM dbo.[Priority] A WITH(NOLOCK)
		INNER JOIN dbo.[Status] S WITH(NOLOCK) ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND IsWarehouse = 0
FOR JSON PATH;


	SET @Status = 1
	SET @Reason = 'Success'
END