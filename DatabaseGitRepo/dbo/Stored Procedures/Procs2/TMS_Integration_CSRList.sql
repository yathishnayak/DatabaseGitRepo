
CREATE proc [dbo].[TMS_Integration_CSRList]
as
select CsrKey, CsrName
from CSR with (nolock)
Order by CsrName
For JSON PATH
