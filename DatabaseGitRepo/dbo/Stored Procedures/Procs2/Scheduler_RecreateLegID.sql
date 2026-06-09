
  
CREATE PROC [dbo].[Scheduler_RecreateLegID]  --[Scheduler_RecreateLegID]  230206
(  
 @OrderDetailKey int  
)  
As   
Begin  
 set nocount on  
 set fmtonly off 
 print @OrderDetailKey
 if(@OrderDetailKey > 0)  
 Begin  
  update RT set Legkey = LN.legkey  
  --select  Rt.routekey, RT.Createdate, Rt.orderdetailkey,   
  -- L.legID, L.FromLocation, L.ToLocation, ODSF.LocationType, ODST.LocationType,  
  -- LC.LocationConvert, LLF.LocationConvert,  
  -- LT.LocationConvert, LLT.LocationConvert, LN.LegID, ln.legkey  
  from  Routes RT  
  inner join orderDetailStops ODSF WITH (NOLOCK) on RT.OrderDetailKey = ODSF.OrderDetailKey and  RT.RouteKey = ODSF.FromRouteKey  
  inner join ORderDetailStops ODST WITH (NOLOCK) on   RT.OrderDetailKey = ODST.OrderDetailKey and Rt.RouteKey = ODsT.toroutekey   
  inner join Leg L WITH (NOLOCK) on RT.legkey = L.legkey  
  inner join LocationConversion LC WITH (NOLOCK) on  ODSF.LocationType = LC.location  
  inner join LocationConversion LLF WITH (NOLOCK) on  L.FromLocation = LLF.location  
  inner join LocationConversion LT WITH (NOLOCK) on  ODSt.LocationType = LT.location  
  inner join LocationConversion LLT WITH (NOLOCK) on  L.ToLocation = LLT.location  
  inner join Legfiltered LN WITH (NOLOCK) on LC.LocationConvert = LN.FromLocation and LT.LocationConvert = LN.ToLocation  
  where (Lc.LocationConvert <> LLF.LocationConvert OR LT.LocationConvert <> LLT.LocationConvert)  
  and Rt.OrderDetailKey = @OrderDetailKey  
 End  
END