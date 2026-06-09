CREATE PROCEDURE [dbo].[Update_ScheduleComplete] -- [Update_ScheduleComplete] 12,2
/*
Schedule Screen
*/
@OrderDetailKey INT,
@UserKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

		IF(
			--SELECT COUNT(1) 
			--FROM dbo.[Routes] 
			--WHERE OrderDetailKey=@OrderDetailKey AND PickupDate IS NOT NULL AND 
			--	  DeliveryDate IS NOT NULL AND SourceAddrKey IS NOT NULL AND DestinationAddrKey IS NOT NULL	
			SELECT COUNT(1) 
			FROM dbo.[Routes] 
			WHERE OrderDetailKey=@OrderDetailKey 
		  )>0		
		BEGIN
			UPDATE dbo.OrderDetail 
			SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Schedule Confirmed' ), 
				LastUpdateDate = GETDATE(),StatusDate=GETDATE(), UpdateUserKey=@UserKey 
			WHERE OrderDetailKey= @OrderDetailKey ;

			exec UpdateContainerStatus @OrderDetailKey

			 SET @OutPut=1;

		END;	
END
