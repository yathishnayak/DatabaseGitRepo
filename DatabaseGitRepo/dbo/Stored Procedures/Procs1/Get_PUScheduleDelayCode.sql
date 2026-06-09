/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '',
	@Status	BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_PUScheduleDelayCode] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_PUScheduleDelayCode]
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
	SET @Status=1
	SET @Reason='Success'
	SELECT CodeKey, Code, IsActive, IsDeleted
	FROM PUScheduleDelayCode WITH (NOLOCK)
	WHERE IsActive=1 AND IsDeleted=0
	FOR JSON PATH
END