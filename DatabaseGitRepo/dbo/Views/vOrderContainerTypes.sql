CREATE View [dbo].[vOrderContainerTypes]
with schemabinding
as
select distinct OD.OrderDetailKey, C.CommentKey, C.Description, OD.ContainerNo 
from dbo.Orderdetail OD WITH (NOLOCK)
inner join dbo.OrderDetailComments ODC WITH (NOLOCK) on OD.OrderDetailKey = ODC.OrderDetailKey
inner join dbo.Comment C WITH (NOLOCK) on ODC.CommentKey = C.CommentKey 
inner join dbo.ContainerTypes CT WITH (NOLOCK) on C.Description  like  CT.TypeDescription + '%'
