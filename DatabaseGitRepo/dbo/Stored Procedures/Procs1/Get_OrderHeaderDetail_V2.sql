/**

DECLARE 
	@UserKey        INT             = 714,
	@JSONString     NVARCHAR(MAX)   = '{"OrderKey":185589}',
	@Status         BIT             = 0,  
    @IsDebug        BIT             = 0,
	@Reason         VARCHAR(100)    = ''
EXEC [Get_OrderHeaderDetail_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @Status, @Reason

**/
CREATE PROCEDURE [dbo].[Get_OrderHeaderDetail_V2]  
(    
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0  
)
AS  
BEGIN  
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    -- Input validation
    IF @JSONString IS NULL OR @JSONString = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'JSONString parameter is required';
        RETURN;
    END
    
    BEGIN TRY
        DECLARE @OrderKey INT = 0;

        -- Parse JSON input with error handling
        SELECT @OrderKey = ISNULL(OrderKey, 0)
        FROM OPENJSON(@JSONString)
        WITH (OrderKey INT '$.OrderKey');
        
        IF @OrderKey = 0
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Invalid or missing OrderKey in JSON';
            RETURN;
        END
      
        -- Execute helper procedure
        EXEC Insert_OrderDetailStops_ByOrderKey @OrderKey;
      
        -- Main query with optimized address lookups
        SELECT  
            OH.OrderNo,
            OH.OrderDate,
            OH.CustKey,
            OH.BillToAddrKey,  
            CUS.CustName AS BillToAddr,
            OH.SourceAddrKey, 
            SR.AddrName AS SourceAddr,  
            OH.DestinationAddrKey,
            DT.AddrName AS DestinationAddr,
            OH.ReturnAddrKey,   
            OH.OrderTypeKey,
            OH.PriorityKey,
            OH.[Status],    
            HR.[Description] AS HoldReason,  
            OH.HoldDate,  
            BR.BrokerName,  
            BR.BrokerKey,  
            BR.BrokerID,  
            OH.BrokerRefNo,  
            OH.Ach_Enabled,  
            OH.Ach_Amount,  
            OH.PortoForiginKey,  
            OH.CarrierKey,  
            OH.VesselName,  
            OH.BillOfLading,  
            OH.BookingNo,  
            NULL AS CutOffDate,    
            OH.CreateDate,  
            OH.CreateUserKey,  
            OH.OrderKey,   
            OS.StatusName AS StatusDescription,  
            '' AS CommentDesc,  
            OT.OrderType AS OrderTypeDescription,  
            OH.CsrKey,
            OH.CSRManagerKey,
            OH.ETADate,  
            OH.BaseRateAmount,  
            OH.SalesPersonKey,  
            OH.ReleaseNo,   
            OH.MarketLocationKey,  
            OH.Consignee,  
            ISNULL(CC.ConsigneeKey,0) ConsigneeKey,
            OH.SteamShipLinekey as SteamShipLineKey,  
            OH.DropLive AS DropOrLive,  
            SenderInfo,
            -- Optimized address JSON generation
            BillAddr.AddressJSON AS BillToAddress,
            SrcAddr.AddressJSON AS SourceAddress,
            DestAddr.AddressJSON AS DestinationAddress,
            RetAddr.AddressJSON AS ReturnAddress
        FROM dbo.OrderHeader OH
            LEFT JOIN dbo.Customer CUS ON CUS.CustKey = OH.CustKey
            LEFT JOIN dbo.Customer_Consignee CC ON CC.ConsigneeKey = OH.ConsigneeKey
            LEFT JOIN dbo.[Broker] BR ON OH.brokerkey = BR.brokerkey  
            LEFT JOIN dbo.OrderType OT ON OH.OrderTypekey = OT.OrderTypeKey     
            LEFT JOIN dbo.[Status] OS ON OS.StatusKey = OH.[Status]   
            LEFT JOIN dbo.Holdreason HR ON HR.HoldReasonKey = OH.HoldReasonKey  
            LEFT JOIN SteamShipLine SL ON SL.LineKey = OH.SteamShipLinekey
            -- Address name lookups (keeping for backward compatibility)
            LEFT JOIN dbo.[Address] SR ON SR.AddrKey = OH.SourceAddrKey  
            LEFT JOIN dbo.[Address] DT ON DT.AddrKey = OH.DestinationAddrKey  
            -- Optimized address JSON lookups
            OUTER APPLY (
                SELECT JSON_QUERY((
                    SELECT AddrKey, AddrName, Address1, Address2, City, CityKey, [State], 
                           ZipCode AS Zip, Country, Website, Phone, Phone2, Email, Email2, Fax
                    FROM dbo.[Address] 
                    WHERE AddrKey = OH.BillToAddrKey
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS AddressJSON
            ) BillAddr
            OUTER APPLY (
                SELECT JSON_QUERY((
                    SELECT AddrKey, AddrName, Address1, Address2, City, CityKey, [State], 
                           ZipCode AS Zip, Country, Website, Phone, Phone2, Email, Email2, Fax
                    FROM dbo.[Address] 
                    WHERE AddrKey = OH.SourceAddrKey
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS AddressJSON
            ) SrcAddr
            OUTER APPLY (
                SELECT JSON_QUERY((
                    SELECT AddrKey, AddrName, Address1, Address2, City, CityKey, [State], 
                           ZipCode AS Zip, Country, Website, Phone, Phone2, Email, Email2, Fax
                    FROM dbo.[Address] 
                    WHERE AddrKey = OH.DestinationAddrKey
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS AddressJSON
            ) DestAddr
            OUTER APPLY (
                SELECT JSON_QUERY((
                    SELECT AddrKey, AddrName, Address1, Address2, City, CityKey, [State], 
                           ZipCode AS Zip, Country, Website, Phone, Phone2, Email, Email2, Fax
                    FROM dbo.[Address] 
                    WHERE AddrKey = OH.ReturnAddrKey
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )) AS AddressJSON
            ) RetAddr
        WHERE OH.OrderKey = @OrderKey
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'No records found for OrderKey: ' + CAST(@OrderKey AS VARCHAR(10));
            RETURN;
        END

        SET @Status = 1;
        SET @Reason = 'Success';
        
    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = 'Error: ' + ERROR_MESSAGE();
        
        IF @IsDebug = 1
        BEGIN
            SET @Reason = @Reason + ' | Line: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + 
                         ' | Procedure: ' + ERROR_PROCEDURE();
        END
    END CATCH
END
