/**
DECLARE 
	@UserKey      INT=951,
	@JSONString   NVARCHAR(MAX)='{"OrderDetailKeyList": "176257"}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = ''

	EXEC [Get_SchedulerList_ByOrderDetailKey] @UserKey,@JSONString,@Status output,@Reason output
	SELECT @Status, @Reason
**/
CREATE procedure [dbo].[Get_SchedulerList_ByOrderDetailKey]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT = 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

    IF (ISNULL(LTRIM(RTRIM(@JSONString)), '') = '')
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Parameters not found';
        RETURN;
    END;

    DECLARE @OrderDetailKeyList NVARCHAR(MAX);

    SELECT @OrderDetailKeyList = OrderDetailKeyList
    FROM OPENJSON(@JSONString)
    WITH (
        OrderDetailKeyList NVARCHAR(MAX)		'$.OrderDetailKeyList'
    );

    CREATE TABLE #OrderDetailKeys
    (
        OrderDetailKey INT
    );

    IF (ISNULL(@OrderDetailKeyList, '') <> '')
    BEGIN
        INSERT INTO #OrderDetailKeys (OrderDetailKey)
        SELECT VALUE FROM dbo.Fn_SplitParamCol(@OrderDetailKeyList);
    END
    ELSE
    BEGIN
        SET @Status = 0;
        SET @Reason = 'OrderDetailKeys is empty';
        RETURN;
    END;

    SELECT DISTINCT 
        OD.Orderkey, OD.OrderDetailKey AS OrderDetailkey, OD.ContainerNo, OD.CSRKey, CS.CsrName,
		Stuff((SELECT ', ' + CAST(CTI.ShortCode AS VARCHAR)
		FROM ContainerTypesLink CTL WITH (NOLOCK)
		inner join ContainerTypes CTI WITH (NOLOCK) on CTL.ContainerTypeKey = CTI.ContainerTypeKey
		WHERE CTL.OrderDetailKey = OD.OrderDetailKey 
		FOR XML PATH('')),1,2,'') AS ContainerProps, 
		OD.Consignee, OD.Weight, OD.OrderTypeKey, OT.OrderType,
		OD.BookingNo, OD.CustRefNo AS BrokerRefNo,
		ISNULL(GD.Size_Type, OD.ContainerSizeKey) AS ContainerSizeKey,
		ISNULL(CS2.Description, CS1.Description) AS ContainerSize,
		OD.BillOfLadding AS BillOfLading,
		POS.StopName AS Source_AddrName,
		DOS.StopName AS Destination_AddrName,
		PA.City AS Source_City,
		DA.City AS Destination_City,
		PA.State AS Source_State,
		DA.State AS Destination_State,
		--POS.StopName + ' - ' + PA.Address1 AS PickupLocation,
		--DOS.StopName + ' - ' + DA.Address1 AS DeliveryLocation,	
		GD.Hold AS HoldStatus, GD.HoldType, GD.Vessel,
		--ISNULL(GD.ETA_ATA,OD.VesselETA) AS VesselETA,
		CONVERT(DATETIME, ISNULL(ISNULL(GD.ETA_ATA, OD.VesselETA), '1900-01-01')) AS VesselETA,
		GD.AvailableDate AS AvailableforPickupDate,
		CONVERT(DATETIME, ISNULL(ISNULL(GD.LFD, OD.LastFreeDay), '1900-01-01')) AS LastFreeDay
		--ISNULL(GD.LFD, OD.LastFreeDay) AS LFD
    FROM OrderDetail OD
		LEFT JOIN Container_GnosisData GD ON GD.OrderDetailKey = OD.OrderDetailKey
        LEFT JOIN CSR CS ON OD.CSRKey = CS.CsrKey 
        LEFT JOIN OrderType OT ON OT.OrderTypeKey = OD.OrderTypeKey
        LEFT JOIN OrderDetailStops POS ON POS.OrderdetailKey = OD.OrderdetailKey AND POS.StopTypeKey = 1
        LEFT JOIN OrderDetailStops DOS ON DOS.OrderdetailKey = OD.OrderdetailKey AND DOS.StopTypeKey = 3
        LEFT JOIN [Address] PA ON PA.AddrKey = POS.StopAddrKey
        LEFT JOIN [Address] DA ON DA.AddrKey = DOS.StopAddrKey
        LEFT JOIN vContainerTypeByOrder CT ON CT.OrderKey = OD.OrderKey 
		LEFT JOIN ContainerSize CS1 ON CS1.ContainerSizeKey = OD.ContainerSizeKey
		LEFT JOIN ContainerSize CS2 ON CS2.ContainerSizeKey = GD.Size_Type
    WHERE OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys)
	FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';
END;
