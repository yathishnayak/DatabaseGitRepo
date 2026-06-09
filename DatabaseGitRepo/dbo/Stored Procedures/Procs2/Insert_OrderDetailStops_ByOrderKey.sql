
CREATE PROCEDURE [dbo].[Insert_OrderDetailStops_ByOrderKey] -- Insert_OrderDetailStops_ByOrderKey 199198
(
	@OrderKey INT
)

AS

CREATE TABLE  #InsertedOrders (OrderStopKey INT);

SELECT		DISTINCT OH.OrderKey, OrderSource, OD1.ContainerNo, OrderNo, COUNT(*)  CNT
			, OD1.SourceAddrKey, OD1.DestinationAddrKey, ISNULL(ReturnAddrKey , RT1.DestinationAddrKey)ReturnAddrKey
INTO		#OrderDetail
FROM		OrderHeader OH WITH (NOLOCK)
INNER JOIN	(SELECT MIN(OrderDetailkey)OrderDetailkey, Orderkey FROM  OrderDetail WITH (NOLOCK) GROUP BY OrderKey) OD ON OH.OrderKey = OD.OrderKey
INNER JOIN	OrderDetail OD1 WITH (NOLOCK) ON OD.OrderDetailkey = OD1.OrderDetailKey
LEFT JOIn	(SELECT		MAX(Routekey)Routekey, OrderKey  FROM Routes  RT WITH (NOLOCK)
			INNER JOIN	Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey 
			WHERE		L.ToLocation = 'Port'
			GROUP BY	OrderKey) RT ON OH.OrderKey = RT.OrderKey 
LEFT JOIN	ROutes RT1 WITH (NOLOCK) ON RT.Routekey = RT1.RouteKey 
WHERE		OH.OrderKey = @OrderKey --AND  OS.OrderKey IS NULL 
GROUP BY	OH.OrderKey,  OrderSource, OD1.ContainerNo, OrderNo,  ReturnAddrKey,OD1.SourceAddrKey, OD1.DestinationAddrKey
			, ISNULL(ReturnAddrKey , RT1.DestinationAddrKey)
ORDER By	OH.OrderKey  DESC

DECLARE @CNT INT = 0, @OrderSource VARCHAR(20) = ''
SET @CNT = (SELECT COUNT(*) FROM OrderStops WITH (NOLOCK) WHERE OrderKey = @OrderKey)
SET @OrderSource = (SELECT OrderSource FROM OrderHeader WITH (NOLOCK) WHERE OrderKey = @OrderKey )

PRINT @CNT

