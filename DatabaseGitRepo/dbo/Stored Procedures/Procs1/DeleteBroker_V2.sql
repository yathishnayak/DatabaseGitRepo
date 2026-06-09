/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"BrokerKey":7}'
 
EXEC [DeleteBroker_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[DeleteBroker_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
As 
BEGIN
   SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @CNTBroker INT=0,
			@CNTBrokerLink	 INT = 0,
			@CNTOrderHeader	 INT = 0,
			@CNTCustrItemRate	 INT = 0,
			@BrokerKey INT

   -- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	SELECT @BrokerKey =  BrokerKey
	FROM OpenJSON(@JSONString, '$')
	WITH (
		BrokerKey			INT				'$.BrokerKey'
	)
				
   SELECT @CNTBroker = (select count (BrokerName) from Broker WITH(NOLOCK) where  BrokerKey=@BrokerKey)
   SELECT @CNTOrderHeader =(select COUNT(1) FROM OrderHeader WITH(NOLOCK) WHERE BrokerKey = @BrokerKey)
   SELECT @CNTCustrItemRate =(select COUNT(1) FROM CustomerItemRate WITH(NOLOCK) WHERE ClientOrBrokerKey = @BrokerKey)

	IF(ISNULL(@CNTBroker,0 ) = 0)
	BEGIN
	    SET @Reason = 'No record found for the given Broker data' 
	    SET @Status  = CONVERT(BIT,0);	
	    RETURN
	END
    ELSE IF ISNULL(@CNTOrderHeader,0) > 0
	BEGIN		
		SET @Status  = CONVERT(BIT,0);
		SET @Reason  = 'Broker linked to Order, can not be deleted';				
		RETURN;
	END
	ELSE IF ISNULL(@CNTCustrItemRate,0) > 0
	BEGIN
		SET @Status  = CONVERT(BIT,0);
		SET @Reason  = 'Broker linked to CustomerItem Rate, can not be deleted';			
		RETURN;
	END
	ELSE
	BEGIN
		UPDATE  broker
		SET IsActive = 0, IsDelete = 1
		WHERE BrokerKey = @BrokerKey
		SET @Reason = 'Broker Deleted Successfully'
		SET @Status = 1;
		RETURN
	END
END