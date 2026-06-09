/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DriverKey" : 1}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [CarrierLLC_list_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[CarrierLLC_list_V3]  --CarrierLLC_list 1
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@DriverKey		int = 0

	SELECT
	@DriverKey		=	DriverKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	DriverKey		INT		'$.DriverKey'
	)

	SELECT @DriverKey as DriverKey, A.LLCKey, LLCName, ISNULL(B.IsSelected,0) as IsSelected
	FROM Carrier_LLC A WITH (NOLOCK)
	LEFT JOIN Driver_LLC B WITH (NOLOCK) on A.LLCKey = B.LLCKey and DriverKey = @DriverKey
	ORDER BY LLCName
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END