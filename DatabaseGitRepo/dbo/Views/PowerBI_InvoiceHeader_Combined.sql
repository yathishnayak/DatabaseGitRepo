



CREATE VIEW [dbo].[PowerBI_InvoiceHeader_Combined]
AS

SELECT ID.*, S.Description AS InvoiceStatus, C.CustID, C.CustName, C.CustomerGroup, 
		CASE	WHEN C.IsFactored=0 THEN 'No' 
				WHEN C.IsFactored=1 THEN 'Yes' ELSE NULL
		END AS Factored,
		SP.SalesPersonName, CSR.CsrName AS CSR, PT.PaymentTermsID, PT.Description AS 'Pmt Terms Dec' , PT.Days AS 'Pmt Terms Days'
			, OH.SourceAddrKey, SA.AddrName AS SourceAddrName, SA.State AS SourceAddrState, SA.City AS SourceAddrCity, SA.ZipCode AS SourceAddrZip
			, OH.DestinationAddrKey, DA.AddrName AS DestinationAddrName, DA.State AS DestinationAddrState, DA.City AS DestinationAddrCity, DA.ZipCode AS DestinationAddrZip
			, OH.BillToAddrKey, BA.AddrName AS BillToAddrName, BA.State AS BillToAddrState, BA.City AS BillToAddrCity, BA.ZipCode AS BillToAddrZip
			
