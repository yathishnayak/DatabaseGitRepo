

CREATE PROCEDURE [dbo].[DA_GetChargeDataItems] -- DA_GetChargeDataItems 'Port'
(
	@FromLocation	VARCHAR(50) = '',
	@ToLocation		VARCHAR(50) = '',
	@RouteType		VARCHAR(20) = ''
)

AS

BEGIN
	DECLARE @WaitTImeKey INT = 0

	CREATE TABLE  #ChargeData
	(
		ChargeDesc		VARCHAR(50),
		ItemKey			INT,
		OrderBy			INT
	)

	

	IF((@FromLocation = 'Port' AND @RouteType = 'Pickup')  OR (@ToLocation = 'Port' AND @RouteType = 'Delivery'))
		BEGIN
			SET @WaitTImeKey = 5
		END
	ELSE IF((@FromLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Pickup')  
			OR (@ToLocation IN ('Consignee','Customer','Depot','Shipper') AND @RouteType = 'Delivery'))
		BEGIN
			SET @WaitTImeKey = 162
		END
	
	------ DO NOT DELETE--- When the data is loaded By RouteKey, the routeType will be Blank, so @WaitTImeKey is SET to 0
	IF(ISNULL(@WaitTImeKey,0) = 0)
		BEGIN
			SET @WaitTImeKey = 0
		END


	INSERT INTO #ChargeData
	VALUES('Stepdeck Damage',144,1),('Scale Ticket',113,2),('Chassis Split',139,3),('Genset',136,4),('Layover',87,5),('Placards',265,6),('Respot',170,7)
	,('Tarp/Un-Tarp',143,8),('Chain Strap',123,9),('Permit/Oversized',229,10),('Wait Time',@WaitTImeKey,11)

	SELECT	* FROM #ChargeData
END
