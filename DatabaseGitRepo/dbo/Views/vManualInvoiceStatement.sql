




CREATE View [dbo].[vManualInvoiceStatement]
as
select 		od.CustID,
			od.CustName,			
			od.OrderNo,
			ContainerCount,
			od.City as DestinationCity,
			isnull(IH.BrokerRef, od.BrokerRefNo) as BrokerRefNo,
			MInvoiceNo,			
			MInvoiceDate,
			IH.MInvoiceKey,
			IH.CustomerKey,
			GetDate() as DueDate,
			S.StatusKey,
			S.Description,
			case when IH.MInvoiceAmount - isnull(P.PaidAmount,0)  =0 then 0 
				else 
					DATEDIFF(DD, IH.MInvoiceDate, GETDATE()) 
			end as OverDueDays, 
			IH.MInvoiceAmount,	
			Case When isnull(P.PaidAmount,0) >=0 Then isnull(P.PaidAmount,0) Else 0 End as Payments,
			Case When isnull(P.PaidAmount,0) <0 Then isnull(P.PaidAmount,0) Else 0 End as Credit,
			IH.MInvoiceAmount - isnull(P.PaidAmount,0) as Balance,
			'Manual' as InvoiceType,
			X.Containers, OD.CsrKey, OD.CsrName, OD.CompleteDate, IH.CreatedUserKey,
			BookingNo,
			InvoiceCompanyKey
	from ManualInvoiceHeader IH WITH (NOLOCK) 
	inner join (
			Select distinct ID.MInvoiceKey, IH.OrderNo, C.CustID, C.CustName, c.CustKey,
			A.City, '' as BrokerRefNo,S.CsrKey, S.CsrName, NULL AS COMPLETEDATE,
			ISNULL(OH.BookingNo,'') as BookingNo,
			count(Distinct ContainerNo) as ContainerCount
			from ManualInvoiceDetail ID  WITH (NOLOCK) 
			Inner Join ManualInvoiceHeader IH WITH (NOLOCK) on ID.MInvoiceKey = IH.MInvoiceKey
			inner join Customer C WITH (NOLOCK)  on IH.CustomerKey = C.CustKey
			LEFT join Address A WITH (NOLOCK)  on C.AddrKey = A.AddrKey
			Left join OrderHeader OH with (NOLOCK) ON IH.OrderKey= OH.OrderKey
			LEFT join CSR S WITH (NOLOCK) ON oh.CsrKey = S.CsrKey
			group by ID.MInvoiceKey,IH.OrderNo, C.CustID, C.CustName, c.CustKey,A.City, S.CsrKey, S.CsrName, ISNULL(OH.BookingNo,'')
		) OD on IH.MInvoiceKey = OD.MInvoiceKey
	inner join InvoiceStatus S WITH (NOLOCK) on IH.StatusKey = S.StatusKey 
	Cross Apply(
			select stuff((Select distinct ',' + ContainerNo 
			from ManualInvoiceDetail A WITH (NOLOCK)
			where A.MInvoiceKey = OD.MInvoiceKey
			FOR XML PATH ('')),1,1,'') as Containers
	) as X
	left outer join 
		(
			select InvoiceKey, sum(PaidAmount) as PaidAmount , InvoiceType 
			from InvoicePayment  WITH (NOLOCK) 
			group by InvoiceKey, InvoiceType
		) P on (IH.MInvoiceKey = P.InvoiceKey and P.InvoiceType = 'M')
	--WHERE		(IH.StatusKey = 3)  
 
