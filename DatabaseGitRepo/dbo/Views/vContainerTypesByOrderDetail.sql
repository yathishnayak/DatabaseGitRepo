create View [dbo].[vContainerTypesByOrderDetail]
as
select OrderDetailKey, ContainerTypeKey, TypeID, TypeDescription, OCT.ContainerNo
from vOrderContainerTypes OCT
inner join ContainerTypes CT on OCT.Description like '%' + CT.TypeID + '%'
