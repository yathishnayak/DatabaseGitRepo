CREATE PROCEDURE [dbo].[InsertUpdate_Yard]
/*

DECLARE @Status BIT = 0, @Reason VARCHAR(100) = '', @YardID smallint = 0

EXEC InsertUpdate_Yard @YardID OUTPUT ,'Short Name','Name',1705,1,1,30, @Status OUTPUT, @Reason OUTPUT

SELECT @Status, @Reason, @YardID
*/
(
	@YardId				SMALLINT  OUTPUT,
	@ShortName			VARCHAR(20),
	@Name				VARCHAR(100),
	@AddrKey			INT,
	@MarketLocationKey	INT,
	@IsActive			BIT,
	@UserKey			INT,
	@Status				BIT=1 OUTPUT,
	@Reason				VARCHAR(100) OUTPUT
)
AS

BEGIN

	BEGIN TRANSACTION
	BEGIN TRY
		IF (ISNULL(@YardId,0)=0)
			BEGIN
				INSERT INTO		Yard
								(ShortName,Name,AddrKey,MarketLocationKey,IsActive,IsDeleted,CreateDate,CreateUserKey,UpdateDate,UpdateUserKey)
				SELECT			@ShortName,@Name,@AddrKey,@MarketLocationKey,@IsActive,0,GETDATE(),@UserKey,GETDATE(),@UserKey
				SET				@YardId = SCOPE_IDENTITY()

				SET				@Status = 1
				SET				@Reason = 'Record Created Successfully'
			END
		ELSE
			BEGIN
				UPDATE			Yard
				SET				ShortName=@ShortName,
								Name=@Name,
								--AddrKey=@AddrKey,
								MarketLocationKey = @MarketLocationKey,
								IsActive=@IsActive,
								UpdateDate = GETDATE(),
								UpdateUserKey = @UserKey
				WHERE			YardId=@YardId

				SET				@Status = 1
				SET				@Reason = 'Record Updated Successfully'

			END
	COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		SET			@Status = 0
		SET			@Reason = 'Record Failed to Update'

		PRINT		@@error
		PRINT		Error_Message()
		PRINT		'Rollback'

		ROLLBACK TRANSACTION
	END CATCH
END
