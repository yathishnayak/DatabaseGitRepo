CREATE PROCEDURE [dbo].[Update_DispatchActionData_ScheduledDeparture]
/*Dispatch Screen*/
@RouteKey		INT,
@ScheduledDepartureFrom	DATETIME,
@ScheduledDepartureTo	DATETIME,
@UserKey		INT,
@Output			bit output
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey		INT
	DECLARE @DriverAsgStatusKey SMALLINT
	DECLARE @IsReadyToComplete	BIT
	DECLARE @StatusKey SMALLINT
	DECLARE @StatusDesc VARCHAR(200)
	DECLARE @LegNo SMALLINT
	DECLARE @NexLeg SMALLINT
	DECLARE @CurrLeg VARCHAR(50)

	

	SET @OutPut=0;
	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WHERE RouteKey= @RouteKey
						 )
	

	UPDATE dbo.[Routes]
	SET 		
		PickupDateFrom	= @ScheduledDepartureFrom,
		PickupDateTo		= @ScheduledDepartureTo,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKey and Status in (  SELECT [Status] FROM dbo.RouteStatus WHERE [Description] in ('DriverAssigned','Open'))

	

	if(@@ROWCOUNT > 0)
	begin
		set @Output = 1;
	end
	exec UpdateContainerStatus @OrderDetailKey
END
