


CREATE VIEW [dbo].[vContainerTypeByOrderKey]
as
select distinct OrderDetailKey, STUFF(
	(Select distinct ',' + CT.TypeDescription
	From ContainerTypesLink CTL WITH (NOLOCK)
	inner join ContainerTypes CT WITH (NOLOCK) on CTL.ContainerTypeKey = Ct.ContainerTypeKey
	where A.OrderDetailKey= CTL.OrderDetailKey
	FOR XML PATH ('')), 1, 1,'')  Comment
from ContainerTypesLink A WITH (NOLOCK) 
inner join ContainerTypes B  WITH (NOLOCK) on A.ContainerTypeKey = B.ContainerTypeKey
