/*
	DECLARE @UserKey	INT,
			@JSONString	NVARCHAR(MAX) = '',
			@Status		BIT,
			@Reason		NVARCHAR(MAX),
			@IsDebug	BIT = 0
	EXEC Document_GetOrderKey_ByRouteKey @UserKey,@JsonString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Document_GetOrderKey_ByRouteKey]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	SET Concat_null_Yields_null ON;
	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE @RouteKey		INT=0

	SELECT	@RouteKey = RouteKey
	FROM	OPENJSON(@JsonString, '$')
			WITH (
					RouteKey			INT			'$.RouteKey'
				 )
	SELECT OrderKey FROM Routes 
		WHERE RouteKey=@RouteKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END