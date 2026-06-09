CREATE PRocedure [dbo].[Insert_InvoiceLine]
@InvoiceKey			INT,
@ItemKey			INT,
@Qty				DECIMAL(18,5),
@UnitPrice			DECIMAL(18,5),
@Container			VARCHAR(50),
@Charge				DECIMAL(18,5),
@SellPrice			decimal(18,5),
@freeTime			smallint,
@BvsNB				varchar(2),
@MinVal				int,
@MaxVal				int,
@UserKey			INT,
@TimeDuration		VARCHAR(10),
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;
	declare @InvoiceLineKey	int = 0

	DECLARE @OrderDetailKey INT
	declare @InvoiceTotal decimal(18,5) = 0, @NewInvoiceAmount decimal(18,5) = 0, @IsPayReceived bit = 0
	select @InvoiceTotal = InvoiceAmount, @IsPayReceived = IsPaymentReceived from InvoiceHeader where InvoiceKey = @Invoicekey
	Set @Container = replace(ltrim(rtrim(@Container)),' ','')

	SET @OrderDetailKey= (	
							SELECT DISTINCT TOP 1 OD.OrderDetailKey 
							FROM InvoiceDetail ID 
								INNER JOIN dbo.InvoiceHeader IH ON IH.InvoiceKey=ID.InvoiceKey
								INNER JOIN dbo.OrderDetail OD ON OD.OrderKey=IH.OrderKey
							WHERE IH.InvoiceKey=@InvoiceKey --AND ID.Container= @Container 
								AND ltrim(rtrim(OD.ContainerNo)) = @Container
						 )

	SET @UnitPrice = ( SELECT CASE WHEN ISNULL(@UnitPrice,0)=0 THEN UnitCost ELSE @UnitPrice END FROM Item WHERE ItemKey= @ItemKey );

	DECLARE @ItemDescription VARCHAR(255);

	SET @ItemDescription= ( SELECT [Description] FROM Item WHERE ItemKey= @ItemKey )	;
		
	INSERT INTO [dbo].Invoicedetail([InvoiceKey], [ItemKey], [Description], [UnitPrice], [Qty], [ExtAmt], 
									[Container], [CreateUserKey], [CreateDate],OrderDetailKey, Charges,
									SellPrice, BvsNB, FreeTime, Minval, MaxVal,TimeDuration)
	VALUES ( @InvoiceKey,@ItemKey,@ItemDescription,@UnitPrice,@Qty,(@UnitPrice*@Qty),@Container,@UserKey,GETDATE(),@OrderDetailKey,@Charge,
			@SellPrice, @BvsNB, @FreeTime, @MinVal, @MaxVal,@TimeDuration);
	set @InvoiceLineKey = SCOPE_IDENTITY()

	insert into InvoiceDetail_SellPriceLog (InvoiceLineKey, LogDate, ItemKey, UnitPrice, Qty, ExtAmt, Container, Charges, 
		SellPrice, BvsNB, FreeTime,	Minval, MaxVal, UserKey)
	select InvoiceLineKey, GetDate(), ItemKey, UnitPrice, Qty, ExtAmt, Container, Charges, 
		SellPrice, BvsNB, FreeTime,	Minval, MaxVal, CreateUserKey 
		from Invoicedetail 
	where InvoicelineKey = @InvoiceLineKey

	SELECT @NewInvoiceAmount = SUM(ExtAmt) FROM dbo.Invoicedetail WHERE InvoiceKey=@Invoicekey and isnull(BvsNB ,'NB') = 'B'

	UPDATE dbo.InvoiceHeader
	SET InvoiceAmount= @NewInvoiceAmount,
		IsPaymentReceived = case when @InvoiceTotal = @NewInvoiceAmount then @IsPayReceived else 0 end,
		StatusKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then 2 else StatusKey end,
		PaymentRecdDate = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdDate end,
		PaymentRecdUserKey = case when @InvoiceTotal <> @NewInvoiceAmount and StatusKey = 3 then null else PaymentRecdUserKey end
	WHERE InvoiceKey= @InvoiceKey;
	
	SET @OutPut=1;
END
