
CREATE view [dbo].[ContainerDocumentCount]
 
as
select  OrderDetailKey, sum(DocumentCount) as DocumentCount from (
SELECT OrderDetailKey, COUNT(1) as DocumentCount 
from dbo.OrderDetailDocuments WITH (NOLOCK) 
group by OrderDetailKey
union All
SELECT OrderDetailKey, COUNT(1) as DocumentCount 
from dbo.schedulerDocument D WITH (NOLOCK) 
inner join dbo.Routes RT WITH (NOLOCK) on D.RouteKey = RT.RouteKey
group by OrderDetailKey
) A
group by OrderDetailKey
