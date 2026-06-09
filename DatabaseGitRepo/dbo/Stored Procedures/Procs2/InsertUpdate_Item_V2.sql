
CREATE PROCEDURE [dbo].[InsertUpdate_Item_V2]
/*
dbo.fn_insert_item
*/
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"itemkey":7,"ItemTypeKey":"5","itemid":"YARD PRE PULL 1ST SHIFT","description":"YARD PRE PULL 1ST SHIFT","unitcost":103,"ItemType":"Driver Expenses","CreateDate":"2021-06-14T00:00:00","PriceBasisDescription":"Fixed Charge","StatusName":"Active","StatusKey":1,"PriceBasisKey":1,"InvoiceItemDesc":"YARD PRE PULL 1ST SHIFT","CostGrpDescription":"Pre Pull","CostGrp":"5","CategoryKey":"2","EDICode":"ACF","InternalCost":3}',
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
								ItemID				VARCHAR(30)		'$.itemid',
								Description			VARCHAR(255)	'$.description',
								ItemTypeKey			SMALLINT		'$.ItemTypeKey',
								UnitCost			DECIMAL(18,2)	'$.unitcost',
								PriceBasisKey		SMALLINT		'$.PriceBasisKey',
								InvoiceItemDesc		varchar(100)	'$.InvoiceItemDesc',
								EDIChargeCode		VARCHAR(3)		'$.EDICode',
								Costgroup			INT				'$.CostGrp',
								InternalCost		DECIMAL(18,2)	'$.InternalCost',
								CategoryKey			INT				'$.CategoryKey',
								ItemKey				INT				'$.itemkey',
								StatusKey			INT				'$.StatusKey'
							 )
	
	--select @ItemTypeKey,@ItemKey
	IF(ISNULL(@ItemKey,0) = 0)
		BEGIN
			INSERT INTO		dbo.Item(ItemID, [Description],UnitCost,ItemTypeKey,PriceBasisKey,StatusKey,CreateDate,StatusDate, InvoiceItemDesc,EDICode,CostGrp,InternalCost,CategoryKey)	
			SELECT			@ItemID,@Description,@UnitCost,@ItemTypeKey,@PriceBasisKey,1,GETDATE(),GETDATE(), @InvoiceItemDesc, @EDIChargeCode,@Costgroup,@InternalCost,@CategoryKey
			SET				@ItemKey = SCOPE_IDENTITY()
			UPDATE Item SET MasterItemKey=@ItemKey WHERE ItemKey=@ItemKey AND ItemID=@ItemID
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
		END
	

		SET @Status = 1
		SET @Reason = 'Success'
END
