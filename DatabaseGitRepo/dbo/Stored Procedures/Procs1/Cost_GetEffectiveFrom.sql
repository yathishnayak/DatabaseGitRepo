
create proc [dbo].[Cost_GetEffectiveFrom]
as
Select EffectiveKey, EffectiveFrom
from Cost_EffectiveFrom
order by EffectiveFrom
