CREATE PRocedure [dbo].[GET_ServiceItemList] 
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT I.ItemKey,IT.ItemTypeKey,I.[Description] AS ItemDescription,I.ItemID,I.UnitCost, 
	I.PriceBasisKey, I.InvoiceItemDesc, P.PriceBasisID,IC.Name As CategoryName,
	M.Description as MDescription, IT.ItemType
	FROM dbo.Item I WITH (NOLOCK)
		INNER JOIN dbo.ItemType IT WITH (NOLOCK) ON IT.ItemTypeKey=I.ItemTypeKey
		INNER JOIN [Status]  S WITH (NOLOCK) ON S.StatusKey=I.StatusKey
		LEFT JOIN ItemPriceBasis P WITH (NOLOCK) ON I.PriceBasisKey = P.PriceBasisKey
		INNER JOIN Item M WITH (NOLOCK) ON M.ItemKey=I.MasterItemKey
		INNER JOIN ItemCateGory IC WITH (NOLOCK) ON IC.CategoryKey=I.CategoryKey
	WHERE S.StatusName='Active' AND IT.ItemType in ('Service','Expense + Service')
	--GROUP BY I.ItemKey,IT.ItemTypeKey,I.[Description],I.ItemID,I.UnitCost, I.PriceBasisKey, I.InvoiceItemDesc,  P.PriceBasisID
	ORDER BY I.[Description]
END
