/*	

	EXEC [DA_CheckUserFireBaseID] NULL,NULL
	EXEC [DA_CheckUserFireBaseID] 1,NULL
	EXEC [DA_CheckUserFireBaseID] NULL,testFB_id2

	EXEC [DA_CheckUserFireBaseID] 5,'testFB_id69'
	EXEC [DA_CheckUserFireBaseID] 1,'testFB_id1'
	EXEC [DA_CheckUserFireBaseID] 8,2,'testFB_id88'

	SELECT * FROM DA_UserFireBaseID

*/

CREATE PROC [dbo].[DA_CheckUserFireBaseID] -- DA_CheckUserFireBaseID 2,3,'dgdfgdfgdfgdf'
(
	@UserKey INT,
	@DeviceKey INT,
	@FireBaseID VARCHAR(500)
) AS
BEGIN
	DECLARE 
		@Status BIT = 1,
		@Message VARCHAR(100) = '',
		@IsFb_IDExist INT = 0,
		@IsFBUserExist INT = 0,
		@IsUserExist BIT = 0

	DECLARE @Serial1 VARCHAR(20)  , @Serial2 VARCHAR(20)  , @Serial3 VARCHAR(20) , @Serial4 VARCHAR(20)  
	DECLARE @CodeKey VARCHAR(50) = (SELECT ConfigValue1 FROM DA_ConfigValues WHERE ConfigKey = 3)

	
	BEGIN TRY
	BEGIN TRANSACTION
	-- edgecase checks
	IF(ISNULL(@FireBaseID,'') = '' OR ISNULL(@UserKey,0) = 0)
		BEGIN
			SET @Status = 0
			SET @Message = 'FirebaseId or UserKey Cannot be NULL'
		END
	ELSE IF(ISNULL(@FireBaseID,'') = 'NA')
		BEGIN
			SET @Status = 0
			SET @Message = 'FirebaseId cannot be NA'
		END
	ELSE
		BEGIN
			SELECT 
				@FireBaseID = FireBaseID,
				@IsFBUserExist = UserKey
			FROM DA_UserFireBaseID 
			WHERE FireBaseID = @FireBaseID 

			IF(@IsFBUserExist IS NOT NULL)
				BEGIN
					UPDATE DA_UserFireBaseID
					SET FireBaseID = '',DateModified = GETDATE(),DeviceKey = 0
					WHERE UserKey = @IsFBUserExist 
				
					SET @IsUserExist = (SELECT COUNT(*) FROM DA_UserFireBaseID WHERE UserKey = @UserKey)

					IF(@IsUserExist = 1)
						BEGIN
							UPDATE	DA_UserFireBaseID
							SET		FireBaseID = @FireBaseID, DateModified = GETDATE(),DeviceKey = @DeviceKey
							WHERE	UserKey = @UserKey
						END
					ELSE
						BEGIN 
							INSERT INTO DA_UserFireBaseID(UserKey,FireBaseID,DateModified,Devicekey)
							VALUES (@UserKey,@FireBaseID,GETDATE(),@DeviceKey)
						END
					SET @Status = 1
					SET @Message = 'Record Saved Successfully'
				END

				SET @Serial1 = SUBSTRING(@CodeKey,11,11)
				SET @Serial2 = '0CC657C735'
				SET @Serial3 = SUBSTRING(@CodeKey,22,11)
				SET @Serial4 = SUBSTRING(@CodeKey,1,10)

		END

		COMMIT TRANSACTION

		SELECT @Status AS Status,@Message AS Message, @Serial1 AS Serial1, @Serial2 AS Serial2, @Serial3 AS Serial3, @Serial4 AS Serial4  
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END
