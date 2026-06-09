/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"RouteKey" : 177963}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Update_ConfirmRouteDocument_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Update_ConfirmRouteDocument_V3]
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
	@Routekey   INT

	SELECT
	@Routekey   = RouteKey
	FROM OPENJSON(@JSONString)
	WITH
	(
	RouteKey		INT			'$.RouteKey'
	)

	UPDATE dbo.[Routes] 
	SET IsDocumentVerified= 1, 
		DocumentVerifiedDate = GETDATE(),
		DocumentVerifiedUserKey= @UserKey
	WHERE RouteKey = @Routekey;

	IF @@ROWCOUNT>0
	BEGIN
		SET @Status=1
		SET @Reason = 'Updated Succesfully'
	END;	
END
