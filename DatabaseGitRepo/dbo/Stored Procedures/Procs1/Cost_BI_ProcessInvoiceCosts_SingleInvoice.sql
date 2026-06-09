
/*
select * from Cost_InvoiceSummary
select * from Cost_InvoiceContainerSummary
select * from Cost_InvoiceItemSummary
select * from Cost_InvoiceProcessStatus

--Truncate table Cost_InvoiceSummary
--Truncate table Cost_InvoiceContainerSummary
--Truncate table Cost_InvoiceItemSummary
--Truncate table Cost_InvoiceProcessStatus

*/

CREATE PROC [dbo].[Cost_BI_ProcessInvoiceCosts_SingleInvoice]
(
	@InvoiceNo		varchar(50) = '',
	@JasonInput		nvarchar(max) ='' OUTPUT,
	@StatusInput			bit = 0 output,
	@ReasonInput			varchar(500) = '' output
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @INVOICEKEY			INT,
			@JsonOutput			nvarchar(max),
			@Status				bit,
			@Reason				varchar(500),
			@InvoiceSummaryKey	int,
			@ProcessDate		Datetime

	set @ProcessDate = GETDATE()

	/* Gets the InvoiceKey from the given InvoiceNo*/
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
	SET @Status = 1

	Create Table #ItemDetailsBI
	(
		ContainerNo		varchar(50),
		ItemKey			int,
		LineItem		varchar(200),
		UnitCost		numeric(18,5),
		Qty				int,
		TotalCost		numeric(18,5)
	)

	Create table #LineItemDetailsBI
	(
		Container			varchar(50),
		ContainerItemList	nvarchar(max) 
	)

		if((select count(1) from Cost_InvoiceSummary where InvoiceKey = @INVOICEKEY) > 0)
		Begin
			select @InvoiceSummaryKey = InvoiceSummaryKey from Cost_InvoiceSummary where InvoiceKey = @INVOICEKEY
			delete from Cost_InvoiceItemSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from Cost_InvoiceContainerSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from Cost_InvoiceSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		End
		PRINT '---------------'
		PRINT @INVOICEKEY
		PRINT @INVOICENO

		set @Status = 0
		Set @Reason = ''
		set @InvoiceSummaryKey = 0

		truncate table #LineItemDetailsBI

		/*
		Exec Cost_OutputByInvoice @InvoiceKey = @INVOICEKEY, @InvoiceNo = @INVOICENO, 
			@JsonOutput=@JsonOutput output,@Status = @Status output, @Reason = @Reason output
		*/
		--print @JsonOutput
		--print @Status
		--print @reason

		SET @JsonOutput = @JasonInput
		SET @Status = @StatusInput
		SET @Reason = @ReasonInput

		--select @INVOICEKEY, @INVOICENO, @JsonOutput, @Status, @Reason

		Delete from Cost_InvoiceProcessStatus where Invoicekey = @INVOICEKEY

		if(@Status = 0)
		Begin
			insert into Cost_InvoiceProcessStatus(InvoiceKey, ProcStatus, ProcReason, CreateDate)
			Select @INVOICEKEY, @Status, @Reason, @ProcessDate 
		End
		ELSE
		BEGIN
			--Select @JsonOutput
			Insert into Cost_InvoiceSummary (InvoiceKey, PrePull_value, YardShuttle_value, 
				StopOff_value, DrayBase_Value, Accessorial_Value, Total_value, CreatedDate)
			Select @INVOICEKEY, LineItem1_Value, LineItem2_Value, 
				LineItem3_Value, LineItem4_Value, LineItem5_Value, Total_value, @ProcessDate
			from OpenJson(@JsonOutput, '$[0].Summary')
			With (
				LineItem1			varchar(50)		'$.LineItem1',
				LineItem1_Value		numeric(18,3)	'$.LineItem1_Value',
				LineItem2			varchar(50)		'$.LineItem2',
				LineItem2_Value		numeric(18,3)	'$.LineItem2_Value',
				LineItem3			varchar(50)		'$.LineItem3',
				LineItem3_Value		numeric(18,3)	'$.LineItem3_Value',
				LineItem4			varchar(50)		'$.LineItem4',
				LineItem4_Value		numeric(18,3)	'$.LineItem4_Value',
				LineItem5			varchar(50)		'$.LineItem5',
				LineItem5_Value		numeric(18,3)	'$.LineItem5_Value',
				Total_text			varchar(50)		'$.Total_text',
				Total_value			numeric(18,3)	'$.Total_value'
			)
			set @InvoiceSummaryKey = SCOPE_IDENTITY()

			Insert into Cost_InvoiceContainerSummary (InvoiceSummaryKey,ContainerNo, 
				PrePull_value, YardShuttle_value, StopOff_value, DrayBase_Value, Accessorial_Value, Total_value, CreatedDate)
			Select @InvoiceSummaryKey, ContainerNo, 
				LineItem1_Value, LineItem2_Value, LineItem3_Value, LineItem4_Value, LineItem5_Value, Total_value, @ProcessDate
			from OpenJson(@JsonOutput, '$[0].ContainerSummary')
			With (
				ContainerNo			varchar(50)		'$.ContainerNo',
				LineItem1			varchar(50)		'$.LineItem1',
				LineItem1_Value		numeric(18,3)	'$.LineItem1_Value',
				LineItem2			varchar(50)		'$.LineItem2',
				LineItem2_Value		numeric(18,3)	'$.LineItem2_Value',
				LineItem3			varchar(50)		'$.LineItem3',
				LineItem3_Value		numeric(18,3)	'$.LineItem3_Value',
				LineItem4			varchar(50)		'$.LineItem4',
				LineItem4_Value		numeric(18,3)	'$.LineItem4_Value',
				LineItem5			varchar(50)		'$.LineItem5',
				LineItem5_Value		numeric(18,3)	'$.LineItem5_Value',
				Total_text			varchar(50)		'$.Total_text',
				Total_value			numeric(18,3)	'$.Total_value'
			)

			insert into #LineItemDetailsBI (Container, ContainerItemList)
			select Container, ContainerItemList 
			from OpenJson(@JsonOutput, '$[0].LineItemDetails')
			With (
				Container			varchar(50),
				ContainerItemList	nvarchar(max) '$.ContainerItemList' as json
			)

			Declare @Container		varchar(50), 
					@ContainerItemList	nvarchar(max)
			Declare ItemCursor Cursor Local for
			Select * from #LineItemDetailsBI

			Open ItemCursor
			Fetch next from ItemCursor into @Container, @ContainerItemList

			While @@FETCH_STATUS = 0
			Begin
				insert into #ItemDetailsBI ( ContainerNo, ItemKey, LineItem, Qty, UnitCost, TotalCost)
				select @Container,  ItemKey, LineItem, Qty, UnitCost, TotalCost
				from OpenJson (@ContainerItemList, '$')
				With (
					ItemKey		int				'$.ItemKey',
					LineItem	varchar(200)	'$.LineItem',
					UnitCost	numeric(18,5)	'$.UnitCost',
					qty			int				'$.qty',
					TotalCost	numeric(18,3)	'$.TotalCost'
				)
				
				Fetch next from ItemCursor into @Container, @ContainerItemList
			End
			close ItemCursor
			Deallocate ItemCursor

			--select * from #ItemDetailsBI

			insert into Cost_InvoiceItemSummary (InvoiceSummaryKey, itemkey, LineItem, Per, UnitCost, Qty, TotalCost, CreatedDate, ContainerNo)
			select @InvoiceSummaryKey, itemkey, LineItem, '', UnitCost, Qty, TotalCost, @ProcessDate, ContainerNo From #ItemDetailsBI 
			

			truncate table #ItemDetailsBI
			truncate table #LineItemDetailsBI
		END

	Delete from Cost_InvoiceSummary
	where invoicekey in (
	select InvoiceKey 
	from (
	select InvoiceKey, count(1) CNT
	from Cost_InvoiceSummary
	group by InvoiceKey
	having count(1) > 1
	)a )

	--Print @InvoiceNo
	DELETE FROM Cost_BI_Rerun WHERE InvoiceNo = @InvoiceNo
END
