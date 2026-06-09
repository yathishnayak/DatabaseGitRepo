/*    
     
Declare @UserKey  INT=952,    
 @JsonString  VARCHAR(MAX)='{"OrderDetailKey":222038}',     
 @Status   BIT = 0 ,    
 @Reason   NVARCHAR(1000) = ''     
    
 EXEC Route_ValidateCreateStops @UserKey,@JsonString,@Status OUTPUT, @Reason OUTPUT    
 select @Reason,@Status    
    
*/
CREATE PROC [dbo].[Route_ValidateCreateStops]  
(
	@UserKey		INT=0,
	@JsonString		VARCHAR(MAX)='',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT	
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	SET @Status = 0
	SET @Reason = ''

	DECLARE @OrderDetailKey			INT
			,@RouteKey				INT

	SELECT @OrderDetailKey=OrderDetailKey
	,@RouteKey=RouteKey
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey		INT			'$.OrderDetailKey',
			RouteKey			INT			'$.RouteKey'
		)

	DECLARE @Test BIT,
			@StopNumber INT = 0,
			@CountStopNumber INT = 0;

	SET @CountStopNumber = (Select Count(*) FROM OrderDetailStops where OrderDetailKey = @OrderDetailKey AND StopTypeKey IN (4,5))

	--Select '@CountStopNumber', @CountStopNumber

	SET @Test =
	(
		SELECT CASE 
				WHEN EXISTS (
						SELECT 1 FROM OrderDetailStops
						WHERE OrderDetailKey = @OrderDetailKey AND @CountStopNumber = 0 AND DropOrLive = 'D'
				)
				AND EXISTS (
						SELECT 1 FROM OrderDetailStops
						WHERE OrderDetailKey = @OrderDetailKey 
						AND StopTypeKey = 3 AND ISNULL(ISDryRunCustomer, 0) = 0
						AND ActualDeliveryDate IS NOT NULL
				)
				THEN 1 ELSE 0 END
	);

	--Select '@Test', @Test
	--Select @UserKey

	IF(@Test = 1)
	BEGIN
		SET @StopNumber =  ((SELECT MAX(StopNumber) FROM OrderDetailStops WHERE orderdetailkey = 221910) + 1)

		--Select '@StopNumber', @StopNumber
		
		BEGIN TRY
			BEGIN TRANSACTION InsertStop
				INSERT INTO OrderDetailStops 
				(OrderDetailKey, StopTypeKey, StopName, StopNameSetUserKey, StopNameSetDateTime, StopAddrKey, StopNumber, LocationType, CreateDate, CreateUserKey)
				VALUES(@OrderDetailKey, 5, '*Unspecified / TBD*', @UserKey, GetDate(), 38953, @StopNumber, 'PORT', GetDate(), @UserKey);
				
			COMMIT TRANSACTION InsertStop
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION InsertStop
		END CATCH
		
	END	
END

