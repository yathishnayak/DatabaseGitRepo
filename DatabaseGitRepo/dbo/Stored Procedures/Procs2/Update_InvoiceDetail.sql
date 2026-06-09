

CREATE PRocedure [dbo].[Update_InvoiceDetail]
@Invoicelinekey		INT,
@Invoicekey			INT,
@Container			VARCHAR(50),
@Qty				DECIMAL(18,5),
@UnitPrice			DECIMAL(18,5),
@Charge				DECIMAL(18,5),
@SellPrice			decimal(18,5),
@freeTime			smallint,
@BvsNB				varchar(2),
@MinVal				int,
@MaxVal				int,
@InvoiceCompanyKey  INT=0,
@UserKey			INT,
@TimeDuration		VARCHAR(10),
@OutPut				BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	IF @Invoicelinekey IS NULL OR @Invoicelinekey =0 OR @Invoicekey IS NULL OR @Invoicekey =0
	BEGIN
		SET @OutPut=0;
		RETURN
	END	

	declare @InvoiceTotal decimal(18,5) = 0, @NewInvoiceAmount decimal(18,5) = 0, @IsPayReceived bit = 0
	select @InvoiceTotal = InvoiceAmount, @IsPayReceived = IsPaymentReceived from InvoiceHeader where InvoiceKey = @Invoicekey

	insert into InvoiceDetail_SellPriceLog (InvoiceLineKey, LogDate, ItemKey, UnitPrice, Qty, ExtAmt, Container, Charges, 
		SellPrice, BvsNB, FreeTime,	Minval, MaxVal, UserKey)
	select InvoiceLineKey, GetDate(), ItemKey, @UnitPrice, @Qty, (@Qty*@UnitPrice), @Container, @Charge, 
		@SellPrice, @BvsNB, @FreeTime,	@Minval, @MaxVal, @UserKey 
	from Invoicedetail 
	where InvoicelineKey = @InvoiceLineKey and ( UnitPrice <> @UnitPrice OR Qty <> @Qty OR
			Charges <> @Charge OR SellPrice <> @SellPrice OR BvsNB <> @BvsNB OR 
			FreeTime <> @freeTime OR Minval <> @MinVal OR MaxVal <> @MaxVal)

	UPDATE dbo.Invoicedetail
	SET Container= @Container, UnitPrice= @UnitPrice, Qty= @Qty, Extamt= (@Qty*@UnitPrice),UpdateUserKey=@UserKey,UpdateDate=GETDATE(), 
		Charges=@Charge, SellPrice = @SellPrice, FreeTime = @freeTime, Minval = @MinVal, MaxVal = @MaxVal, BvsNB = @BvsNB, TimeDuration=@TimeDuration
	WHERE Invoicelinekey = @Invoicelinekey and Invoicekey =@Invoicekey;  

	SELECT @NewInvoiceAmount = SUM(ExtAmt) FROM dbo.Invoicedetail WHERE InvoiceKey=@Invoicekey

	UPDATE dbo.InvoiceHeader
	SET InvoiceAmount= @NewInvoiceAmount,InvoiceCompanyKey=@InvoiceCompanyKey,
		IsPaymentReceived = case when @InvoiceTotal = @NewInvoiceAmount then @IsPayReceived else 0 end,
		StatusKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then 2 else StatusKey end,
		PaymentRecdDate = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdDate end,
		PaymentRecdUserKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdUserKey end
	WHERE InvoiceKey=@Invoicekey;

	update invoicedetail set  timeduration = null where InvoiceKey = @Invoicekey and  TimeDuration = ''
	SET @OutPut=1;
END

