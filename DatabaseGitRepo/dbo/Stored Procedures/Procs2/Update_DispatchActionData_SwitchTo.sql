CREATE PROCEDURE [dbo].[Update_DispatchActionData_SwitchTo]
/*Dispatch Screen*/
@RouteKey		INT,
@SwitchTo		VARCHAR(30),
@UserKey		INT,
@OutPut			BIT OUTPUT,
@IsReadyToComplete BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT;
	DECLARE @DriverAsgStatusKey SMALLINT;

	SET @OutPut=0;

	SET @OrderDetailKey= (
							SELECT DISTINCT OrderDetailKey 
							FROM dbo.[Routes] WHERE RouteKey= @RouteKey
						 )
	SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

	UPDATE dbo.[Routes]
	SET 		
		SwitchTo		= @SwitchTo,
		UpdateUserKey	= @UserKey,
		LastUpdateDate	= GETDATE()
	WHERE RouteKey= @RouteKey;

--********************Container Status Update******************************
	IF (	SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status] 
			WHERE RT.OrderDetailKey= @OrderDetailKey AND RTS.[Description]<>'Leg Completed'
				AND (
						ISNULL(RT.driverKey ,0) > 0 OR ISNULL(RT.ChassisNo,'') <> ''  OR 
						ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') <>  '1970-01-01 00:00:00.000' OR
						ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') <> '1970-01-01 00:00:00.000'
					)
	   )>0
	BEGIN
		UPDATE dbo.OrderDetail
		SET [Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Dispatch InProgress' AND IsActive=1 ),
			StatusDate=GETDATE()
		WHERE OrderDetailKey= @OrderDetailKey;
	END;
	--**************************Container Leg Status****************************
	IF  (	
			SELECT COUNT(1) 
			FROM dbo.[Routes] RT 
				INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
			WHERE RouteKey= @RouteKey AND RTS.Description<>'Leg Completed'
		)>0
	BEGIN
		UPDATE dbo.[Routes]
		SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Delivery Pending' )
		WHERE RouteKey= @RouteKey AND [Status]<>@DriverAsgStatusKey;
	END;
	--***************************************************************************
	SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey)
	SET @OutPut=1;
END
