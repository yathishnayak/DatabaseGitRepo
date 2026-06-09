CREATE PRocedure [dbo].[GET_ExpenseItemList] 
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT I.ItemKey,IT.ItemTypeKey,I.[Description] AS ItemDescription,I.ItemID,I.UnitCost, I.PriceBasisKey,  I.InvoiceItemDesc, P.PriceBasisID
	FROM dbo.Item I 
		INNER JOIN dbo.ItemType IT ON IT.ItemTypeKey=I.ItemTypeKey
		INNER JOIN [Status]  S ON S.StatusKey=I.StatusKey
		INNER JOIN ItemPriceBasis P ON I.PriceBasisKey = P.PriceBasisKey
	WHERE S.StatusName='Active' AND IT.ItemType in ( 'Expense', 'Expense + Service')
	ORDER BY I.DESCRIPTION
END
