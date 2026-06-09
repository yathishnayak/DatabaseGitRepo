CREATE Procedure [dbo].[Insert_OrderHeader]
	@OrderNo		 VARCHAR(200),
	@OrderDate		 DATETIME,
	@CustKey		 INT,
	@BillToAddrKey   INT,
	@Csrkey			 INT=NULL,
	@CSRManagerKey	 int,
	@SalesPersonKey	 int,
	@SourceAddrkey	 INT,
	@DestAddrkey	 INT,
	@ReturnAddrkey	 INT= NULL,
	@OrderTypeKey	 SMALLINT,
	@Status			 SMALLINT=12,
	@BrokerKey		 INT=NULL,
	@BrokerrefNo	 VARCHAR(100)=NULL,
	@CarrierKey		 INT=NULL,
	@VesselName		 VARCHAR(100)=NULL,
	@BillOfLading	 VARCHAR(100)=NULL,
	@DropLive			NVARCHAR(10)='',
	@BookingNo		 VARCHAR(100)=NULL,
	@Ach_Enabled	 SMALLINT=NULL,
	@Ach_Amount		 DECIMAL(18,2)=null,
	@IsHazardous	 BIT=0,
	@IsOverWeight	 BIT=0,
	@IsTriaxle		 BIT=0,
	@NeedsTobeScaled BIT=0,
	@PriorityKey	 SMALLINT=Null,
	@Comment		 VARCHAR(max)=NULL,
	@CreateUserkey	 INT,
	@ETADate		 DATETIME=NULL,
	@BaseRateAmount	 DECIMAL(18,2),
	@MarketLocationKey	INT,
	@SteamShipLinekey  INT,
	@Consignee			NVARCHAR(100)='',
	@ConsigneeKey		INT,
	@OrderKey			INT OUTPUT,
	@SenderInfo			NVARCHAR(100)=''
AS
BEGIN
        SET @OrderNo= Replace(REPLACE(@Orderno,'-',''),'.','')

		SET NOCOUNT ON
		SET FMTONLY OFF

		DECLARE @NewCommentKeyOut INT
		DECLARE @NewOrderKeyOut   INT
		DECLARE @Ouput			  BIT
		DECLARE @CustomerKey	  INT
		DECLARE @OrderStausKey SMALLINT
		DECLARE @CreditLimt DECIMAL(18,2)
		DECLARE @HoldReasonKey SMALLINT
		DECLARE @ESTDATE DATETIME
		--*********************Time Zone to EST*********

		SET @OrderDate= ( SELECT dbo.EST_GetDateTime() )

		--SET @ESTDATE= ( SELECT dbo.EST_GetDateTime() )

		--**********************************************
		SET @HoldReasonKey= NULL

		SET @CreditLimt= (SELECT ISNULL(CreditLimit,0) FROM dbo.Customer WHERE CustKey=@CustKey )

		SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )

		SET @CustomerKey = ( SELECT  CustKey  FROM dbo.OrderHeader WHERE OrderKey= @OrderKey )

		IF @CreditLimt <= 0 AND ISNULL(@Ach_Amount,0)<=0 AND @Ach_Enabled = 1
		BEGIN
			SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='On Hold' )
			SET @HoldReasonKey= ( SELECT HoldReasonKey FROM Holdreason WHERE [Description]='Credit Hold' )
		END

		IF  @CreditLimt <= 0 AND ISNULL(@Ach_Amount,0)>0
		BEGIN
			SET @OrderStausKey = ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )
		END

		IF  @CreditLimt > 0  
		BEGIN
			SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='OPen' )
		END
		
		IF @Csrkey=0 OR @Csrkey=''
		BEGIN
			SET @Csrkey=NULL
		END

		SET @Ouput=0
		IF @BrokerKey=0 
		BEGIN 
			SET @BrokerKey=NULL
		END

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

		INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
					SourceAddrKey,  DestinationAddrKey,  ReturnAddrKey,
					OrderTypeKey, [Status], HoldReasonKey,
					StatusDate, BrokerKey, BrokerRefNo, 
					CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
					IsHazardous,IsOverWeight,IsTriaxle,NeedsTobeScaled, [PriorityKey], CreateDate, 
					CreateUserKey,BillToAddrKey,ETADate,BaseRateAmount,
					SalesPersonKey, CSRManagerKey, MarketLocationKey,SteamShipLinekey,Consignee,ConsigneeKey,DropLive,SenderInfo  )
		VALUES (
					@OrderNo, @OrderDate, @Csrkey,@CustKey, @SourceAddrkey, @DestAddrkey,    
					@ReturnAddrkey,@OrderTypeKey, @OrderStausKey,@HoldReasonKey, GETDATE(),@BrokerKey, @BrokerrefNo, 
					@CarrierKey, @VesselName, @BillOfLading, @BookingNo, @Ach_Enabled,@Ach_Amount,
					@IsHazardous,@IsOverWeight,@IsTriaxle,@NeedsTobeScaled, @PriorityKey, GETDATE(), @CreateUserkey
					,@BillToAddrKey,@ETADate,@BaseRateAmount
					,@SalesPersonKey, @CSRManagerKey, @MarketLocationKey,@SteamShipLinekey, @Consignee,@ConsigneeKey,@DropLive,@SenderInfo
				)

		SET @NewOrderKeyOut =( SELECT SCOPE_IDENTITY() )

		--INSERT INTO DriverOrder (OrderKey)
		--SELECT @NewOrderKeyOut

		UPDATE dbo.OrderHeader
		SET BillToAddrKey= @BillToAddrKey -- ( SELECT AddrKey FROM Customer WHERE CustKey= @CustKey )
		WHERE OrderKey=@OrderKey
		
		IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''		
		BEGIN
			INSERT INTO dbo.Comment(Description,CreateDate,CreateUserKey)
			VALUES (@Comment, GETDATE(),@CreateUserkey)

			SET @NewCommentKeyOut= ( SELECT SCOPE_IDENTITY() )

			INSERT INTO dbo.OrderHeaderComments(OrderKey,CommentKey)
			VALUES (@NewOrderKeyOut, @NewCommentKeyOut);		
		END				
			
		SET @OrderKey= @NewOrderKeyOut

		SET @Ouput=1

		SELECT @Ouput AS Result
END
