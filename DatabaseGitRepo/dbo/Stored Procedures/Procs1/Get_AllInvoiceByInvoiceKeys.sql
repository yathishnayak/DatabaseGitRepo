--24-25-28

CREATE PROCEDURE [dbo].[Get_AllInvoiceByInvoiceKeys]  -- [Get_AllInvoiceByInvoiceKeys]  '24:25:28'
/*
dbo.fn_getinvoicebyinvoicekey
*/
@InvoiceKeys  varchar(500)  -- Send Invoice Keys semicolon seperated
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	create table #InvoiceKey
	(
		InvoiceKey int
	)
	insert into #InvoiceKey 
	select value from dbo.Fn_SplitParamCol(@InvoiceKeys)

	Select
	IH.[InvoiceKey]
      ,[InvoiceNo]
      ,[InvoiceDate]
      ,IH.[CustKey]
	  ,C.CustName
	  ,C.CustID
      ,IH.[BillToAddrKey]
      ,[InvoiceAmount]
      ,[DueDate]
      ,[InvoiceType]
      ,IH.[CompanyKey]
      ,IH.[StatusKey]
      ,IH.[CreateUserKey]
      ,[IsInvoiceApproved]
      ,[IsPaymentReceived]
      ,IH.[CreateDate]
      ,[UpdateUserKey]
      ,[UpdateDate]
      ,[InvoiceApprovedUserKey]
      ,[InvoiceApprovedDate]
	  ,Container	  
	  ,SR.AddrName AS S_AddrName,SR.Address1 AS S_Address1,SR.City AS S_City,SR.[State] AS S_State,SR.ZipCode AS S_ZipCode,SR.Country AS S_Country
	  ,DT.AddrName AS D_AddrName,DT.Address1 AS D_Address1,DT.City AS D_City,DT.[State] AS D_State,DT.ZipCode AS D_ZipCode,DT.Country AS D_Country
	  ,BT.AddrName AS B_AddrName,BT.Address1 AS B_Address1,BT.City AS B_City,BT.[State] AS B_State,BT.ZipCode AS B_ZipCode,BT.Country AS B_Country
	  ,OH.OrderNo
	  ,IH.CustomerNote
	  ,IH.InternalNote
  FROM [dbo].[InvoiceHeader] IH 
	INNER JOIN
			(				
				SELECT STRING_AGG(Container + ':' + convert(varchar,OrderDetailKey) ,', ') AS Container,InvoiceKey
				FROM
				(
					SELECT DISTINCT Container, OrderDetailKey ,InvoiceKey FROM Invoicedetail
				) T GROUP BY InvoiceKey
			)INV ON INV.InvoiceKey=IH.InvoiceKey
	LEFT JOIN DBO.Customer C ON IH.CustKey = C.CustKey
	LEFT JOIN dbo.OrderHeader OH ON Oh.OrderKey=IH.OrderKey 
	LEFT JOIN [Address] SR	ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN [Address] DT	ON	DT.AddrKey=OH.DestinationAddrKey
	LEFT JOIN [Address] BT	ON	BT.AddrKey=IH.BillToAddrKey
	inner join #InvoiceKey B on ih.InvoiceKey = B.InvoiceKey
END

