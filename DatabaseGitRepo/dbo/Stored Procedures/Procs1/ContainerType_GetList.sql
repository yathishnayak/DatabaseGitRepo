

create proc [dbo].[ContainerType_GetList]
as
Begin
	select ContainerTypeKey, TypeID, TypeDescription, LinkedItemKey, 
		isActive, CreatedDate, UpdatedDate, ItemKey, ContainerTypes 
	from ContainerTypes
	order by TypeDescription
End
