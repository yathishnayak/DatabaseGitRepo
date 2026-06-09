
CREATE proc [dbo].[TMS_Integration_CarrierList]
as
select CarrierKey, CarrierName, ScacCode
from Carrier with (nolock)
Order by CarrierName
For JSON PATH
