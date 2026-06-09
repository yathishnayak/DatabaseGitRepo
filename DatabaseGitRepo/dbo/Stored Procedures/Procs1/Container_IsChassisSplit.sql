CREATE PROCEDURE [dbo].[Container_IsChassisSplit]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	
	--SELECT 1 AS SerialNo,@JSONString AS Request INTO Temp_ChassiSplit
	DECLARE @RouteKey	INT= 1, @IsChassisSplit	BIT=0, @USerName VARCHAR(100),
			@CommentKey INT, @Comment VARCHAR(500)='', @OrderDetailKey INT, @ContainerNo VARCHAR(20)=''

	SELECT @RouteKey = RouteKey, @IsChassisSplit = IsChassisSplit
	FROM OPENJSON(@JSONString,'$')
    WITH (
			RouteKey		INT     '$.RouteKey',
			IsChassisSplit	BIT		'$.IsChassisSplit'
		)

	SELECT @USerName = ISNULL(UserName,'') FROM [User] WITH (NOLOCK) WHERE UserKey = @UserKey

	SET @Status=0;
	SET @Reason='Failure';
	SET @OrderDetailKey =(SELECT TOP 1 OrderDetailKey FROM [Routes] WITH (NOLOCK) WHERE RouteKey=@RouteKey)
	SELECT @ContainerNo=ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey
	IF(@IsChassisSplit=1)
	BEGIN
		Create Table #Params
		(
			OrderDetailKey			int,
			MarketLocationKey		int,
			Market					varchar(100),
			Terminal				varchar(100),
			City					varchar(100),
			State					varchar(100),
			Location				varchar(100),
			ZoneKey					int,
			ZoneName				varchar(100),
			ContainerNo				varchar(20),
			TruckType				varchar(50),
			CustKey					int,
			CustName				varchar(200)
		)

		insert into #Params
		exec Auto_ReturnsParameters @OrderDetailKey = @OrderDetailKey, @isDebug = 0

		Declare 
			@ItemKeys				varchar(500), -- Colon separated itemkeys
			@MarketKey				int = 0,
			@Terminal				varchar(50) = '',
			@Location				varchar(100) = '',
			@city					varchar(100) = '',
			@State					varchar(20) = '',
			@TruckType				varchar(50) = '',
			@CustKey				int = 0,
			@IsGeneralNAC			Bit = 1 -- When 1, then Ignore custKey and use General Data in NAC

		select @MarketKey = MarketLocationKey, @Terminal = Terminal, @Location = Location,
				@City = city, @State = State, @TruckType = TruckType, @CustKey = CustKey, @IsGeneralNAC = 1
		from #Params

		CREATE Table #ItemsAcc
		(
			RecordSL		int,
			LineItem		varchar(200),
			Market			varchar(100),
			Terminal		varchar(100),
			ItemKey			int,
			Rate			numeric(18,4),
			BvsNB			varchar(2),
			Freetime		int,
			MinCnt			int,
			MaxCnt			int,
			EffectiveDate	DateTime,
			EffectiveDateFrom	varchar(50),
			CostGroup			varchar(50),
			FileName			varchar(200),
			DateUploaded		Datetime,
			UploadedBy			varchar(200)
		)
	
		SEt @ItemKeys = '139:'

		insert into #ItemsAcc
		Exec AUTO_SELL_CalcAccessorialValueByOrderDetailKey @ItemKeys, @MarketKey,@OrderDetailKey, @ContainerNo	,
			@Terminal, @Location, @city	, @State, @TruckType, @CustKey,@IsGeneralNAC, 0
			Print '1' 
		IF((SELECT COUNT(1) FROM OrderExpense WITH (NOLOCK) WHERE RouteKey=@Routekey AND ItemKey=139)>0)
		BEGIN
		Print '2'
			UPDATE OrderExpense SET Qty=Qty+1 WHERE RouteKey=@RouteKey AND Itemkey=139
		END
		ELSE
		BEGIN
			Print '3' 
			insert into OrderExpense (Itemkey, Routekey, UnitCost, Qty, NewUnitCost, CreateDate, CreateUserKey, FreeTime, 
				BvsNB, MinCnt, MaxCnt, ChargeSource, OrderDetailKey, DateFrom, DateTo)
			Select I.ItemKey, @RouteKey, ISNULL(a.RATE, I.UnitCost), 1, ISNULL(a.RATE, I.UnitCost), Getdate(),  
				1, 0, 1, 0, 0, 'Auto', @OrderDetailKey, null, null
			from Item I With (NOLOCK)
			LEFT JOIN #ItemsAcc A ON i.ItemKey = A.ItemKey
			where I.itemkey = 139
		END
		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'ChssisSplitCheckBox', 'Text' , 'Chassis Item Added for Container '
	END
	ELSE
	BEGIN
		UPDATE OrderExpense SET Qty=Qty-1 WHERE RouteKey=@RouteKey AND Itemkey=139

		INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		Select GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'ChssisSplitCheckBox', 'Text' , 'Chassis Item removed for Container '
	END
	IF(ISNULL(@IsChassisSplit ,0) =1)
	BEGIN
		UPDATE Routes SET
				IsChassisSplit = 1, 
				ChassisSplitBy = @UserKey, 
				ChassisSplitDate = GETDATE(),
				LastUpdateDate=GETDATE(),
				UpdateUserKey=@UserKey
		WHERE RouteKey = @routeKey	
		SET @Comment = 'Container Leg Marked ChassisSplit by ' + @USerName + ' on ' + CONVERT(VARCHAR, GETDATE(),101) + ' ' + CONVERT(VARCHAR, GETDATE(),108);	
	END
	
	IF(ISNULL(@IsChassisSplit ,0) =0)
	BEGIN
		UPDATE Routes SET
				IsChassisSplit = 0, 
				ChassisSplitBy = null, 
				ChassisSplitDate = null,
				LastUpdateDate=GETDATE(),
				UpdateUserKey=@UserKey
		WHERE RouteKey = @routeKey	
		SET @Comment = 'Container Leg UnChecked ChassisSplit by ' + @USerName + ' on ' + CONVERT(VARCHAR, GETDATE(),101) + ' ' + CONVERT(VARCHAR, GETDATE(),108);		
	END
	INSERT INTO  AuditLogDetail	(DateCreated,CreateUser,RefType,RefId,Stage,CommentType,Comments,RefKey)
	VALUES(GETDATE(),@UserName,'Container',
		(SELECT ContainerNo FROM OrderDetail WITH (NOLOCK) WHERE OrderDetailKey=@OrderDetailKey),null,'Text',@Comment,@OrderDetailKey)

	SET @Status=1
	SET @Reason='Success'
END