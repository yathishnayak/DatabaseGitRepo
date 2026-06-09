
/*
DECLARE @UserKey INT , @JSOnString NVARCHAR(MAX)  , @Status BIT, @IntMessage NVARCHAR(MAX), @ExtMessage VARCHAR(1000), @IsDebug BIT ,
@Result1 VARCHAR(1000), @Result2 VARCHAR(1000), @Result3 VARCHAR(1000)

SET @UserKey = 714
SET @JSONString = '{"InvoiceNo":"21"}'
SET	@IsDebug  = 0

EXEC [Admin_invoicedetails] @UserKey,@JSOnString,@Status OUTPUT, @IntMessage OUTPUT, @ExtMessage OUTPUT, @Result1 OUTPUT, @Result2 OUTPUT
,@Result3 OUTPUT, @IsDebug

SELECT @Status,@IntMessage,@ExtMessage,@Result1,@Result2,@Result3
*/


CREATE PROCEDURE [dbo].[Admin_invoicedetails]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX)	= '',
	@Status			BIT				= 0		OUTPUT,
	--@IntMessage		NVARCHAR(MAX)	= ''	OUTPUT,
	--@ExtMessage		VARCHAR(1000)	= ''	OUTPUT,
	--@Result1		VARCHAR(1000)	= ''	OUTPUT,
	--@Result2		VARCHAR(1000)	= ''	OUTPUT,
	--@Result3		VARCHAR(1000)	= ''	OUTPUT,
	@Reason		NVARCHAR(100)=''  OUTPUT,
	@IsDebug		BIT				= 0
)
AS
BEGIN


	DECLARE 	@InvoiceNo	VARCHAR(1000)	= ''


		SELECT		@InvoiceNo = InvoiceNo 
		FROM		OPENJSON(@JSONString, '$')
				WITH (
						InvoiceNo	VARCHAR(1000)			'$.InvoiceNo'
					)


	SELECT InvoiceKey,OrderKey into #Invoicekey FROM InvoiceHeader WHERE InvoiceNo =@InvoiceNo

	--select * from #Invoicekey
	--select * from #InvoiceHeader

	SELECT DISTINCT ih.InvoiceKey, id.Qty, id.UnitPrice,id.OrderDetailKey,it.ItemID,it.InvoiceItemDesc,it.MasterItemKey,it.Description,MI.Description AS MDescription
	INTO #Invoice
	FROM #Invoicekey ih
	INNER JOIN InvoiceDetail id ON ih.InvoiceKey = id.InvoiceKey
	INNER JOIN Item it ON it.ItemKey = id.ItemKey
	LEFT JOIN Item MI WITH (NOLOCK) ON MI.ItemKey=IT.MasterItemKey;

	--select * from #Invoice

	SELECT DISTINCT OrderDetailKey,InvoiceKey INTO #OrderdetailList FROM #Invoice;
	
		SELECT DISTINCT 
		od.ContainerNo, 
		oh.OrderNo, 
		oh.OrderDate, 
		od.PickupDate, 
		od.OrderDetailKey, 
		nt.InvoiceKey,
		ad.Address1 AS SourceAddress1, 
		ad.Address2 AS SourceAddress2, 
		ad.AddrName AS SourceAddrName, 
		ad.City AS SourceCity, 
		ad.ZipCode AS SourceZipCode, 
		ar.Address1 AS DestinationAddress1, 
		ar.Address2 AS DestinationAddress2
		INTO #orderlist
		FROM #OrderdetailList nt
		INNER JOIN OrderDetail od ON nt.OrderDetailKey = od.OrderDetailKey
		INNER JOIN OrderHeader oh ON oh.OrderKey = od.OrderKey
		INNER JOIN Address ad ON od.SourceAddrKey = ad.AddrKey 
		INNER JOIN Address ar ON od.DestinationAddrKey = ar.AddrKey;
	
	--select * from #orderlist
	
	SELECT DISTINCT ic.ContainerNo, ih.InvoiceNo
	INTO  #invoicecontainer
	FROM #orderlist ic
	LEFT JOIN OrderDetail od ON od.OrderDetailKey = ic.OrderDetailKey
	LEFT JOIN InvoiceHeader ih ON ic.InvoiceKey = ih.InvoiceKey;

	--select * from #orderlist;

	SELECT distinct RI.InvoiceKey 
	INTO #Routeinvoice
	FROM #orderlist RI
	left join #OrderdetailList Tb on Tb.OrderDetailKey = RI.OrderDetailKey

	--select * from #Routeinvoice

	
	BEGIN
		SELECT Invoice = (
			SELECT  * FROM #Invoice WITH (NOLOCK)
			For JSON PATH
			),
			OrderDetail=(
			SELECT  * FROM #orderlist WITH (NOLOCK)
			For JSON PATH
			),
			InvoiceContainers=(SELECT  * FROM #invoicecontainer WITH (NOLOCK)
			For JSON PATH
			),
			RouteInvoice=(SELECT  * FROM #Routeinvoice WITH (NOLOCK)
			For JSON PATH)
			FOR JSON PATH
	END		
	
	
	SET @Status = 1
	--SET @IntMessage = 'Success'
	--SET @ExtMessage = 'Success'
	SET @Reason='Success'

	DROP TABLE #Invoicekey
	DROP TABLE #Invoice
	DROP TABLE #orderlist
	DROP TABLE #invoicecontainer
	DROP TABLE #Routeinvoice
	DROP TABLE #OrderdetailList
End
