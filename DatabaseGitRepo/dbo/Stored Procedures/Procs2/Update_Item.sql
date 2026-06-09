CREATE PROCEDURE [dbo].[Update_Item]
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
@OutPut			BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

    UPDATE dbo.Item 
    SET 
		ItemID =@ItemID ,
		[Description] =@Description,
		ItemtypeKey =@ItemTypeKey ,
		UnitCost=@UnitCost,
		StatusKey = @StatusKey,
		StatusDate = getdate(),
		PriceBasisKey = @PriceBasisKey,
		InvoiceItemDesc = @InvoiceItemDesc,
		EDICode =@EDIChargeCode,
		CostGrp=@Costgroup,
		InternalCost=@InternalCost,
		CategoryKey = @CategoryKey
     WHERE Itemkey = @ItemKey;	 

	SET @OutPut=1
END