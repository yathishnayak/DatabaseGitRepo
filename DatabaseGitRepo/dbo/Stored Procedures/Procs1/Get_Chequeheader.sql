CREATE Procedure [dbo].[Get_Chequeheader]
@Chequekey  int
as 
	Select CH.ChequeKey ,CH.CustKey, C.CustID, C.CustName,  ChequeRef, ChequeDate, ChequeAmount, Balance
	from Cheque_Header CH
		Left Join Customer C on C.CustKey = CH.CustKey 
	where CH.ChequeKey = @Chequekey
