
CREATE PROCEDURE [dbo].[DeleteShippingPortTerminal]  --DeletePort 0
/*

DECLARE @ShippingPortKey INT = 128, @UserKey INT = 29,  @Status BIT = 0, @Reason VARCHAR(100) = ''
EXEC DeletePort @ShippingPortKey,@UserKey, @Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason

*/
(
	@TerminalKey		INT,
	@UserKey			INT,
	@Status				BIT = 0 OUTPUT,
	@Reason				VARCHAR(100) = '' OUTPUT
)
AS

BEGIN
		UPDATE		ShippingPortTerminals 
		SET			IsDeleted = 1, IsActive = 0, UpdateDate = GETDATE(), UpdateUserKey = @UserKey 
		WHERE		TerminalKey = @TerminalKey

		SET @Status = 1;
		SET @Reason = 'Record Deleted Successfully';
END
