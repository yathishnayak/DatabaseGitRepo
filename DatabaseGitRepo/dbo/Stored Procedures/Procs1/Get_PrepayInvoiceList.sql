
CREATE Proc [dbo].[Get_PrepayInvoiceList]
(
	@CustomerKey	int = 0,
	@StatusKey			int = 0, -- // 0 : All, 1 : Open, 2: Send, 3 : Confirmed
	@DateFrom		datetime = '2022-01-01',
	@DateTo			Datetime = '2050-12-31'
)
AS
BEGIN
	Select * from (
	Select PPInvoiceKey,
		PPInvoiceNo,
		PPInvoiceDate, 
		PPInvoiceAmount, 
		CustomerKey, 
		BillToAddressKey, 
		H.OrderKey,
		PPInvoiceSentDate, 
		PPInvoiceConfirmDate, 
		isnull(U.UserName,'NA') UserName,
		C.CustName,
		C.CustID,
		A.AddrName,
		A.City,
		A.State, 
		A.ZipCode,
		A.Country,
		h.OrderNo,
		OH.OrderDate,
		isnull(H.StatusKey,1) StatusKey,
		Case when  isnull(H.statusKey,0) = 1 then 'Open'
			 when H.StatusKey = 2 then 'Sent'
			 when H.StatusKey = 3 then 'Confirmed' else '' end as StatusName,
		H.InternalNotes,
		H.CustomerNotes
	from PrepayInvoiceHeader H WITH (NOLOCK) 
	LEft join OrderHeader OH WITH (Nolock) on H.orderKey = OH.orderKey
	LEft join [User] U WITH (NOLOCK)  on isnull(H.UpdatedUserKey,H.CreatedUserKey) = U.UserKey
	LEFT join [Customer] C WITH (NOLOCK)  on H.CustomerKey = C.CustKey
	Left join [Address] A WITH (NOLOCK)  on H.BillToAddressKey = A.AddrKey
	) A
	where 
		(isnull(@CustomerKey,0) = 0 OR CustomerKey = @CustomerKey  ) and
		--(isnull(@StatusKey,0) = 0 OR A.StatusKey = @StatusKey ) and
		(ISNULL(@DateFrom,convert(date, '2022-01-01')) = convert(date, '2022-01-01') OR @DateFrom <= PPInvoiceDate) AND
		(ISNULL(@DateTo, convert(date, '2050-12-31')) = convert(Date, '2050-12-31') OR @DateTo >= PPInvoiceDate )
END
