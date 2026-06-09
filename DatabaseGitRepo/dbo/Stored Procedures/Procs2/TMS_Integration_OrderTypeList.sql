
create Proc [dbo].[TMS_Integration_OrderTypeList]
as
Select OrderTypeKey, OrderType
from OrderType with (nolock)
order by OrderType
For JSON PATH