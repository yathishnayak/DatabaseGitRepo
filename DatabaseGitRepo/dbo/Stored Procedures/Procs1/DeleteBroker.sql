--select * from Broker

CREATE PROCEDURE [dbo].[DeleteBroker]
(
@BrokerKey INT,
@UserKey   INT,
@OutPut bit = 0 OUTPUT,
@Reason varchar(100) = '' OUTPUT
)
As 
BEGIN
   SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CNTBroker INT=0,
			@CNTBrokerLink	 INT = 0,
			@CNTOrderHeader	 INT = 0,
			@CNTCustrItemRate	 INT = 0
				
   SELECT @CNTBroker = (select count (BrokerName) from Broker where  BrokerKey=@BrokerKey)
   SELECT @CNTOrderHeader =(select COUNT(1) FROM OrderHeader WHERE BrokerKey = @BrokerKey)
   SELECT @CNTCustrItemRate =(select COUNT(1) FROM CustomerItemRate WHERE ClientOrBrokerKey = @BrokerKey)

	IF(ISNULL(@CNTBroker,0 ) = 0)
	BEGIN
	    SET @Reason = 'No record found for the given Broker data' 
	    SET @output  = CONVERT(BIT,0);	
	    RETURN
	END
    ELSE IF ISNULL(@CNTOrderHeader,0) > 0
	BEGIN		
		SET @output  = CONVERT(BIT,0);
		SET @Reason  = 'Broker linked to Order, can not be deleted';				
		RETURN;
	END
	ELSE IF ISNULL(@CNTCustrItemRate,0) > 0
	BEGIN
		SET @output  = CONVERT(BIT,0);
		SET @Reason  = 'Broker linked to CustomerItem Rate, can not be deleted';			
		RETURN;
	END
ELSE
	BEGIN
		UPDATE  broker
		SET IsActive = 0, IsDelete = 1
		WHERE BrokerKey = @BrokerKey
		SET @Reason = 'Broker Deleted Successfully'
		SET @OutPut = 1;
		RETURN
	END
END
