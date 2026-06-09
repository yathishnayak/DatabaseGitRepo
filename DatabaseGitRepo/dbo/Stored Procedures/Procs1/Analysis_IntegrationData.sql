
/*
DECLARE @UserKey			int,
	@JsonString			nvarchar(max) = '{"FromDate":"2025-04-01","ToDate":"2025-04-30"}',
	@JsonOutput			nvarchar(max) ='' ,
	@Status				bit = 0 ,
	@Reason				varchar(500) = '' ,
	@IsDebug			bit = 0 
	exec Analysis_IntegrationData @Userkey,@JsonString,@Jsonoutput output,@Status output,@Reason output,@Isdebug 
	*/
CREATE Proc [dbo].[Analysis_IntegrationData] -- EXEC Analysis_IntegrationData '2025-04-01','2025-04-30'
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT,
	@IsDebug			bit = 0
	--@FromDate		date = '2020-04-01',
	--@ToDate			date = '2050-12-31'
)
as
Begin
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid JSON input';
        RETURN;
    END

	DECLARE @FromDate DATE, @ToDate DATE
	Select @FromDate = FromDate, @ToDate = ToDate
	from OpenJSON(@JsonString, '$')
	WITH (
			FromDate		DATE	'$.FromDate',
			ToDate			DATE	'$.ToDate'
		)

	if(@FromDate = convert(Date, '2020-04-01'))
	Begin
		set @FromDate = convert(date, str(year(getdate())) + '-' + str(month(getdate())) + '-01')
	End
	if(@ToDate = convert(Date, '2050-12-31'))
	Begin
		set @ToDate = convert(date, Getdate() + 1)
	End
	else 
	Begin
		SET @ToDate = Convert(Date, DATEADD(DD,1,@ToDate))
	End

	select RT.OrderDetailKey, ContainerNo,Rt.Routekey, L.LegID, L.FromLocation, RT.ActualArrival, RT.ActualDeparture,
		L.ToLocation,AL.DateSource,AL.ActualArrival as DS_ActualArrival, AL.ActualDeparture as DS_ActualDeparture,
		YF.YardId as YardIDFrom, YT.YardId as YardIDTo,YF.ShortName as YardNameFrom,YT.ShortName as YardNameTo,
		RT.SourceAddrKey , RT.DestinationAddrKey
	into #TempData
	from routes RT with (nolock)
	inner join orderdetail OD with (nolock) on rt.OrderDetailKey = OD.OrderDetailKey
	Left join Routes_ActualLog AL WITH (NOLOCK) on RT.routekey = AL.RouteKey
	Left join LEg L WITH (NOLOCK) on Rt.LEgKey = L.legKey
	LEft join Yard YF WITH (NOLOCK) on RT.SourceAddrKey = YF.AddrKey
	LEft join Yard YT WITH (NOLOCK) on RT.DestinationAddrKey = YT.AddrKey
	where RT.CreateDate between convert(date,@FromDate) and Convert(Date, @ToDate) 
		and (Rt.ActualArrival is not null OR Rt.ActualDeparture is not null)

	declare @TotalRECS		decimal(18,2) = 0,
			@FromPort		decimal(18,2)	= 0,
			@ToConsignee	decimal(18,2)	= 0,
			@ToPort			decimal(18,2) = 0,
			@FromYardAll	decimal(18,2) = 0,
			@ToYardAll		decimal(18,2) = 0,
			@FromYard		decimal(18,2) = 0,
			@ToYard			decimal(18,2) = 0,

			@GnosisArrival				decimal(18,2) = 0,
			@GnosisDeparture			decimal(18,2) = 0,
			@SafegateCheckin			decimal(18,2) = 0,
			@SafegateCheckout			decimal(18,2) = 0,
			@GnosisArrivalOverride		decimal(18,2) = 0,
			@GnosisDepartureOverride	decimal(18,2) = 0,
			@SafegateCheckinOverride	decimal(18,2) = 0,
			@SafegateCheckoutOVerride	decimal(18,2) = 0

	Select @TotalRECS = count(1) from #TempData
	SElect @FromPort = Count(1) from #TempData where FromLocation = 'Port' and ActualDeparture is not null
	SElect @ToConsignee = Count(1) from #TempData where ToLocation in ('Consignee','Customer','Shipper') and ActualArrival is not null
	SElect @ToPort = Count(1) from #TempData where ToLocation in ('Port') and ActualArrival is not null
	SElect @FromYardAll = Count(1) from #TempData where FromLocation in ('Yard','Warehouse','Depot')   and ActualDeparture is not null 
	SElect @ToYardAll = Count(1) from #TempData where ToLocation in ('Yard','Warehouse','Depot') and ActualArrival is not null
	SElect @FromYard = Count(1) from #TempData where FromLocation in ('Yard','Warehouse','Depot')   and ActualDeparture is not null 
		and Yardidfrom in (select TMSYardID from SafegateIntegration_SafegateTMSYardNameMapping)
	SElect @ToYard = Count(1) from #TempData where ToLocation in ('Yard','Warehouse','Depot') and ActualArrival is not null
		and YardIDTo in (select TMSYardID from SafegateIntegration_SafegateTMSYardNameMapping)

	--select * from SafegateIntegration_SafegateTMSYardNameMapping
	Select @GnosisArrival = count(1) from #TempData 
		where DS_ActualArrival is not null and DateSource = 'Gnosis' and ActualArrival is not null
	Select @GnosisDeparture = count(1) from #TempData 
		where DS_ActualDeparture is not null and DateSource = 'Gnosis' and ActualDeparture is not null
	Select @SafegateCheckin = count(1) from #TempData 
		where DS_ActualArrival is not null and DateSource = 'SafeGate' and ActualArrival is not null
	Select @SafegateCheckout = count(1) from #TempData 
		where DS_ActualDeparture is not null and DateSource = 'SafeGate' and ActualDeparture is not null

	Select @GnosisArrivalOverride = count(1) from #TempData 
		where DS_ActualArrival is not null and DateSource = 'Gnosis' and ActualArrival <> DS_ActualArrival  
			and ActualArrival is not null 
	Select @GnosisDepartureOverride = count(1) from #TempData 
		where DS_ActualDeparture is not null and DateSource = 'Gnosis' and ActualDeparture <> DS_ActualDeparture 
			and ActualDeparture is not null 
	Select @SafegateCheckinOverride = count(1) from #TempData 
		where DS_ActualArrival is not null and DateSource = 'SafeGate' and ActualArrival <> DS_ActualArrival  
			and ActualArrival is not null 
	Select @SafegateCheckoutOVerride = count(1) from #TempData 
		where DS_ActualDeparture is not null and DateSource = 'SafeGate' and ActualDeparture <> DS_ActualDeparture 
			and ActualDeparture is not null  
	Select Params = JSON_QUERY((SElect @FromDate as FromDate, DateAdd(DD,-1,@ToDate) as ToDate FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)),
	Summary = 
	JSON_QUERY((select convert(int,@TotalRECS) as TotalRecs,
		convert(int,@FromPort) as FromPort,
		convert(int,@ToConsignee) as ToConsignee,
		convert(int,@ToPort)	as ToPort,
		convert(int,@FromYardAll) as FromYardAll,
		convert(int,@ToYardAll) as ToYardAll,
		convert(int,@FromYard) as FromJCTYard,
		convert(int,@ToYard) as ToJCTYard,
		convert(int,@GnosisArrival) as GnosisArrival,
		convert(int,@GnosisDeparture) as GnosisDeparture,
		convert(int,@SafegateCheckin) as SafegateCheckin,
		convert(int,@SafegateCheckout) as SafegateCheckout,
		convert(int,@GnosisArrivalOverride) as GnosisArrivalOverride,
		convert(int,@GnosisDepartureOverride) as GnosisDepartureOverride,
		convert(int,@SafegateCheckinOverride) as SafegateCheckinOverride,
		convert(int,@SafegateCheckoutOVerride) as SafegateCheckoutOverride,

		case when isnull(@ToPort,0.00) > 0 and isnull(@GnosisArrival,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@GnosisArrival,0.00) / isnull(@ToPort,0.00))*100) 
		else 0 end as GnosisArrivalPercent,

		Case when isnull(@GnosisDeparture,0.00) >0 and isnull(@FromPort,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@GnosisDeparture,0.00) / isnull(@FromPort,0.00))*100)
		else 0 end as GnosisDeparturePercent,

		case when isnull(@SafegateCheckout,0.00) > 0 and isnull(@ToYard,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@SafegateCheckout,0.00) / isnull(@ToYard,0.00))*100) 
		else 0 end as SafegateArrivalPercent,

		Case when isnull(@SafegateCheckin,0.00) > 0 and isnull(@FromYard,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@SafegateCheckin,0.00) / isnull(@FromYard,0.00))*100) 
		else 0 end as SafegateDeparturePercent,

		case when isnull(@GnosisArrivalOverride,0.00) > 0 and isnull(@GnosisArrival,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@GnosisArrivalOverride,0.00) / isnull(@GnosisArrival,0.00))*100)
		else 0 end as GnosisArrivalOverridePercent,

		Case when isnull(@GnosisDepartureOverride,0.00) > 0 and isnull(@GnosisDeparture,0.00) > 0 Then
		convert(Decimal(18,2),(isnull(@GnosisDepartureOverride,0.00) / isnull(@GnosisDeparture,0.00))*100) 
		else 0 end as GnosisDepartureOverridePercent,

		case when isnull(@SafegateCheckoutOVerride,0.00) > 0 and  isnull(@SafegateCheckout,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@SafegateCheckoutOVerride,0.00) / isnull(@SafegateCheckout,0.00))*100)
		else 0 end as SafegateArrivalOverridePercent,

		Case when isnull(@SafegateCheckinOverride,0.00) > 0 and  isnull(@SafegateCheckin,0.00) > 0 then
		convert(Decimal(18,2),(isnull(@SafegateCheckinOverride,0.00) / isnull(@SafegateCheckin,0.00))*100)
		else 0 end as SafegateDepartureOverridePercent

		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	)),
	DetailData = (
		select * from #TempData order by OrderDetailKey, RouteKey FOR JSON PATH
	) FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
	SET @Reason='Success';
	SET @Status =1
	--select * from #TempData

	--  select convert(int,@TotalRECS) as TotalRecs,
	--	convert(int,@FromPort) as FromPort,
	--	convert(int,@ToConsignee) as ToConsignee,
	--	convert(int,@ToPort)	as ToPort,
	--	convert(int,@FromYardAll) as FromYardAll,
	--	convert(int,@ToYardAll) as ToYardAll,
	--	convert(int,@FromYard) as FromJCTYard,
	--	convert(int,@ToYard) as ToJCTYard,
	--	convert(int,@GnosisArrival) as GnosisArrival,
	--	convert(int,@GnosisDeparture) as GnosisDeparture,
	--	convert(int,@SafegateCheckin) as SafegateCheckin,
	--	convert(int,@SafegateCheckout) as SafegateCheckout,
	--	convert(int,@GnosisArrivalOverride) as GnosisArrivalOverride,
	--	convert(int,@GnosisDepartureOverride) as GnosisDepartureOverride,
	--	convert(int,@SafegateCheckinOverride) as SafegateCheckinOverride,
	--	convert(int,@SafegateCheckoutOVerride) as SafegateCheckoutOverride,

	--	case when isnull(@ToPort,0.00) > 0 and isnull(@GnosisArrival,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@GnosisArrival,0.00) / isnull(@ToPort,0.00))*100) 
	--	else 0 end as GnosisArrivalPercent,

	--	Case when isnull(@GnosisDeparture,0.00) >0 and isnull(@FromPort,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@GnosisDeparture,0.00) / isnull(@FromPort,0.00))*100)
	--	else 0 end as GnosisDeparturePercent,

	--	case when isnull(@SafegateCheckout,0.00) > 0 and isnull(@ToYard,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@SafegateCheckout,0.00) / isnull(@ToYard,0.00))*100) 
	--	else 0 end as SafegateArrivalPercent,

	--	Case when isnull(@SafegateCheckin,0.00) > 0 and isnull(@FromYard,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@SafegateCheckin,0.00) / isnull(@FromYard,0.00))*100) 
	--	else 0 end as SafegateDeparturePercent,

	--	case when isnull(@GnosisArrivalOverride,0.00) > 0 and isnull(@GnosisArrival,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@GnosisArrivalOverride,0.00) / isnull(@GnosisArrival,0.00))*100)
	--	else 0 end as GnosisArrivalOverridePercent,

	--	Case when isnull(@GnosisDepartureOverride,0.00) > 0 and isnull(@GnosisDeparture,0.00) > 0 Then
	--	convert(Decimal(18,2),(isnull(@GnosisDepartureOverride,0.00) / isnull(@GnosisDeparture,0.00))*100) 
	--	else 0 end as GnosisDepartureOverridePercent,

	--	case when isnull(@SafegateCheckoutOVerride,0.00) > 0 and  isnull(@SafegateCheckout,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@SafegateCheckoutOVerride,0.00) / isnull(@SafegateCheckout,0.00))*100)
	--	else 0 end as SafegateArrivalOverridePercent,

	--	Case when isnull(@SafegateCheckinOverride,0.00) > 0 and  isnull(@SafegateCheckin,0.00) > 0 then
	--	convert(Decimal(18,2),(isnull(@SafegateCheckinOverride,0.00) / isnull(@SafegateCheckin,0.00))*100)
	--	else 0 end as SafegateDepartureOverridePercent

	--drop table #TempData
	/*
	select YardIDFrom, count(1) from #TempData group by YardIDFrom
	select YardIDto, count(1) from #TempData group by YardIDto

	select * from #TempData where YardIDFrom = 21 or yardidto = 21
	select * from SafegateIntegration_SafegateTMSYardNameMapping 
	select * from SafeGateIntegration_ActualDepartureDateUpdate

	select * from #TempData where SourceAddrKey = 44906 or DestinationAddrKey = 44906
	select * from #TempData where SourceAddrKey = 47280 or DestinationAddrKey = 47280
*/
END