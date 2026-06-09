CREATE Procedure [dbo].[DeleteYard]  --DeleteYard 0,32
/*

DECLARE @YardId INT = 13, @UserKey INT = 29,  @Status BIT = 0, @Reason VARCHAR(100) = ''
EXEC DeleteYard @YardId,@UserKey, @Status OUTPUT, @Reason OUTPUT
SELECT @Status, @Reason

*/
(
	@YardId			SMALLINT,
	@UserKey		INT,
	@OutPut			BIT = 0 OUTPUT,
	@Reason			VARCHAR(100) = '' OUTPUT
)
AS

BEGIN
	DECLARE			@CNT INT=0, @RefCount INT=0
	SET				@CNT=(SELECT COUNT(YardId) FROM Yard WHERE YardId=@YardId)
	SET				@RefCount= (SELECT COUNT(1) FROM YardLocation WHERE YardID=@YardId)
	IF(@CNT=0)
			BEGIN
				SET @Reason='No record found for the given yard Id';
				SET @OutPut=0;
				return;
			END
	ELSE IF(@RefCount > 0)
		BEGIN
			--DECLARE @LocName NVARCHAR(100)
			--SET @LocName = (SELECT [Name] FROM YardLocation WHERE YardID=@YardId)
			SET @Reason='Selected record cannot be deleted as it has linked to yard location';
			SET @OutPut=0;
			return;
		END
	ELSE
		BEGIN
			UPDATE		Yard 
			SET			IsDeleted = 1, IsActive = 0, UpdateDate = GETDATE(), UpdateUserKey = @UserKey 
			WHERE		YardId=@YardId

			SET @Reason='Yard Deleted Successfully';
			SET @OutPut=1;
			return;
		END
END
