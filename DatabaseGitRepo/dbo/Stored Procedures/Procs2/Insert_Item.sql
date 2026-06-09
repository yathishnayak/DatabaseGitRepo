CREATE PROCEDURE [dbo].[Insert_Item]
/*
dbo.fn_insert_item
*/
@ItemID			VARCHAR(30),
@Description	VARCHAR(255),
@ItemTypeKey	SMALLINT,
@UnitCost		DECIMAL(18,2),
@PriceBasisKey	INT,
@InvoiceItemDesc varchar(100),
@EDIChargeCode	VARCHAR(3),
@Costgroup		INT,
@InternalCost	DECIMAL(18,2),
@CategoryKey    INT,
@ItemKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.Item(ItemID, [Description],UnitCost,ItemTypeKey,PriceBasisKey,StatusKey,CreateDate,StatusDate, InvoiceItemDesc,EDICode,CostGrp,InternalCost,CategoryKey)
	VALUES (@ItemID,@Description,@UnitCost, @ItemTypeKey,@PriceBasisKey,1,GETDATE(),Getdate(), @InvoiceItemDesc, @EDIChargeCode,@Costgroup,@InternalCost,@CategoryKey)
	
	SET @ItemKey= SCOPE_IDENTITY()
	UPDATE Item SET MasterItemKey=@ItemKey WHERE ItemKey=@ItemKey AND ItemID=@ItemID
END