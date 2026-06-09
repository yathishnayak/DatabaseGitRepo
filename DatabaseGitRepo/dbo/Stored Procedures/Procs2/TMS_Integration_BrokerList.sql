

CREATE proc [dbo].[TMS_Integration_BrokerList]
as
Select BrokerKey, BrokerName
from Broker with (nolock)
Order by BrokerName
For JSON PATH
