
CREATE PROC [dbo].[TMS_INTEGRATION_InsertRPStops_Century]
AS

BEGIN
	SELECT			DISTINCT CL.ContainerKey,SD.AddrName,
					SD.address1, SD.Address2, SD.City, SD.State, SD.Country, SD.ZipCode, CL.equipmentNumber, CL.equipmentTypeCode 
	INTO			#TMP
	FROM			TKT_RouteDataNew RTN WITH (NOLOCK)
	INNER JOIN		Integration_JCB.DBO.Century_Header FH WITH (NOLOCK) ON RTN.OrderKey = FH.TMS_OrderKey
	INNER JOIN		Integration_JCB.DBO.Century_ContainerList CL WITH (NOLOCK) ON  FH.DATAKEY = CL.DataKey
	INNER JOIN		routes RT WITH (NOLOCK) on rtn.RouteKey = RT.RouteKey
	INNER JOIN		Address SD WITH (NOLOCK) on RT.SourceAddrKey = SD.AddrKey
	LEFT JOIN		Integration_JCB.DBO.Century_StopList SL WITH (NOLOCK) ON CL.ContainerKey = SL.ContainerKey AND RTN.LocationType = SL.facilityCode
	WHERE			rtn.LocationType = 'RP'   and sl.stopkey is null --  and FH.DataKey = 7458  
					--and  convert(Datetime, FH.workOrderDate) > convert(Date, '2024-09-01') --  AND FH.TMS_OrderKey IN (123801)

	 -- SELECT		* FROM #TMP
	 --SELECT		* FROM #TMP1


	INSERT INTO		Integration_JCB.DBO.Century_StopList (ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber,
					address1, Address2, city, state, country, postalCode, equipmentNumber, equipmentTypeCode,IsScheduleSent,PrepullFlag)
	SELECT			ContainerKey,'Return Pickup', AddrName, 2, 'RP', 2,
					address1,Address2, City,State, Country, ZipCode, equipmentNumber, equipmentTypeCode,0,'D'
	FROM			#TMP

	SELECT			ContainerKey, ROW_NUMBER() OVER (ORDER BY ContainerKey) SL
	INTO			#ContData
	FROM			(SELECT			DISTINCT ContainerKey
					FROM			#TMP) A

	DECLARE @i INT = 1, @n INT = (SELECT COUNT(*) FROM #ContData), @ContainerKey INT = 0

	WHILE(@i <= @n)
		BEGIN
			SET		@ContainerKey = (SELECT ContainerKey FROM #ContData WHERE SL = @i)
			-- SELECT	@ContainerKey
			EXEC	TMS_INTEGRATION_UpdateStopNo_Century @ContainerKey

			SET @i = @i + 1
		END

	DROP TABLE		#TMP
	DROP TABLE		#ContData

END
