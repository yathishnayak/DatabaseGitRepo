/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"DriverKey" : 1}'
	EXEC [CarrierFTC_list_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[CarrierFTC_list_V2]  
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
	@DriverKey		INT = 0

	SELECT 
	@DriverKey	= DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	DriverKey		INT			'$.DriverKey'
	)

	SELECT @DriverKey as DriverKey, A.FTCKey, FTCName, ISNULL(B.IsSelected,0) as IsSelected
	FROM Carrier_FTC A WITH (NOLOCK)
	LEFT JOIN Driver_FTC B WITH (NOLOCK) on A.FTCKey = B.FTCKey AND DriverKey = @DriverKey
	ORDER BY FTCName
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END