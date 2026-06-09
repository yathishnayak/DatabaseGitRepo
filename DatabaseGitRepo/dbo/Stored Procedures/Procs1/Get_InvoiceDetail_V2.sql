/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"InvoiceKey" : 361}'
EXEC [Get_InvoiceDetail_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Get_InvoiceDetail_V2] -- [Get_InvoiceDetail] 361
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE 
		@InvoiceKey  INT=52

	SELECT 
		@InvoiceKey  =  InvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey		INT		'$.InvoiceKey'
	)


	SELECT 
		I.ItemID,
      --, ID.[Description]   ,
	  CASE WHEN I.ItemKey=24 THEN 'Empty Stop Off' else ID.[Description] END As [Description]
      , SUM(ID.[ExtAmt]) AS ExtAmt 
	  , I.InvoiceItemDesc,PriceBasisKey,TimeDuration, ISNULL(CI.ChargeCode,'') CustomerChargeCode, 
	ISNULL(CI.ChargeDescription,ID.[Description]) ChargeDescription, CAST(0 AS INT) FreeQty, CAST(0 AS INT) TotalQty,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem WITH (NOLOCK)) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc
  FROM [dbo].[Invoicedetail] ID WITH (NOLOCK) 
		JOIN dbo.InvoiceHeader IH WITH (NOLOCK)  ON IH.InvoiceKey =  ID.InvoiceKey
		--JOIN  dbo.RouteInvoice RI ON RI.InvoiceKey = IH.InvoiceKey
		JOIN dbo.Item I WITH (NOLOCK) ON I.Itemkey=ID.ItemKey
		LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
  WHERE id.InvoiceKey = @InvoiceKey and OrderDetailKey is not null
  GROUP BY I.ItemKey, I.ItemID, ID.[Description], I.InvoiceItemDesc,PriceBasisKey,TimeDuration,ChargeCode,ChargeDescription,I.[Description],IH.CustKey
  FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END
