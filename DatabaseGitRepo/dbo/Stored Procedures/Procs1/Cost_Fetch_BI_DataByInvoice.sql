/*
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '87417',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' 
	EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
	SELECT @JsonOutput, @Status, @Reason
*/

/*
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '91974',   @JsonOutput nvarchar(max) ='',
			@Status	bit = 0 , @Reason	varchar(500) = '', @debug			bit = 1
	EXEC [Cost_Fetch_BI_DataByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
	SELECT @JsonOutput, @Status, @Reason
*/
CREATE PRoc [dbo].[Cost_Fetch_BI_DataByInvoice]
(
	@InvoiceKey		int	= 0,
	@InvoiceNo		varchar(50) = '',
	@JsonOutput		nvarchar(max) ='' OUTPUT,
	@Status			bit = 0 output,
	@Reason			varchar(500) = '' output,
	@debug			bit = 0
)
as
BEGIN
	declare @DryRunReason	varchar(1000) = '',
			@IsBobtail		bit = 0,
			@IsDryRun		bit = 0,
			@IsDraybase		bit = 0,
			@DryRunType		varchar(20) = ''

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

	-- @Market			  varchar(50) = '',
	--		@DriverType		  varchar(50) = '',
	--		@Terminal		  varchar(50) = '',
	--		@PrePullLocation  varchar(50) = '',
	--		@StopOffLocation  varchar(50) = '',
	--		@YardPortType	  varchar(50) = '',
	--		@OrderType		  varchar(50) = '',
	--		@City			  varchar(50) = '',
	--		@State			  varchar(50) = '',
		declare	@ContainerNo	  varchar(20) = ''

	set @ContainerNo = (SELECT TOP 1 ContainerNo from Cost_InvoiceItemSummary I
	inner join Cost_InvoiceSummary S on I.InvoiceSummaryKey = S.InvoiceSummaryKey
	where S.invoicekey = @InvoiceKey)

	Print 'ContainerNo = ' + @ContainerNo

	SELECT	PrePull_value			,
			YardShuttle_value		,
			StopOff_value			,
			DrayBase_Value			,
			Accessorial_Value		,
			Total_value			
	INTO	#Summary
	FROM	Cost_InvoiceSummary S
	Where	S.InvoiceKey = @InvoiceKey

	if (@debug = 1)
		BEGIN
			select * from #Summary
		END

	SELECT	CS.ContainerNo			,
			CS.PrePull_value		,
			CS.YardShuttle_value	,
			CS.StopOff_value		,
			CS.DrayBase_Value		,
			CS.Accessorial_Value	,
			CS.Total_value					 
	INTO	#ContainerSummary
	FROM	Cost_InvoiceContainerSummary CS
	inner join Cost_InvoiceSummary S on CS.InvoiceSummaryKey = S.InvoiceSummaryKey
	Where	S.InvoiceKey = @InvoiceKey

	if (@debug = 1)
		BEGIN
			select * from #ContainerSummary
		END

	SELECT	I.ContainerNo as ContainerNo,
			'Item Cost Breakup' AS Heading,
			I.itemkey AS ItemKey,
			I.LineItem,
			I.Per, 
			I.UnitCost, 
			I.Qty, 
			I.TotalCost
	INTO	#LineItemDetails
	from	Cost_InvoiceItemSummary I
	inner join Cost_InvoiceSummary S on I.InvoiceSummaryKey = S.InvoiceSummaryKey
	where	S.InvoiceKey = @InvoiceKey

	if (@debug = 1)
		BEGIN
			select * from #LineItemDetails
		END

    SELECT 
    @JsonOutput = (
        SELECT 
            PriceGroupingKey = NULL,
            PriceGrouping = NULL,
            MarketLocationKey = NULL,

            LegList = (
                SELECT 
                    Orderdetailkey = NULL,
                    ContainerNo = @ContainerNo, 
                    LegName = NULL,
                    LegOrderBy = NULL,
                    LegCost = NULL
                FOR JSON PATH
            ),

            LegGroupTotalCost = NULL,

            -- AddedAccessorials
            AddedAccessorials = (
                SELECT 
                    ItemKey = NULL, 
                    ItemID = NULL, 
                    LineItem = NULL, 
                    Per = NULL, 
                    UnitCost = NULL, 
                    TotalCost = NULL
                FOR JSON PATH
            ),

            AddedAccessorialsTotalCost = NULL,

            -- Summary
            Summary = (
                SELECT 
                    LineItem1 = 'Pre-Pull', 
                    LineItem1_Value = ISNULL(S.PrePull_value, 0), 
                    LineItem2 = 'Yard Shuttle', 
                    LineItem2_Value = ISNULL(S.YardShuttle_value, 0), 
                    LineItem3 = 'Stop Off', 
                    LineItem3_Value = ISNULL(S.StopOff_value, 0), 
                    LineItem4 = 'Dray base', 
                    LineItem4_Value = ISNULL(S.DrayBase_Value, 0), 
                    LineItem5 = 'Accessorial Costs', 
                    LineItem5_Value = ISNULL(S.Accessorial_Value, 0),
                    LineItem6 = 'DryRun', 
                    LineItem6_Value = NULL,
                    LineItem7 = 'BobTail', 
                    LineItem7_Value = NULL,
                    LineItem8 = 'FSF',
                    LineItem8_Value = NULL,
                    Total_text = 'TOTAL $$', 
                    Total_value = S.Total_value
                FROM #Summary S
                FOR JSON PATH
            ),

            -- ContainerSummary
            ContainerSummary = (
                SELECT 
                    ContainerNo = CS.ContainerNo, 
                    LineItem1 = 'Pre-Pull', 
                    LineItem1_Value = ISNULL(CS.PrePull_value, 0), 
                    LineItem2 = 'Yard Shuttle', 
                    LineItem2_Value = ISNULL(CS.YardShuttle_value, 0), 
                    LineItem3 = 'Stop Off', 
                    LineItem3_Value = ISNULL(CS.StopOff_value, 0), 
                    LineItem4 = 'Dray base', 
                    LineItem4_Value = ISNULL(CS.DrayBase_Value, 0), 
                    LineItem5 = 'Accessorial Costs', 
                    LineItem5_Value = ISNULL(CS.Accessorial_Value, 0),
                    LineItem6 = 'DryRun',  
                    LineItem6_Value = NULL,
                    LineItem7 = 'BobTail', 
                    LineItem7_Value = NULL,
                    LineItem8 = 'FSF',	   
                    LineItem8_Value = NULL,
                    Total_text = '$$ TOTAL COST', 
                    Total_value = CS.Total_value
                FROM #ContainerSummary CS
                FOR JSON PATH
            ),

            -- LineItemDetails
            LineItemDetails = (
                SELECT 
                    ItemContainer = (
                        SELECT 
                            Container = CI.ContainerNo,
                            ContainerItemList = (
                                SELECT 
                                    Heading = 'Item Cost Breakup', 
                                    ItemKey = I.itemkey,
                                    LineItem = I.LineItem,
                                    Per = I.Per, 
                                    UnitCost = I.UnitCost, 
                                    Qty = I.Qty, 
                                    TotalCost = I.TotalCost
                                FROM #LineItemDetails I
                                WHERE I.ContainerNo = CI.ContainerNo
                                FOR JSON PATH
                            )
                        FROM #LineItemDetails CI
                        FOR JSON PATH
                    )
                FOR JSON PATH
            ),

            -- ContainerDetails
            ContainerDetails = (
                SELECT 
                    ContainerNo = @ContainerNo,
                    LegDetails = (
                        SELECT 
                            LegId = NULL, 
                            FromLoc = NULL, 
                            ToLoc = NULL, 
                            TruckType = NULL, 
                            LegCostType = NULL, 
                            LegTypeName = NULL,
                            IsDryRun = CONVERT(BIT, 0), 
                            IsBobtail = NULL
                        FOR JSON PATH
                    )
                FOR JSON PATH
            ),

            -- Params
            Params = (
                SELECT 
                    Market = NULL,
                    TruckType = NULL,
                    Terminal = NULL,
                    PrePullLocation = NULL,
                    StopOffLocation = NULL,
                    YardPortType = NULL,
                    YardShuttleFrom = NULL,
                    YardShuttleTo = NULL,
                    OrderType = NULL,
                    City = NULL,
                    [State] = NULL
                FOR JSON PATH
            ),

            -- Reasons
            Reasons = (
                SELECT 
                    DrayBaseReason = @Reason,
                    DryRunReason = @DryRunReason
                FOR JSON PATH
            )
        FOR JSON PATH
    );

    -- Return the JSON result
    -- SELECT @JsonOutput AS JsonResult;

	If @Status = 1
	Begin
		Set @Reason = 'SUCCESS'
	End

	drop table #LineItemDetails
	drop table #ContainerSummary
	drop table #Summary
END
