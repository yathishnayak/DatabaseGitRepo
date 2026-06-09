
CREATE View [dbo].[vContainerTypeByOrder]
as
Select * from (
select  OrderKey, STUFF(
	(Select distinct ',' + CT.TypeDescription
	From ContainerTypesLink CTL WITH (NOLOCK)
	inner join ContainerTypes CT WITH (NOLOCK) on CTL.ContainerTypeKey = Ct.ContainerTypeKey
	inner join Orderdetail OD  WITH (NOLOCK) on CTL.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey
	where A.ORderKey= OD.orderKey
	FOR XML PATH ('')), 1, 1,'')  Properties
from OrderHeader A WITH (NOLOCK)
) A where Properties is not null
--where A.orderkey = 37376
