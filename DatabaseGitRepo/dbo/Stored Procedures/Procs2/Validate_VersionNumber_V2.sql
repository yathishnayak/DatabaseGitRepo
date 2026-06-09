/** 
DECLARE 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"VersionNumber" : "V4.0"}'
	EXEC [Validate_VersionNumber_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/

CREATE PROCEDURE [dbo].[Validate_VersionNumber_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET nocount on
	SET fmtonly off

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
	@VersionNumber		VARCHAR(10)=''

	SELECT 
	@VersionNumber	= VersionNumber
	FROM OPENJSON(@JSONSTRING)
	WITH
	(
	VersionNumber		VARCHAR(10)   '$.VersionNumber'
	)

	DECLARE @cnt int = 0
	SET @Status = CONVERT(BIT,0)
	SET @Reason = 'Version Number is invalid'
	
	SELECT @cnt = COUNT(1) 
	FROM VersionHistory WITH(NOLOCK)
	WHERE LTRIM(RTRIM(REPLACE(UPPER(VersionNumber),'V',''))) = LTRIM(RTRIM(REPLACE(UPPER(@VersionNumber),'V','')))

	IF(ISNULL(@cnt,0) = 0)
	BEGIN
		SET @Status = CONVERT(BIT,1)
		SET @Reason = 'Version Number is Valid'
	END

	SELECT @Status AS Status, @Reason AS Reason FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END