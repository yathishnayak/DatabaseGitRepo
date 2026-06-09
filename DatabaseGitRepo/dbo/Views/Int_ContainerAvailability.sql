


CREATE View [dbo].[Int_ContainerAvailability]
as
select OD.OrderDetailKey, ContainerNo AS ContainerNumber, 
	GETDATE() as LastFreeDay
	--convert(Date,'2020-01-01') as LastFreeDay
from OrderDetail OD WITH (nolock)
--inner join Integration_TMS.dbo.Int_ContainerAvailability IA WITH (nolock) 
--on OD.ContainerNo = IA.ContainerNumber
