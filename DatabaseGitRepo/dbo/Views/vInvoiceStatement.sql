


CREATE View [dbo].[vInvoiceStatement]
as
select 		od.CustID,
			od.CustName,			
			od.OrderNo,
			ContainerCount,
			od.City as DestinationCity,
			od.BrokerRefNo,
			InvoiceNo,			
			InvoiceDate,
			IH.InvoiceKey,
			IH.CustKey,
			DueDate,
			S.StatusKey,
			S.Description,
			case when IH.InvoiceAmount - isnull(P.PaidAmount,0)  =0 then 0 
				else 
					case when DATEDIFF(DD, IH.DueDate, GETDATE()) <0 then 0 else DATEDIFF(DD, IH.DueDate, GETDATE()) end
			end as OverDueDays, 
			IH.InvoiceAmount,	
			Case When isnull(P.PaidAmount,0) >=0 Then isnull(P.PaidAmount,0) Else 0 End as Payments,
			Case When isnull(P.PaidAmount,0) <0 Then isnull(P.PaidAmount,0) Else 0 End as Credit,
			IH.InvoiceAmount - isnull(P.PaidAmount,0) as Balance,
			'Invoice' as InvoiceType, 
			X.Containers,
			null CsrKey, '' CsrName, 
			null as CompleteDate,
			IH.CreateUserKey,
			OD.BookingNo,
			InvoiceCompanyKey
	from InvoiceHeader IH WITH (NOLOCK) 
	inner join (
			Select distinct ID.InvoiceKey, OrderNo, C.CustID, C.CustName, c.CustKey,
			A.City, ISNULL(isnull(IH.BrokerRefNo,OH.BrokerRefNo),'') as BrokerRefNo,     
			ISNULL(OH.BookingNo,'') as BookingNo,
			count(Distinct OD.ContainerNo) as ContainerCount
			from InvoiceDetail ID  WITH (NOLOCK) 
			INNER JOIN InvoiceHeader IH WITH (NOLOCK) ON ID.InvoiceKey=IH.InvoiceKey
			inner join OrderDetail OD WITH (NOLOCK)  on ID.OrderDetailKey = OD.OrderDetailKey AND OD.Status<>15
			inner join OrderHeader OH WITH (NOLOCK)  on OD.OrderKey = OH.OrderKey 
			inner join Customer C WITH (NOLOCK)  on OH.CustKey = C.CustKey
			LEFT join Address A WITH (NOLOCK)  on OH.DestinationAddrKey = A.AddrKey
			group by ID.InvoiceKey, OrderNo, C.CustID, C.CustName, c.CustKey,A.City, OH.BrokerRefNo, ISNULL(OH.BookingNo,'') , ISNULL(IH.BrokerRefNo,OH.BrokerRefNo)
		) OD on IH.InvoiceKey = OD.InvoiceKey
	inner join InvoiceStatus S WITH (NOLOCK) on IH.StatusKey = S.StatusKey
	Cross Apply(
			select stuff((Select distinct ',' + ContainerNo 
			from Invoicedetail A WITH (NOLOCK)
			inner join OrderDetail B WITH (NOLOCK) on A.OrderDetailKey = B.OrderDetailKey
			where A.InvoiceKey = OD.InvoiceKey
			FOR XML PATH ('')),1,1,'') as Containers
	) as X
	left outer join 
		(
			select InvoiceKey, sum(PaidAmount) as PaidAmount , InvoiceType
			from InvoicePayment  WITH (NOLOCK) 
			group by InvoiceKey, InvoiceType
		) P on (IH.InvoiceKey = P.InvoiceKey and P.InvoiceType = 'I')
	--WHERE		(IH.StatusKey = 3)  
 
