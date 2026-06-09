/*
DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"TerminalKey":0}'
 
EXEC [DeleteShippingPortTerminal_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/
CREATE PROCEDURE [dbo].[DeleteShippingPortTerminal_V2]
	(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @TerminalKey INT;
			SELECT @TerminalKey = TerminalKey
			FROM OPENJSON(@JSONString)
			WITH (
				TerminalKey INT '$.TerminalKey'
			)


		 UPDATE		ShippingPortTerminals 
		SET			IsDeleted = 1, IsActive = 0, UpdateDate = GETDATE(), UpdateUserKey = @UserKey 
		WHERE		TerminalKey = @TerminalKey

		SET @Status = 1;
		SET @Reason = 'Record Deleted Successfully';


END