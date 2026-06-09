CREATE Procedure [dbo].[Get_TerminalLocation]
as
select  MarketLocationKey as TerminalLocationKey, MarketLocation as TerminalLocation 
from MarketLocation order by MarketLocation
