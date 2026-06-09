/*
DECLARE @UserKey INT = 714, @JSOnString NVARCHAR(MAX) = '', @Status BIT, @@IntError NVARCHAR(MAX), @Reason VARCHAR(1000), @IsDebug BIT = 0, @FirebaseID VARCHAR(100) = '', @IsLogout BIT
SET @JSOnString = '{"DriverKey":1681,"MsgHeader":"driver34443Header","MsgDetail":"driver3MsgDetali","MsgType":"MsgType"}'
SET @FirebaseID = ''
EXEC DA_InsertNotification @UserKey,@JSOnString,@Status OUTPUT, @@IntError OUTPUT, @Reason OUTPUT,@IsDebug, @FirebaseID , @IsLogout OUTPUT
SELECT @Status,@@IntError,@Reason, @IsLogout
*/

CREATE PROCEDURE [dbo].[DA_InsertNotification](
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"DriverKey":1681,"MsgHeader":"df","MsgDetail":"","MsgType":""}',
	@Status			BIT	= 0 OUTPUT,
	@IntError		NVARCHAR(MAX) = '' OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
	@FirebaseID		VARCHAR(500) = '',
	@IsLogout		BIT = 0 OUTPUT
) AS 
BEGIN
	
	SET @IsLogout = 0

	DECLARE @LogKey INT
	INSERT INTO DA_RequestResponseLogs (ProcedureName,UserKey,RequestJSONString,FirebaseID, IsDebug,CreatedDate)
	SELECT  OBJECT_NAME(@@PROCID),@UserKey,@JSONString,'No FirebaseID will be Received',@IsDebug,GETDATE()
	SET @LogKey = @@IDENTITY
	   
	DECLARE 	@AppUserKey		INT,@DeviceKey		INT,@DriverKey INT,
				@MsgHeader		VARCHAR(500),
				@MsgDetail		VARCHAR(1000),
				@MsgType		VARCHAR(50) = NULL

	
	IF(ISNULL(@JSONString,'') <> '')
		BEGIN
			SELECT		@DriverKey = DriverKey,@MsgHeader = MsgHeader,@MsgDetail = MsgDetail,@MsgType = MsgType
			FROM		OPENJSON(@JSONString, '$')
						WITH (
								DriverKey		INT				'$.DriverKey',
								MsgHeader		VARCHAR(50)		'$.MsgHeader',
								MsgDetail		VARCHAR(1000)	'$.MsgDetail',
								MsgType			VARCHAR(100)	'$.MsgType'
								)
			

			SELECT		@AppUserKey = FBI.UserKey,@DeviceKey = DD.DeviceKey, @FirebaseID = FBI.FireBaseID
			FROM		DA_UserFireBaseID FBI
			INNER JOIN	DA_UserDeviceDetails DD ON FBI.UserKey = DD.UserKey AND FBI.DeviceKey = DD.DeviceKey
			WHERE		DD.DriverKey = @DriverKey

			SET			@AppUserKey = ISNULL(@AppUserKey,0)
			SET			@UserKey = ISNULL(@UserKey,0)
			SET			@DeviceKey = ISNULL(@DeviceKey,0)
			SET			@DriverKey = ISNULL(@DriverKey,0)
			SET			@MsgHeader = ISNULL(@MsgHeader,'')
			SET			@MsgDetail = ISNULL(@MsgDetail,'')
			SET			@MsgType = ISNULL(@MsgType,'')
			SET			@FirebaseID = ISNULL(@FirebaseID,'')
		
		END	

		IF(@IsDebug = 1)
			BEGIN
				SELECT @AppUserKey, @DeviceKey,@DriverKey, @MsgHeader ,@MsgDetail,@MsgType,@FirebaseID, @UserKey
			END
		
		DECLARE @JsonOutput NVARCHAR(MAX) = ''
		IF(@AppUserKey= 0 OR @DeviceKey = 0 OR @DriverKey = 0 OR @MsgHeader = '' OR @MsgDetail = '' OR @MsgType = '' OR @FirebaseID = '' OR @USerKey = 0)
			BEGIN
				SET	@Status	= 0
				SET	@IntError = 'Notification Param Fields cannot be Blank or NULL'
				SET	@Reason = 'Something went wrong, Contact System administrator'
			END
		ELSE
			BEGIN
				INSERT INTO DA_DeviceNotification(UserKey,Driverkey, DeviceKey,FireBaseID,MessageHeader,MessageDetail,MessageType, CreatedBy)
				VALUES (@AppUserKey,@Driverkey,@DeviceKey,@FirebaseID,@MsgHeader,@MsgDetail,@MsgType, @UserKey)
				
				DECLARE @nKey INT = SCOPE_IDENTITY()

				SET @JsonOutput = (SELECT @nKey AS NotificationKey, @FirebaseID AS FirebaseID, @MsgHeader AS MsgHeader
								, @MsgDetail AS MsgDetail FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

				SET @Status = 1
				SET @IntError = 'Notification Inserted Successfully'
				SET @Reason = @IntError
			END
		
		SELECT @JsonOutput AS JsonOutput

		UPDATE DA_RequestResponseLogs
		SET OutputStatus = @Status, OutputInternalError = @IntError, OutputExternallError= @Reason, UpdatedDate = GETDATE()
		, ReponseJSONString = @JsonOutput, IsLogout = 0
		WHERE LogKey = @LogKey

END
