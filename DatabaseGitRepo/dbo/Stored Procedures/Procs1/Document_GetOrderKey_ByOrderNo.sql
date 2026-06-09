/*
	DECLARE @UserKey	INT,
			@JSONString	NVARCHAR(MAX) = '{"OrderNo" : 36676}',
			@Status		BIT,
			@Reason		NVARCHAR(MAX),
			@IsDebug	BIT = 0
	EXEC Document_GetOrderKey_ByOrderNo @UserKey,@JsonString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
	SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Document_GetOrderKey_ByOrderNo]
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

	DECLARE	@OrderNo		VARCHAR(20)=''

	SELECT	@OrderNo	= OrderNo
	FROM	OPENJSON(@JsonString, '$')
			WITH (
					OrderNo				VARCHAR(20)	'$.OrderNo'
				 )
	SELECT OrderKey FROM OrderHeader 
		WHERE OrderKey=@OrderNo
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

	SET @Status = 1
	SET @Reason = 'Success'
END