FROM
(
SELECT	I.InvoiceKey, NULL AS MInvoiceKey, NULL AS PPInvoiceKey, I.InvoiceNo, I.InvoiceDate, I.DueDate, I.CreateDate, I.InvoiceApprovedDate, I.UpdateDate, SUM(ID.Volume) AS InvoiceVolume
		, 'I' AS InvoiceType, 'Invoice' AS 'Invoice Type Desc', CONCAT('I-', I.InvoiceKey) AS 'InvoiceType+Key'
		, I.CustKey	, I.InvoiceAmount, I.StatusKey, I.OrderKey, O.OrderNo, O.OrderDate
		, I.CustomerNote, I.InternalNote, I.BrokerRefNo, USRC.UserName AS InvoiceCreateUser, USRA.UserName AS InvoiceApprovedUser, IRC.ReasonCode AS InvoiceReasonCode
FROM InvoiceHeader I WITH (NOLOCK)
LEFT JOIN (SELECT DISTINCT OrderKey, OrderNo, OrderDate FROM OrderHeader WITH (NOLOCK)) O ON I.OrderKey = O.OrderKey
LEFT JOIN 
		(	SELECT ID.InvoiceKey, COUNT(DISTINCT ID.Container) AS Volume
			FROM Invoicedetail ID WITH (NOLOCK)
			GROUP BY ID.InvoiceKey ) AS ID ON I.InvoiceKey = ID.InvoiceKey
LEFT JOIN [User] USRC WITH (NOLOCK) ON I.CreateUserKey = USRC.UserKey
LEFT JOIN [User] USRA WITH (NOLOCK) ON I.InvoiceApprovedUserKey = USRA.UserKey
LEFT JOIN InvoiceReasonCode IRC WITH (NOLOCK) ON I.ReasoncodeKey = IRC.ReasoncodeKey
where I.InvoiceKey  not in (134684, 136005,136330,139782, 143588, 147042, 148171)

GROUP BY I.InvoiceKey, I.InvoiceNo, I.InvoiceDate, I.DueDate, I.CreateDate, I.InvoiceApprovedDate, I.UpdateDate
		, I.CustKey	, I.InvoiceAmount, I.StatusKey, I.OrderKey, O.OrderNo, O.OrderDate
		, I.CustomerNote, I.InternalNote, I.BrokerRefNo, USRC.UserName, USRA.UserName, IRC.ReasonCode


UNION ALL

SELECT NULL AS InvoiceKey, M.MInvoiceKey, NULL AS PPInvoiceKey, M.MInvoiceNo AS InvoiceNo, M.MInvoiceDate AS InvoiceDate, DATEADD(DAY,PT.Days, M.MInvoiceDate) AS DueDate, M.CreatedDate, M.MInvoiceConfirmDate, M.UpdateDate, SUM(IMD.Volume) AS InvoiceVolume

		, 'M' AS InvoiceType, 'Manual Invoice' AS 'Invoice Type Desc', CONCAT('M-', M.MInvoiceKey) AS 'InvoiceType+Key'
		, M.CustomerKey AS CustKey, M.MInvoiceAmount AS InvoiceAmount, M.StatusKey, NULL AS OrderKey, M.OrderNo, NULL AS OrderDate
		, M.CustomerNotes AS CustomerNote, M.InternalNotes AS InternalNote, M.BrokerRef AS BrokerRefNo, USRC.UserName AS InvoiceCreateUser, USRC.UserName AS InvoiceApprovedUser, NULL AS InvoiceReasonCode
FROM ManualInvoiceHeader M WITH (NOLOCK)
LEFT JOIN Customer C WITH (NOLOCK) ON M.CustomerKey = C.CustKey
LEFT JOIN PaymentTerms PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
LEFT JOIN 
		(	SELECT IMD.MInvoiceKey, COUNT(DISTINCT IMD.ContainerNo) AS Volume
			FROM ManualInvoiceDetail IMD WITH (NOLOCK)
			GROUP BY IMD.MInvoiceKey ) AS IMD ON M.MInvoiceKey = IMD.MInvoiceKey
LEFT JOIN [User] USRC WITH (NOLOCK) ON M.CreatedUserKey = USRC.UserKey
GROUP BY M.MInvoiceKey, M.MInvoiceNo, M.MInvoiceDate, M.CreatedDate, M.MInvoiceConfirmDate, M.UpdateDate, PT.Days
		, M.CustomerKey, M.MInvoiceAmount, M.StatusKey, M.OrderNo
		, M.CustomerNotes, M.InternalNotes, M.BrokerRef, USRC.UserName


UNION ALL

SELECT NULL AS InvoiceKey, NULL AS MInvoiceKey, P.PPInvoiceKey, P.PPInvoiceNo AS InvoiceNo, P.PPInvoiceDate AS InvoiceDate, P.PPInvoiceDate AS DueDate, P.CreatedDate, P.PPInvoiceConfirmDate, P.UpdateDate, SUM(IPD.Volume) AS InvoiceVolume
		, 'P' AS InvoiceType, 'Prepay Invoice' AS 'Invoice Type Desc', CONCAT('P-', P.PPInvoiceKey) AS 'InvoiceType+Key'
		, P.CustomerKey AS CustKey, P.PPInvoiceAmount AS InvoiceAmount, P.StatusKey, P.OrderKey, P.OrderNo, O.OrderDate
		, P.CustomerNotes AS CustomerNote, P.InternalNotes AS InternalNote, O.BrokerRefNo AS BrokerRefNo, USRC.UserName AS InvoiceCreateUser, USRC.UserName AS InvoiceApprovedUser, NULL AS InvoiceReasonCode
FROM PrepayInvoiceHeader P WITH (NOLOCK)
LEFT JOIN (SELECT DISTINCT OrderKey, BrokerRefNo, OrderDate FROM OrderHeader WITH (NOLOCK)) O ON P.OrderKey = O.OrderKey
LEFT JOIN 
		(	SELECT IPD.PPInvoiceKey, COUNT(DISTINCT IPD.ContainerNo) AS Volume
			FROM PrepayInvoiceDetail  IPD WITH (NOLOCK)
			GROUP BY IPD.PPInvoiceKey ) AS IPD ON P.PPInvoiceKey = IPD.PPInvoiceKey
LEFT JOIN [User] USRC WITH (NOLOCK) ON P.CreatedUserKey = USRC.UserKey
GROUP BY P.PPInvoiceKey, P.PPInvoiceNo, P.PPInvoiceDate, P.PPInvoiceDate, P.CreatedDate, P.UpdateDate, P.PPInvoiceConfirmDate
		, P.CustomerKey, P.PPInvoiceAmount, P.StatusKey, P.OrderKey, P.OrderNo, O.OrderDate
		, P.CustomerNotes, P.InternalNotes, O.BrokerRefNo, USRC.UserName 

) AS ID

LEFT JOIN InvoiceStatus S WITH (NOLOCK) ON ID.StatusKey = S.StatusKey
LEFT JOIN Customer C WITH (NOLOCK) ON ID.CustKey = C.CustKey
LEFT JOIN SalesPerson SP WITH (NOLOCK) ON C.SalesPersonKey = SP.SalesPersonKey
LEFT JOIN CSR CSR WITH (NOLOCK) ON C.CsrKey = CSR.CsrKey
LEFT JOIN PaymentTerms PT WITH (NOLOCK) ON C.PaymentTermsKey = PT.PaymentTermsKey
LEFT JOIN OrderHeader OH WITH (NOLOCK) ON ID.OrderKey = OH.OrderKey
LEFT JOIN Address SA WITH (NOLOCK) ON OH.SourceAddrKey = SA.AddrKey
LEFT JOIN Address DA WITH (NOLOCK) ON OH.DestinationAddrKey = DA.AddrKey
LEFT JOIN Address BA WITH (NOLOCK) ON OH.BillToAddrKey = BA.AddrKey


