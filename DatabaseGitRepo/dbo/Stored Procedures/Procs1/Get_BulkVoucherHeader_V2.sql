/*
DECLARE 
    @UserKey    INT = 0,
    @JSONString NVARCHAR(MAX),
    @Status     BIT = 0,
    @Reason     NVARCHAR(500) = ''

SET @JSONString = '{"VoucherKeys": [299430, 299435, 299436]}'
 
EXEC dbo.Get_BulkVoucherHeader_V2 @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT
SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[Get_BulkVoucherHeader_V2]
(
    @UserKey    INT = 0,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     NVARCHAR(500) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- Initialize outputs
    SET @Status = 0;
    SET @Reason = '';

    BEGIN TRY
        -- Validate JSON input
        IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
        BEGIN
            SET @Reason = 'JSONString cannot be blank';
            RETURN;
        END

        IF ISJSON(@JSONString) = 0
        BEGIN
            SET @Reason = 'Invalid JSON format';
            RETURN;
        END

        -- Create temp table for voucher keys
        CREATE TABLE #VoucherKey (
            VoucherKey INT PRIMARY KEY
        );

        -- Parse JSON and populate temp table
        INSERT INTO #VoucherKey (VoucherKey)
        SELECT DISTINCT CAST(value AS INT)
        FROM OPENJSON(@JSONString, '$.VoucherKeys') 
        WHERE ISNUMERIC(value) = 1 AND CAST(value AS INT) > 0;

        -- Validate at least one voucher key was provided
        IF NOT EXISTS (SELECT 1 FROM #VoucherKey)
        BEGIN
            SET @Reason = 'No valid VoucherKeys provided in JSON';
            RETURN;
        END

        -- Get concatenated container numbers and order numbers
        DECLARE @ContainerNo NVARCHAR(MAX) = '',
                @OrderNo     NVARCHAR(MAX) = '';

        -- Return voucher header information
        SELECT VH.VoucherKey,
               VH.VoucherNo,
               VH.VoucherAmount,
               VH.DueDate, 
               VH.VoucherDate,
               VH.IsPaymentApproved, 
               VH.IsPaid, 
               0 AS RouteKey,
               BT.AddrName,
               BT.Address1,
               BT.City,
               BT.State,
               BT.ZipCode,
               BT.Country,
               ISNULL(@ContainerNo, '') AS ContainerNo,
               ISNULL(@OrderNo, '') AS OrderNo,
               VH.DriverNote, 
               VH.InternalNote
        FROM dbo.VoucherHeader VH 
        LEFT JOIN dbo.Address BT ON BT.AddrKey = VH.BillToAddrKey
        INNER JOIN #VoucherKey V ON VH.VoucherKey = V.VoucherKey
        ORDER BY VH.VoucherKey
            FOR JSON PATH;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END;