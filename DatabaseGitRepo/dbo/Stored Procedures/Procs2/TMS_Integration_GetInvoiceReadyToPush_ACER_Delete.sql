

CREATE proc [dbo].[TMS_Integration_GetInvoiceReadyToPush_ACER_Delete] -- TMS_Integration_GetInvoiceReadyToPush_ACER_Delete 'ACER', 3165
(
	@SiteID		varchar(20),
	@CustKey	int
)
as
set nocount on
set fmtonly off

CREATE TABLE #InvoiceHeader
(
	InvoiceNo		VARCHAR(50),
	CustKey			INT,
	InvoiceKey		INT,
	InvoiceDate		DATETIME,
	InvoiceAmount	DECIMAL(18,2),
	StatusKey		INT,
	IsManual		BIT
)



INSERT INTO #InvoiceHeader 
			(InvoiceNo, CustKey, InvoiceKey, InvoiceDate, InvoiceAmount, StatusKey, IsManual)
SELECT		InvoiceNo, CustKey, InvoiceKey, InvoiceDate, InvoiceAmount, StatusKey, 0
FROM		InvoiceHeader;


INSERT INTO #InvoiceHeader 
			(InvoiceNo, CustKey, InvoiceKey, InvoiceDate, InvoiceAmount, StatusKey, IsManual)
SELECT		MInvoiceNo, CustomerKey, MInvoiceKey, MInvoiceDate, MInvoiceAmount, StatusKey, 1
FROM		ManualInvoiceHeader
WHERE		MInvoiceNo IN ('M-110447');

SELECT		ItemKey,InvoiceKey, OrderDetailKey,UnitPrice,ExtAmt,BvsNB,Qty INTO #Invoicedetail FROM Invoicedetail

INSERT INTO #Invoicedetail
SELECT		ItemKey,MInvoiceKey, OrderDetailKey,UnitPrice,ExtCost,0 BvsNB,Quantity   
FROM		ManualInvoiceDetail ID
INNER JOIn	OrderDetail OD ON ID.ContainerNo = OD.ContainerNo
INNER JOIN	#InvoiceHeader IH ON ID.MInvoiceKey = IH.InvoiceKey
WHERE		IsManual = 1


select @CustKey = CustKey from Customer where CustID = 'ACER'
select IH.InvoiceKey, COUNT(1) as NoEDICount
into #NoEDICount
		from (SELECT * FROM #Invoicedetail ) ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		inner join #InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
		where CustKey = @CustKey  and isnull(I.EDICode,'') = ''
group by IH.InvoiceKey

-- SELECT * FROM #NoEDICount

select distinct OrderNo, OH.OrderNo as WorkOrdernumber , InvoiceNo, InvoiceDate, InvoiceAmount, Ih.InvoiceKey,TH.SiteID ,
	OH.OrderKey,TH.DataKey DataKey, OD.OrderDetailKey, OD.ContainerNo,  TC.ContainerKey ,
	ItemDetails = (
		select  I.ItemKey, I.ItemID, I.Description, I.EDICode,
		sum(ID.Qty) as Qty, max(ID.UnitPrice) as UnitPrice, sum(ID.ExtAmt) as ExtAmt
		from #Invoicedetail ID --on OD.OrderDetailKey = ID.OrderDetailKey
		inner join Item I on ID.ItemKey = I.ItemKey
		where OD.OrderDetailKey = ID.OrderDetailKey   AND ISNULL(ID.BvsNB,0) = 1
		group by  I.ItemKey, I.ItemID, I.Description, I.EDICode
		FOR JSON PATH
	),
	ItemWOEDICodeCount = nec.NoEDICount
from  (SELECT * FROM OrderHeader  ) OH 
inner join OrderDetail OD on OH.OrderKey = OD.OrderKey
inner join #Invoicedetail ID on OD.OrderDetailKey = ID.OrderDetailKey
inner join #InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey  AND TH.SiteID = 'ACER'
inner join TMS_Integration_Container TC on TH.DataKey = TC.DataKey and OD.ContainerNo = TC.ContainerNo    AND TC.SiteID = TH.SiteID 
--Left join TMS_Integration_Invoice TI on TI.SiteID = @SiteID and IH.InvoiceKey = TI.InvoiceKey
LEFT JOIN (SELECT DataKey,InvoiceKey FROM Integration_JCB.dbo.ACER_InvoiceHeader) AIH on TH.DataKey = AIH.DataKey and IH.InvoiceKey = AIH.InvoiceKey
left join #NoEDICount NEC on IH.InvoiceKey = NEC.InvoiceKey
where OH.CustKey = @CustKey  and IH.StatusKey >= 2   and isnull(NEC.NoEDICount,0) = 0   AND AIH.DataKey IS NULL --  AND 1 = 2
FOR JSON PATH

DROP TABLE #Invoicedetail
DROP TABLE #InvoiceHeader
DROP TABLE #NoEDICount
