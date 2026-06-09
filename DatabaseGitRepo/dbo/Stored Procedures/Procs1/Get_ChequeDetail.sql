


CREATE Procedure [dbo].[Get_ChequeDetail] -- [Get_ChequeDetail] 1
@ChequeKey int
as
set nocount on
set fmtonly off
Select CH.ChequeKey, CD.ChequeDetailKey, CD.InvoiceKey, 
	IH.InvoiceNo, IH.InvoiceDate, IH.InvoiceAmount,
	CD.InvAdjAmount, CD.InvAdjDate, CD.CreateDate, CD.CreateUser, Cd.UpdateDate, CD.UpdateUser,
	C.CustID, C.CustKey, C.CustName
From Cheque_Header CH
left join Cheque_Detail CD on CD.ChequeKey = CH.ChequeKey	
left Join InvoiceHeader IH on IH.InvoiceKey = CD.InvoiceKey
left join Customer C on IH.CustKey = C.CustKey
Where CH.ChequeKey = @ChequeKey

