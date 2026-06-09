




CREATE View [dbo].[vPrepayInvoiceStatement]
as
select 		od.CustID,
			od.CustName,			
			od.OrderNo,
			ContainerCount,
			od.City as DestinationCity,
			od.BrokerRefNo,
			PPInvoiceNo,			
			PPInvoiceDate,
			IH.PPInvoiceKey,
			IH.CustomerKey,
			GetDate() as DueDate,
			S.StatusKey,
			S.Description,
			case when IH.PPInvoiceAmount - isnull(P.PaidAmount,0)  =0 then 0 
				else 
					DATEDIFF(DD, IH.PPInvoiceDate, GETDATE()) 
			end as OverDueDays, 
			IH.PPInvoiceAmount,	
			Case When isnull(P.PaidAmount,0) >=0 Then isnull(P.PaidAmount,0) Else 0 End as Payments,
			Case When isnull(P.PaidAmount,0) <0 Then isnull(P.PaidAmount,0) Else 0 End as Credit,
			IH.PPInvoiceAmount - isnull(P.PaidAmount,0) as Balance,
			'PrePay' as InvoiceType,
			X.Containers, OD.CsrKey, OD.CsrName, OD.CompleteDate, IH.CreatedUserKey,
			BookingNo,
			null as InvoiceCompanyKey
	from PrepayInvoiceHeader IH WITH (NOLOCK) 
	inner join (
			Select distinct ID.PPInvoiceKey, IH.OrderNo, C.CustID, C.CustName, c.CustKey,
			A.City, '' as BrokerRefNo,S.CsrKey, S.CsrName, NULL AS COMPLETEDATE,
			count(Distinct ContainerNo) as ContainerCount,
			ISNULL(OH.BookingNo,'') as BookingNo
			from PrepayInvoiceDetail ID  WITH (NOLOCK) 
			Inner Join PrepayInvoiceHeader IH WITH (NOLOCK) on ID.PPInvoiceKey = IH.PPInvoiceKey
			inner join Customer C WITH (NOLOCK)  on IH.CustomerKey = C.CustKey
			LEFT join Address A WITH (NOLOCK)  on C.AddrKey = A.AddrKey
			LEFT JOIN OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
			LEFT join CSR S WITH (NOLOCK) ON oh.CsrKey = S.CsrKey
			group by ID.PPInvoiceKey, IH.OrderNo, C.CustID, C.CustName, c.CustKey,A.City, S.CsrKey, S.CsrName, ISNULL(OH.BookingNo,'')
		) OD on IH.PPInvoiceKey = OD.PPInvoiceKey
	inner join InvoiceStatus S on IH.StatusKey = S.StatusKey
	Cross Apply(
			select stuff((Select distinct ',' + ContainerNo 
			from PrepayInvoiceDetail A WITH (NOLOCK)
			where A.PPInvoiceKey = OD.PPInvoiceKey
			FOR XML PATH ('')),1,1,'') as Containers
	) as X
	left outer join 
		(
			select InvoiceKey, sum(PaidAmount) as PaidAmount , InvoiceType 
			from InvoicePayment  WITH (NOLOCK) 
			group by InvoiceKey, InvoiceType
		) P on (IH.PPInvoiceKey = P.InvoiceKey and P.InvoiceType = 'P')
	--WHERE		(IH.StatusKey = 3)  
 
