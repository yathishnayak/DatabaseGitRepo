

CREATE Proc [dbo].[ReBuild_Route_DateTracker]
as
Begin
	select * into #temp from Routes_DateTracker where 1=0

	insert into #temp
	select RT.RouteKey, 'SP' as DateType, isnull(PickupDateTo, PickupDateFrom), Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'SP' 
	where RTD.RouteKey is null and RT.PickupDateFrom is not null

	insert into #Temp
	select RT.RouteKey, 'SD' as DateType, isnull(DeliveryDateTo, DeliveryDateFrom), Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'SD'
	where RTD.RouteKey is null and RT.DeliveryDateFrom is not null

	insert into #Temp
	select RT.RouteKey, 'AP' as DateType, ActualDeparture, Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'AP'
	where RTD.RouteKey is null and RT.ActualDeparture is not null

	insert into #Temp
	select RT.RouteKey, 'AD' as DateType, ActualArrival, Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'AD'
	where RTD.RouteKey is null and RT.ActualArrival is not null

	insert into Routes_DateTracker
	select *
	from #temp 

	drop table #Temp

	update RTD set DateTime = RT.PickupDateFrom
	from Routes_DateTracker RTD
	inner join Routes RT on RTD.RouteKey = Rt.RouteKey 
	where RTD.DateType = 'SP' and  isnull(PickupDateTo, PickupDateFrom) <> RTD.DateTime

	update RTD set DateTime = RT.DeliveryDateFrom
	from Routes_DateTracker RTD
	inner join Routes RT on RTD.RouteKey = Rt.RouteKey 
	where RTD.DateType = 'SD' and isnull(DeliveryDateTo, DeliveryDateFrom) <> RTD.DateTime

	update RTD set DateTime = RT.ActualDeparture
	from Routes_DateTracker RTD
	inner join Routes RT on RTD.RouteKey = Rt.RouteKey 
	where RTD.DateType = 'AP' and RT.ActualDeparture <> RTD.DateTime

	update RTD set DateTime = RT.ActualArrival
	from Routes_DateTracker RTD
	inner join Routes RT on RTD.RouteKey = Rt.RouteKey 
	where RTD.DateType = 'AD' and RT.ActualArrival <> RTD.DateTime


	insert into Routes_DateTracker
	select RT.RouteKey, 'SP' as DateType,  isnull(PickupDateTo, PickupDateFrom), Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'SP'
	where RTD.RouteKey is null and isnull(PickupDateTo, PickupDateFrom) is not null

	insert into Routes_DateTracker
	select RT.RouteKey, 'SD' as DateType,  isnull(DeliveryDateTo, DeliveryDateFrom), Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'SD'
	where RTD.RouteKey is null and  isnull(DeliveryDateTo, DeliveryDateFrom) is not null


	insert into Routes_DateTracker
	select RT.RouteKey, 'AP' as DateType, ActualDeparture, Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'AP'
	where RTD.RouteKey is null and RT.ActualDeparture is not null

	insert into Routes_DateTracker
	select RT.RouteKey, 'AD' as DateType, ActualArrival, Rt.CreateDate, 
	isnull(RT.UpdateUserKey, RT.CreateUserKey) as CreateUser
	from Routes RT
	LEft join Routes_DateTracker RTD on RT.RouteKey = RTD.RouteKey and RTD.DateType = 'AD'
	where RTD.RouteKey is null and RT.ActualArrival is not null

	EXEC [TMS_INTEGRATION_UPDATE_TKT_ROUTESDATANEW]

END
