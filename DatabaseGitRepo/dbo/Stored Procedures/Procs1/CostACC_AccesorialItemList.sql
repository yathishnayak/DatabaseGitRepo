
create proc [dbo].[CostACC_AccesorialItemList]
as
Begin
	set nocount on
	set fmtonly off

	select distinct LineItem 
	from COSTACC_FinalDataOutput A
	inner join Item I on A.LineItem = I.Description
	Order by LineItem
End
