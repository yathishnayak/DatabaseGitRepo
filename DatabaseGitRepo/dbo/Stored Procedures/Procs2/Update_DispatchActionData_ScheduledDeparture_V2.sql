/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"RouteKey" : 181633, "ScheduledDepartureFrom":"2023-04-14 12:00:00", "ScheduledDepartureTo" : "2023-04-20 12:00:00"}'
	EXEC [Update_DispatchActionData_ScheduledDeparture_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Update_DispatchActionData_ScheduledDeparture_V2]
/*Dispatch Screen*/
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
--@UserKey		INT,
--@Status			bit output
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

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
	@RouteKey		INT,
	@ScheduledDepartureFrom	DATETIME,
	@ScheduledDepartureTo	DATETIME

	SELECT 
	@RouteKey		=		RouteKey,
	@ScheduledDepartureFrom		=		ScheduledDepartureFrom,
	@ScheduledDepartureTo		=		ScheduledDepartureTo
	FROM OPENJSON(@JSONString)
	WITH
	(
	RouteKey					INT				'$.RouteKey',
	ScheduledDepartureFrom		DATETIME		'$.ScheduledDepartureFrom',
	ScheduledDepartureTo		DATETIME		'$.ScheduledDepartureTo'
	)

	DECLARE @OrderDetailKey		INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @IsReadyToComplete	BIT
	DECLARE @StatusKey SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)

	

	SET @Status=0;
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes]  WITH (NOLOCK)
                            WHERE RouteKey= @RouteKey
						 )
	

	UPDATE dbo.[Routes]
	SET 		
		PickupDateFrom	= @ScheduledDepartureFrom,
		PickupDateTo	= @ScheduledDepartureTo,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKey and Status in (  SELECT [Status] FROM dbo.RouteStatus WITH (NOLOCK)
    WHERE [Description] in ('DriverAssigned','Open'))

	--UPDATE ODS
	--SET 
	--		ODS.SchedulePickupDate        = @ScheduledDepartureFrom,
	--		ODS.SchedulePickupDateTo      = @ScheduledDepartureTo,
	--		ODS.SchedulePickupUserKey     = @UserKey,
	--		--ODS.SchedulePickupSetDateTime = GETDATE(),
	--		ODS.UpdateUserKey             = @UserKey,
	--		ODS.UpdateDate                = GETDATE()
	--FROM OrderDetailStops ODS
	----INNER JOIN Routes ON  
	--WHERE ODS.OrderDetailKey = @OrderDetailKey AND  ODS.StopTypeKey = 1 

		--	UPDATE ODS
		--SET 
		--	ODS.SchedulePickupDate        = RT.PickupDateFrom,
		--	ODS.SchedulePickupDateTo      = RT.PickupDateTo,
		--	ODS.SchedulePickupUserKey     = @UserKey,
		--	ODS.UpdateUserKey             = @UserKey,
		--	ODS.UpdateDate                = GETDATE()
		--FROM OrderDetailStops ODS
		--INNER JOIN Routes RT ON RT.RouteKey = @RouteKey
		--WHERE ODS.OrderDetailKey = @OrderDetailKey
		----	AND ODS.StopTypeKey = 1


		UPDATE ODS
SET 
    ODS.SchedulePickupDate        = RT.PickupDateFrom,
    ODS.SchedulePickupDateTo      = RT.PickupDateTo,
    ODS.SchedulePickupUserKey     = @UserKey,
    ODS.UpdateUserKey             = @UserKey,
    ODS.UpdateDate                = GETDATE()
FROM OrderDetailStops ODS
INNER JOIN Routes RT 
    ON RT.RouteKey = ODS.FromRouteKey   
WHERE 
    ODS.OrderDetailKey = @OrderDetailKey
    AND RT.RouteKey = @RouteKey         
 --   AND ODS.StopTypeKey = 1           


	if(@@ROWCOUNT > 0)
	begin
		set @Status = 1
		SET @Reason = 'Success'
	end
	exec UpdateContainerStatus @OrderDetailKey
END
