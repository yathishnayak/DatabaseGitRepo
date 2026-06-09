CREATE PROCEDURE [dbo].[Update_OrderHeader]
@OrderKey			INT,
@CustKey			int,
@BillToAddrKey		INT,
@CsrKey				INT=NULL,
@CSRManagerKey		int,
@SalesPersonKey		int,
@SourceAddrKey		INT,
@DestinationAddrkey INT,
@ReturnAddrKey		INT=NULL,
@OrderTypeKey		SMALLINT=NULL,
@StatusKey			SMALLINT,
@BrokerKey			INT=NULL,
@BrokerRefNo		VARCHAR(50)=NULL,
@CarrierKey			INT=NULL,
@VesselName			VARCHAR(50)=NULL,
@BillOfLading		VARCHAR(50)=NULL,
@DropLive			NVARCHAR(10)='',
@BookingNo			VARCHAR(50)=NULL,
@PriorityKey		SMALLINT,
@Ach_Enabled		BIT=NULL,
@Ach_Amount			DECIMAL(18,2)=NULL,
@Comment			VARCHAR(500)=NULL,
@CreateUserKey		INT,
@ETADate			DATETIME=NULL,
@BaseRateAmount		DECIMAL(18,2),
@OrderNo			varchar(20),
@MarketLocationKey	INT=0,
@SteamShipLinekey   INT= 0,
@Consignee			NVARCHAR(100)='',
@ConsigneeKey		INT,
@OutPut				BIT OUT,
@SenderInfo			NVARCHAR(100)

