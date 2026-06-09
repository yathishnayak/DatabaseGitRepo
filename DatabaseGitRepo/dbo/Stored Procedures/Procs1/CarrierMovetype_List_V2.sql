/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey" : 647}'
	EXEC [CarrierMovetype_List_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[CarrierMovetype_List_V2] 
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@DriverKey		int = 0

	SELECT 
		@DriverKey	= DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		DriverKey		INT		'$.DriverKey'
	)

	SELECT @DriverKey AS DriverKey, a.MoveTypeKey, MoveTypeName, ISNULL(B.IsSelected,0) AS IsSelected
	FROM CarrierMoveType A WITH (NOLOCK)
	LEFT JOIN Driver_MoveType B WITH (NOLOCK) on A.MoveTypeKey = B.MoveTypeKey AND DriverKey = @DriverKey
	ORDER BY MoveTypeName

	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END