CREATE PROCEDURE [dbo].[DA_UpdateNotification](
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsLogout		BIT = 0 OUTPUT,
	@IsDebug		BIT = 0,
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@FirebaseID		VARCHAR(500)
) AS BEGIN
	DECLARE @NotificationKey INT = 0,@nUserKey INT = 0,@nDeviceKey INT = 0,@nDriverKey INT = 0
	IF(
		ISNULL(@UserKey,0) = 0		OR
		ISNULL(@JSONString,'') = '' OR
		ISNULL(@FirebaseID,'') = ''
	)	BEGIN
			SET @Status = 0
			SET	@IntError = 'UserKey,DeviceKey cannot be Blank or NULL'
			SET	@Reason = 'Something went wrong, Contact System administrator'
			SET @IsLogout = 0

			SELECT 'Response'='Empty fields, Cannot be processesd' FOR JSON PATH
		END
	ELSE
		BEGIN
			
			-- validate
			DECLARE @ValidateUser BIT = 0, @FBInternalError NVARCHAR(MAX), @FBExternalError  VARCHAR(1000)
			EXEC DA_ValidateUserFireBaseID @UserKey,@FirebaseID, @ValidateUser OUTPUT, @FBInternalError OUTPUT, @FBExternalError OUTPUT

			DECLARE @LogKey INT
			DECLARE	@UserName VARCHAR(50) = (SELECT UserName FROM [User] WHERE UserKey = @UserKey )

			INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID,IsDebug,CreatedDate)
			SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,@FirebaseID,@IsDebug,GETDATE()

			SET @LogKey = @@IDENTITY

			IF(@ValidateUser = 0)
				BEGIN
					SET @Status = 0
					SET @IntError = @FBInternalError
					SET @Reason = @FBExternalError
					SET @IsLogout = 1

					UPDATE DA_RequestResponseLogs
					SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, IsLogout = @IsLogout,  UpdatedDate = GETDATE(), ReponseJSONString = NULL
					WHERE LogKey = @LogKey

					RETURN
				END
			-- validate	


			BEGIN TRY
				BEGIN TRANSACTION
					
					--SELECT @nUserKey = uKey,@nDeviceKey = dKey
					SELECT @nDriverKey = drKey
					FROM OPENJSON(@JSONString)
					WITH(
						--uKey INT '$.UserKey',
						--dkey INT '$.DeviceKey'
						drKey INT '$.DriverKey'
					)

					CREATE TABLE #temp_r(
						t_NotificationKey INT
					)

					INSERT INTO #temp_r(t_NotificationKey)
					SELECT nKey 
					FROM OPENJSON(@JSONString,'$.NotifcationArr')
					WITH(
						nKey INT '$.NotificationKey'
					)

					UPDATE DA_DeviceNotification
					SET ReadDate = GETDATE()
					WHERE 
						NotificationKey IN (SELECT * FROM #temp_r) 
						--AND
						--UserKey = @nUserKey AND
						--DeviceKey = @nDeviceKey

					DROP TABLE #temp_r

				COMMIT TRANSACTION



				SET @Status = 1
				SET @IsLogout = 0
				SET	@IntError = ''
				SET	@Reason = ''

				SELECT 'Response'='Updated Successfully' FOR JSON PATH

			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @Status = 0
				SET	@IntError = 'UserKey,DeviceKey cannot be Blank or NULL'
				SET	@Reason = 'Something went wrong, Contact System administrator'
				SET @IsLogout = 0

				SELECT 'Response'= ERROR_MESSAGE() FOR JSON PATH
			END CATCH
		END
END
