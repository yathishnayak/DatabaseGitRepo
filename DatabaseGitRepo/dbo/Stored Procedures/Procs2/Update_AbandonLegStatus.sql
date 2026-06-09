CREATE PROCEDURE [dbo].[Update_AbandonLegStatus]
@RouteKey	INT = 0,
@ReasonKey	 SMALLINT=9,
@UserKey	 INT = 1
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @Output			BIT = 0
	DECLARE @DriverKey		INT
	DECLARE @OrderdetailKey INT
	DECLARE @ComplStatusKey SMALLINT
	DECLARE @LegCount		SMALLINT
	DECLARE @SchProgStatusKey SMALLINT
	DECLARE @SchOpenStatusKey SMALLINT

	SET @LegCount=0

	SET @OrderdetailKey= ( SELECT OrderDetailKey FROM dbo.[routes] WHERE RouteKey=@RouteKey )

	SET @ComplStatusKey= ( SELECT [Status] FROM RouteStatus WHERE [Description]='Leg Completed')

	SET @SchProgStatusKey= ( SELECT [Status] FROM OrderDetailStatus WHERE [Description]='Schedule InProgress' )

	SET @SchOpenStatusKey= ( SELECT [Status] FROM OrderDetailStatus WHERE [Description]='Open' )

	SET @DriverKey=( SELECT DriverKey FROM dbo.[routes] WHERE RouteKey=@RouteKey)
	
	SELECT RT.RouteKey,RT.LegKey,RT.OrderDetailKey,RT.OrderKey,RT.LegNo,RT.SourceAddrKey,
		RT.DestinationAddrKey,FromLocation,ToLocation,CutOffDate,LastFreeDay INTO #RouteData
	FROM dbo.[routes] RT 
		INNER JOIN dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]
	WHERE RouteKey=@RouteKey AND RTS.[Description]='DriverAssigned'	

	IF ( SELECT COUNT(1) FROM #RouteData )>0
	BEGIN
		UPDATE dbo.Routes
		SET [Status]=@ComplStatusKey,IsAbandoned=1
		WHERE RouteKey=@RouteKey

		SET @LegCount = (	
					SELECT Count(1) 	 
					FROM dbo.routes 
					WHERE OrderDetailKey= @OrderdetailKey AND ISNULL(IsAbandoned,0)=0
				)

		INSERT INTO [DriverRouteAbandon] (RouteKey,CreateDate,AbandonReasonKey,CreateUserKey,DriverKey)
		VALUES(@RouteKey,GETDATE(),@ReasonKey,@UserKey,@DriverKey)

		IF @LegCount>0
		BEGIN
			UPDATE dbo.OrderDetail
			SET [Status]=@SchProgStatusKey
			WHERE OrderDetailKey=@OrderdetailKey
		END
		ELSE	
		BEGIN
			UPDATE dbo.OrderDetail
			SET [Status]=@SchOpenStatusKey
			WHERE OrderDetailKey=@OrderdetailKey
		END

		INSERT INTO dbo.Routes(OrderDetailKey,OrderKey,LegKey,LegNo,SourceAddrKey,DestinationAddrKey,
			FromLocation,ToLocation,[Status],CutOffDate,LastFreeDay)
		SELECT OrderDetailKey,OrderKey,LegKey,LegNo,SourceAddrKey,DestinationAddrKey,FromLocation,ToLocation,1,
			CutOffDate,LastFreeDay
		FROM #RouteData	

		IF @@ROWCOUNT>0
		BEGIN
			SET @OutPut=1
		END
	END

	exec UpdateContainerStatus @OrderDetailKey

	SELECT RouteKey, RS.[Status], RS.[Description], R.IsAbandoned
	FROM dbo.Routes R
		LEFT JOIN dbo.RouteStatus RS ON R.[Status] = RS.[Status]
	WHERE RouteKey = @RouteKey
END
