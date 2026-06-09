/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"OrderDetailKeys":"221397:211972:226148"}'
 
EXEC [Get_MassDeliveryOrderReport] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_MassDeliveryOrderReport]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @OrderDetailKeys	NVARCHAR(MAX)
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @OrderDetailKeys = ''
	END
	ELSE
	BEGIN
		SELECT @OrderDetailKeys =  OrderDetailKeys

		FROM OpenJSON(@JSONString, '$')
		WITH (
			OrderDetailKeys			NVARCHAR(MAX)				'$.OrderDetailKeys'
		)
	END

	-- Split OrderDetailKeys into table
	SELECT CAST([Value] AS INT) AS OrderDetailKey
    INTO #OrderDetailKeys
    FROM dbo.Fn_SplitParamCol(@OrderDetailKeys)
    WHERE ISNULL([Value], '') <> '';

	IF @IsDebug = 1
	BEGIN
		SELECT * FROM #OrderDetailKeys;
	END
 
	-- ================================
	-- Main Business Logic goes here
	-- ================================

	DECLARE @JSONResult NVARCHAR(MAX) = ''

	SET @JSONResult = (
		SELECT	OD.OrderDetailKey, CurrentRouteKey, OH.CreateDate, OH.OrderNo, D.DriverID + '-' + D.FirstName + ' ' + D.LastName AS CarrierName,
				R.DeliveryDateFrom, SA.AddrKey AS SourAddrKey, SA.AddrName AS SourAddrName, SA.Address1 AS SourAddress1, SA.City AS SourCity, 
				SA.State AS SourState, SA.ZipCode As SourZipCode, DA.Country AS SourCountry, DA.AddrKey AS DestAddrKey, DA.AddrName AS DestAddrName, 
				DA.Address1 AS DestAddress1, DA.City AS DestCity, DA.State AS DestState, DA.ZipCode AS DestZipCode, DA.Country AS DestCountry,
				ISNULL(R.DriverInstructions,OD.DriverNotes) DriverNotes, OD.ContainerNo, CS.[Description] AS ContainerSize, OD.SealNo, 
				OD.[Weight], WU.WeightUnit, ISNULL(OH.ReleaseNo,'NA') AS ReleaseNo, R.chassisNo, R.RouteKey,
				ContainerProperties = ISNULL(STUFF((
					SELECT ',' + TypeID
					FROM ContainerTypesLink CTLI
					INNER JOIN ContainerTypes CTI ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
					WHERE CTLI.OrderDetailKey = ODK.OrderDetailkey
					FOR XML PATH('')
				), 1, 1, ''),''),
				HazardClasses = ISNULL(STUFF((
					SELECT ',' + Description
					FROM HazardClassesLink HCL
					INNER JOIN Container_HazardClasses CHC ON CHC.ClassKey=HCL.ClassKey
					WHERE HCL.OrderDetailKey = ODK.OrderDetailkey
					ORDER BY Description
					FOR XML PATH('')
				), 1, 1, ''),'')
					
			    FROM OrderDetail OD			 WITH (NOLOCK) 
				INNER JOIN OrderHeader OH	 WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey 				 		
				INNER JOIN [Routes] R		 WITH (NOLOCK) ON  OD.OrderDetailKey = R.OrderDetailKey
				LEFT JOIN  ContainerSize CS  WITH (NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey
				LEFT JOIN  [Address] SA		 WITH (NOLOCK) ON SA.AddrKey = R.SourceAddrKey
				LEFT JOIN  [Address] DA		 WITH (NOLOCK) ON DA.AddrKey = R.DestinationAddrKey		
				LEFT JOIN  Driver D			 WITH (NOLOCK) ON D.DriverKey = R.DriverKey
				LEFT JOIN  WeighUnit WU      WITH (NOLOCK) ON WU.WeightUnitKey = OD.WeightUnit
				INNER JOIN #OrderDetailKeys ODK ON ODK.OrderDetailKey = OD.OrderDetailKey
		FOR JSON PATH
	);
 
	SELECT @JSONResult AS JSONResult

	SET @Status = 1;
	SET @Reason = 'Success';

END