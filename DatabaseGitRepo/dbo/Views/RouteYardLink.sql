



CREATE View [dbo].[RouteYardLink]
as
SELECT R.RouteKey, L.FromLocation, L.ToLocation, 
YS.YardId as SourceYardID, YD.YardId DestinationYardID,
R.LocationKey as YardLocationKey,
YL.Name as YardLocationName,
Effect = case when isnull(YS.YardId,0) > 0 then -1 when ISNULL(YD.YardId,0) > 0 then +1 else 0 end 
FROM dbo.routes R WITH (NOLOCK) 
left join leg L WITH (NOLOCK)  on R.LegKey = L.LegKey
LEft join dbo.Yard YD WITH (NOLOCK)  on YD.AddrKey = R.DestinationAddrKey
LEft join dbo.Yard YS WITH (NOLOCK)  on YS.AddrKey = R.SourceAddrKey
left join dbo.YardLocation YL WITH (NOLOCK)  on R.LocationKey = YL.LocationKey
