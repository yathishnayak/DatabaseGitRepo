

CREATE view [dbo].[vGnosis_Container_HoldStatus]
as
select C.datakey, H.CTF, H.Line, H.Other, H.TMF, HoldStatus =
Case when CTF = 'true' OR TMF = 'true' OR Line = 'true' OR Other = 'true' OR Customs = 'true' then 'Yes' else 'No' end,
HoldTypes = Case when CTF = 'true' then 'CTF:' else '' end 
			+ case when TMF = 'true' then 'TMF:' else '' end 
			+ case when LINE = 'true' then 'LINE:' else '' end
			+ case when OTHER = 'true' then 'OTHER:' else '' end
			+ case when Customs = 'true' then 'CUSTOMS:' else '' end,
C.Updated_dt 
from Gnosis_Integration_Container C  WITH (NOLOCK)
LEft join Gnosis_Integration_Holds H  WITH (NOLOCK) on C.DataKey = H.DataKey
