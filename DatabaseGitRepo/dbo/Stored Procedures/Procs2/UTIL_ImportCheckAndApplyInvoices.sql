





CREATE Procedure [dbo].[UTIL_ImportCheckAndApplyInvoices]
as
Begin

	Update A set CustId = C.CustID, CustKey= B.CustKey   from StgApplyInvoices A
	inner join InvoiceHeader B on (trim(A.InvoiceNo) = B.InvoiceNo)
	inner join Customer C on (B.CustKey = C.CustKey)
	where ISNULL(A.ProcessStatus,0)=0

	--Update A set CustKey= B.CustKey  from StgApplyInvoices A
	--inner join Customer B on (A.CustId = B.CustID)
	--where  isnull(ProcessStatus,0)=0


	Update A set InvcKey = B.InvoiceKey from StgApplyInvoices A
	inner join InvoiceHeader B on (trim(A.InvoiceNo) = B.InvoiceNo and A.CustKey = B.CustKey)
	where  isnull(ProcessStatus,0)=0
	
	if exists(select InvcKey from StgApplyInvoices where InvcKey is null and  isnull(ProcessStatus,0)=0)
	Begin
		raiserror('Some invoices not found', 16,1) 
		return
	End

	Declare @CustKey as int
	Declare @CheckNo as varchar(50)
	Declare @CheckKey as int
	Declare @CurCheck as Cursor
	set @CurCheck  = Cursor for 
					select Distinct CheckNo from StgApplyInvoices 
					where CustKey is not null and  isnull(ProcessStatus,0)=0

	Open @CurCheck
	While (0=0)
	Begin
		fetch next from @CurCheck into @CheckNo
		if @@FETCH_STATUS <>0 break
		insert into Cheque_Header 
			(CustKey,ChequeRef,ChequeDate,ChequeAmount,Balance,CreateUser,UpdateUser,UpdateDate,CreateDate)
		select distinct  0, @CheckNo, CheckDate, 0, 0, 287, 287, getdate(), getdate()  from  StgApplyInvoices
		where CheckNo= @CheckNo and isnull(ProcessStatus,0)=0
		set @CheckKey = @@IDENTITY

		Update StgApplyInvoices set CheckKey =@CheckKey  where CheckNo= @CheckNo 

		insert into Cheque_Detail 
		(ChequeKey,InvoiceKey,InvAdjAmount,InvAdjDate,CreateDate,UpdateDate,CreateUser,UpdateUser)
		select  @CheckKey, InvcKey,ApplyAmount,AdjustDate, getdate(), getdate(), 287, 287   from StgApplyInvoices 
		where  CheckNo= @CheckNo and  isnull(ProcessStatus,0)=0

		
		insert into InvoicePayment (InvoiceKey, PaymentDate, PaidAmount, UserKey,PaymentType,PaymentReference, Note, ChequeKey)
		select A.InvoiceKey, D.ChequeDate, A.InvAdjAmount, 331, 'Check', D.ChequeRef, 'From Cheque', A.ChequeKey from Cheque_Detail A
		inner join InvoiceHeader B on (A.InvoiceKey = B.InvoiceKey)
		inner join Cheque_Header D on (A.ChequeKey = D.ChequeKey)
		left outer join InvoicePayment C on(A.ChequeKey = C.ChequeKey and A.InvoiceKey = C.InvoiceKey)
		where C.ChequeKey is null and d.ChequeKey=@CheckKey

		update Invoiceheader set StatusKey=3 where invoicekey in 
		(select distinct InvoiceKey from Cheque_Detail(nolock) where ChequeKey=@CheckKey)
         and StatusKey <>3

		Update StgApplyInvoices set ProcessStatus=1 where CheckNo= @CheckNo and isnull(ProcessStatus,0)=0
	End
End



