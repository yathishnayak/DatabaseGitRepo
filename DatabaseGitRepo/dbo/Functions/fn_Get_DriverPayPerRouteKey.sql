	create function fn_Get_DriverPayPerRouteKey(
		@RouteKey	int = 0,
		@ItemKey	int = 0
	)
	RETURNS DECIMAL(18,2)
	AS
	BEGIN
		DECLARE @rtnVal decimal(18,2) = 0
		select top 1 @rtnVal =  LI.UnitCost
		from Routes R
		inner join Address A on R.DestinationAddrKey = A.AddrKey
		left join DriverLocationItem LI on A.CityKey = LI.CityKey
		where routekey = @RouteKey and itemkey = @ItemKey and EffectiveDate<= getdate()
		order by EffectiveDate desc

		if(@rtnVal = 0)
		begin
			select top 1 @rtnVal = UnitCost from Item where ItemKey = @ItemKey
		end

		RETURN @RTNVAL
	END
