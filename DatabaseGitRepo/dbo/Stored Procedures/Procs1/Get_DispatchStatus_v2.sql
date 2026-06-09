/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = ''
	EXEC [Get_DispatchStatus_v2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_DispatchStatus_v2]
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

	SELECT [Status] AS StatusKey, [Description] AS StatusName
	FROM dbo.RouteStatus WITH (NOLOCK)

	--SELECT [Status] AS StatusKey, [Description] AS StatusName
	--FROM dbo.OrderDetailStatus WHERE StatusType='Dispatch'
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
	
END