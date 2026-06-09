
CREATE PROCEDURE [dbo].[Get_ItemsByStatusKey_V2]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '[{"StatusKey": 3}]',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
--@StatusKey INT = 1
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE  @StatusKey INT;
	SELECT @StatusKey = StatusKey
	from OPENJSON(@JSONString, '$')
	with (
			StatusKey int '$.StatusKey'
		 )

	SELECT 	I.ItemKey,IT.ItemTypeKey,I.ItemID,I.Description AS ItemDescription,I.UnitCost , 
	IT.Description AS ItemType,I.CreateDate	,IPB.Description 'PriceBasisDescription',
	ST.StatusName, 
	I.InvoiceItemDesc
	FROM dbo.Item I 
		INNER JOIN dbo.ItemType IT WITH(NOLOCK) ON I.ItemTypeKey = IT.ItemTypeKey
		INNER JOIN dbo.[Status] ST  WITH(NOLOCK) ON ST.StatusKey = I.StatusKey
		INNER JOIN [dbo].[ItemPriceBasis] IPB WITH(NOLOCK) ON IPB.PriceBasisKey = I.PriceBasisKey 
	WHERE (@StatusKey = 0 OR ST.StatusKey=@StatusKey)
	

	FOR JSON PATH

		SET @Status = 1
		SET @Reason = 'Success'
END
