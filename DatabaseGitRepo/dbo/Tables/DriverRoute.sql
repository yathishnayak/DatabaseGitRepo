CREATE TABLE [dbo].[DriverRoute] (
    [RouteKey]           INT      NOT NULL,
    [DriverKey]          INT      NULL,
    [DriverStartDate]    DATETIME NULL,
    [DriverCompleteDate] DATETIME NULL,
    CONSTRAINT [PK_DriverRoute] PRIMARY KEY CLUSTERED ([RouteKey] ASC)
);


GO
CREATE TRIGGER [dbo].[TR_DriverRoute_AfterUpdate] 
ON [dbo].[DriverRoute] AFTER UPDATE
AS
BEGIN
	IF @@ROWCOUNT>0 	
	BEGIN
		DECLARE @RouteKey INT
		DECLARE @StartDate DATETIME
		DECLARE @ComplDate DATETIME

		SET @RouteKey = ( SELECT RouteKey FROM INSERTED )
		SET @StartDate=  ( SELECT DriverStartDate FROM INSERTED )
		SET @ComplDate=  ( SELECT DriverCompleteDate FROM INSERTED )

		IF UPDATE (DriverStartDate)
		BEGIN
			--UPDATE RT
			--SET RT.ActualDeparture=H.DriverStartDate
			--FROM dbo.Routes RT 
			--	INNER JOIN inserted H ON H.RouteKey=RT.RouteKey
			--WHERE ISNULL(RT.ActualDeparture,'01/01/2000')<>ISNULL(H.DriverStartDate,'01/01/2000')
			--

			EXECUTE Update_ActualDeparture @RouteKey,@StartDate,NULL
		END
		IF  UPDATE (DriverCompleteDate)
		BEGIN
				--UPDATE RT
				--SET RT.ActualArrival=H.DriverCompleteDate
				--FROM dbo.Routes RT 
				--	INNER JOIN inserted H ON H.RouteKey=RT.RouteKey
				--WHERE ISNULL(RT.ActualArrival,'01/01/2000')<>ISNULL(H.DriverCompleteDate,'01/01/2000')
			EXECUTE Update_ActualArrival @RouteKey,@ComplDate,NULL
		END	
	--**********************Leg Status Update****************************
		--DECLARE @DriverAsgStatusKey SMALLINT

		--SET @DriverAsgStatusKey= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned')

		--IF  (	
		--		SELECT COUNT(1) 
		--		FROM dbo.[Routes] RT 
		--			INNER JOIN inserted I ON I.RouteKey=RT.RouteKey
		--			INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
		--		WHERE RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NULL 
		--			  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		--	)>0
		--BEGIN
		--	UPDATE RT
		--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Open' AND IsActive=1 )
		--	FROM dbo.[Routes] RT 
		--		INNER JOIN inserted I ON I.RouteKey=RT.RouteKey;			
		--END;
		--IF  (	
		--		SELECT COUNT(1) 
		--		FROM dbo.[Routes] RT
		--			INNER JOIN inserted I ON I.RouteKey=RT.RouteKey
		--			INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
		--		WHERE RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
		--			  AND RT.ActualDeparture IS NULL AND RT.ActualArrival IS NULL
		--	)>0
		--BEGIN
		--	UPDATE RT
		--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='DriverAssigned' AND IsActive=1 )
		--	FROM dbo.[Routes] RT 
		--		INNER JOIN inserted I ON I.RouteKey=RT.RouteKey AND [Status]<>@DriverAsgStatusKey;
		--END;
		--IF  (	
		--		SELECT COUNT(1) 
		--		FROM dbo.[Routes] RT 
		--			INNER JOIN inserted I ON I.RouteKey=RT.RouteKey
		--			INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
		--		WHERE RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
		--			AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NULL
		--	)>0
		--BEGIN
		--	UPDATE RT
		--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='InProgress' AND IsActive=1 )
		--	FROM dbo.[Routes] RT 
		--		INNER JOIN inserted I ON I.RouteKey=RT.RouteKey
		--END;
		--IF  (	
		--		SELECT COUNT(1) 
		--		FROM dbo.[Routes] RT 
		--			INNER JOIN dbo.RouteStatus RTS  ON RTS.[Status]=RT.[Status]
		--		WHERE RTS.[Description]<>'Leg Completed' AND RT.DriverKey IS NOT NULL 
		--			AND RT.ActualDeparture IS NOT NULL AND RT.ActualArrival IS NOT NULL
		--	)>0
		--BEGIN
		--		UPDATE RT
		--	SET [Status]= ( SELECT [Status] FROM dbo.RouteStatus WHERE [Description]='Ready To Complete' AND IsActive=1 )
		--	FROM dbo.[Routes] RT 
		--		INNER JOIN inserted I ON I.RouteKey=RT.RouteKey
		--END;
	END
END
