/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"InvoiceKey":161033}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_InvoiceDetailByKey_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_InvoiceDetailByKey_V2]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	DECLARE @ExpenseAmt DECIMAL(18,2),
	@InvoiceKey  INT

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	select @InvoiceKey = InvoiceKey
	from OpenJSON(@JsonString, '$')
	WITH (
		InvoiceKey				INT				'$.InvoiceKey'
	)

	SELECT DISTINCT  
	I.ItemKey, I.ItemID,
	--ID.[Description],
	CASE WHEN I.ItemKey=24 ThEn 'Empty STop Off' ELSE ID.[Description] END AS [Description],
	ID.Qty,ID.UnitPrice,ID.ExtAmt,ID.Invoicelinekey,IH.InvoiceKey,IH.CustKey,
	ID.OrderDetailKey	,ltrim(rtrim(IC.ContainerNo)) as Container	, I.InvoiceItemDesc as InvoiceDescription, 
	convert(bit,0) IsNewInvoiceline,ID.BvsNB, ID.FreeTime, ID.Minval, ID.MaxVal,
	PB.PriceBasisKey, pb.PriceBasisID, InvoiceCompanyKey, TimeDuration, ISNULL(CI.ChargeCode,'') CustomerChargeCode, 
	ISNULL(CI.ChargeDescription,ID.[Description]) ChargeDescription, CAST(0 AS INT) FreeQty, CAST(0 AS INT) TotalQty,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(ISNULL(ShowCustomerItemDesc,0) AS BIT) ELSE CAST(0 AS BIT) END AS ShowCustomerItemDesc,
	CASE WHEN IH.CustKey IN (SELECT DISTINCT MasterCustomerKey FROM CustomerItem) THEN CAST(ISNULL(ShowChargeCode,0) AS BIT) ELSE CAST(0 AS BIT) END AS ShowChargeCode,
	CASE WHEN M.ItemKey=24  THEN'Empty Stop Off' ELSE M.Description END  as MDescription
	--M.Description END  as MDescription
	FROM 
		dbo.Invoicedetail ID WITH(NOLOCK)	
		LEFT JOIN InvoiceContainers IC WITH (NOLOCK) ON IC.InvoiceKey=ID.InvoiceKey and ID.OrderDetailKey  =  IC.OrderDetailsKey
		JOIN dbo.InvoiceHeader IH WITH(NOLOCK)	ON IH.InvoiceKey = ID.InvoiceKey
		--JOIN  dbo.RouteInvoice RI	ON RI.InvoiceKey = IH.InvoiceKey
		JOIN dbo.Item I	WITH(NOLOCK) ON I.ItemKey=ID.ItemKey
		LEft join dbo.item M WITH(NOLOCK) ON I.MasterItemKey = M.ItemKey
		LEFT JOIN dbo.ItemPriceBasis PB WITH (NOLOCK) ON I.PriceBasisKey = PB.PriceBasisKey
		LEFT JOIN dbo.CustomerItem CI WITH (NOLOCK) ON ISNULL(CI.MasterItemKey,0)=I.ItemKEy
	WHERE ID.InvoiceKey = @InvoiceKey and ID.OrderDetailKey is not null 
	ORDER BY LTRIM(RTRIM(IC.ContainerNo)), I.ItemID
	FOR JSON PATH
	SEt @Status = 1
	SET @Reason = 'SUCCESS'
END