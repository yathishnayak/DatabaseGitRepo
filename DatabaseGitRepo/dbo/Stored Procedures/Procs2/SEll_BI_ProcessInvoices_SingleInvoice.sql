
/*
SELECT * FROM SELL_InvoiceSummary
SELECT * FROM SELL_InvoiceItemSummary 
SELECT * FROM SELL_InvoiceDraybaseSummary
SELECT * FROM SELL_InvoiceBobtailSummary
SELECT * FROM SELL_InvoiceProcessStatus

exec [SEll_BI_ProcessInvoices_SingleInvoice] '3798', @JsonInput = N'[]', @Status = 0, @Reason = ''
*/

CREATE Proc [dbo].[SEll_BI_ProcessInvoices_SingleInvoice]
(
	@InvoiceNo			varchar(50),
	@JsonInput			nvarchar(max),
	@Status				bit,
	@Reason				varchar(500)
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	Print 'JsonInput->: '+ @JsonInput

	DECLARE @INVOICEKEY			INT,
			--@JsonOutput			nvarchar(max),
			@InvoiceSummaryKey	int,
			@ProcessDate		Datetime

	set @ProcessDate = GETDATE()

	if(isnull(@InvoiceKey,0) = 0 AND ISNULL(@InvoiceNo,'') = '')
	BEGIN
		set @Status = 0
		set @Reason = 'Invoice Parameters not received'
		return
	END
	if(isnull(@InvoiceKey,0) = 0)
	Begin
		select @InvoiceKey = InvoiceKey From InvoiceHeader where InvoiceNo = @InvoiceNo
	End
	print '@InvoiceKey'
	print @InvoiceKey
	SEt @Status = 1

	--EXEC Delete_Sell_InvoiceTable_Data

		if((select count(1) from SELL_InvoiceSummary where invoiceKey = @INVOICEKEY) > 0)
		Begin
			select @InvoiceSummaryKey = InvoiceSummaryKey from SELL_InvoiceSummary where InvoiceKey = @INVOICEKEY
			delete from SELL_InvoiceItemSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from SELL_InvoiceDraybaseSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from SELL_InvoiceBobtailSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from SELL_InvoiceSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		End
		PRINT '---------------'
		PRINT @INVOICEKEY
		PRINT @INVOICENO

		--set @JsonInput = N'[]'
		set @Status = 0
		Set @Reason = ''
		set @InvoiceSummaryKey = 0


		--Exec SELL_OutputByInvoice @InvoiceKey = @INVOICEKEY, @InvoiceNo = '', 
		--	@JsonOutput= @JsonOutput output,@Status = @Status output, @Reason = @Reason output
		--print @JsonOutput
		--print @Status
		--print @reason

		--select @INVOICEKEY, @INVOICENO, @JsonOutput, @Status, @Reason

		Delete from SELL_InvoiceProcessStatus where Invoicekey = @INVOICEKEY

		insert into SELL_InvoiceProcessStatus(InvoiceKey, ProcStatus, ProcReason, CreateDate, DrayReason, BobtailReason, AccessorialReason)
		Select @INVOICEKEY, @Status, @Reason, @ProcessDate, DrayReason, BobtailReason, AccessorialReason
		from OpenJson(@JsonInput, '$.Error')
		With (
			DrayReason			varchar(1000)		'$.DrayReason',
			AccessorialReason	varchar(1000)		'$.AccessorialReason',
			BobtailReason		varchar(1000)		'$.BobtailReason',
			ConfigReason		varchar(1000)		'$.ConfigReason'
		) where DrayReason <> '' OR BobtailReason <> '' OR AccessorialReason <> ''

		Declare @ProcCnt int = 0
		select @ProcCnt = count(1) from SELL_InvoiceProcessStatus where Invoicekey = @INVOICEKEY and ProcReason <> 'SUCCESS'
		
		--select 'SELL_InvoiceProcessStatus' TableName, * from SELL_InvoiceProcessStatus where Invoicekey = @INVOICEKEY

		if(isnull(@ProcCnt,0) = 0)
		BEGIN
			--Select @JsonOutput
			Insert into SELL_InvoiceSummary (InvoiceKey, Market, MArketKey, Terminal, TerminalKey, ZoneKey, ZoneName, 
				city, State, CustKey, CustName, IsDryRun, IsBobTail,  CreatedDate)
			Select @INVOICEKEY, Market, MArketKey, Terminal, TerminalKey, ZoneKey, ZoneName, 
				city, State, CustKey, CustName, IsDryRun, IsBobTail, @ProcessDate
			from OpenJson(@JsonInput, '$[0]')
			With (
				Market			varchar(50)		'$.Market',
				MarketKey		int				'$.MarketKey',
				Terminal		varchar(50)		'$.Terminal',
				TerminalKey		int				'$.TerminalKey',
				ZoneKey			int				'$.ZoneKey',
				ZoneName		varchar(50)		'$.city',
				city			varchar(50)		'$.LineItem4',
				State			varchar(20)		'$.State',
				CustKey			int				'$.CustKey',
				CustName		varchar(100)	'$.CustName',
				IsDryRun		bit				'$.IsDryRun',
				IsBobTail		bit				'$.IsBobTail'
			)
			set @InvoiceSummaryKey = SCOPE_IDENTITY()

			--select 'SELL_InvoiceSummary' TableName, * from SELL_InvoiceSummary where Invoicekey = @INVOICEKEY

			Insert into SELL_InvoiceDraybaseSummary ( InvoiceSummaryKey, ContainerNo, DrayBase_Value, Margin_Percent, 
				Margin_Value, DrayBase_Rate, FSF_Value, FSF_Percent, Draybase_Total, Total_value, CreatedDate, NetRevenue, 
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey)
			Select @InvoiceSummaryKey, ContainerNo, DrayBase_Value, Margin_Percent, 
				Margin_Value, DrayBase_Rate, FSF_Value, FSF_Percent, Draybase_Total, Total_value, @ProcessDate, NetRevenue, 
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey
			from OpenJson(@JsonInput, '$[0].DrayBase')
			With (
				ContainerNo			varchar(50)		'$.ContainerNo',
				DrayBase_Value		numeric(18,2)	'$.DrayBase_Value',
				Margin_Percent		numeric(18,2)	'$.Margin_Percent',
				Margin_Value		numeric(18,3)	'$.Margin_Value',
				DrayBase_Rate		numeric(18,3)	'$.DrayBase_Rate',
				FSF_Value			numeric(18,3)	'$.FSF_Value',
				FSF_Percent			numeric(18,3)	'$.FSF_Percent',
				Draybase_Total		numeric(18,3)	'$.Draybase_Total',
				Total_value			numeric(18,3)	'$.Total_value',
				NetRevenue			numeric(18,3)	'$.NetRevenue',
				CreatedDate			DateTime		'$.CreatedDate',
				EffectiveDate		DateTime		'$.EffectiveDate',
				EffectiveDateFrom	varchar(50)		'$.EffectiveDateFrom',
				FileName			varchar(100)	'$.FileName',
				DateUploaded		Datetime		'$.DateUploaded',
				UploadedBy			varchar(100)	'$.UploadedBy',
				OutputDataKey		int				'$.OutputDataKey'
			)

			Insert into SELL_InvoiceBobtailSummary ( InvoiceSummaryKey, ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey)
			Select @InvoiceSummaryKey, ContainerNo, BobtailFormat, BobtailRate, BobtailCalc,
				EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey
			from OpenJson(@JsonInput, '$[0].Bobtail')
			With (
				ContainerNo			varchar(50)		'$.ContainerNo',
				BobtailFormat		varchar(50)		'$.BobtailFormat',
				BobtailRate			numeric(18,2)	'$.BobtailRate',
				BobtailCalc			numeric(18,3)	'$.BobtailCalc',
				EffectiveDate		DateTime		'$.EffectiveDate',
				EffectiveDateFrom	varchar(50)		'$.EffectiveDateFrom',
				FileName			varchar(100)	'$.FileName',
				DateUploaded		Datetime		'$.DateUploaded',
				UploadedBy			varchar(100)	'$.UploadedBy',
				OutputDataKey		int				'$.OutputDataKey'
			)

			insert into SELL_InvoiceItemSummary(InvoiceSummaryKey, ContainerNo, RecordSL, MarketLocation, itemkey, LineItem, BvsNB, Rate, 
				CostGroup, EffectiveDate, EffectiveDateFrom,  FileName, DateUploaded, UploadedBy, CreatedDate)
			select @InvoiceSummaryKey, ContainerNo, RecordSL, MarketLocation, itemkey, LineItem, BvsNB, Rate, 
				CostGroup, EffectiveDate, EffectiveDateFrom,  FileName, DateUploaded, UploadedBy, @ProcessDate
			from OpenJson(@JsonInput, '$[0].Accessorials')
			With (
				ContainerNo			varchar(50)		'$.ContainerNo',
				RecordSL			numeric(18,2)	'$.RecordSL',
				LineItem			varchar(100)	'$.LineItem',
				MarketLocation		varchar(50)		'$.MarketLocation',
				ItemKey				int				'$.ItemKey',
				Rate				numeric(18,2)	'$.Rate',
				BvsNB				varchar(5)		'$.BvsNB',
				CostGroup			varchar(50)		'$.CostGroup',
				EffectiveDate		DateTime		'$.EffectiveDate',
				EffectiveDateFrom	varchar(50)		'$.EffectiveDateFrom',
				FileName			varchar(100)	'$.FileName',
				DateUploaded		Datetime		'$.DateUploaded',
				UploadedBy			varchar(100)	'$.UploadedBy',
				OutputDataKey		int				'$.OutputDataKey'
			)		
		END

	Delete from SELL_InvoiceSummary
	where invoicekey in (
	select InvoiceKey 
	from (
	select InvoiceKey, count(1) CNT
	from SELL_InvoiceSummary
	group by InvoiceKey
	having count(1) > 1
	)a )

	Delete from SELL_BI_Rerun where InvoiceNo = @InvoiceNo

END
