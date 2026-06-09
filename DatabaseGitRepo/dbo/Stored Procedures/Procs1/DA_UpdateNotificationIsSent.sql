CREATE PROC [dbo].[DA_UpdateNotificationIsSent](
	@nKey INT = 0
)AS BEGIN
	IF(@nKey > 0)
		BEGIN
			UPDATE DA_DeviceNotification
			SET IsSent = 1,SentDate = GETDATE()
			WHERE NotificationKey = @nKey
		END
END
