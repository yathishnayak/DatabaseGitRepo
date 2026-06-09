CREATE PROCEDURE [dbo].[DA_UserDeviceApprove](
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
) AS 
BEGIN
	DECLARE
		@d_UserKey INT = 0,
		@d_DeviceKey INT = 0

	IF(@JSONString = '')
		BEGIN
			SET @Status = 0
			SET @Reason = 'Empty Json String'
			SELECT ''
			RETURN
		END
	ELSE
		BEGIN
			SELECT @d_UserKey = uKey,@d_DeviceKey = dKey
			FROM OPENJSON(@JSONString,'$')
			WITH(
				uKey INT '$.UserKey',
				dKey INT '$.DeviceKey'
			)

			IF(ISNULL(@d_UserKey,0)=0 OR ISNULL(@d_DeviceKey,0)=0)
				BEGIN 
					SET @Status = 0
					SET @Reason = 'Param UserKey or DeviceKey Cannot be Empty'
					SELECT ''
					RETURN
				END

			--IF(ISNULL((SELECT 1 FROM DA_UserDeviceDetails WHERE UserKey = @d_UserKey AND DeviceKey = @d_DeviceKey),0) = 1)
			IF EXISTS (SELECT 1 FROM DA_UserDeviceDetails WHERE UserKey = @d_UserKey AND DeviceKey = @d_DeviceKey)
				BEGIN
					UPDATE DA_UserDeviceDetails
					SET IsApproved = 1
					WHERE 
						UserKey = @d_UserKey AND
						DeviceKey = @d_DeviceKey
					SET @Status = 1
					SET @Reason = 'APPROVED SUCCESSFULLY'
					SELECT ''
				RETURN

			END
			SET @Status = 0
			SET @Reason = 'RECORD NOT FOUND'
			SELECT ''
		END
END