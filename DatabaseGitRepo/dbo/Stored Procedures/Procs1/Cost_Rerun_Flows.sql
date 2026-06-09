
/*	73164, , 10035
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '94052',   @JsonOutput nvarchar(max) ='',
			@Status	bit = 0, @Reason varchar(500) = '', @debug bit = 1

	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '6',   @JsonOutput nvarchar(max) ='',
			@Status	bit = 0, @Reason varchar(500) = '', @debug bit = 0
	EXEC [Cost_Rerun_Flows] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug = 1

*/
CREATE PROC [dbo].[Cost_Rerun_Flows]
(
	@InvoiceKey				int	= 0,
	@InvoiceNo				varchar(50) = '',
	@JsonOutput				nvarchar(max) ='' OUTPUT,
	@Status					bit = 0 output,
	@Reason					varchar(500) = '' output,
	@debug					bit = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(isnull(@InvoiceKey,0) = 0 AND ISNULL(@InvoiceNo,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invoice Parameters not received'
		RETURN
	END
	IF(isnull(@InvoiceKey,0) = 0)
	BEGIN
		select @InvoiceKey = InvoiceKey From InvoiceHeader where InvoiceNo = @InvoiceNo
	End
	SET @Status = 1

	DECLARE @IsApproved			bit = 0,
			@IsRerunExists		bit = 0,
			@BI_Data_Exists		bit = 0,
			@IsSpotOn			bit  = 0,
			@CustomerSegment	varchar(5) = '',
			--@JsonOutput			nvarchar(max) = '',
			@JsonInput			nvarchar(max) = ''

	DECLARE	@BI_Existsance TABLE (BI_Exists BIT)

	select @IsApproved = case when StatusKey <> 1 then 1 else 0 end
						 from InvoiceHeader where invoicekey = @InvoiceKey

	IF (@IsApproved = 0)
	BEGIN
		if (@Debug = 1)
		Begin
			select @IsApproved as IsApproved
		End
		EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
		Select @JsonOutput as JsonResult

		EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
	END

	IF (@IsApproved = 1)
	BEGIN
		if (@Debug = 1)
		Begin
			select @IsApproved as IsApproved
		End
		SELECT @IsRerunExists = case when count(1) > 0 then 1 else 0 end
								from Cost_BI_Rerun where InvoiceNo = @InvoiceNo

		IF (@IsRerunExists = 1)
		BEGIN
			if (@Debug = 1)
			Begin
				select @IsRerunExists as IsRerunExists
			End
			EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
			Select @JsonOutput as JsonResult

			EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
		END

		IF (@IsRerunExists = 0)
		BEGIN
			if (@Debug = 1)
			Begin
				select @IsRerunExists as IsRerunExists
			End
			EXEC [Cost_BI_Data_Exists] @InvoiceNo, @is_BI_DataExists = @BI_Data_Exists output
			IF (@BI_Data_Exists = 0)
			BEGIN
				if (@Debug = 1)
				Begin
					Select @BI_Data_Exists as BI_Data_Exists
				End
				EXEC [Cost_OutputByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
				Select @JsonOutput as JsonResult

				EXEC Cost_BI_ProcessInvoiceCosts_SingleInvoice @InvoiceNo, @JsonOutPut, @Status, @Reason
			END

			IF (@BI_Data_Exists = 1)
			BEGIN
				if (@Debug = 1)
				Begin
					Select @BI_Data_Exists as BI_Data_Exists
				End

				EXEC [Cost_BI_Fetch_DataByInvoice] @InvoiceKey, @InvoiceNo, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @debug
				Select @JsonOutput as JsonResult
				--
				--
				--
			END
		END
	END
END