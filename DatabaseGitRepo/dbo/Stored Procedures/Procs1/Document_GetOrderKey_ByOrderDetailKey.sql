/*
	DECLARE @UserKey	INT,
			@JSONString	NVARCHAR(MAX) = '{"OrderDetailKey" : 47697}',
			@Status		BIT,
			@Reason		NVARCHAR(MAX),
			@IsDebug	BIT = 0
	EXEC Document_GetOrderKey_ByOrderDetailKey @UserKey,@JsonString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	Select @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Document_GetOrderKey_ByOrderDetailKey]
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

	DECLARE @OrderDetailKey	INT

	SELECT	@OrderDetailKey = OrderDetailKey
	FROM	OPENJSON(@JsonString, '$')
			WITH (
					OrderDetailKey		INT			'$.OrderDetailKey'
				 )
	SELECT OrderKey FROM OrderDetail 
		WHERE OrderDetailKey=@OrderDetailKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END