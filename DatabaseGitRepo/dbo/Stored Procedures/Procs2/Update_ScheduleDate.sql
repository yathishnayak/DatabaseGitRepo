CREATE PROCEDURE [dbo].[Update_ScheduleDate]
/*
Update Schedule Dates--- Schedule Screen
*/
@RouteKey				INT,
@OrderDetailKey			INT,
@ActualArrival			DATETIME=NULL,
@ActualDeparture		DATETIME=NULL,
@OdometerAtDestination  SMALLINT=NULL,
@OutPut					BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	UPDATE dbo.[Routes]
	SET	ActualArrival= ISNULL(@ActualArrival,ActualArrival), ActualDeparture= ISNULL(@ActualDeparture,ActualDeparture),
		OdometerAtDestination=ISNULL( @OdometerAtDestination,OdometerAtDestination)
	WHERE RouteKey=@RouteKey AND OrderDetailKey=@OrderDetailKey;

	SET @OutPut=1;
END
