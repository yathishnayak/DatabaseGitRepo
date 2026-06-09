
CREATE view [dbo].[vOrderExpencesCount]
 
as
Select ORderDetailKey, Count_big(*) as ExpCount
FROM dbo.OrderExpense OE WITH (NOLOCK)
inner join Item I WITH (NOLOCK) on OE.ItemKey = I.ItemKey
where I.ItemTypeKey in (1,5)
Group by OE.OrderDetailKey
