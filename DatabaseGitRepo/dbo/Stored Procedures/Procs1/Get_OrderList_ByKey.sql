/*
DECLARE @UserKey      INT=953,
	@JSONString   NVARCHAR(MAX)='{"OrderKeyList":"145029:145024:145011:144981:144980:144979:144977:144973:144966:144961:144943"}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = ''

	EXEC [Get_OrderList_ByKey] @UserKey,@JSONString,@Status output,@Reason output
	SELECT @Status, @Reason
	*/

CREATE PROCEDURE [dbo].[Get_OrderList_ByKey]
(
	@UserKey    INT = 0,
	@JSONString NVARCHAR(MAX) = '',
	@Status     BIT = 0 OUTPUT,
	@Reason     VARCHAR(1000) = '' OUTPUT

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

    DECLARE @OrderKeyList NVARCHAR(MAX);

    SELECT @OrderKeyList = OrderKeyList
    FROM OPENJSON(@JSONString)
    WITH (
        OrderKeyList NVARCHAR(MAX)			'$.OrderKeyList'
    );

    CREATE TABLE #OrderKeys
    (
        OrderKey INT
    );

    IF (ISNULL(@OrderKeyList, '') <> '')
    BEGIN
        INSERT INTO #OrderKeys (OrderKey)
        SELECT VALUE FROM dbo.Fn_SplitParamCol(@OrderKeyList);
    END
    ELSE
    BEGIN
        SET @Status = 0;
        SET @Reason = 'OrderKeyList is empty';
        RETURN;
    END;


    SELECT DISTINCT 
        OH.Orderkey AS OrderKey, 
        OH.Csrkey, CS.CsrName AS CSRName,
        OH.MarketLocationKey,M.MarketLocation,
        OH.OrderTypeKey, OT.OrderType AS OrderTypeDescription,
        OH.BrokerRefNo AS BrokerRefNo,
		OH.Billoflading AS BillOfLading,
        OH.Consignee,
        POS.StopAddrKey AS PickupAddKey, POS.StopName + ' - ' + PICKADD.Address1 AS PickupLocation,
		DOS.StopAddrKey AS DeliveryAddrKey,DOS.StopName + ' - ' + DELADD.Address1 AS DeliveryLocation,
        CT.Properties AS Properties
    FROM OrderHeader OH
    LEFT JOIN CSR CS ON OH.CsrKey = CS.CsrKey
    LEFT JOIN MarketLocation M ON M.MarketLocationKey = OH.MarketLocationKey 
    LEFT JOIN OrderType OT ON OT.OrderTypeKey = OH.OrderTypeKey
    LEFT JOIN OrderStops POS ON POS.OrderKey = OH.OrderKey AND POS.StopTypeKey = 1
    LEFT JOIN OrderStops DOS ON DOS.OrderKey = OH.OrderKey AND DOS.StopTypeKey = 3
    LEFT JOIN [Address] PICKADD ON PICKADD.AddrKey = POS.StopAddrKey
    LEFT JOIN [Address] DELADD ON DELADD.AddrKey = DOS.StopAddrKey
    LEFT JOIN vContainerTypeByOrder CT ON CT.OrderKey = OH.OrderKey 
    WHERE OH.OrderKey IN (SELECT OrderKey FROM #OrderKeys)
	FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';
END;
