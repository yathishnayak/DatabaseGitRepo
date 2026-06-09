CREATE Procedure [dbo].[Get_ChequeList]
		(
			@ChequeNo	varchar(50) = '',
			@DateFrom	DateTime = '2000-01-01',
			@DateTo		DateTime = '2050-12-31',
			@CustKey	int = 0,
			@InvoiceNo	varchar(50) = ''
		)
		as
		Select CH.CustKey, C.CustID + ' - '  + C.CustName as CustID
		,CH.ChequeKey, 
			CH.ChequeRef, CH.ChequeDate, CH.ChequeAmount, 
			CH.ChequeAmount - isnull(B.AmtAdjusted,0) as Balance, D.InvoiceNos as InvoiceNo, 
			isnull(CH.UpdateDate, CH.CreateDate) as LastUpdateDate, 
			isnull(CH.UpdateUser, CH.CreateUser) as LastUpdateBy
		From Cheque_Header CH
		Left Join Customer C on C.CustKey = CH.CustKey
		LEft join (select ChequeKey, sum(InvAdjAmount) as AmtAdjusted 
				from Cheque_Detail CD
				group by ChequeKey) B on CH.ChequeKey = B.ChequeKey
		LEft join (
			SELECT ChequeKey,  
				InvoiceNos=STUFF  
				(  
					 (  
					   SELECT DISTINCT ', ' + CAST(IH.InvoiceNo AS VARCHAR(MAX))  
					   from Cheque_detail CD 
					   inner join InvoiceHeader IH on CD.InvoiceKey = IH.InvoiceKey  
					   where CD.ChequeKey = t1.ChequeKey
					   FOR XML PATH('')  
					 ),1,1,''  
				)  
			FROM Cheque_detail t1  
			GROUP BY ChequeKey  
		) D on Ch.ChequeKey = D.ChequeKey
		Where 
			( isnull(@ChequeNo,'') = '' OR CH.ChequeRef like '%' + @ChequeNo + '%' ) AND
			( isnull(@DateFrom, '2000-01-01') = '2000-01-01' OR CH.ChequeDate >= @DateFrom) AND
			( isnull(@DateTo, '2050-12-31') = '2050-12-31' OR CH.ChequeDate <= @DateTo) AND
			( isnull(@CustKey,0) = 0 OR CH.CustKey = @CustKey ) AND
			( isnull(@InvoiceNo,'') = '' OR @InvoiceNo in ('abcd'))
		Order by CH.ChequeKey
