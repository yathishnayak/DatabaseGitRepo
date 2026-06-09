Create VIEW [dbo].[PowerBI_Routes]
AS

WITH ADR AS
(SELECT AddrKey, AddrName
	, Address1
	, CASE WHEN Address2 = '' OR Address2 = '-' THEN NULL ELSE Address2 END AS Address2
	, CONCAT_WS(', ',
					CASE WHEN Address1 <> '' AND Address1 <> '-' AND Address1 IS NOT NULL THEN Address1 ELSE NULL END,
					CASE WHEN Address2 <> '' AND Address2 <> '-' AND Address2 IS NOT NULL THEN Address2 ELSE NULL END
					) AS AddressLineCard
	
	, City, State, ZipCode, Country
	, CONCAT_WS(', ',
					CASE WHEN Address1 <> '' AND Address1 <> '-' AND Address1 IS NOT NULL THEN Address1 ELSE NULL END,
					CASE WHEN Address2 <> '' AND Address2 <> '-' AND Address2 IS NOT NULL THEN Address2 ELSE NULL END,
					City, State, ZipCode
					) AS AddressDetailCard
FROM Address)

SELECT	  R.RouteKey, RS.Description AS RouteStatus, RS.OrderBy AS RouteStatusOrder
		, R.OrderDetailKey, R.OrderKey, R.LegKey, R.LegNo
		, R.ConfirmationNo AS PickupConfNo, R.DelConfirmationNo AS DeliveryConfNo
		, L.Description AS LegType, L.FromLocation AS LegFrom, L.ToLocation AS LegTo
		, CASE 
				WHEN L.FromLocation = 'Port' AND L.ToLocation = 'Port' THEN 'Port Transfer'
				WHEN L.FromLocation = 'Port' THEN 'From Port' 
				WHEN L.ToLocation = 'Port' THEN 'To Port' 
				ELSE 'Inland'
			END AS LegTypeGroup
		, ISNULL(Y.YardType, 'Local') AS YardType
		, CC.ChassisCategory, R.ChassisNo, C.ChassisType, R.FromLocation, R.ToLocation
		, R.PickupDateFrom, R.PickupDateTo, R.CutOffDate, R.DeliveryDateFrom, R.DeliveryDateTo, R.ActualDeparture, R.ActualArrival, R.CreateDate, R.LastUpdateDate, R.DriverKey
		, R.SourceAddrKey, SA.AddrName AS SourceAddrName, SA.AddressLineCard AS SourceAddr, SA.City AS SourceAddrCity, SA.ZipCode AS SourceAddrZip, SA.State AS SourceAddrState, SA.AddressDetailCard AS SourceAddrCard
		, R.DestinationAddrKey, DA.AddrName AS DestinationAddrName, DA.AddressLineCard AS DestinationAddr, DA.City AS DestinationAddrCity, DA.ZipCode AS DestinationAddrZip, DA.State AS DestinationAddrState, DA.AddressDetailCard AS DestinationAddrCard
		, CASE WHEN OD.CurrentRouteKey = R.RouteKey THEN 'Yes' ELSE 'No' END AS IsCurrentRoute
		, CASE WHEN R.IsEmpty = 1 THEN 'Yes' ELSE 'No' END AS IsEmpty
		, CASE WHEN R.IsBobtail = 1 THEN 'Yes' ELSE 'No' END AS IsBobtail
		, CASE WHEN R.IsStreetTurn = 1 THEN 'Yes' ELSE 'No' END AS IsStreetTurn
		, CASE WHEN R.IsDryRun = 1 THEN 'Yes' ELSE 'No' END AS IsDryRun
		, UPDU.UserName AS UpdateUser

FROM Routes R WITH (NOLOCK)
LEFT JOIN RouteStatus RS WITH (NOLOCK) ON R.Status = RS.Status
LEFT JOIN Chassis C WITH (NOLOCK) ON R.ChassisKey = C.chassisKey
LEFT JOIN ChassisCategory CC WITH (NOLOCK) ON R.ChassisCategoryKey = CC.ChassisCategoryKey
LEFT JOIN ADR SA WITH (NOLOCK) ON R.SourceAddrKey = SA.AddrKey
LEFT JOIN ADR DA WITH (NOLOCK) ON R.DestinationAddrKey = DA.AddrKey
LEFT JOIN LEG L WITH (NOLOCK) ON R.LegKey = L.LegKey
LEFT JOIN [User] as UPDU WITH (NOLOCK) ON R.UpdateUserKey = UPDU.UserKey
LEFT JOIN 
(SELECT DISTINCT OrderDetailKey, CurrentRouteKey FROM OrderDetail WITH (NOLOCK) ) AS OD ON R.OrderDetailKey = OD.OrderDetailKey

LEFT JOIN Yard AS Y WITH (NOLOCK) ON 
			(	CASE WHEN L.FromLocation = 'Yard' THEN R.SourceAddrKey
 WHEN L.ToLocation = 'Yard' THEN R.DestinationAddrKey ELSE 0 END ) = Y.AddrKey


