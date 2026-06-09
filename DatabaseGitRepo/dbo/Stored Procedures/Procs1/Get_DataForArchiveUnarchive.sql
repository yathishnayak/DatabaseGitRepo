CREATE PROCEDURE [dbo].[Get_DataForArchiveUnarchive]  -- Get_DataForArchiveUnarchive '','CCLU5146495'
	@InvoiceNo		VARCHAR(100)='',
	@ContainerNo	VARCHAR(20)=''
AS
BEGIN
	SELECT AI.*,OD.ContainerNo,OH.OrderNo, OH.BookingNo, OH.BrokerRefNo,C.CustName,M.MarketLocation, 
		CASE WHEN C.IsFactored=1 THEN 'Factored' WHEN C.IsFactored=0 THEN  'Non-Factored' ELSE 'N/A' END AS Factored ,A.AddrName
	FROM ArchivedInvoiceHistory AI
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=AI.OrderDetailKey
	INNER JOIN OrderHeader OH WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	LEFT JOIN MarketLocation M WITH (NOLOCK) ON M.MarketLocationKey=OH.MarketLocationKey
	INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=OH.DestinationAddrKey
	WHERE (invoiceno=@InvoiceNo OR ''=@InvoiceNo)
	AND (ContainerNo=@ContainerNo OR ''=@ContainerNo)

	UNION

	SELECT 0 as ArchivedKey,OH.OrderKey,ISNULL(IH.InvoiceKey,0),OD.OrderDetailKey,InvoiceNo,Od.Status,IH.StatusKey,'' as ArchivedDate,
		OD.ContainerNo,OH.OrderNo , OH.BookingNo, OH.BrokerRefNo, C.CustName,M.MarketLocation, 
		CASE WHEN C.IsFactored=1 THEN 'Factored' WHEN C.IsFactored=0 THEN  'Non-Factored' ELSE 'N/A' END  AS Factored,A.AddrName
	FROM OrderHeader OH 
	INNER JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
	LEFT JOIN InvoiceDetail ID WITH (NOLOCK) ON (ID.OrderDetailKey=OD.OrderDetailKey)
	LEFT JOIN InvoiceHeader IH WITH (NOLOCK) ON IH.InvoiceKey=ID.InvoiceKey
	INNER JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	LEFT JOIN MarketLocation M WITH (NOLOCK) ON M.MarketLocationKey=OH.MarketLocationKey
	INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=OH.DestinationAddrKey
	WHERE (invoiceno=@InvoiceNo OR ''=@InvoiceNo)
	AND (ContainerNo=@ContainerNo OR ''=@ContainerNo)
	AND OD.Status<>15
	FOR JSON PATH
END
