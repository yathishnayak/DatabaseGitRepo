

CREATE proc [dbo].[Rerun_Flow_Reethika]
(
   @Invoicekey    INT = 0,
   @InvoiceNo     VARCHAR(50) ='',
   @JsonOutput    NVARCHAR(max) = '' OUTPUT,
   @Status        BIT = 0 ,
   @Reason        VARCHAR(50) OUTPUT
)AS
BEGIN

	DECLARE  @IsApproved BIT = 0,       @JsonOutputData NVARCHAR(max) = '', 
	         @IsRerunExists BIT = 0,    @BI_Data_Exists BIT = 0

	SELECT @IsApproved = CASE WHEN  StatusKey <> 1 THEN 1 ELSE 0 END  FROM InvoiceHeader

	IF(@IsApproved = 0)
	BEGIN
	 -- EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT
		SELECT @JsonOutPut
		--EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
	END

	IF(@IsApproved = 1)
	BEGIN 
		SELECT @IsRerunExists = CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END
		FROM Cost_BI_Rerun WHERE InvoiceNo = @InvoiceNo

		IF(@IsRerunExists = 1)
		BEGIN
		--	EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
			SELECT @JsonOutPut
		--	EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
		END

		IF(@IsRerunExists = 0)
		BEGIN
			--EXEC [Cost_BI_Data_Exists_Pavan] @InvoiceNo, @JsonOutputData OUTPUT, @BI_Data_Exists OUTPUT

			IF (@BI_Data_Exists = 0)
			BEGIN
				--EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
				SELECT @JsonOutPut

				--EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
			END
		END
	END
	
END