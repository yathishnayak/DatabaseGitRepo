-- DELETE FROM MelroseIntegrate_DCSAProcess_WRK WHERE OrderDetailkey = 275414
CREATE PROCEDURE [dbo].[MelroseIntegrate_GetMilestoneData_Delete] -- MelroseIntegrate_GetMilestoneData_Delete  0,'','',0
--MelroseIntegrate_GetMilestoneData  0,'Delivery','A',1
(
	@RouteKey		INT,
	@Datetype		VARCHAR(50),	-- Pickup, Delivery, Empty
	@ScheduleActual	VARCHAR(5),		-- A,S
	@IsDebug		BIT
)

AS

BEGIN
	-- DROP TABLE #Data

	--SET @RouteKey = 870943

	CREATE TABLE #OrderDetailKey
	(
		OrderDetailKey		INT
	)

	IF(ISNULL(@RouteKey,0) = 0)
		BEGIN
			SET @ScheduleActual = ''
			SET @Datetype = ''
		END

	
	DELETE FROM MelroseIntegrate_DCSAProcess_WRK
	WHERE DATEDIFF(MINUTE, CreateDate, GETDATE()) > 5 

	SELECT		CustKey, CustName 
	INTO		#Customer
	FROM		Customer WITH (NOLOCK) 
	--WHERE		CustKey IN (1843,2992,2831,3307,3405,3148,2385,3594)
	WHERE		CustKey IN (SELECT CustKey  FROM MelroseIntegrate_MappedCustomers WHERE ISNULL(Custkey,0) > 0 AND ISNULL(IsDeleted,0) = 0)

	IF(@IsDebug = 1)
		BEGIN
			SELECT '#Customer',* FROM #Customer 
		END

	IF(ISNULL(@RouteKey,0) > 0)
		BEGIN
			INSERT INTO #OrderDetailKey
			SELECT OrderDetailKey FROM Routes WITH (NOLOCK) WHERE RouteKey = @RouteKey
		END
	ELSE
		BEGIN
			INSERT INTO #OrderDetailKey
			SELECT DISTINCT OrderDetailKey FROM Routes WITH (NOLOCK) 
			-- WHERE LastUpdateDate > DATEADD(MINUTE, -60, GETDATE())
			WHERE OrderDetailKey NOT IN (SELECT DISTINCT OrderDetailKey FROM MelroseIntegrate_DCSAProcess_WRK WITH (NOLOCK) ) 
			AND  LastUpdateDate > GETDATE() - 10
			-- AND OrderDetailKey = 275414
		END

		--SELECT		*
		DELETE		TDK 
		FROm		OrderDetail OD
		INNER JOIN	#OrderDetailkey TDK ON OD.OrderDetailKey = TDK.OrderDetailKey
		WHERE		LEFT(ContainerNo,4) IN ('UUUU','JFTL')

	IF(@IsDebug = 1)
		BEGIN
			SELECT '#OrderDetailKey',* FROM #OrderDetailKey 
		END

	CREATE CLUSTERED INDEX IX_OrderDetailKey ON #OrderDetailKey (OrderDetailKey);
	CREATE CLUSTERED INDEX IX_Customer_CustKey ON #Customer (CustKey);

	SELECT		DC.ContainerNo,DC.LocationCode, DC.Routekey,DC.OrderKey, DC.OrderDetailkey, DC.OrderTypeKey,DC.EventDate,DC.ScheduleActual
				,DC.AddrKey, DC.OrderNo, UTCEventDate, DateType
	INTO		#FinalData
	FROM		vw_MelroseIntegrate_RouteEventData DC
	INNER JOIN	#OrderDetailKey OD ON DC.OrderDetailkey = OD.OrderDetailKey
	INNER JOIN	#Customer C ON DC.CustKey = C.Custkey

	IF(@IsDebug = 1)
		BEGIN
			
			SELECt		@RouteKey, @ScheduleActual,@Datetype
			SELECT		'FinalData',*
			FROM		#FinalData FD
			--WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
			--			AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
			--			AND ( DateType = @Datetype OR '' = @Datetype)


			SELECT		DISTINCT FD.OrderDetailKey,FD.Routekey,LocationCode StopType, FD.OrderKey,OrderTypeKey,FD.EventDate,FD.ScheduleActual,AddrKey
						,FD.ContainerNo, FD.OrderNo 
			FROM		#FinalData  FD
			LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_GetRecentTransactions MI WITH (NOLOCK)  ON FD.OrderDetailKey = MI.OrderDetailKey 
						AND FD.ContainerNo = MI.ContainerNo
						AND LocationCode = MI.FacilityCode AND CASE WHEN FD.ScheduleActual = 'A' THEN 'Actual' ELSE 'Schedule' END = MI.ScheduleActual
			LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_FailedRecent FR ON FR.OrderDetailkey = FD.OrderDetailKey
						AND FD.ContainerNo = FR.ContainerNo
						AND LocationCode = FR.FacilityCode AND FD.ScheduleActual = FR.ScheduleActual
			WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
						AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
						AND ( DateType = @Datetype OR '' = @Datetype)
						AND (ABS(DATEDIFF(MINUTE, UTCEventDate, MI.EventDate)) > 5 OR MI.EventDate IS NULL OR Issuccess = 0 )
						-- AND FR.OrderDetailkey IS NULL
						AND FD.EventDate IS NOT NULL
						AND FD.OrderDetailKey NOT IN (SELECT DISTINCT OrderDetailKey FROM MelroseIntegrate_DCSAProcess_WRK WITH (NOLOCK) )
		END

	-- UPDATE #FinalData SET EventDate = GETDATE()

	DECLARE @TopCount INT = 3

	IF(@RouteKey > 0)
		BEGIN
			SET @TopCount = 10
		END


	SELECT		DISTINCT  TOP (@TopCount) FD.OrderDetailKey,FD.Routekey,LocationCode StopType, FD.OrderKey,OrderTypeKey,FD.EventDate,FD.ScheduleActual,AddrKey
				,FD.ContainerNo, FD.OrderNo 
	INTO		#FinalProcessData
	FROM		#FinalData  FD
	LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_GetRecentTransactions MI WITH (NOLOCK)  ON FD.OrderDetailKey = MI.OrderDetailKey 
				AND FD.ContainerNo = MI.ContainerNo
				AND LocationCode = MI.FacilityCode AND CASE WHEN FD.ScheduleActual = 'A' THEN 'Actual' ELSE 'Schedule' END = MI.ScheduleActual
	LEFT JOIN	MelroseIntegrate.dbo.vw_IntegrationData_FailedRecent FR ON FR.OrderDetailkey = FD.OrderDetailKey
				AND FD.ContainerNo = FR.ContainerNo
				AND LocationCode = FR.FacilityCode AND FD.ScheduleActual = FR.ScheduleActual
	WHERE		(FD.Routekey = @RouteKey OR 0 = @RouteKey) 
				AND (FD.ScheduleActual = @ScheduleActual  OR '' = @ScheduleActual)
				AND ( DateType = @Datetype OR '' = @Datetype)
				AND (ABS(DATEDIFF(MINUTE, UTCEventDate, MI.EventDate)) > 5 OR MI.EventDate IS NULL)
				AND FR.OrderDetailkey IS NULL
				AND FD.EventDate IS NOT NULL
				AND FD.OrderDetailKey NOT IN (SELECT DISTINCT OrderDetailKey FROM MelroseIntegrate_DCSAProcess_WRK WITH (NOLOCK) )
	
	INSERT INTO MelroseIntegrate_DCSAProcess_WRK (OrderDetailkey,CreateDate)
	SELECT		DISTINCT OrderDetailKey, GETDATE() FROM #FinalProcessData
	
	DECLARE		@JsonResult NVARCHAR(MAX) = (
	SELECT		DISTINCT  FD.OrderDetailKey,FD.Routekey,StopType, FD.OrderKey,OrderTypeKey,FD.EventDate,FD.ScheduleActual,AddrKey
				,FD.ContainerNo, FD.OrderNo 
	FROM		#FinalProcessData  FD
	FOR JSON PATH)

	SELECT		@JsonResult AS JsonResult 
END
