
/*
declare @BrokerKey	INT = 0,
	@BrokerID		VARCHAR(100) = '',
	@BrokerName	 VARCHAR(100) = ' Linen Park Inc',
	@OutPut     BIT = 0  ,
	@Reason     VARCHAR(50) 
exec	Broker_ValidateIdName @BrokerKey,  @BrokerID ,@BrokerName ,@OutPut output ,@Reason output
select @OutPut,@Reason

*/



CREATE PROCEDURE [dbo].[Broker_ValidateIdName]
(
	@BrokerKey   INT = 0,
	@BrokerID	 VARCHAR(100) = '',
	@BrokerName	 VARCHAR(100) = '',
	@OutPut      BIT = 0 OUTPUT,
	@Reason      VARCHAR(100) OUTPUT
)
AS
 BEGIN
  SET NOCOUNT ON
  SET FMTONLY OFF

  DECLARE @CNTId INT = 0,
		  @CNTName INT = 0;
		  
  SELECT @CNTId = COUNT(1) FROM Broker B WHERE B.BrokerKey <> @BrokerKey AND B.BrokerID = @BrokerID
  SELECT @CNTName = COUNT(1) FROM Broker B WHERE B.BrokerKey <> @BrokerKey AND B.BrokerName = @BrokerName

  IF ISNULL(@CNTId,0) = 0 AND ISNULL(@CNTName,0) = 0
	BEGIN
		SET @OutPut = 1
		SET @Reason = 'Success'
	END
 ELSE
	BEGIN
		IF ISNULL(@CNTId,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = 'Broker Id Already Exist'
			END
		IF ISNULL(@CNTName,0) > 0
			BEGIN
				SET @OutPut = 0
				SET @Reason = ISNULL(@Reason,'') + ' Broker Name Already Exist'
			END
	END
 END

 --SELECT * FROM Broker
