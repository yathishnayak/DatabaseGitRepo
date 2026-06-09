

/*
SELECT * FROM SELL_InvoiceSummary
SELECT * FROM SELL_InvoiceItemSummary 
SELECT * FROM SELL_InvoiceDraybaseSummary
SELECT * FROM SELL_InvoiceBobtailSummary
SELECT * FROM SELL_InvoiceProcessStatus


*/

CREATE Proc [dbo].[SEll_BI_ProcessInvoices_Single]
(
	@INVOICEKEY			INT,
	@INVOICENO			VARCHAR(50),
	@JsonOutput			nvarchar(max),
	@Status				bit,
	@Reason				varchar(500)
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE 
			@InvoiceSummaryKey	int,
			@ProcessDate		Datetime

		set @ProcessDate = GETDATE()

		select @InvoiceSummaryKey = InvoiceSummaryKey from SELL_InvoiceSummary WITH (NOLOCK) where InvoiceKey = @INVOICEKEY
		delete from SELL_InvoiceItemSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		delete from SELL_InvoiceDraybaseSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		delete from SELL_InvoiceBobtailSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		--delete from SELL_InvoiceSummary where InvoiceSummaryKey = @InvoiceSummaryKey

		PRINT '---------------'
		PRINT @INVOICEKEY
		PRINT @INVOICENO

		select @INVOICEKEY, @INVOICENO, @JsonOutput, @Status, @Reason

		Delete from SELL_InvoiceProcessStatus where Invoicekey = @INVOICEKEY

		
		insert into SELL_InvoiceProcessStatus(InvoiceKey, ProcStatus, ProcReason, CreateDate, DrayReason, BobtailReason, AccessorialReason)
		Select @INVOICEKEY, @Status, @Reason, @ProcessDate,  DrayReason, BobtailReason, AccessorialReason
		from OpenJson(@JsonOutput, '$[0].Error')
		With (
			DrayReason			varchar(1000)		'$.DrayReason',
			AccessorialReason	varchar(1000)		'$.AccessorialReason',
			BobtailReason		varchar(1000)		'$.BobtailReason',
			ConfigReason		varchar(1000)		'$.ConfigReason'
		) where DrayReason <> '' OR BobtailReason <> '' OR AccessorialReason <> ''

		Declare @ProcCnt int = 0
		select @ProcCnt = count(1) from SELL_InvoiceProcessStatus WITH (NOLOCK) where Invoicekey = @INVOICEKEY and ProcReason <> 'SUCCESS'
		
		if(@InvoiceSummaryKey > 0)
		Begin
			update B Set 
				Market = A.Market,
				MarketKey	= A.MarketKey	,
				Terminal	= A.Terminal	,
				TerminalKey	= A.TerminalKey,	
				ZoneKey		= A.ZoneKey	,	
				ZoneName	= A.ZoneName	,
				city		= A.city		,
				State		= A.State		,
				CustKey		= A.CustKey	,	
				CustName	= A.CustName	,
				IsDryRun	= A.IsDryRun	,
				IsBobTail	= A.IsBobTail	,
				CreatedDate = @ProcessDate
			from SELL_InvoiceSummary B
			inner join (Select * from 
			OpenJson(@JsonOutput, '$[0]')
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
			)) A on B.InvoiceSummaryKey = @InvoiceSummaryKey
		End
		ELSE
		Begin
			Insert into SELL_InvoiceSummary (InvoiceKey, Market, MArketKey, Terminal, TerminalKey, ZoneKey, ZoneName, 
				city, State, CustKey, CustName, IsDryRun, IsBobTail,  CreatedDate)
			Select @INVOICEKEY, Market, MArketKey, Terminal, TerminalKey, ZoneKey, ZoneName, 
				city, State, CustKey, CustName, IsDryRun, IsBobTail, @ProcessDate
			from OpenJson(@JsonOutput, '$[0]')
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
		End

		Insert into SELL_InvoiceDraybaseSummary ( InvoiceSummaryKey, ContainerNo, DrayBase_Value, Margin_Percent, 
			Margin_Value, DrayBase_Rate, FSF_Value, FSF_Percent, Draybase_Total, Total_value, CreatedDate, NetRevenue, 
			EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey)
		Select @InvoiceSummaryKey, ContainerNo, DrayBase_Value, Margin_Percent, 
			Margin_Value, DrayBase_Rate, FSF_Value, FSF_Percent, Draybase_Total, Total_value, @ProcessDate, NetRevenue, 
			EffectiveDate, EffectiveDateFrom, FileName, DateUploaded, UploadedBy, OutputDataKey
		from OpenJson(@JsonOutput, '$[0].DrayBase')
		With (
			ContainerNo			varchar(50)		'$.ContainerNo',
			DrayBase_Value		numeric(18,6)	'$.DrayBase_Value',
			Margin_Percent		numeric(18,6)	'$.Margin_Percent',
			Margin_Value		numeric(18,6)	'$.Margin_Value',
			DrayBase_Rate		numeric(18,6)	'$.DrayBase_Rate',
			FSF_Value			numeric(18,6)	'$.FSF_Value',
			FSF_Percent			numeric(18,6)	'$.FSF_Percent',
			Draybase_Total		numeric(18,6)	'$.Draybase_Total',
			Total_value			numeric(18,6)	'$.Total_value',
			NetRevenue			numeric(18,6)	'$.NetRevenue',
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
		from OpenJson(@JsonOutput, '$[0].Bobtail')
		With (
			ContainerNo			varchar(50)		'$.ContainerNo',
			BobtailFormat		varchar(50)	'$.BobtailFormat',
			BobtailRate			numeric(18,6)	'$.BobtailRate',
			BobtailCalc			numeric(18,6)	'$.BobtailCalc',
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
		from OpenJson(@JsonOutput, '$[0].Accessorials')
		With (
			ContainerNo			varchar(50)		'$.ContainerNo',
			RecordSL			numeric(18,2)	'$.RecordSL',
			LineItem			varchar(100)	'$.LineItem',
			MarketLocation		varchar(50)		'$.MarketLocation',
			ItemKey				int				'$.ItemKey',
			Rate				numeric(18,6)	'$.Rate',
			BvsNB				varchar(5)		'$.BvsNB',
			CostGroup			varchar(50)		'$.CostGroup',
			EffectiveDate		DateTime		'$.EffectiveDate',
			EffectiveDateFrom	varchar(50)		'$.EffectiveDateFrom',
			FileName			varchar(100)	'$.FileName',
			DateUploaded		Datetime		'$.DateUploaded',
			UploadedBy			varchar(100)	'$.UploadedBy',
			OutputDataKey		int				'$.OutputDataKey'
		)	
		
		--insert into SELL_InvoiceItemSummary(InvoiceSummaryKey, ContainerNo, RecordSL, MarketLocation, 
		--	itemkey, LineItem, BvsNB, Rate, 
		--	CostGroup, EffectiveDate, EffectiveDateFrom,  FileName, DateUploaded, UploadedBy, CreatedDate)
		--select SIS.InvoiceSummaryKey,Id.Container, RecordSL,SIs.Market, 
		--	M.itemkey, isnull(M.Description,I.Description), case when Id.BvsNB = 1 then 'B' else 'NB' end, Id.SellPrice, 
		--	'Accessorial' , EffectiveDate, EffectiveDateFrom,  FileName, DateUploaded, UploadedBy, Id.CreateDate
		--from InvoiceDetail ID
		--inner join SELL_InvoiceSummary SIS on ID.InvoiceKey = SIS.InvoiceKey
		--inner join Item I on ID.ItemKey = I.ItemKey
		--Left Join Item M on I.MasterItemKey = M.ItemKey
		--LEft join SELL_InvoiceItemSummary ITS on SIS.InvoiceSummaryKey = ITS.InvoiceSummaryKey and M.ItemKey = ITS.itemkey
		--where ID.invoicekey = @INVOICEKEY and Id.ItemKey not in (18) and   ITS.itemkey is null

		update ID SET SellPrice = STS.Rate
		from InvoiceDetail ID
		inner join SELL_InvoiceSummary SIS WITH (NOLOCK) on ID.InvoiceKey = SIS.InvoiceKey
		inner join SELL_InvoiceItemSummary STS WITH (NOLOCK) on SIS.InvoiceSummaryKey = STS.InvoiceSummaryKey and Id.ItemKey = STs.itemkey
		where ID.SellPrice <> STS.Rate and ID.InvoiceKey = @INVOICEKEY
		
END
