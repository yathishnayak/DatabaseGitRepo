
/*
SELECT * FROM SELL_InvoiceSummary
SELECT * FROM SELL_InvoiceItemSummary 
SELECT * FROM SELL_InvoiceDraybaseSummary
SELECT * FROM SELL_InvoiceBobtailSummary
SELECT * FROM SELL_InvoiceProcessStatus
*/

CREATE Proc [dbo].[SEll_BI_ProcessInvoices]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @INVOICEKEY			INT,
			@INVOICENO			VARCHAR(50),
			@JsonOutput			nvarchar(max),
			@Status				bit,
			@Reason				varchar(500),
			@InvoiceSummaryKey	int,
			@ProcessDate		Datetime

	set @ProcessDate = GETDATE()

	--EXEC Delete_Sell_InvoiceTable_Data

	if((select count(1)
		FROM InvoiceHeader IH WITH (NOLOCK)
		inner join SELL_BI_Rerun CIP WITH (NOLOCK) on IH.InvoiceNo = CIP.InvoiceNo) > 0)
	Begin
		declare InvoiceCursor Cursor Local FOR
		Select distinct INVOICEKEY, InvoiceNo from (
			select top 1000 IH.InvoiceKey, IH.Invoiceno 
			FROM InvoiceHeader IH WITH (NOLOCK)
			inner join SELL_BI_Rerun CIP WITH (NOLOCK) on IH.InvoiceNo = CIP.InvoiceNo
		
		) A 
		order by invoicekey desc
	End
	else
	Begin
		declare InvoiceCursor Cursor Local FOR
		Select distinct INVOICEKEY, InvoiceNo from (
			SELECT IH.INVOICEKEY, IH.InvoiceNo
			FROM InvoiceHeader IH WITH (NOLOCK)
			LEFT JOIN SELL_InvoiceSummary CI WITH (NOLOCK) ON IH.InvoiceKey = CI.INVOICEKEY
			WHERE CI.InvoiceKey IS NULL AND IH.StatusKey IN (1,2,3)  and IH.InvoiceDate > Getdate() - 30
	
			UNION ALL
			select distinct  InvoiceKey, Invoiceno from (
				select distinct IH.Invoicekey, IH.Invoiceno from Invoicedetail ID
					Inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
				where isnull(ID.UpdateDate, ID.CreateDate) > (Getdate() -1)
				union all
				select Invoicekey, Invoiceno from InvoiceHeader where isnull(UpdateDate, CreateDate) > (Getdate() -1)
			) a

			--UNION ALL

			--select top 1000 IH.InvoiceKey, IH.Invoiceno 
			--FROM InvoiceHeader IH WITH (NOLOCK)
			--inner join SELL_BI_Rerun CIP WITH (NOLOCK) on IH.InvoiceNo = CIP.InvoiceNo
		
		) A 
		--where invoiceno in ('60355')
		--where invoiceno in (Select invoiceno from SELL_BI_Rerun)
		order by invoicekey desc
	end
	

	 

	OPEN InvoiceCursor

	FETCH NEXT FROM InvoiceCursor INTO @INVOICEKEY, @INVOICENO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		Exec SELL_OutputByInvoice @InvoiceKey = @INVOICEKEY, @InvoiceNo = @INVOICENO, 
			@JsonOutput=@JsonOutput output,@Status = @Status output, @Reason = @Reason output
		print @Invoiceno
		Print @InvoiceKey
		print @JsonOutput
		print @Status
		print @reason

		
		--Exec [SEll_BI_ProcessInvoices_Single] 
		--	@INVOICEKEY	= @InvoiceKey,
		--	@INVOICENO	= @InvoiceNo,
		--	@JsonOutput	 = @JsonOutput,
		--	@Status		 = @Status,
		--	@Reason		 = @Reason
		Delete from SELL_BI_Rerun where  InvoiceNo = @INVOICENO
		FETCH NEXT FROM InvoiceCursor INTO @INVOICEKEY, @INVOICENO
	END

	CLOSE InvoiceCursor
	DEALLOCATE InvoiceCursor

	Delete from SELL_InvoiceSummary
	where invoicekey in (
	select InvoiceKey 
	from (
	select InvoiceKey, count(1) CNT
	from SELL_InvoiceSummary
	group by InvoiceKey
	having count(1) > 1
	)a )

	

END
