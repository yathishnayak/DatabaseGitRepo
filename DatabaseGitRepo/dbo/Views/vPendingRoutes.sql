
CREATE view vPendingRoutes
as
select status,PickupDateFrom, DeliveryDateFrom, LF.LocationConvert FromLocation, LT.LocationConvert ToLocation, 
TYPE=CASE WHEN LF.LocationConvert = 'PORT' AND RT.PickupDateFrom IS NOT NULL AND RT.ActualDeparture IS NULL THEN 'FROM' 
	WHEN LT.LocationConvert in ('Consignee','PORT') AND RT.DeliveryDateFrom IS NOT NULL AND RT.ActualArrival IS NULL then 'TO' 
	ELSE 'NA' end ,
RT.ActualDeparture,RT.ActualArrival,
case when RT.ActualDeparture IS NULL then cast(PickupDateFrom as Date) else cast(DeliveryDateFrom as Date) end as EffectiveDate,
case when RT.ActualDeparture IS NULL then cast(PickupDateFrom as time) else cast(DeliveryDateFrom as time) end as Effectivetime
from Routes RT WITH (NOLOCK) 
inner join LEG L WITH (NOLOCK)  on RT.legkey = L.LegKey
inner join LocationConversion LF WITH (NOLOCK) on L.FromLocation = LF.Location
inner join LocationConversion LT WITH (NOLOCK) on L.ToLocation = LT.Location
where RT.Status in (1,2,4) and 
	((LF.LocationConvert = 'PORT' AND RT.PickupDateFrom IS NOT NULL AND RT.ActualDeparture IS NULL) OR 
	(LT.LocationConvert in ('Consignee','PORT') AND RT.DeliveryDateFrom IS NOT NULL AND RT.ActualArrival IS NULL))
