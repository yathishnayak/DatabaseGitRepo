

CREATE Procedure [dbo].[CostBIDataExists_Reethika]
(
	@InvoiceNo VARCHAR(50) = '',
	@JsonOutput		NVARCHAR(MAX) ='' OUTPUT,
	@isBIDataExists BIT OUTPUT
)
AS
BEGIN
	DECLARE	@InvoiceKey		Int,
	        @count1 INT, @count2 INT, @count3 INT, @count4 INT, @finalcount INT

	SET @InvoiceKey = (SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
						WHERE IH.InvoiceNo = @InvoiceNo)

	SELECT @count1 = COUNT(1)
	FROM Cost_InvoiceProcessStatus IPS
	WHERE InvoiceKey IN (
	SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
	WHERE IH.InvoiceNo = @InvoiceNo) 
 
	SELECT @count2 = COUNT(1)
	FROM Cost_InvoiceItemSummary
	WHERE InvoiceSummaryKey IN (
	SELECT InvoiceSummaryKey 
	FROM InvoiceHeader IH WITH (NOLOCK)
	INNER JOIN Cost_InvoiceSummary CIS WITH (NOLOCK)  ON IH.InvoiceKey = CIS.InvoiceKey
	WHERE IH.InvoiceNo = @InvoiceNo)
 
	SELECT @count3 = COUNT(1)
	FROM Cost_InvoiceContainerSummary
	WHERE InvoiceSummaryKey IN (
	SELECT InvoiceSummaryKey 
	FROM InvoiceHeader IH WITH (NOLOCK) 
	INNER JOIN Cost_InvoiceSummary CIS ON IH.InvoiceKey = CIS.InvoiceKey
	WHERE IH.InvoiceNo = @InvoiceNo)
 
	SELECT @count4 = COUNT(1) 
	FROM Cost_InvoiceSummary ICS
	WHERE InvoiceKey IN (
	SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
	WHERE IH.InvoiceNo = @InvoiceNo)

	SET @finalcount = @count1 + @count2 + @count3 + @count4
	SET @isBIDataExists = CASE WHEN @finalcount = 0 THEN 0 ELSE 1 END

	IF(@finalcount > 0)
	BEGIN
		 PRINT @finalcount


		 CREATE TABLE #InvoiceSummary
	     (
			LineItem1			VARCHAR(100),
			LineItem1_Value		DECIMAL(18,3),
			LineItem2			VARCHAR(100),
			LineItem2_Value		DECIMAL(18,3),
			LineItem3			VARCHAR(100),
			LineItem3_Value		DECIMAL(18,3),
			LineItem4			VARCHAR(100),
			LineItem4_Value		DECIMAL(18,3),
			LineItem5			VARCHAR(100),
			LineItem5_Value		DECIMAL(18,3),
			LineItem6			VARCHAR(100), -- Dry run
			LineItem6_Value		DECIMAL(18,3), -- Dry run Value
			LineItem7			VARCHAR(100),  -- Bobtail
			LineItem7_Value		DECIMAL(18,3), -- Bobtail Value
			LineItem8			VARCHAR(100),  -- FSF
			LineItem8_Value		DECIMAL(18,3), -- FSF Value
			Total_text			VARCHAR(100),
			Total_value			DECIMAL(18,3)
	    )

	    DECLARE @DryRun_Value DECIMAL(18,2),
				@FSF_Value      DECIMAL(18,2),
				@Bobtail_Value  DECIMAL(18,2),
				@IsBobtail		BIT = 0

		SET @DryRun_Value  = (SELECT UnitCost FROM Cost_InvoiceItemSummary CIIS
							INNER JOIN Cost_InvoiceSummary CIS ON CIS.InvoiceSummaryKey = CIIS.InvoiceSummaryKey
							where LineItem LIKE 'Dry Run-%' AND CIS.InvoiceKey IN 
							(SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
							WHERE IH.InvoiceNo = @InvoiceNo))

		SET @Bobtail_Value = (SELECT DrayBase_Value FROM Cost_InvoiceSummary 
								WHERE InvoiceKey IN (SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
								WHERE IH.InvoiceNo = @InvoiceNo))

		IF(@IsBobtail = 1)
		BEGIN
			SET @Bobtail_Value = @Bobtail_Value/2
		END		
		ELSE
		BEGIN
			SET @Bobtail_Value = 0
		END

		SET @FSF_Value = (SELECT UnitCost FROM Cost_InvoiceItemSummary CIIS
						INNER JOIN Cost_InvoiceSummary CIS ON CIS.InvoiceSummaryKey = CIIS.InvoiceSummaryKey
						WHERE LineItem Like 'FUEL SURCHARGE FEE' AND CIS.InvoiceKey IN 
						(SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
								WHERE IH.InvoiceNo =  @InvoiceNo))

		INSERT INTO #InvoiceSummary (
			LineItem1, LineItem1_Value, 
			LineItem2, LineItem2_Value, 
			LineItem3, LineItem3_Value,
			LineItem4, LineItem4_Value, 
			LineItem5, LineItem5_Value,
			LineItem6, LineItem6_Value,
			LineItem7, LineItem7_Value,
			LineItem8, LineItem8_Value,
			Total_text, Total_value)
		SELECT	
			'PrePull_value',	 PrePull_value,			
			'YardShuttle_value', YardShuttle_value,	
			'StopOff_value',	 StopOff_value,			
			'DrayBase_Value',    DrayBase_Value,		
			'Accessorial_Value', Accessorial_Value,	
			'DryRun',            ISNULL(@DryRun_Value,0),
			'BobTail',           ISNULL(@Bobtail_Value,0),
			'FSF',               ISNULL(@FSF_Value,0),
			'Total_value',       Total_value				
			FROM Cost_InvoiceSummary 
			WHERE InvoiceKey IN (SELECT InvoiceKey FROM InvoiceHeader IH WITH (NOLOCK)
			WHERE IH.InvoiceNo = @InvoiceNo)

		SELECT 'Summary', * FROM #InvoiceSummary
	END
END

--SELECT top 1000 * FROM Cost_InvoiceSummary where InvoiceKey = 38845  
 
--SELECT top 1000 * FROM Cost_InvoiceContainerSummary where InvoiceSummaryKey =  168435 
 
--SELECT top 1000 * FROM Cost_InvoiceItemSummary where InvoiceSummaryKey = 168435
--InvoiceItemSummaryKey = 179854
 
--SELECT top 1000 * FROM Cost_InvoiceProcessStatus where InvoiceKey = 135005