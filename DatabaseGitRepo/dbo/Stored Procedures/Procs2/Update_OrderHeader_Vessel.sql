CREATE PROCEDURE [dbo].[Update_OrderHeader_Vessel]
/*
Update Header data from Container Screen
*/
@OrderKey		INT,
@Vessel	VARCHAR(50),
@UpdateUserKey	INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE OrderHeader 
	SET VesselName= @Vessel, lastupdatedate =GETDATE(), lastupdateuserkey = @UpdateUserKey  
	WHERE OrderKey= @OrderKey;

	SET @OutPut=1;
END