IF(@CNT = 0)
BEGIN
	INSERT INTO OrderStops (OrderKey,StopTypeKey,StopName,StopAddrKey,StopNumber, LocationType,CreateDate,CreateUserKey,UpdateDate, UpdateUserKey) 
	OUTPUT INSERTED.OrderStopKey INTO #InsertedOrders
	SELECT		DISTINCT OD.OrderKey, 1,AddrName, SourceAddrKey,1,'Port',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.SourceAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL
	UNION ALL
	SELECT		DISTINCT OD.OrderKey, 3,AddrName, DestinationAddrKey,2,'Consignee',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.DestinationAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL
	UNION ALL
	SELECT		DISTINCT OD.OrderKey, 5,AddrName, ReturnAddrKey,3,'Port',GETDATE(),714,GETDATE(),714
	FROM		#OrderDetail OD
	INNER JOIN	Address AD WITH (NOLOCK) ON OD.ReturnAddrKey = AD.AddrKey
	LEFT JOIN	OrderStops OS WITH (NOLOCK) ON OD.OrderKey = OS.OrderKey
	WHERE		OD.OrderKey = @OrderKey AND OS.OrderKey IS NULL AND ISNULL(ReturnAddrKey,0) >0

	UPDATE OD	SET CSRKey = OS.CSRKey
	FROM		OrderHeader OS
	INNER JOIN	OrderDetail OD ON OS.OrderKey = OD.OrderKey
	WHERE		OS.OrderKey = @OrderKey AND ISNULL(OD.CSRKey,'') = ''


	IF(@OrderSource = 'Melrose')
	BEGIN
			INSERT INTO OrderDetailStops
						(OrderDetailKey, OrderStopKey, StopTypeKey, StopName, StopAddrKey,  LocationType, StopNumber)
			SELECT		OD.OrderDetailKey, OS.OrderStopKey,OS.StopTypeKey, OS.StopName,OS.StopAddrKey,OS.LocationType, Os.StopNumber
			FROM		OrderStops OS
			INNER JOIN	OrderDetail OD ON OS.OrderKey = OD.OrderKey
			WHERE		OS.OrderKey = @OrderKey
	END


	--INSERT INTO OrderDetailStops (OrderDetailKey, StopTypeKey,StopName,StopAddrKey,StopNumber, LocationType)
	--SELECT		OD.OrderDetailKey, OS.StopTypeKey,OS.StopName,OS.StopAddrKey,OS.StopNumber, OS.LocationType
	--FROM		OrderStops OS WITH (NOLOCK)
	--INNER JOIN	(SELECT MIN(OrderDetailkey)OrderDetailkey, Orderkey FROM  OrderDetail WITH (NOLOCK) GROUP BY OrderKey) 
	--			OD ON OS.OrderKey = OD.OrderKey
	--LEFT JOIN	OrderDetailStops ODS WITH (NOLOCK) ON OD.OrderDetailkey = ODS.OrderDetailKey 
	--WHERE		OS.OrderStopKey IN (SELECT OrderStopKey FROM #InsertedOrders ) AND ODS.OrderDetailKey IS NULL

	

END

/* ORDER DETAIL STOP INSERT PROCESS */
	
	declare @OrderDetailKey	int = 0,
			@RouteCount		int = 0,
			@OSCount		int = 0,
			@IsLegNoIssue	bit = 0,
			@SourceAddrKey	int = 0,
			@DestAddrKey	int = 0,
			@ReturnAddrKey	int = 0

	SET		@OrderDetailKey = (SELECT TOP 1 OrderDetailKey FROM OrderDetail WITH (NOLOCK)  WHERE OrderKey = @OrderKey)

	select @SourceAddrKey = OH.SourceAddrKey, @DestAddrKey = OH.DestinationAddrKey, @ReturnAddrKey = OH.ReturnAddrKey
	from orderdetail OD WITH (NOLOCK) 
	inner join ORderHeader OH WITH (NOLOCK) on OD.orderkey = OH.orderkey
	where OD.orderdetailkey = @OrderDetailKey

	SELECT @OSCount = OSCount  
	from OrderDetail OD WITH (NOLOCK) 
	LEft join (Select ORderDetailKey, count(1) OSCount from  OrderDetailStops WITH (NOLOCK)  group by ORderDetailKey) OS 
	on OD.ORderDetailKey = OS.ORderDetailKey
	where od.OrderDetailKey = @OrderDetailKey
	print '@OSCount'
	print @RouteCount
	select @RouteCount = count(1) from ROUTES WITH (NOLOCK)  where orderdetailkey = @OrderDetailKey

	if(isnull(@OSCount,0) = 0 AND isnull(@RouteCount,0) > 0)
	BEGIN
		Select @IsLegNoIssue = case when count(1)> 1 then 1 else 0 end from routes WITH (NOLOCK)  where LegNo = 1
		-- select @RouteCount as RouteCount, @OSCount as OSCount, @IsLegNoIssue as IsLegNoIssue;
		if(isnull(@IsLegNoIssue,0) = 1)
		Begin
			UPDATE RT SET LEGNO = new_legno
			from routes rt 
			inner join (
				select ROW_NUMBER() OVER(Order by Routekey) new_legno, routekey, legno 
				from Routes  WITH (NOLOCK) 
				where ORderDetailKey = @OrderDetailKey
			) a on RT.routekey = A.RouteKey
		End;
		
		update routes set 
			SourceAddrKey = @SourceAddrKey ,
			DestinationAddrKey = @DestAddrKey
		where OrderDetailKey = @OrderDetailKey and Legno = 1

		update routes set 
			SourceAddrKey = @DestAddrKey ,
			DestinationAddrKey = @ReturnAddrKey
		where OrderDetailKey = @OrderDetailKey and Legno = 2
		
		SELECT	DISTINCT	OD.OrderDetailKey,ISNULL( OSCount,0) OSCount,
			RT.ROUTEKEY,RT.LegNo, LCF.LocationConvert as FromLocation, LCT.LocationConvert as ToLocation, 
			RT.SourceAddrKey, RT.DestinationAddrKey, AF.AddrName as FromName, AT.AddrName as ToName, RT.IsManual
		INTO #TEMP
		FROM		ORderDetail OD WITH (NOLOCK)
		LEFT JOIN	 (Select ORderDetailKey, count(1) OSCount from  OrderDetailStops group by ORderDetailKey) OS 
					on OD.OrderDetailKey = OS.OrderDetailKey
		LEFT JOIN	ROUTES RT	WITH (NOLOCK) ON OD.OrderDetailKey = RT.OrderDetailKey 
		LEFT JOIN	ADDRESS AF	WITH (NOLOCK) ON RT.SourceAddrKey = AF.AddrKey
		LEFT JOIN	ADDRESS AT	WITH (NOLOCK) ON RT.DestinationAddrKey = AT.AddrKey
		LEFT JOIN	LEG L			WITH (NOLOCK) ON RT.LegKey = L.LegKey
		LEFT JOIN	LocationConversion	LCF WITH (NOLOCK) ON L.FromLocation = LCF.Location
		LEFT JOIN	LocationConversion	LCT	WITH (NOLOCK) ON L.ToLocation = LCT.Location
		where		isnull(OS.OSCount,0) = 0 and OD.OrderDetailKey = @OrderDetailKey

		--SELECT * FROM #TEMP

		insert into OrderdetailStops (OrderDetailKey,FromRouteKey,ToRouteKey, 
			StopTypeKey,StopName,StopAddrKey,StopNumber, LocationType)
		SELECT OrderDetailKey,routekey as fromroutekey,null as toRoutekey, 
			1 AS StopTypeKey, FROMNAME as StopName, SourceAddrKey as StopAddrKey,
			legno as StopNumber, FromLocation as LocationType
		FROM #TEMP WHERE LEGNO = 1 and isnull(IsManual,0) = 0
		UNION ALL
		SELECT OrderDetailKey,(select routekey from #Temp where legno = 2) as fromroutekey,Routekey as toRoutekey, 
			3 AS StopTypeKey,TONAME as StopName, DestinationAddrKey as StopAddrKey,
			legno + 1 as StopNumber, ToLocation as LocationType
		FROM #TEMP WHERE LEGNO = 1 and isnull(IsManual,0) = 0
		UNION ALL
		SELECT OrderDetailKey, null as fromroutekey,routekey as toRoutekey,
			5 AS StopTypeKey,TONAME as StopName, DestinationAddrKey as StopAddrKey,
			legno + 1 as StopNumber, ToLocation as LocationType
		FROM #TEMP WHERE LEGNO = 2 and isnull(IsManual,0) = 0
		
		if(@@ROWCOUNT > 0)
		Begin
		update RT set FromODStopKey = ODS.OrderDetailStopKey
		 --select Rt.routekey, ODS.FromRouteKey, ODS.OrderDetailStopKey
		 from Routes Rt
		 inner join OrderDetailStops ODS WITH (NOLOCK)  on RT.Orderdetailkey = ODS.Orderdetailkey and Rt.RouteKey = ODS.FromRouteKey
		 where RT.Orderdetailkey =@OrderDetailKey 

		 update RT set ToODStopKey = ODS.OrderDetailStopKey
		 --select Rt.routekey, ODS.ToRouteKey, ODS.OrderDetailStopKey
		 from Routes Rt
		 inner join OrderDetailStops ODS WITH (NOLOCK)  on RT.Orderdetailkey = ODS.Orderdetailkey and Rt.RouteKey = ODS.ToRoutekey
		 where RT.Orderdetailkey =@OrderDetailKey 
		End
		DROP TABLE #TEMP
	end

DROP TABLE #InsertedOrders
DROP TABLE #OrderDetail 