AS
BEGIN
    SET @OrderNo= Replace(REPLACE(@Orderno,'-',''),'.','')
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @New_CommentKey INT;
	DECLARE @CustomerKey INT;
	DECLARE @OrderStatusKey SMALLINT;	
	DECLARE @OrderHoldStausKey SMALLINT;
	DECLARE @CreditLimt DECIMAL(18,2);
	DECLARE @HoldReasonKey SMALLINT;
	DECLARE @OldOrderStatusKey SMALLINT
	DECLARE @OrderDetailOpenStatus smallInt

	--IF(@PriorityKey=0)
	--BEGIN
	--	SET @PriorityKey=(SELECT PriorityKey FROM Priority WHERE Description='Low')
	--END
	
	if(isnull(@BillToAddrKey,0) = 0)
	Begin
		SELECT @BillToAddrKey=Addrkey from Customer where CustKey=@CustKey
	End

	DECLARE @PrevOrderNo	varchar(20)
	Select @PrevOrderNo = OrderNo  from OrderHeader where OrderKey = @OrderKey
	if(@OrderNo != @PrevOrderNo)
	Begin
		Declare @CommentKey int = 0, @OrderNoComment varchar(100)
		set @OrderNoComment = 'Order No changed from ' + @PrevOrderNo + '  to ' + @OrderNo
		Exec Insert_comment @OrderNoComment , '', @CreateUserKey,0,0, @CommentKey Output
		if(@CommentKey > 0)
		Begin
			Exec Insert_OrderHeaderComment @OrderKey, @CommentKey
		End
	End

	IF @ReturnAddrKey='' 
	BEGIN
		SET @ReturnAddrKey=NULL
	END

	IF @CarrierKey='' 
	BEGIN
		SET @CarrierKey=NULL
	END

	IF @BrokerKey='' 
	BEGIN
		SET @BrokerKey=NULL
	END

	SET @OldOrderStatusKey = ( SELECT [Status] FROM OrderHeader WHERE OrderKey= @OrderKey )

	SET @OrderHoldStausKey=( SELECT [Status] FROM OrderStatus WHERE [Description]='On Hold' )

	SET @OrderStatusKey= ( SELECT [Status] FROM OrderHeader WHERE OrderKey= @OrderKey )
	if(@OrderStatusKey is null)
	begin
		 SELECT @OrderStatusKey = [Status] from dbo.OrderStatus WHERE [Description]='Open'
	end

	--SET @CustomerKey = ( SELECT CustKey FROM dbo.OrderHeader WHERE OrderKey= @OrderKey )

	SET @CreditLimt= (SELECT ISNULL(CreditLimit,0) FROM dbo.Customer WHERE CustKey=@CustKey )

	IF (@OrderStatusKey=@OrderHoldStausKey)
	BEGIN
		IF ISNULL( @Ach_Amount,0)<=0 AND @CreditLimt<=0
		BEGIN
			SET @OrderStatusKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='On Hold' )
			SET @HoldReasonKey= ( SELECT HoldReasonKey FROM Holdreason WHERE [Description]='Credit Hold')
		END

		IF ISNULL( @Ach_Amount,0)>0 AND @CreditLimt<=0
		BEGIN
			SET @OrderStatusKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )
			SET @HoldReasonKey= NULL
		END

		IF @CreditLimt>0
		BEGIN
			SET @OrderStatusKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )
			SET @HoldReasonKey= NULL
		END
	END

	if(RIGHT(@OrderNo,3) = 'XXX')
	Begin
		DECLARE @CNT INT = 0
		SELECT @CNT = COUNT(1) 
		FROM 
		(select CustKey, OrderNo from OrderHeader where custkey = @CustKey 
		union all
		select CustKey,OrderNo  cnt from OrderHeader_Deleted where CustKey = @CustKey
		) A WHERE CustKey= @CustKey

		SET @CNT = ISNULL(@CNT,0) + 1
		
		SET @OrderNo = REPLACE(@OrderNo,'XXX',case when @cnt < 100 then 
			substring( CONVERT(VARCHAR,100 + @CNT),2,2)
			else CONVERT(VARCHAR,100 + @CNT) END)
	End

	UPDATE dbo.OrderHeader 
	SET  CsrKey = @CsrKey,   OrderNo = @OrderNo,  CustKey = @CustKey, BillToAddrKey=@BillToAddrKey,   
				SourceAddrKey=@SourceAddrKey,  DestinationAddrKey=@DestinationAddrkey,  
				OrderTypeKey=@OrderTypeKey, [status]=@OrderStatusKey, Ach_Enabled= @Ach_Enabled,
				Ach_Amount=@Ach_Amount,
				StatusDate =GETDATE(), BrokerRefNo=@BrokerRefNo, 
				VesselName=@VesselName, BillOfLading=@BillOfLading, BookingNo=@BookingNo, 
				PriorityKey=CASE WHEN @PriorityKey=0 THEN null ELSE @PriorityKey END, LastUpdateDate=GETDATE(), CreateUserKey=@CreateUserKey,
				HoldReasonKey= @HoldReasonKey,ReturnAddrKey=@ReturnAddrKey,CarrierKey= @CarrierKey,BrokerKey=@BrokerKey,
				ETADate=@ETADate,BaseRateAmount=@BaseRateAmount,
				CSRManagerKey = @CSRManagerKey, SalesPersonKey = @SalesPersonKey, MarketLocationKey=@MarketLocationKey,
				SteamShipLinekey = @SteamShipLinekey, Consignee=@Consignee, ConsigneeKey=@ConsigneeKey, DropLive=@DropLive,SenderInfo=@SenderInfo
	WHERE OrderKey =@OrderKey ;

	Update dbo.OrderDetail
	set SourceAddrKey = @SourceAddrKey, DestinationAddrKey = @DestinationAddrkey
	where orderkey = @OrderKey

	SELECT  @OrderDetailOpenStatus = [Status] from dbo.OrderDetailStatus WHERE [Description]='Open'

	update dbo.OrderDetail
	set [Status] = @OrderDetailOpenStatus
	where OrderKey = @OrderKey and [Status] is null

	UPDATE dbo.OrderDetail
	SET [Status]= CASE	WHEN [Status]=11  AND @OrderStatusKey<>8 THEN 1
						WHEN [Status]<>11 AND @OrderStatusKey=8 THEN 11
						WHEN [Status]<>11 AND @OrderStatusKey<>8 THEN  [Status] END
	WHERE OrderKey= @OrderKey

	
		
	IF ISNULL(RTRIM(LTRIM(@Comment)),'')<>''
	BEGIN
		IF  (	SELECT COUNT(1) 
				FROM dbo.Comment CM
					INNER JOIN OrderHeaderComments OHC ON OHC.CommentKey=CM.CommentKey  
				WHERE [Description]= @Comment AND OHC.OrderKey= @OrderKey
			 )=0
		BEGIN
			INSERT INTO dbo.Comment([Description],CreateDate,CreateUserKey)
			VALUES (@Comment, GETDATE(),@CreateUserKey);
		
			SET @New_CommentKey= ( SELECT SCOPE_IDENTITY() ) ;

			INSERT INTO dbo.OrderHeaderComments(OrderKey,CommentKey)
			VALUES (@OrderKey, @New_CommentKey);
		END	 
	END
	
	SET @OutPut=1
END
