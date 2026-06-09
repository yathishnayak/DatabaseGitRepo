CREATE PROCEDURE [dbo].[Update_Item_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"ItemKey":358,"ItemID":"BYE","Description":"","ItemTypeKe":"","StatusKe":"","PriceBasisK":"","UnitCos":"","InvoiceItemDe":"","EDIChargeCo":"","Costgrou":"","InternalCo":"","CategoryKe":"","OutPut":""}]',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE
	@ItemKey		INT,
	@ItemID			VARCHAR(30),
	@Description	VARCHAR(255),
	@ItemTypeKey	SMALLINT,
	@StatusKey		INT,
	@PriceBasisKey  INT,
	@UnitCost		DECIMAL(18,2),
	@InvoiceItemDesc varchar(100),
	@EDIChargeCode	VARCHAR(3),
	@Costgroup		INT,
	@InternalCost	DECIMAL(18,2),
	@CategoryKey    INT,
	@OutPut			BIT

	SELECT @ItemKey = ItemKey, @ItemID = ItemID, @Description = Description, @ItemTypeKey = ItemTypeKey, @StatusKey = StatusKey, @PriceBasisKey = PriceBasisKey, @UnitCost = UnitCost,
	@InvoiceItemDesc = InvoiceItemDesc, @EDIChargeCode = EDIChargeCode, @Costgroup = Costgroup, @InternalCost = InternalCost, @CategoryKey = CategoryKey, @OutPut = OutPut

	FROM OPENJSON(@JSONString, '$')
	WITH (
	ItemKey					INT					 '$.ItemKey',
	ItemID					VARCHAR(30)			 '$.ItemID',
	Description				VARCHAR(255)		 '$.Description',
	ItemTypeKey				SMALLINT			 '$.ItemTypeKey',
	StatusKey				INT					 '$.StatusKey',
	PriceBasisKey			INT					 '$.PriceBasisKey',
	UnitCost				DECIMAL(18,2)		 '$.UnitCost',
	InvoiceItemDesc			VARCHAR(100)		 '$.InvoiceItemDesc',
	EDIChargeCode			VARCHAR(3)			 '$.EDIChargeCode',
	Costgroup				INT					 '$.Costgroup',
	InternalCost			DECIMAL(18,2)		 '$.InternalCost',
	CategoryKey				INT					 '$.CategoryKey',
	OutPut					BIT					 '$.OutPut'
	)

    UPDATE dbo.Item 
    SET 
		ItemID					= @ItemID ,
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
     WHERE Itemkey = @ItemKey;	 

	SET @OutPut=1
END
