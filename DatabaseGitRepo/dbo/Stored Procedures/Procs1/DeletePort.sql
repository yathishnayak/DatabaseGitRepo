CREATE Procedure [dbo].[DeletePort]  --DeletePort 0
/*

DECLARE @ShippingPortKey INT = 128, @UserKey INT = 29,  @Status BIT = 0, @Reason VARCHAR(100) = ''
EXEC DeletePort @ShippingPortKey,@UserKey, @Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason

*/
(
	@ShippingPortKey	INT,
	@UserKey			INT,
	@OutPut				BIT = 0 OUTPUT,
	@Reason				VARCHAR(100) = '' OUTPUT
)
AS

BEGIN
	DECLARE				@CNT INT=0, @RefCount INT=0
	SET					@CNT=(SELECT COUNT(ShippingPortID) FROM ShippingPort WHERE ShippingPortKey=@ShippingPortKey)
	SET					@RefCount= (SELECT COUNT(1) FROM ShippingPortTerminals WHERE PortKey=@ShippingPortKey)
	IF(@CNT=0)
		BEGIN
			SET			@Reason='No record found for the given Port data';
			SET			@OutPut=0;
			RETURN;
		END
	ELSE IF(@RefCount > 0)
		BEGIN
			--DECLARE @LocName NVARCHAR(100)
			--SET @LocName = (SELECT [Name] FROM YardLocation WHERE YardID=@YardId)
			SET			@Reason='Selected record cannot be deleted as it has linked to shipping port terminals';
			SET			@OutPut=0;
			RETURN;
		END
	ELSE
		BEGIN
			UPDATE		ShippingPort 
			SET			IsDeleted = 1, IsActive = 0, UpdateDate = GETDATE(), UpdateUserKey = @UserKey 
			WHERE		ShippingPortKey=@ShippingPortKey


			SET			@Reason='Port Deleted Successfully';
			SET			@OutPut=1;
			RETURN;
		END
END
