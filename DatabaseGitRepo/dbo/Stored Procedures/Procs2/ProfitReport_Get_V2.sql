/**

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustKey": 3241, "InvDateFrom": "2024-12-31T18:30:00.000Z", "InvDateTo": "2025-12-31T18:30:00.000Z"}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [ProfitReport_Get_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status Status, @Reason Reason

****************************************
{
  "userKey": 1,
  "jsonString": "{\"CustKey\": 3241, \"InvDateFrom\": \"2024-12-31T18:30:00.000Z\", \"InvDateTo\": \"2025-12-31T18:30:00.000Z\"}",
  "status": true,
  "reason": "",
  "fileName": null,
  "procName": "",
  "outputType": "pdf"
}
**/

CREATE PROCEDURE [dbo].[ProfitReport_Get_V2]
(
    @UserKey    INT             = 714,
    @JSONString NVARCHAR(MAX)   = '',
    @Status     BIT             = 0 OUTPUT,
    @Reason     VARCHAR(1000)   = '' OUTPUT,
    @IsDebug    BIT             = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @CustKey        INT          = 0,
        @InvDateFrom    DATE         = '2020-01-01',
        @InvDateTo      DATE         = '2050-12-31';

    ------------------------------------------------------------------
    -- Parse JSON input
    ------------------------------------------------------------------
    SELECT 
        @CustKey     = ISNULL(CustKey, 0),
        @InvDateFrom = ISNULL(InvDateFrom, @InvDateFrom),
        @InvDateTo   = ISNULL(InvDateTo,   @InvDateTo)
    FROM OPENJSON(@JSONString)
    WITH
    (
        CustKey      INT       '$.CustKey',
        InvDateFrom  DATETIME  '$.InvDateFrom',
        InvDateTo    DATETIME  '$.InvDateTo'
    );

    ------------------------------------------------------------------
    -- Invoices temp table
    ------------------------------------------------------------------
    SELECT 
        IH.InvoiceKey,
        ID.OrderDetailKey,
        R.RouteKey,
        SUM(ISNULL(ID.ExtAmt, 0)) AS ODInvAmt
    INTO #Invoices
    FROM dbo.InvoiceHeader IH WITH (NOLOCK)
    INNER JOIN dbo.InvoiceDetail ID WITH (NOLOCK) 
        ON IH.InvoiceKey    = ID.InvoiceKey
    INNER JOIN dbo.Routes R WITH (NOLOCK) 
        ON ID.OrderDetailKey = R.OrderDetailKey
    WHERE IH.CustKey = @CustKey
      AND IH.InvoiceDate >= @InvDateFrom
      AND IH.InvoiceDate <  DATEADD(DAY, 1, @InvDateTo)
    GROUP BY 
        IH.InvoiceKey, 
        ID.OrderDetailKey, 
        R.RouteKey;

    ------------------------------------------------------------------
    -- Driver pay temp table
    ------------------------------------------------------------------
    SELECT  
        OD.OrderDetailKey,
        VH.VoucherKey,
        VH.VoucherNo,
        VH.VoucherDate,
        VH.VoucherAmount,
        R.RouteKey,
        SUM(ISNULL(vd.ExtCost, 0)) AS ContVouchAmt
    INTO #DRIVERPAY
    FROM dbo.OrderDetail OD WITH (NOLOCK)
    INNER JOIN dbo.Routes R WITH (NOLOCK) 
        ON R.OrderDetailKey = OD.OrderDetailKey
    INNER JOIN dbo.VoucherDetail vd WITH (NOLOCK) 
        ON vd.RouteKey = R.RouteKey
    INNER JOIN dbo.VoucherHeader VH WITH (NOLOCK) 
        ON VH.VoucherKey = vd.VoucherKey
    INNER JOIN #Invoices I WITH (NOLOCK) 
        ON OD.OrderDetailKey = I.OrderDetailKey 
       AND R.RouteKey       = I.RouteKey
    GROUP BY 
        OD.OrderDetailKey,
        VH.VoucherKey,
        VH.VoucherNo,
        VH.VoucherDate,
        VH.VoucherAmount,
        R.RouteKey;

    ------------------------------------------------------------------
    -- Final JSON result
    ------------------------------------------------------------------
    SELECT 
        IH.InvoiceKey,
        IH.InvoiceNo,
        IH.InvoiceDate,
        IH.InvoiceAmount,
        I.ODInvAmt               AS ContInvoiceAmt,
        DP.VoucherKey,
        DP.VoucherNo,
        DP.VoucherDate,
        DP.VoucherAmount,
        OD.OrderDetailKey,
        OD.ContainerNo,
        C.CustID,
        C.CustName,
        C.CustKey,
        ISNULL(I.ODInvAmt, 0) - ISNULL(DP.VoucherAmount, 0) AS GrossProfit
    FROM dbo.InvoiceHeader IH WITH (NOLOCK)
    INNER JOIN #Invoices I 
        ON IH.InvoiceKey = I.InvoiceKey
    LEFT JOIN #DRIVERPAY DP 
        ON I.OrderDetailKey = DP.OrderDetailKey
       AND I.RouteKey       = DP.RouteKey
    LEFT JOIN dbo.OrderDetail OD WITH (NOLOCK) 
        ON I.OrderDetailKey = OD.OrderDetailKey
    LEFT JOIN dbo.Customer C WITH (NOLOCK)  
        ON IH.CustKey = C.CustKey
    FOR JSON PATH;

    SET @Status = 1;
    SET @Reason = 'Success';

    DROP TABLE #Invoices;
    DROP TABLE #DRIVERPAY;
END;