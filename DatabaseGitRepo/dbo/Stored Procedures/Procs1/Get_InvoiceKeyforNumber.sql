
CREATE proc [dbo].[Get_InvoiceKeyforNumber] -- Get_InvoiceKeyforNumber '34'
(
	@InvoiceNo	varchar(50),
	@InvoiceType	varchar(1) = ''  -- I: Invoice, P:Prepay, M: Manual
)
as
Begin
	set nocount on
	set fmtonly off

	create table #Invoice
	(
		InvoiceKey	int,
		InvoiceDate	DateTime,
		InvoiceAmount	decimal(18,2),
		CustKey			int,
		CustId			varchar(50),
		CustName		varchar(200),
		CustAddress		varchar(1000),
		BalanceAmount	decimal(18,2),
		IsPaid			bit,
		InvoiceType		varchar(2),
		StatusKey		int
	)
	if(isnull(@InvoiceType,'') = '')
	begin
		if(left(@InvoiceNo,1) = 'P')
		begin
			set @InvoiceType = 'P'
		end
		else if (left(@InvoiceNo,1) = 'M')
		begin
			set @InvoiceType = 'M'
		end
		else 
		Begin
			SEt @InvoiceType = 'I'
		End
	end
	Print @invoiceType

	if(@InvoiceType = 'I')
	Begin
		update IH set InvoiceAmount = id.Amt
		from InvoiceHeader IH 
		inner join (Select invoiceKey, sum(ExtAmt) Amt from Invoicedetail WITH (NOLOCK) where isnull(BvsNB,0) = 1 group by Invoicekey
			) ID on IH.InvoiceKey = ID.InvoiceKey 
		where IH.InvoiceKey = ID.InvoiceKey and IH.InvoiceAmount <> id.Amt and IH.InvoiceNo  =@InvoiceNo

		insert into #Invoice (InvoiceKey, InvoiceDate, InvoiceAmount, CustKey, BalanceAmount, IsPaid, InvoiceType, StatusKey)
		select IH.InvoiceKey, InvoiceDate, IH.InvoiceAmount, CustKey, BP.BalanceAmount, 
		case when StatusKey = 3 then 1 else  IH.IsPaymentReceived end as IsPaymentReceived,
		'I', StatusKey
		from InvoiceHeader IH WITH (NOLOCK)
		LEft join vInvoiceBalanceAmount BP WITH (NOLOCK) on IH.InvoiceKey = BP.InvoiceKey
		where InvoiceNo = @InvoiceNo AND IH.InvoiceKey NOT IN(SELECT ISNULL(InvoiceKey,0) FROM ArchivedInvoiceHistory)
	END

	If(@InvoiceType = 'P')
	begin
		insert into #Invoice (InvoiceKey, InvoiceDate, InvoiceAmount, CustKey, BalanceAmount, IsPaid, InvoiceType, StatusKey)
		select IH.PPInvoiceKey, PPInvoiceDate, IH.PPInvoiceAmount, CustomerKey, BP.BalanceAmount, 
			case when IH.StatusKey = 3 then 1 else 0 end, 'P', StatusKey
		from PrepayInvoiceHeader IH WITH (NOLOCK)
		LEft join vInvoiceBalanceAmount BP WITH (NOLOCK) on IH.PPInvoiceKey = BP.InvoiceKey
		where PPInvoiceNo = @InvoiceNo
	end

	If(@InvoiceType = 'M')
	begin
		insert into #Invoice (InvoiceKey, InvoiceDate, InvoiceAmount, CustKey, BalanceAmount, IsPaid, InvoiceType, StatusKey)
		select IH.MInvoiceKey, MInvoiceDate, IH.MInvoiceAmount, CustomerKey, isnull(BP.BalanceAmount,0),
		case when IH.StatusKey = 3 then 1 else 0 end,'M', StatusKey
		from ManualInvoiceHeader IH WITH (NOLOCK)
		LEft join vInvoiceBalanceAmount BP WITH (NOLOCK) on IH.MInvoiceKey = BP.InvoiceKey
		where MInvoiceNo = @InvoiceNo
		and StatusKey <> 4
	end
	
	UPDATE I SET CustId = C.CustID, CustName = C.CustName,
		CustAddress = isnull(a.AddrName,'') + '<br>' + 
						isnull(a.Address1,'') + '<br>' + 
						isnull(a.City,'') + ' - ' + isnull(a.State,'') + ' - ' 
						+ isnull(a.ZipCode,'') + ', ' + isnull(a.Country,''),
		BalanceAmount = ISNULL(BalanceAmount,0) 
	from #Invoice I
	inner join Customer C WITH (NOLOCK) on i.CustKey = c.CustKey
	inner join Address A WITH (NOLOCK) on isnull(c.BillToAddrKey,c.AddrKey) = a.AddrKey

	select I.*,IP.PaymentStatus from #Invoice I
	LEFT JOIN (SELECT Distinct InvoiceKey,StatusKey As PaymentStatus FROM InvoicePayment) IP ON IP.InvoiceKey=I.InvoiceKey 
	
end
