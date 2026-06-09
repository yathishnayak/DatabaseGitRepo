CREATE PROCEDURE [dbo].[Update_OrderHeader_BrokerRefNo]
/*
Update Header data from Container Screen
*/
@OrderKey		INT,
@BrokerRefNo	VARCHAR(50),
@UpdateUserKey	INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	UPDATE OrderHeader 
	SET BrokerRefNo= @BrokerRefNo,LastUpdateDate = GETDATE(), LastUpdateUserKey = @UpdateUserKey  
	WHERE OrderKey= @OrderKey;

	SET @OutPut=1;
END
