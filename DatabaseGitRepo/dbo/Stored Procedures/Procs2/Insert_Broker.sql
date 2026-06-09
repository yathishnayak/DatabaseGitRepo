CREATE PROCEDURE [dbo].[Insert_Broker]
@Brokerid	AS VARCHAR(20), 
@BrokerName AS VARCHAR(50), 
@Addrkey	AS INT
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO [dbo].[Broker]([BrokerID],[Brokername],[Addrkey],[Createdate],[StatusKey],StatusDate,IsActive,IsDelete)
	VALUES ( @Brokerid,@BrokerName,@Addrkey,GETDATE(),1,GETDATE(),1,0);
END



