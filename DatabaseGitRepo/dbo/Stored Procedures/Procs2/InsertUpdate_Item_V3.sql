/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceItemDesc":"Invoice_desc","ItemID":"17207","Description":"Test_Item","ItemTypeKey":"1","UnitCost":1000,"PriceBasisKey":"1","StatusKey":"1","EDICode":"DFS","CategoryKey":"1","CostGrp":"3","InternalCost":17207}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InsertUpdate_Item_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_Item_V3]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '{"ItemID":7,"ItemTypeKey":"5","ItemID":"YARD PRE PULL 1ST SHIFT","Description":"YARD PRE PULL 1ST SHIFT","UnitCost":103,"ItemType":"Driver Expenses","CreateDate":"2021-06-14T00:00:00","PriceBasisDescription":"Fixed Charge","StatusName":"Active","StatusKey":1,"PriceBasisKey":1,"InvoiceItemDesc":"YARD PRE PULL 1ST SHIFT","CostGrpDescription":"Pre Pull","CostGrp":"5","CategoryKey":"2","EDICode":"ACF","InternalCost":4}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @ItemID				VARCHAR(30),
			@Description		VARCHAR(255),
			@ItemTypeKey		SMALLINT,
			@UnitCost			DECIMAL(18,2),
			@PriceBasisKey		SMALLINT,
			@InvoiceItemDesc	VARCHAR(100),
			@EDIChargeCode		VARCHAR(3),
			@Costgroup			INT,
			@InternalCost		DECIMAL(18,2),
			@CategoryKey		INT,
			@ItemKey			INT,
			@StatusKey			INT

	SELECT				@ItemID = ItemID, @Description = Description, @ItemTypeKey = ItemTypeKey, @UnitCost = UnitCost, @PriceBasisKey = PriceBasisKey
						,@InvoiceItemDesc = InvoiceItemDesc, @EDIChargeCode = EDIChargeCode, 
						@Costgroup = Costgroup, @InternalCost = InternalCost, @CategoryKey = CategoryKey, @itemkey = itemkey , @StatusKey = StatusKey
	FROM OPENJSON		(@JSONString, '$')
						WITH (
								ItemID				VARCHAR(30)		'$.ItemID',
								Description			VARCHAR(255)	'$.Description',
								ItemTypeKey			SMALLINT		'$.ItemTypeKey',
								UnitCost			DECIMAL(18,2)	'$.UnitCost',
								PriceBasisKey		SMALLINT		'$.PriceBasisKey',
								InvoiceItemDesc		varchar(100)	'$.InvoiceItemDesc',
								EDIChargeCode		VARCHAR(3)		'$.EDICode',
								Costgroup			INT				'$.CostGrp',
								InternalCost		DECIMAL(18,2)	'$.InternalCost',
								CategoryKey			INT				'$.CategoryKey',
								ItemKey				INT				'$.ItemKey',
								StatusKey			INT				'$.StatusKey'
							 )
	
	--select @ItemTypeKey,@ItemKey
	IF(ISNULL(@ItemKey,0) = 0)
	BEGIN

	IF EXISTS (SELECT 1 FROM dbo.Item WHERE ItemID = @ItemID)
		BEGIN
				SET @Status = 0
				SET @Reason = 'ItemID already exists'
			 RETURN
		END
			INSERT INTO		dbo.Item(ItemID, [Description],UnitCost,ItemTypeKey,PriceBasisKey,StatusKey,CreateDate,StatusDate, InvoiceItemDesc,EDICode,CostGrp,InternalCost,CategoryKey)	
			SELECT			@ItemID,@Description,@UnitCost,@ItemTypeKey,@PriceBasisKey,1,GETDATE(),GETDATE(), @InvoiceItemDesc, @EDIChargeCode,@Costgroup,@InternalCost,@CategoryKey
			SET				@ItemKey = SCOPE_IDENTITY()
			UPDATE Item SET MasterItemKey=@ItemKey WHERE ItemKey=@ItemKey AND ItemID=@ItemID

		SET @Status = 1
		SET @Reason = 'Item Added SuccessFully'

		END
	ELSE
		BEGIN
		
			UPDATE	dbo.Item 
			SET		ItemID					= @ItemID ,
					[Description]			= @Description,
					ItemtypeKey				= @ItemTypeKey ,
					UnitCost				= @UnitCost,
					StatusKey				= @StatusKey,
					StatusDate				= getdate(),
					PriceBasisKey			= @PriceBasisKey,
					InvoiceItemDesc			= @InvoiceItemDesc,
					EDICode					= @EDIChargeCode,
					CostGrp					= @Costgroup,
					InternalCost			= @InternalCost,
					CategoryKey				= @CategoryKey
			 WHERE	Itemkey = @ItemKey	
			 
		DECLARE @Comments  nvarchar(max),@UserName nvarchar(100);
 
		SELECT @UserName=ISNULL(UserName,'') from [User] where UserKey=@UserKey;
 
		INSERT INTO dbo.AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
		SELECT DISTINCT GETDATE(),@UserName,'Item',@ItemID,@ItemKey,NULL, 'Text','Item ' + @ItemID + '  Updated by ' +   @UserName

		SET @Status = 1
		SET @Reason = 'Item Updated SuccessFully'

		END
	
	
END