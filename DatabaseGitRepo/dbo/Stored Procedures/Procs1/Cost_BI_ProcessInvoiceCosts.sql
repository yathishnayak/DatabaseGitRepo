

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
CREATE Proc [dbo].[Cost_BI_ProcessInvoiceCosts]

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

	-- Deletes the records from 'Cost_InvoiceProcessStatus', 'Cost_InvoiceItemSummary', 
	--'Cost_InvoiceContainerSummary', 'Cost_InvoiceSummary' with resp to InvoiceNo in 'Cost_BI_Rerun'
	EXEC Delete_Cost_InvoiceTable_Data

	declare InvoiceCursor Cursor Local FOR
	Select distinct  INVOICEKEY, InvoiceNo from (
		SELECT IH.INVOICEKEY, IH.InvoiceNo
		FROM InvoiceHeader IH WITH (NOLOCK)
		LEFT JOIN Cost_InvoiceSummary CI WITH (NOLOCK) ON IH.InvoiceKey = CI.INVOICEKEY
		WHERE CI.InvoiceKey IS NULL AND IH.StatusKey IN (1,2,3)
	
		UNION ALL
		select distinct InvoiceKey, Invoiceno from (
			select distinct IH.Invoicekey, IH.Invoiceno from Invoicedetail ID
				Inner join InvoiceHeader IH on ID.InvoiceKey = IH.InvoiceKey
			where isnull(ID.UpdateDate, ID.CreateDate) > (Getdate() -1)
			union all
			select Invoicekey, Invoiceno from InvoiceHeader where isnull(UpdateDate, CreateDate) > (Getdate() -1)
		) a
		UNION ALL 
		SELECT IH.INVOICEKEY, IH.InvoiceNo
		FROM InvoiceHeader IH WITH (NOLOCK)
		inner join Cost_BI_Rerun R WITH (NOLOCK) on IH.InvoiceNo = R.InvoiceNo
	) A
	--where invoicekey = 160423
	order by invoicekey ASC

	OPEN InvoiceCursor

	FETCH NEXT FROM InvoiceCursor INTO @INVOICEKEY, @INVOICENO

	WHILE @@FETCH_STATUS = 0
	BEGIN
		if((select count(1) from Cost_InvoiceSummary where invoiceKey = @INVOICEKEY) > 0)
		Begin
			select @InvoiceSummaryKey = InvoiceSummaryKey from Cost_InvoiceSummary where InvoiceKey = @INVOICEKEY
			delete from Cost_InvoiceItemSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from Cost_InvoiceContainerSummary where InvoiceSummaryKey = @InvoiceSummaryKey
			delete from Cost_InvoiceSummary where InvoiceSummaryKey = @InvoiceSummaryKey
		End
		PRINT '---------------'
		PRINT @INVOICEKEY
		PRINT @INVOICENO

		set @JsonOutput = ''
		set @Status = 0
		Set @Reason = ''
		set @InvoiceSummaryKey = 0

		truncate table #LineItemDetailsBI

		Exec Cost_OutputByInvoice @InvoiceKey = @INVOICEKEY, @InvoiceNo = @INVOICENO, 
			@JsonOutput=@JsonOutput output,@Status = @Status output, @Reason = @Reason output
		--print @JsonOutput
		--print @Status
		--print @reason

		select @INVOICEKEY, @INVOICENO, @JsonOutput, @Status, @Reason

		Delete from Cost_InvoiceProcessStatus where Invoicekey = @INVOICEKEY

		--if(@Status = 0)
		--Begin
		--	insert into Cost_InvoiceProcessStatus(InvoiceKey, ProcStatus, ProcReason, CreateDate)
		--	Select @INVOICEKEY, @Status, @Reason, @ProcessDate 
		--End
		--ELSE
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

			select * from #ItemDetailsBI

			insert into Cost_InvoiceItemSummary (InvoiceSummaryKey, itemkey, LineItem, Per, UnitCost, Qty, TotalCost, CreatedDate, ContainerNo)
			select @InvoiceSummaryKey, itemkey, LineItem, '', UnitCost, Qty, TotalCost, @ProcessDate, ContainerNo From #ItemDetailsBI 
			

			truncate table #ItemDetailsBI
			truncate table #LineItemDetailsBI
		END
		FETCH NEXT FROM InvoiceCursor INTO @INVOICEKEY, @INVOICENO
	END

	CLOSE InvoiceCursor
	DEALLOCATE InvoiceCursor

	Delete from Cost_InvoiceSummary
	where invoicekey in (
	select InvoiceKey 
	from (
	select InvoiceKey, count(1) CNT
	from Cost_InvoiceSummary
	group by InvoiceKey
	having count(1) > 1
	)a )

	DELETE FROM Cost_BI_Rerun
END
