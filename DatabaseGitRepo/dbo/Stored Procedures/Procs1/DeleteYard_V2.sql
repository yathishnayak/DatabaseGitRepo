/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"YardId": 25}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [DeleteYard_V2] @UserKey,@JSONString,'',@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[DeleteYard_V2]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
		SET @Reason='Parameter not Present';
		SET @Status=0
		RETURN;
	END

	SET @Status=0;
	SET @Reason='Failure';

	DECLARE
		@YardId				SMALLINT		= 0

	SELECT
			@YardId = YardId
		FROM OPENJSON(@JsonString, '$')
		WITH(
				YardId	SMALLINT	'$.YardId'
			)

	BEGIN TRY
		-- Validate UserKey exists
		IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
		BEGIN
			SET @Reason='Invalid UserKey - User does not exist';
			SET @Status=0;
			RETURN;
		END

		DECLARE @CNT INT=0, @RefCount INT=0
		SET @CNT=(SELECT COUNT(YardId) FROM dbo.Yard WHERE YardId=@YardId)
		SET @RefCount= (SELECT COUNT(1) FROM dbo.YardLocation WHERE YardID=@YardId)

		IF(@CNT=0)
		BEGIN
			SET @Reason='No record found for the given yard Id';
			SET @Status=0;
			RETURN;
		END
		ELSE IF(@RefCount > 0)
		BEGIN
			SET @Reason='Selected record cannot be deleted as it has linked to yard location';
			SET @Status=0;
			RETURN;
		END
		ELSE
		BEGIN
			BEGIN TRAN;

			UPDATE	dbo.Yard 
			SET		IsDeleted = 1, 
					IsActive = 0, 
					UpdateDate = GETDATE(), 
					UpdateUserKey = @UserKey 
			WHERE	YardId=@YardId

			COMMIT;
			SET @Reason='Yard Deleted Successfully';
			SET @Status=1;
			RETURN;
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		SET @Status=0;
		SET @Reason=ERROR_MESSAGE();
	END CATCH
END