/*
DECLARE 
    @UserKey        INT = 953,
    @Status         BIT = 0,
    @Reason         VARCHAR(1000) = '',
    @IsDebug        BIT = 0,
    @JSONString     NVARCHAR(MAX) = '{"CarrierRate": 10, "RouteKey":729700}'

EXEC [dbo].[Update_DispatchActionData_CarrierRate_V2]   @UserKey,@JSONString, @Status OUTPUT,  @Reason OUTPUT,@IsDebug
SELECT @Status AS Status, @Reason AS Reason;
*/

CREATE  PROCEDURE [dbo].[Update_DispatchActionData_CarrierRate_V2]
(    
    @UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)  
AS
BEGIN
	
	SET NOCOUNT ON;

	 IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
 IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

			 DECLARE
				 @RouteKey  INT,  
				 @CarrierRate DECIMAL


			SELECT 
				@CarrierRate = CarrierRate ,	@RouteKey = RouteKey
			FROM OPENJSON(@JSONString)
			WITH
			(
				CarrierRate   DECIMAL    '$.CarrierRate',
				RouteKey     INT    '$.RouteKey'
			)



	update [routes] 
	set CarrierRate = @CarrierRate
	where  RouteKey = @RouteKey

	SET @Status =1;
	SET @Reason='Success';
END