CREATE PROCEDURE [dbo].[DA_GetDeviceNotification](
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsLogout		BIT = 0 OUTPUT,
	@JSONString		NVARCHAR(MAX),
	@UserKey		INT,
	@FirebaseID		VARCHAR(500)
) AS BEGIN
	DECLARE @nUserKey INT = 0,@nDeviceKey INT = 0

	SELECT @nUserKey = uKey,@nDeviceKey = dKey
	FROM OPENJSON(@JSONString)
	WITH(
		uKey INT '$.UserKey',
		dKey INT '$.DeviceKey'
	)
	IF(ISNULL(@JSONString,'')='' OR (ISNULL(@nUserKey,0)=0 OR ISNULL(@nDeviceKey,0)=0) OR ISNULL(@UserKey,0)=0 OR ISNULL(@FirebaseID,'')='')
		BEGIN
			SET @Status = 0
			SET	@IntError = 'UserKey,DeviceKey cannot be Blank or NULL'
			SET	@Reason = 'Something went wrong, Contact System administrator'
			SET @IsLogout = 0

			SELECT ''
		END
	ELSE 
		BEGIN
			SET @Status = 1
			SET @IsLogout = 0
			SET	@IntError = ''
			SET	@Reason = ''

			SELECT MessageHeader,MessageDetail,CreatedDate
			FROM DA_DeviceNotification 
			WHERE UserKey = @nUserKey AND DeviceKey = @nDeviceKey
			FOR JSON PATH
		END
END
